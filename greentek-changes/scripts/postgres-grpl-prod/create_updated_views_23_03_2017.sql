-- View: vg_xxy_move_by_location_customer

DROP VIEW IF EXISTS vg_stock_gate_pass_invoice_status_gtr_no_2 cascade;
DROP VIEW IF EXISTS vg_xxy_stock_move_by_location_4 cascade;
DROP VIEW IF EXISTS vg_xxy_move_by_location_customer cascade;

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

-- View: vg_xxy_stock_move_by_location_4


CREATE OR REPLACE VIEW vg_xxy_stock_move_by_location_4 AS 
 WITH x AS (
         SELECT vg_xxy_stock_move_by_location.id,
            vg_xxy_stock_move_by_location.location_id,
            vg_xxy_stock_move_by_location.product_id,
            vg_xxy_stock_move_by_location.qty,
            vg_xxy_stock_move_by_location.unit_sale_price,
            vg_xxy_stock_move_by_location.date,
            vg_xxy_stock_move_by_location.prodlot_id,
            vg_xxy_stock_move_by_location.picking_id,
            vg_xxy_stock_move_by_location.invoice_line_id,
            row_number() OVER (PARTITION BY vg_xxy_stock_move_by_location.picking_id, vg_xxy_stock_move_by_location.product_id) AS rnk
           FROM vg_xxy_move_by_location_customer vg_xxy_stock_move_by_location
        ), y AS (
         SELECT x.id,
            x.location_id,
            x.product_id,
            x.qty,
            x.unit_sale_price,
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
    a.unit_sale_price,
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
    a.unit_sale_price,
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
    a.unit_sale_price,
    a.prodlot_id,
    a.qty AS stock_qty
   FROM y a
  WHERE a.prodlot_id IS NOT NULL;

ALTER TABLE vg_xxy_stock_move_by_location_4
  OWNER TO odoo;

  
-- View: vg_stock_gate_pass_invoice_status_gtr_no_2


CREATE OR REPLACE VIEW vg_stock_gate_pass_invoice_status_gtr_no_2 AS 
 SELECT a.id,
    a.partner_id,
    a.picking_type_id,
    a.move_type,
    a.invoice_id,
    e.prodlot_id,
    e.product_id,
    a.origin,
    b.code AS gate_pass_type,
    b.name AS gate_pass_transfer,
    a.name AS gate_pass,
    a.date AS gate_pass_date,
    a.state AS gate_pass_status,
    a.invoice_state,
    c.number AS invoice_number,
    c.internal_number,
    c.date_invoice,
    c.state AS invoice_status,
    d.company_name AS sold_thru,
    d.company_partner_name AS sale_party,
    e.stock_qty,
    round(h.price_subtotal / h.quantity, 0) AS price_unit,
    f.name AS gtr_no,
    f.x_greentek_lot AS lot_no,
    f.x_transfer_price_cost AS transfer_price,
    g.product_name,
    g.product_category
   FROM stock_picking a
     JOIN stock_picking_type b ON a.picking_type_id = b.id
     LEFT JOIN account_invoice c ON a.invoice_id = c.id
     LEFT JOIN vg_all_partners d ON a.partner_id = d.id
     LEFT JOIN vg_xxy_stock_move_by_location_4 e ON a.id = e.picking_id
     LEFT JOIN stock_production_lot f ON e.prodlot_id = f.id
     LEFT JOIN vg_product_category g ON e.product_id = g.id
     LEFT JOIN account_invoice_line h ON h.id = e.invoice_line_id
  WHERE b.code::text <> 'internal'::text;

ALTER TABLE vg_stock_gate_pass_invoice_status_gtr_no_2
  OWNER TO postgres;
GRANT ALL ON TABLE vg_stock_gate_pass_invoice_status_gtr_no_2 TO postgres;
GRANT ALL ON TABLE vg_stock_gate_pass_invoice_status_gtr_no_2 TO odoo;
GRANT SELECT ON TABLE vg_stock_gate_pass_invoice_status_gtr_no_2 TO joomla;
