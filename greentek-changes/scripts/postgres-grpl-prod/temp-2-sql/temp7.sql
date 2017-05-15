-- View: vg_xxy_move_by_location_customer

-- DROP VIEW vg_xxy_move_by_location_customer;

CREATE OR REPLACE VIEW vg_xxy_move_by_location_customer AS 
 WITH x AS (
         SELECT a.id,
            a.origin,
            a.date,
            a.product_qty,
            a.location_id,
            a.state,
            a.name,
            a.warehouse_id,
            a.restrict_lot_id,
            a.product_id,
            a.picking_id,
            a.location_dest_id,
            a.invoice_state,
            a.invoice_line_id,
            round(b.price_subtotal / b.quantity, 0) AS unit_sale_price
           FROM stock_move a
             JOIN account_invoice_line b ON a.invoice_line_id = b.id
          WHERE a.state::text <> 'cancel'::text AND a.invoice_state::text = 'invoiced'::text AND a.origin_returned_move_id IS NULL AND a.product_qty <> 0::numeric
        )
 SELECT i.id,
    l.id AS location_id,
    i.product_id,
        CASE
            WHEN i.state::text = 'done'::text THEN i.product_qty
            ELSE 0::numeric
        END AS qty,
    i.date,
    i.unit_sale_price,
    i.restrict_lot_id AS prodlot_id,
    i.picking_id,
    i.invoice_line_id
   FROM stock_location l,
    x i
  WHERE l.usage::text = 'customer'::text AND i.location_dest_id = l.id
UNION ALL
 SELECT o.id,
    l.id AS location_id,
    o.product_id,
        CASE
            WHEN o.state::text = 'done'::text THEN - o.product_qty
            ELSE 0::numeric
        END AS qty,
    o.date,
    o.unit_sale_price,
    o.restrict_lot_id AS prodlot_id,
    o.picking_id,
    o.invoice_line_id
   FROM stock_location l,
    x o
  WHERE l.usage::text = 'customer'::text AND o.location_dest_id = l.id;

ALTER TABLE vg_xxy_move_by_location_customer
  OWNER TO odoo;
