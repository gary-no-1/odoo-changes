DROP VIEW IF EXISTS  vg_xxx_stock_location_product_serial_make_model cascade;
DROP VIEW IF EXISTS  vg_stock_location_make_model_hdd_grade_color_ageing;
DROP VIEW IF EXISTS  vg_stock_location_make_model_hdd_ageing cascade;

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
    vg_stock_by_location_product_serial.list_price,
    vg_stock_by_location_product_serial.stock_qty,
        CASE
            WHEN vg_stock_by_location_product_serial.stock_start_date IS NOT NULL THEN date_part('day'::text, age(now(), vg_stock_by_location_product_serial.stock_start_date::timestamp with time zone))
            ELSE 60::double precision
        END AS age
   FROM vg_stock_by_location_product_serial;

ALTER TABLE vg_xxx_stock_location_product_serial_make_model
  OWNER TO odoo;
  
-- View: vg_stock_location_make_model_hdd_grade_color_ageing


CREATE OR REPLACE VIEW vg_stock_location_make_model_hdd_grade_color_ageing AS 
 SELECT vg_xxx_stock_location_product_serial_make_model.wh_location,
    vg_xxx_stock_location_product_serial_make_model.make,
    vg_xxx_stock_location_product_serial_make_model.model,
    vg_xxx_stock_location_product_serial_make_model.hdd,
    vg_xxx_stock_location_product_serial_make_model.grade,
    vg_xxx_stock_location_product_serial_make_model.color,
    max(vg_xxx_stock_location_product_serial_make_model.list_price) AS rsp,
    sum(vg_xxx_stock_location_product_serial_make_model.stock_qty) AS stock_qty,
    avg(vg_xxx_stock_location_product_serial_make_model.age)::bigint AS age
   FROM vg_xxx_stock_location_product_serial_make_model
  GROUP BY vg_xxx_stock_location_product_serial_make_model.wh_location, vg_xxx_stock_location_product_serial_make_model.make, vg_xxx_stock_location_product_serial_make_model.model, vg_xxx_stock_location_product_serial_make_model.hdd, vg_xxx_stock_location_product_serial_make_model.grade, vg_xxx_stock_location_product_serial_make_model.color
 HAVING sum(vg_xxx_stock_location_product_serial_make_model.stock_qty) > 0::numeric;

ALTER TABLE vg_stock_location_make_model_hdd_grade_color_ageing
  OWNER TO odoo;

-- View: vg_stock_location_make_model_hdd_ageing


CREATE OR REPLACE VIEW vg_stock_location_make_model_hdd_ageing AS 
 SELECT vg_xxx_stock_location_product_serial_make_model.wh_location,
    vg_xxx_stock_location_product_serial_make_model.make,
    vg_xxx_stock_location_product_serial_make_model.model,
    vg_xxx_stock_location_product_serial_make_model.hdd,
    max(vg_xxx_stock_location_product_serial_make_model.list_price) AS rsp,
    sum(vg_xxx_stock_location_product_serial_make_model.stock_qty) AS stock_qty,
    avg(vg_xxx_stock_location_product_serial_make_model.age)::bigint AS age
   FROM vg_xxx_stock_location_product_serial_make_model
  GROUP BY vg_xxx_stock_location_product_serial_make_model.wh_location, vg_xxx_stock_location_product_serial_make_model.make, vg_xxx_stock_location_product_serial_make_model.model, vg_xxx_stock_location_product_serial_make_model.hdd
 HAVING sum(vg_xxx_stock_location_product_serial_make_model.stock_qty) > 0::numeric;

ALTER TABLE vg_stock_location_make_model_hdd_ageing
  OWNER TO odoo;
