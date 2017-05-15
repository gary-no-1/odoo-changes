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
