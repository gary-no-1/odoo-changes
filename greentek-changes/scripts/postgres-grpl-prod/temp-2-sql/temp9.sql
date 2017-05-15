-- View: vg_xxy_stock_move_by_location

-- DROP VIEW vg_xxy_stock_move_by_location;

CREATE OR REPLACE VIEW vg_xxy_stock_move_by_location AS 
 SELECT i.id,
    l.id AS location_id,
    i.product_id,
        CASE
            WHEN i.state::text = 'done'::text THEN i.product_qty
            ELSE 0::numeric
        END AS qty,
    i.date,
    i.restrict_lot_id AS prodlot_id,
    i.picking_id,
    i.invoice_line_id
   FROM stock_location l,
    stock_move i
  WHERE l.usage::text = 'internal'::text AND i.location_dest_id = l.id AND i.state::text <> 'cancel'::text AND i.company_id = l.company_id AND i.invoice_state::text = 'invoiced'::text
UNION ALL
 SELECT o.id,
    l.id AS location_id,
    o.product_id,
        CASE
            WHEN o.state::text = 'done'::text THEN - o.product_qty
            ELSE 0::numeric
        END AS qty,
    o.date,
    o.restrict_lot_id AS prodlot_id,
    o.picking_id,
    o.invoice_line_id
   FROM stock_location l,
    stock_move o
  WHERE l.usage::text = 'internal'::text AND o.location_id = l.id AND o.state::text <> 'cancel'::text AND o.company_id = l.company_id AND o.invoice_state::text = 'invoiced'::text;

ALTER TABLE vg_xxy_stock_move_by_location
  OWNER TO odoo;
