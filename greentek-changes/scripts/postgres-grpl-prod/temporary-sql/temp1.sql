-- View: stock_move_by_location

-- DROP VIEW stock_move_by_location;

CREATE OR REPLACE VIEW stock_move_by_location AS 
 SELECT i.id,
    l.id AS location_id,
    i.product_id,
    i.name AS description,
        CASE
            WHEN i.state::text = 'done'::text THEN i.product_qty
            ELSE 0::numeric
        END AS name,
        CASE
            WHEN i.state::text <> 'done'::text THEN i.product_qty
            ELSE 0::numeric
        END AS product_qty_pending,
    i.date,
    i.restrict_lot_id AS prodlot_id,
    i.picking_id,
    l.company_id
   FROM stock_location l,
    stock_move i
  WHERE l.usage::text = 'internal'::text AND i.location_dest_id = l.id AND i.state::text <> 'cancel'::text AND i.company_id = l.company_id
UNION ALL
 SELECT - o.id AS id,
    l.id AS location_id,
    o.product_id,
    o.name AS description,
        CASE
            WHEN o.state::text = 'done'::text THEN - o.product_qty
            ELSE 0::numeric
        END AS name,
        CASE
            WHEN o.state::text <> 'done'::text THEN - o.product_qty
            ELSE 0::numeric
        END AS product_qty_pending,
    o.date,
    o.restrict_lot_id AS prodlot_id,
    o.picking_id,
    l.company_id
   FROM stock_location l,
    stock_move o
  WHERE l.usage::text = 'internal'::text AND o.location_id = l.id AND o.state::text <> 'cancel'::text AND o.company_id = l.company_id;

ALTER TABLE stock_move_by_location
  OWNER TO odoo;
