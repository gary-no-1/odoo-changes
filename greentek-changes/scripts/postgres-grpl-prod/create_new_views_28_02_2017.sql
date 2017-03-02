-- View: vg_stock_gate_pass_invoice_status_gtr_no

DROP VIEW IF EXISTS vg_stock_gate_pass_invoice_status_gtr_no;

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	

-- View: vg_stock_gate_pass_invoice_status_gtr_no

CREATE OR REPLACE VIEW vg_stock_gate_pass_invoice_status_gtr_no AS 
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
     LEFT JOIN vg_xxy_stock_move_by_location_2 e ON a.id = e.picking_id
     LEFT JOIN stock_production_lot f ON e.prodlot_id = f.id
     LEFT JOIN vg_product_category g ON e.product_id = g.id
     LEFT JOIN account_invoice_line h ON h.id = e.invoice_line_id
  WHERE b.code::text <> 'internal'::text
  ORDER BY a.name;

ALTER TABLE vg_stock_gate_pass_invoice_status_gtr_no
  OWNER TO odoo;
COMMENT ON VIEW vg_stock_gate_pass_invoice_status_gtr_no
  IS '-- starting with stock_picking , get all stock moves against each picking voucher
-- all stock moves are available in vg_xxy_stock_move_by_location_2
-- if stock_picing has been invoiced , get invoice details even if cancelled
-- if stock moves exist , get transfer price and gtr_no from lot details as well as price from invoice_line details
-- left joins since invoice or stock move may not exist
';


-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	
  