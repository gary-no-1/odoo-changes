-- View: vg_xxy_stock_moves_today

-- DROP VIEW vg_xxy_stock_moves_today;

CREATE OR REPLACE VIEW vg_xxy_stock_moves_today AS 
 SELECT f.complete_name AS wh_location,
    d.name AS product_name,
    a.stock_qty,
    e.name AS gtr_no,
    e.x_greentek_lot AS lot_no,
    e.x_greentek_imei AS imei_no,
    a.date,
    date_part('day'::text, now() - a.date::timestamp with time zone) AS days,
    b.name AS vchr_no,
    "substring"(b.name::text, '^.*?(?=[0-9]|$)'::text) AS vchr_type
   FROM vg_xxx_stock_move_by_location a
     LEFT JOIN stock_picking b ON a.picking_id = b.id
     JOIN stock_location f ON a.location_id = f.id
     JOIN product_product c ON a.product_id = c.id
     JOIN product_template d ON c.product_tmpl_id = d.id
     LEFT JOIN stock_production_lot e ON a.prodlot_id = e.id
  WHERE date_part('day'::text, now() - a.date::timestamp with time zone) < 5::double precision;

ALTER TABLE vg_xxy_stock_moves_today
  OWNER TO odoo;

-- View: vg_xxx_stock_move_by_location

-- DROP VIEW vg_xxx_stock_move_by_location;

CREATE OR REPLACE VIEW vg_xxx_stock_move_by_location AS 
 SELECT a.id,
    a.location_id,
    a.product_id,
    a.description,
    a.date,
    a.picking_id,
    a.company_id,
    b.lot_id AS prodlot_id,
        CASE
            WHEN a.name < 0::numeric THEN (-1)
            ELSE 1
        END AS stock_qty
   FROM stock_move_by_location a
     JOIN stock_pack_operation b ON a.picking_id = b.picking_id AND a.product_id = b.product_id AND b.location_dest_id = a.location_id
  WHERE a.prodlot_id IS NULL
UNION
 SELECT a.id,
    a.location_id,
    a.product_id,
    a.description,
    a.date,
    a.picking_id,
    a.company_id,
    b.lot_id AS prodlot_id,
        CASE
            WHEN a.name < 0::numeric THEN (-1)
            ELSE 1
        END AS stock_qty
   FROM stock_move_by_location a
     JOIN stock_pack_operation b ON a.picking_id = b.picking_id AND a.product_id = b.product_id AND b.location_id = a.location_id
  WHERE a.prodlot_id IS NULL
UNION
 SELECT a.id,
    a.location_id,
    a.product_id,
    a.description,
    a.date,
    a.picking_id,
    a.company_id,
    a.prodlot_id,
    a.name AS stock_qty
   FROM stock_move_by_location a
  WHERE a.prodlot_id IS NOT NULL;

ALTER TABLE vg_xxx_stock_move_by_location
  OWNER TO postgres;
GRANT ALL ON TABLE vg_xxx_stock_move_by_location TO postgres;
GRANT ALL ON TABLE vg_xxx_stock_move_by_location TO odoo;
GRANT SELECT ON TABLE vg_xxx_stock_move_by_location TO joomla;

with l as (
SELECT a.id, a.name ,
    split_part(a.name::text, '-'::text, 1) AS make,
    split_part(a.name::text, '-'::text, 2) AS model,
    split_part(a.name::text, '-'::text, 3) AS hdd,
    split_part(a.name::text, '-'::text, 4) AS grade,
    split_part(a.name::text, '-'::text, 5) AS ram,
    split_part(split_part(a.name::text, '-'::text, 5),' ',1) AS ram_name,
    split_part(split_part(a.name::text, '-'::text, 5),' ',2) AS ram_size,
    upper(split_part(a.name::text, '-'::text, 6)) AS color
  FROM product_template a where active )
  select * from l where ram_name <> 'RAM' or ((ram_size = '') IS NOT FALSE) ;

