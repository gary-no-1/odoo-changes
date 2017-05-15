-- View: vg_xxy_stock_move_by_location_2

-- DROP VIEW vg_xxy_stock_move_by_location_2;

CREATE OR REPLACE VIEW vg_xxy_stock_move_by_location_2 AS 
 WITH x AS (
         SELECT vg_xxy_stock_move_by_location.id,
            vg_xxy_stock_move_by_location.location_id,
            vg_xxy_stock_move_by_location.product_id,
            vg_xxy_stock_move_by_location.qty,
            vg_xxy_stock_move_by_location.date,
            vg_xxy_stock_move_by_location.prodlot_id,
            vg_xxy_stock_move_by_location.picking_id,
            vg_xxy_stock_move_by_location.invoice_line_id,
            row_number() OVER (PARTITION BY vg_xxy_stock_move_by_location.picking_id, vg_xxy_stock_move_by_location.product_id) AS rnk
           FROM vg_xxy_stock_move_by_location
        ), y AS (
         SELECT x.id,
            x.location_id,
            x.product_id,
            x.qty,
            x.date,
            x.prodlot_id,
            x.picking_id,
            x.invoice_line_id,
            x.rnk
           FROM x
          WHERE x.rnk = 1
        )
 SELECT a.id,
    a.location_id,
    a.product_id,
    a.date,
    a.picking_id,
    a.invoice_line_id,
    b.lot_id AS prodlot_id,
        CASE
            WHEN a.qty < 0::numeric THEN (-1)
            ELSE 1
        END AS stock_qty
   FROM y a
     JOIN stock_pack_operation b ON a.picking_id = b.picking_id AND a.product_id = b.product_id AND b.location_dest_id = a.location_id
  WHERE a.prodlot_id IS NULL
UNION
 SELECT a.id,
    a.location_id,
    a.product_id,
    a.date,
    a.picking_id,
    a.invoice_line_id,
    b.lot_id AS prodlot_id,
        CASE
            WHEN a.qty < 0::numeric THEN (-1)
            ELSE 1
        END AS stock_qty
   FROM y a
     JOIN stock_pack_operation b ON a.picking_id = b.picking_id AND a.product_id = b.product_id AND b.location_id = a.location_id
  WHERE a.prodlot_id IS NULL
UNION
 SELECT a.id,
    a.location_id,
    a.product_id,
    a.date,
    a.picking_id,
    a.invoice_line_id,
    a.prodlot_id,
    a.qty AS stock_qty
   FROM y a
  WHERE a.prodlot_id IS NOT NULL;

ALTER TABLE vg_xxy_stock_move_by_location_2
  OWNER TO odoo;
