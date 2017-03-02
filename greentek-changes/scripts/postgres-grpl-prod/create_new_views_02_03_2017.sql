
DROP VIEW IF EXISTS vg_stock_gate_pass_invoice_status_gtr_no_gate_pass_done_invoice;
DROP VIEW IF EXISTS vg_stock_gate_pass_invoice_status_gtr_no_gate_pass_not_done;
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
  WHERE b.code::text <> 'internal'::text ;

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

-- View: vg_stock_gate_pass_invoice_status_gtr_no_gate_pass_not_done

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
          WHERE vg_stock_gate_pass_invoice_status_gtr_no.gate_pass_status::text <> 'done'::text
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

ALTER TABLE vg_stock_gate_pass_invoice_status_gtr_no_gate_pass_not_done
  OWNER TO odoo;
COMMENT ON VIEW vg_stock_gate_pass_invoice_status_gtr_no_gate_pass_not_done
  IS '-- list of gate pass with status <> ''done'' 
-- along with their corresponding invoice details';

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	

-- View: vg_stock_gate_pass_invoice_status_gtr_no_gate_pass_done_invoice

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
          WHERE vg_stock_gate_pass_invoice_status_gtr_no.gate_pass_status::text = 'done'::text AND vg_stock_gate_pass_invoice_status_gtr_no.invoice_status::text <> 'open'::text AND vg_stock_gate_pass_invoice_status_gtr_no.invoice_status::text <> 'paid'::text) s
  WHERE s.rnk = 1;

ALTER TABLE vg_stock_gate_pass_invoice_status_gtr_no_gate_pass_done_invoice
  OWNER TO odoo;
COMMENT ON VIEW vg_stock_gate_pass_invoice_status_gtr_no_gate_pass_done_invoice
  IS '-- list of gate pass with status = ''done'' 
-- select invoice which is cancelled or draft -- not paid or open';

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	
  
  
select
   a.location_id,
    b.complete_name AS wh_location,
    a.product_id,
    c.product_name,
    c.product_category,
    a.name AS stock_qty,
    a.prodlot_id,
    d.name as gtr_no,
    d.x_greentek_lot as lot_no,
    d.x_transfer_price_cost as transfer_price
   FROM stock_product_by_location_prodlot a
     JOIN stock_location b ON a.location_id = b.id
     JOIN vg_product_category  c ON a.product_id = c.id
     left join stock_production_lot d on a.prodlot_id = d.id
  
  
with x as (
 SELECT stock_move_by_location.product_id,
    stock_move_by_location.prodlot_id,
    sum(stock_move_by_location.name) AS qty,
    stock_move_by_location.company_id
   FROM stock_move_by_location
  GROUP BY stock_move_by_location.prodlot_id, stock_move_by_location.product_id, stock_move_by_location.company_id
 HAVING round(sum(stock_move_by_location.name), 4) <> 0::numeric)
 select * from x where product_id = 18691 ; -- in (select product_id from vg_stock_by_product) and; -- prodlot_id is not null ;

  