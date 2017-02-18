-- View: vg_xxx_stock_location_product_serial_make_model_4

-- DROP VIEW vg_xxx_stock_location_product_serial_make_model_4;

CREATE OR REPLACE VIEW vg_xxx_stock_location_product_serial_make_model_4 AS 
 WITH l AS (
         SELECT a.id,
            a.location_id,
            a.product_id,
            a.prodlot_id,
            e.name AS gtr_no,
            e.x_greentek_lot AS lot_no,
            e.x_transfer_price_cost AS transfer_price,
                CASE
                    WHEN e.create_date IS NOT NULL THEN date_part('day'::text, age(now(), e.create_date::timestamp with time zone))
                    ELSE 60::double precision
                END AS age,
            a.stock_qty
           FROM vg_xxx_stock_move_by_location a
             LEFT JOIN stock_production_lot e ON a.prodlot_id = e.id
        )
 SELECT l.id,
    l.location_id,
    l.product_id,
    l.prodlot_id,
    r.complete_name AS wh_location,
    d.name AS product_name,
    split_part(d.name::text, '-'::text, 1) AS make,
    split_part(d.name::text, '-'::text, 2) AS model,
    split_part(d.name::text, '-'::text, 3) AS hdd,
    split_part(d.name::text, '-'::text, 4) AS grade,
    upper(split_part(d.name::text, '-'::text, 6)) AS color,
    d.list_price,
    l.gtr_no,
    l.lot_no,
    l.transfer_price,
    l.age,
    l.stock_qty
   FROM l
     JOIN product_product c ON l.product_id = c.id
     JOIN product_template d ON c.product_tmpl_id = d.id
     JOIN stock_location r ON l.location_id = r.id;

ALTER TABLE vg_xxx_stock_location_product_serial_make_model_4
  OWNER TO odoo;

-- --------------------------------  ----------------------------------------------------------------
-- View: vg_xxx_stock_location_product_serial_make_model_5

-- DROP VIEW vg_xxx_stock_location_product_serial_make_model_5;

CREATE OR REPLACE VIEW vg_xxx_stock_location_product_serial_make_model_5 AS 
 SELECT vg_xxx_stock_location_product_serial_make_model_4.id,
    vg_xxx_stock_location_product_serial_make_model_4.location_id,
    vg_xxx_stock_location_product_serial_make_model_4.product_id,
    vg_xxx_stock_location_product_serial_make_model_4.prodlot_id,
    vg_xxx_stock_location_product_serial_make_model_4.wh_location,
    vg_xxx_stock_location_product_serial_make_model_4.product_name,
    vg_xxx_stock_location_product_serial_make_model_4.make,
    vg_xxx_stock_location_product_serial_make_model_4.model,
    vg_xxx_stock_location_product_serial_make_model_4.hdd,
    vg_xxx_stock_location_product_serial_make_model_4.grade,
    vg_xxx_stock_location_product_serial_make_model_4.color,
    vg_xxx_stock_location_product_serial_make_model_4.list_price,
    vg_xxx_stock_location_product_serial_make_model_4.gtr_no,
    vg_xxx_stock_location_product_serial_make_model_4.lot_no,
    vg_xxx_stock_location_product_serial_make_model_4.transfer_price,
    vg_xxx_stock_location_product_serial_make_model_4.age,
    vg_xxx_stock_location_product_serial_make_model_4.stock_qty
   FROM vg_xxx_stock_location_product_serial_make_model_4
  WHERE NOT (vg_xxx_stock_location_product_serial_make_model_4.prodlot_id IN ( SELECT vg_xxx_stock_location_product_serial_make_model_4_1.prodlot_id
           FROM vg_xxx_stock_location_product_serial_make_model_4 vg_xxx_stock_location_product_serial_make_model_4_1
          WHERE vg_xxx_stock_location_product_serial_make_model_4_1.prodlot_id IS NOT NULL
          GROUP BY vg_xxx_stock_location_product_serial_make_model_4_1.prodlot_id
         HAVING sum(vg_xxx_stock_location_product_serial_make_model_4_1.stock_qty) < 0::numeric));

ALTER TABLE vg_xxx_stock_location_product_serial_make_model_5
  OWNER TO odoo;
-- --------------------------------  ----------------------------------------------------------------
-- View: vg_xxy_serial_age

-- DROP VIEW vg_xxy_serial_age;

CREATE OR REPLACE VIEW vg_xxy_serial_age AS 
 WITH a AS (
         SELECT vg_xxx_stock_location_product_serial_make_model_4.prodlot_id,
            sum(vg_xxx_stock_location_product_serial_make_model_4.stock_qty) AS closing_stk
           FROM vg_xxx_stock_location_product_serial_make_model_4
          GROUP BY vg_xxx_stock_location_product_serial_make_model_4.prodlot_id
         HAVING sum(vg_xxx_stock_location_product_serial_make_model_4.stock_qty) > 0::numeric
        )
 SELECT d.name AS product_name,
    split_part(d.name::text, '-'::text, 1) AS make,
    split_part(d.name::text, '-'::text, 2) AS model,
    split_part(d.name::text, '-'::text, 3) AS hdd,
    split_part(d.name::text, '-'::text, 4) AS grade,
    upper(split_part(d.name::text, '-'::text, 6)) AS color,
    d.list_price,
        CASE
            WHEN l.create_date IS NOT NULL THEN date_part('day'::text, age(now(), l.create_date::timestamp with time zone))
            ELSE 60::double precision
        END AS age,
    l.name AS gtr_no,
    l.x_greentek_lot AS lot_no,
    l.x_transfer_price_cost AS transfer_price
   FROM stock_production_lot l
     JOIN product_product c ON l.product_id = c.id
     JOIN product_template d ON c.product_tmpl_id = d.id
  WHERE (l.id IN ( SELECT a.prodlot_id
           FROM a));

ALTER TABLE vg_xxy_serial_age
  OWNER TO odoo;
COMMENT ON VIEW vg_xxy_serial_age
  IS '-- first get which serial nos are in stock
-- now for each serial # in stock , from stock_production_lot get name , gtr , create_date (which is age)';
-- --------------------------------  ----------------------------------------------------------------
-- View: vg_xxy_max_sale_date_location_product_1

-- DROP VIEW vg_xxy_max_sale_date_location_product_1;

CREATE OR REPLACE VIEW vg_xxy_max_sale_date_location_product_1 AS 
 SELECT i.location_id,
    i.product_id,
    max(i.date) AS last_sale_date
   FROM stock_move i
     JOIN stock_picking_type m ON i.picking_type_id = m.id
  WHERE i.state::text <> 'cancel'::text AND i.invoice_state::text = 'invoiced'::text AND i.invoice_line_id IS NOT NULL AND m.name::text = 'Delivery Orders'::text
  GROUP BY i.location_id, i.product_id;

ALTER TABLE vg_xxy_max_sale_date_location_product_1
  OWNER TO odoo;
COMMENT ON VIEW vg_xxy_max_sale_date_location_product_1
  IS 'location wise product wise get maximum date of transaction 
the transaction status must be invoiced and delivery note created';
-- --------------------------------  ----------------------------------------------------------------
-- View: vg_xxy_max_sale_date_location_product_2

-- DROP VIEW vg_xxy_max_sale_date_location_product_2;

CREATE OR REPLACE VIEW vg_xxy_max_sale_date_location_product_2 AS 
 SELECT l.location_id,
    l.product_id,
    l.last_sale_date,
    d.name AS product_name,
    split_part(d.name::text, '-'::text, 1) AS make,
    split_part(d.name::text, '-'::text, 2) AS model,
    split_part(d.name::text, '-'::text, 3) AS hdd,
    split_part(d.name::text, '-'::text, 4) AS grade,
    upper(split_part(d.name::text, '-'::text, 6)) AS color,
    b.complete_name AS wh_location
   FROM vg_xxy_max_sale_date_location_product_1 l
     JOIN product_product c ON l.product_id = c.id
     JOIN product_template d ON c.product_tmpl_id = d.id
     JOIN stock_location b ON l.location_id = b.id;

ALTER TABLE vg_xxy_max_sale_date_location_product_2
  OWNER TO odoo;
-- --------------------------------  ----------------------------------------------------------------
