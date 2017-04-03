DROP VIEW IF EXISTS vg_xxy_stock_move_by_location_2 cascade;

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

 -- ------------------------------------------------------------

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
    round((h.price_subtotal / h.quantity), 0) AS price_unit,
    f.name AS gtr_no,
    f.x_greentek_lot AS lot_no,
    f.x_transfer_price_cost AS transfer_price,
    g.product_name,
    g.product_category
   FROM (((((((stock_picking a
     JOIN stock_picking_type b ON ((a.picking_type_id = b.id)))
     LEFT JOIN account_invoice c ON ((a.invoice_id = c.id)))
     LEFT JOIN vg_all_partners d ON ((a.partner_id = d.id)))
     LEFT JOIN vg_xxy_stock_move_by_location_2 e ON ((a.id = e.picking_id)))
     LEFT JOIN stock_production_lot f ON ((e.prodlot_id = f.id)))
     LEFT JOIN vg_product_category g ON ((e.product_id = g.id)))
     LEFT JOIN account_invoice_line h ON ((h.id = e.invoice_line_id)))
  WHERE ((b.code)::text <> 'internal'::text);
 ALTER TABLE vg_stock_gate_pass_invoice_status_gtr_no OWNER TO postgres;
 GRANT ALL ON vg_stock_gate_pass_invoice_status_gtr_no TO postgres;
 GRANT ALL ON vg_stock_gate_pass_invoice_status_gtr_no TO odoo;
 GRANT SELECT ON vg_stock_gate_pass_invoice_status_gtr_no TO joomla;

-- ------------------------------------------------------------

CREATE OR REPLACE VIEW vg_invoice_product_serial_sale_transfer AS 
 WITH x AS (
         SELECT a.id,
            a.reference AS sale_order,
            a.origin,
            a.number AS invoice_number,
            a.date_invoice,
            a.partner_id,
            a.journal_id,
            a.amount_untaxed,
            a.amount_tax,
            a.amount_total,
            a.state,
            a.move_id,
            a.type,
            a.user_id,
            b_1.name AS saleperson,
            a.section_id,
            a.x_po_ref
           FROM (account_invoice a
             JOIN vg_user_name b_1 ON ((a.user_id = b_1.id)))
          WHERE (((a.state)::text <> ''::text) AND ((a.state)::text <> 'draft'::text))
        ), y AS (
         SELECT a.invoice_line_id,
            a.prodlot_id,
            a.stock_qty,
            b_1.name AS gtr_no,
            b_1.x_greentek_lot AS lot_no,
            b_1.x_transfer_price_cost AS transfer_price
           FROM (vg_xxy_stock_move_by_location_2 a
             JOIN stock_production_lot b_1 ON ((a.prodlot_id = b_1.id)))
          WHERE (a.invoice_line_id IS NOT NULL)
        )
 SELECT x.id,
    x.invoice_number,
    x.date_invoice,
    p.company_partner_name,
    p.company_name,
    x.amount_untaxed,
    x.amount_tax,
    x.amount_total,
    x.state AS invoice_status,
    x.type AS invoice_type,
    x.saleperson,
    b.invoice_id,
    b.price_unit,
    b.price_subtotal,
    b.discount,
    b.quantity,
    b.product_id,
    pc.product_name,
    pc.product_category,
    y.gtr_no,
    y.lot_no,
    y.transfer_price
   FROM ((((x
     JOIN account_invoice_line b ON ((x.id = b.invoice_id)))
     JOIN vg_product_category pc ON ((b.product_id = pc.id)))
     JOIN vg_all_partners p ON ((p.id = x.partner_id)))
     LEFT JOIN y ON ((y.invoice_line_id = b.id)))
  ORDER BY x.date_invoice, x.invoice_number, b.product_id;
 ALTER TABLE vg_invoice_product_serial_sale_transfer OWNER TO postgres;
 GRANT ALL ON vg_invoice_product_serial_sale_transfer TO postgres;
 GRANT ALL ON vg_invoice_product_serial_sale_transfer TO odoo;
 GRANT SELECT ON vg_invoice_product_serial_sale_transfer TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_stock_gate_pass_invoice_status_gtr_no_gate_pass_not_done AS 
 WITH x AS (
         SELECT vg_stock_gate_pass_invoice_status_gtr_no.origin,
            vg_stock_gate_pass_invoice_status_gtr_no.gate_pass_type,
            vg_stock_gate_pass_invoice_status_gtr_no.gate_pass_transfer,
            vg_stock_gate_pass_invoice_status_gtr_no.gate_pass,
            vg_stock_gate_pass_invoice_status_gtr_no.gate_pass_date,
            vg_stock_gate_pass_invoice_status_gtr_no.gate_pass_status,
            vg_stock_gate_pass_invoice_status_gtr_no.invoice_state,
            vg_stock_gate_pass_invoice_status_gtr_no.invoice_number,
            vg_stock_gate_pass_invoice_status_gtr_no.internal_number,
            vg_stock_gate_pass_invoice_status_gtr_no.date_invoice,
            vg_stock_gate_pass_invoice_status_gtr_no.invoice_status,
            vg_stock_gate_pass_invoice_status_gtr_no.sold_thru,
            vg_stock_gate_pass_invoice_status_gtr_no.sale_party,
            vg_stock_gate_pass_invoice_status_gtr_no.stock_qty,
            vg_stock_gate_pass_invoice_status_gtr_no.price_unit,
            vg_stock_gate_pass_invoice_status_gtr_no.gtr_no,
            vg_stock_gate_pass_invoice_status_gtr_no.lot_no,
            vg_stock_gate_pass_invoice_status_gtr_no.transfer_price,
            vg_stock_gate_pass_invoice_status_gtr_no.product_name,
            vg_stock_gate_pass_invoice_status_gtr_no.product_category
           FROM vg_stock_gate_pass_invoice_status_gtr_no
          WHERE ((vg_stock_gate_pass_invoice_status_gtr_no.gate_pass_status)::text <> 'done'::text)
        )
 SELECT DISTINCT x.origin,
    x.gate_pass_type,
    x.gate_pass_transfer,
    x.gate_pass,
    x.gate_pass_date,
    x.gate_pass_status,
    x.invoice_state,
    x.invoice_number,
    x.internal_number,
    x.date_invoice,
    x.invoice_status,
    x.sold_thru,
    x.sale_party,
    x.stock_qty,
    x.price_unit,
    x.gtr_no,
    x.lot_no,
    x.transfer_price,
    x.product_name,
    x.product_category
   FROM x
  ORDER BY x.gate_pass;
 ALTER TABLE vg_stock_gate_pass_invoice_status_gtr_no_gate_pass_not_done OWNER TO postgres;
 GRANT ALL ON vg_stock_gate_pass_invoice_status_gtr_no_gate_pass_not_done TO postgres;
 GRANT ALL ON vg_stock_gate_pass_invoice_status_gtr_no_gate_pass_not_done TO odoo;
 GRANT SELECT ON vg_stock_gate_pass_invoice_status_gtr_no_gate_pass_not_done TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_stock_gate_pass_invoice_status_gtr_no_gate_pass_done_invoice AS 
 SELECT s.origin,
    s.gate_pass_type,
    s.gate_pass_transfer,
    s.gate_pass,
    s.gate_pass_date,
    s.gate_pass_status,
    s.invoice_state,
    s.invoice_number,
    s.internal_number,
    s.date_invoice,
    s.invoice_status,
    s.sold_thru,
    s.sale_party
   FROM ( SELECT vg_stock_gate_pass_invoice_status_gtr_no.origin,
            vg_stock_gate_pass_invoice_status_gtr_no.gate_pass_type,
            vg_stock_gate_pass_invoice_status_gtr_no.gate_pass_transfer,
            vg_stock_gate_pass_invoice_status_gtr_no.gate_pass,
            vg_stock_gate_pass_invoice_status_gtr_no.gate_pass_date,
            vg_stock_gate_pass_invoice_status_gtr_no.gate_pass_status,
            vg_stock_gate_pass_invoice_status_gtr_no.invoice_state,
            vg_stock_gate_pass_invoice_status_gtr_no.invoice_number,
            vg_stock_gate_pass_invoice_status_gtr_no.internal_number,
            vg_stock_gate_pass_invoice_status_gtr_no.date_invoice,
            vg_stock_gate_pass_invoice_status_gtr_no.invoice_status,
            vg_stock_gate_pass_invoice_status_gtr_no.sold_thru,
            vg_stock_gate_pass_invoice_status_gtr_no.sale_party,
            row_number() OVER (PARTITION BY vg_stock_gate_pass_invoice_status_gtr_no.gate_pass) AS rnk
           FROM vg_stock_gate_pass_invoice_status_gtr_no
          WHERE ((((vg_stock_gate_pass_invoice_status_gtr_no.gate_pass_status)::text = 'done'::text) AND ((vg_stock_gate_pass_invoice_status_gtr_no.invoice_status)::text <> 'open'::text)) AND ((vg_stock_gate_pass_invoice_status_gtr_no.invoice_status)::text <> 'paid'::text))) s
  WHERE (s.rnk = 1);
 ALTER TABLE vg_stock_gate_pass_invoice_status_gtr_no_gate_pass_done_invoice OWNER TO postgres;
 GRANT ALL ON vg_stock_gate_pass_invoice_status_gtr_no_gate_pass_done_invoice TO postgres;
 GRANT ALL ON vg_stock_gate_pass_invoice_status_gtr_no_gate_pass_done_invoice TO odoo;
 GRANT SELECT ON vg_stock_gate_pass_invoice_status_gtr_no_gate_pass_done_invoice TO joomla;

-- ------------------------------------------------------------
 