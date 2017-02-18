DROP VIEW IF EXISTS  vg_xxx_location_product_sale_date cascade;
DROP VIEW IF EXISTS  vg_xxx_location_product_last_sale_date cascade;
DROP VIEW IF EXISTS  vg_xxx_stock_location_product_serial_make_model cascade;
DROP VIEW IF EXISTS  vg_stock_location_make_model_hdd_grade_color_ageing cascade;
DROP VIEW IF EXISTS  vg_stock_location_make_model_hdd_ageing cascade;


CREATE OR REPLACE VIEW vg_xxx_location_product_sale_date AS 
 SELECT i.id,
    i.origin,
    i.product_uom,
    i.company_id,
    i.date,
    i.product_qty,
    i.location_id,
    i.picking_type_id,
    i.state,
    i.restrict_lot_id,
    i.product_id,
    i.picking_id,
    i.location_dest_id,
    i.invoice_state,
    i.invoice_line_id,
    l.complete_name AS wh_location,
    m.code,
    m.name AS picking_type,
    a.name_template AS product_name
   FROM stock_move i
     JOIN stock_location l ON i.location_id = l.id
     JOIN stock_picking_type m ON i.picking_type_id = m.id
     JOIN product_product a ON i.product_id = a.id
  WHERE i.state::text <> 'cancel'::text AND i.invoice_state::text = 'invoiced'::text AND i.invoice_line_id IS NOT NULL AND m.name::text = 'Delivery Orders'::text;

ALTER TABLE vg_xxx_location_product_sale_date
  OWNER TO odoo;

  
CREATE OR REPLACE VIEW vg_xxx_location_product_last_sale_date AS 
 SELECT vg_xxx_location_product_sale_date.wh_location,
    vg_xxx_location_product_sale_date.product_name,
    max(vg_xxx_location_product_sale_date.date) AS last_sale_date
   FROM vg_xxx_location_product_sale_date
  GROUP BY vg_xxx_location_product_sale_date.wh_location, vg_xxx_location_product_sale_date.product_name;

ALTER TABLE vg_xxx_location_product_last_sale_date
  OWNER TO odoo;

CREATE OR REPLACE VIEW vg_xxx_stock_location_product_serial_make_model AS 
 SELECT vg_stock_by_location_product_serial.wh_location,
    vg_stock_by_location_product_serial.product_name,
    split_part(vg_stock_by_location_product_serial.product_name::text, '-'::text, 1) AS make,
    split_part(vg_stock_by_location_product_serial.product_name::text, '-'::text, 2) AS model,
    split_part(vg_stock_by_location_product_serial.product_name::text, '-'::text, 3) AS hdd,
    split_part(vg_stock_by_location_product_serial.product_name::text, '-'::text, 4) AS grade,
    upper(split_part(vg_stock_by_location_product_serial.product_name::text, '-'::text, 6)) AS color,
    vg_stock_by_location_product_serial.gtr_no,
    vg_stock_by_location_product_serial.stock_start_date,
    vg_xxx_location_product_last_sale_date.last_sale_date,
    vg_stock_by_location_product_serial.list_price,
    vg_stock_by_location_product_serial.stock_qty,
        CASE
            WHEN vg_stock_by_location_product_serial.stock_start_date IS NOT NULL THEN date_part('day'::text, age(now(), vg_stock_by_location_product_serial.stock_start_date::timestamp with time zone))
            ELSE 60::double precision
        END AS age
   FROM vg_stock_by_location_product_serial
     LEFT JOIN vg_xxx_location_product_last_sale_date ON vg_xxx_location_product_last_sale_date.wh_location::text = vg_stock_by_location_product_serial.wh_location::text AND vg_xxx_location_product_last_sale_date.product_name::text = vg_stock_by_location_product_serial.product_name::text;

ALTER TABLE vg_xxx_stock_location_product_serial_make_model
  OWNER TO odoo;

CREATE OR REPLACE VIEW vg_stock_location_make_model_hdd_grade_color_ageing AS 
 SELECT vg_xxx_stock_location_product_serial_make_model.wh_location,
    vg_xxx_stock_location_product_serial_make_model.make,
    vg_xxx_stock_location_product_serial_make_model.model,
    vg_xxx_stock_location_product_serial_make_model.hdd,
    vg_xxx_stock_location_product_serial_make_model.grade,
    vg_xxx_stock_location_product_serial_make_model.color,
    max(vg_xxx_stock_location_product_serial_make_model.list_price) AS rsp,
    sum(vg_xxx_stock_location_product_serial_make_model.stock_qty) AS stock_qty,
    max(vg_xxx_stock_location_product_serial_make_model.last_sale_date) AS last_sale_date,
    avg(vg_xxx_stock_location_product_serial_make_model.age)::bigint AS age
   FROM vg_xxx_stock_location_product_serial_make_model
  GROUP BY vg_xxx_stock_location_product_serial_make_model.wh_location, vg_xxx_stock_location_product_serial_make_model.make, vg_xxx_stock_location_product_serial_make_model.model, vg_xxx_stock_location_product_serial_make_model.hdd, vg_xxx_stock_location_product_serial_make_model.grade, vg_xxx_stock_location_product_serial_make_model.color
 HAVING sum(vg_xxx_stock_location_product_serial_make_model.stock_qty) > 0::numeric;

ALTER TABLE vg_stock_location_make_model_hdd_grade_color_ageing
  OWNER TO odoo;

CREATE OR REPLACE VIEW vg_stock_location_make_model_hdd_ageing AS 
 SELECT vg_xxx_stock_location_product_serial_make_model.wh_location,
    vg_xxx_stock_location_product_serial_make_model.make,
    vg_xxx_stock_location_product_serial_make_model.model,
    vg_xxx_stock_location_product_serial_make_model.hdd,
    max(vg_xxx_stock_location_product_serial_make_model.list_price) AS rsp,
    sum(vg_xxx_stock_location_product_serial_make_model.stock_qty) AS stock_qty,
    max(vg_xxx_stock_location_product_serial_make_model.last_sale_date) AS last_sale_date,
    avg(vg_xxx_stock_location_product_serial_make_model.age)::bigint AS age
   FROM vg_xxx_stock_location_product_serial_make_model
  GROUP BY vg_xxx_stock_location_product_serial_make_model.wh_location, vg_xxx_stock_location_product_serial_make_model.make, vg_xxx_stock_location_product_serial_make_model.model, vg_xxx_stock_location_product_serial_make_model.hdd
 HAVING sum(vg_xxx_stock_location_product_serial_make_model.stock_qty) > 0::numeric;

ALTER TABLE vg_stock_location_make_model_hdd_ageing
  OWNER TO odoo;
  