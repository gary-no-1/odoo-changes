DROP VIEW IF EXISTS vg_invoice_product_serial_sale_transfer;
DROP VIEW IF EXISTS vg_stock_adjustments_all;
DROP VIEW IF EXISTS vg_stock_lot_gtr_info;
DROP VIEW IF EXISTS vg_xxy_stock_move_by_location_2;
DROP VIEW IF EXISTS vg_xxy_stock_move_by_location;
DROP VIEW IF EXISTS vg_xxx_stock_inventory_stock_line_inventory;
DROP VIEW IF EXISTS vg_all_partners;
DROP VIEW IF EXISTS vg_product_category;

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	

CREATE OR REPLACE VIEW vg_product_category AS 
 SELECT a.id,
    b.name AS product_name,
    c.name AS product_category
   FROM product_product a
     JOIN product_template b ON a.product_tmpl_id = b.id
     JOIN product_category c ON b.categ_id = c.id;

ALTER TABLE vg_product_category
  OWNER TO odoo;

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	

CREATE OR REPLACE VIEW vg_all_partners AS 
 WITH x AS (
         SELECT a.id,
            a.name AS company_partner_name,
            a.name AS company_name,
            b.name AS company_state,
            a.parent_id,
            a.is_company
           FROM res_partner a
             LEFT JOIN res_country_state b ON a.state_id = b.id
          WHERE a.is_company
        ), y AS (
         SELECT a.id,
            a.name AS company_partner_name,
            x.company_name,
            x.company_state,
            a.parent_id,
            a.is_company
           FROM res_partner a
             LEFT JOIN x ON a.parent_id = x.id
          WHERE NOT a.is_company AND a.parent_id IS NOT NULL
        ), z AS (
         SELECT a.id,
            a.name AS company_partner_name,
            a.name AS company_name,
            b.name AS company_state,
            a.parent_id,
            a.is_company
           FROM res_partner a
             LEFT JOIN res_country_state b ON a.state_id = b.id
          WHERE NOT a.is_company AND a.parent_id IS NULL
        )
 SELECT x.id,
    x.company_partner_name,
    x.company_name,
    x.company_state
   FROM x
UNION
 SELECT y.id,
    y.company_partner_name,
    y.company_name,
    y.company_state
   FROM y
UNION
 SELECT z.id,
    z.company_partner_name,
    z.company_name,
    z.company_state
   FROM z;

ALTER TABLE vg_all_partners
  OWNER TO odoo;
	
-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	


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
  WHERE l.usage::text = 'internal'::text AND i.location_dest_id = l.id AND i.state::text <> 'cancel'::text AND i.company_id = l.company_id and i.invoice_state::text = 'invoiced'
UNION ALL
 SELECT o.id AS id,
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
  WHERE l.usage::text = 'internal'::text AND o.location_id = l.id AND o.state::text <> 'cancel'::text AND o.company_id = l.company_id and o.invoice_state::text = 'invoiced';

ALTER TABLE vg_xxy_stock_move_by_location
  OWNER TO odoo;

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	

CREATE OR REPLACE VIEW vg_xxy_stock_move_by_location_2 AS 
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
   FROM vg_xxy_stock_move_by_location a
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
   FROM vg_xxy_stock_move_by_location a
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
   FROM vg_xxy_stock_move_by_location a
  WHERE a.prodlot_id IS NOT NULL;

ALTER TABLE vg_xxy_stock_move_by_location_2
  OWNER TO odoo;
GRANT ALL ON TABLE vg_xxy_stock_move_by_location_2 TO odoo;

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	

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
           FROM account_invoice a
             JOIN vg_user_name b_1 ON a.user_id = b_1.id
          WHERE a.state::text <> 'cancel'::text AND a.state::text <> 'draft'::text
        ), y AS (
         SELECT a.invoice_line_id,
            a.prodlot_id,
            a.stock_qty,
            b_1.name AS gtr_no,
			b_1.x_greentek_lot as lot_no,
            b_1.x_transfer_price_cost AS transfer_price
           FROM vg_xxy_stock_move_by_location_2 a
             JOIN stock_production_lot b_1 ON a.prodlot_id = b_1.id
          WHERE a.invoice_line_id IS NOT NULL
        )
 SELECT x.id,
    x.invoice_number,
    x.date_invoice,
	p.company_partner_name,
	p.company_name,
    x.amount_untaxed,
    x.amount_tax,
    x.amount_total,
    x.state as invoice_status,
    x.type as invoice_type,
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
   FROM x
     JOIN account_invoice_line b ON x.id = b.invoice_id
	 JOIN vg_product_category pc ON b.product_id = pc.id
	 JOIN vg_all_partners p ON p.id = x.partner_id
     LEFT JOIN y ON y.invoice_line_id = b.id
  ORDER BY x.date_invoice, x.invoice_number, b.product_id;

ALTER TABLE vg_invoice_product_serial_sale_transfer
  OWNER TO odoo;

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	
CREATE OR REPLACE VIEW vg_xxx_stock_inventory_stock_line_inventory AS 
 SELECT a.id,
    a.name,
    a.state,
    a.date,
    b.prod_lot_id,
    b.location_id,
    b.product_id,
    COALESCE(b.product_qty, 0::numeric) - COALESCE(b.theoretical_qty, 0::numeric) AS qty
   FROM stock_inventory a
     LEFT JOIN stock_inventory_line b ON a.id = b.inventory_id
  WHERE a.state::text = 'done'::text;

ALTER TABLE vg_xxx_stock_inventory_stock_line_inventory
  OWNER TO odoo;

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	

CREATE OR REPLACE VIEW vg_stock_adjustments_all AS 
 SELECT a.id,
    a.create_date,
    a.name,
    a.state,
    a.write_date,
    a.date,
    b.prod_lot_id,
    b.location_id,
    b.product_id,
    COALESCE(b.product_qty, 0::numeric) - COALESCE(b.theoretical_qty, 0::numeric) AS qty,
    c.name AS gtr_no,
    c.x_greentek_lot AS lot_no,
    c.x_greentek_imei AS imei_no,
    c.x_transfer_price_cost AS transfer_price,
    d.complete_name AS location,
    e.product_name,
    e.product_category
   FROM stock_inventory a
     LEFT JOIN stock_inventory_line b ON a.id = b.inventory_id
     LEFT JOIN stock_production_lot c ON b.prod_lot_id = c.id
     JOIN stock_location d ON b.location_id = d.id
     JOIN vg_product_category  e ON b.product_id = e.id
  WHERE a.state::text = 'done'::text;

ALTER TABLE vg_stock_adjustments_all
  OWNER TO odoo;

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	

CREATE OR REPLACE VIEW vg_stock_lot_gtr_info AS 
 WITH x AS (
         SELECT f.prod_lot_id,
            min(f.date) AS date
           FROM vg_xxx_stock_inventory_stock_line_inventory f
          GROUP BY f.prod_lot_id
        ), y AS (
         SELECT a.name,
            a.date,
            a.prod_lot_id,
            a.location_id,
            a.product_id,
            a.qty
           FROM vg_xxx_stock_inventory_stock_line_inventory a
             JOIN x ON a.prod_lot_id = x.prod_lot_id AND a.date = x.date
        )
 SELECT y.name AS adj_doc,
    c.name AS gtr_no,
    y.qty,
    c.x_greentek_lot AS lot_no,
    c.x_greentek_imei AS imei_no,
    c.x_transfer_price_cost AS transfer_price,
    d.complete_name AS location,
    e.product_name,
	e.product_category,
    y.prod_lot_id,
    y.location_id,
    y.product_id
   FROM y
     LEFT JOIN stock_production_lot c ON y.prod_lot_id = c.id
     JOIN stock_location d ON y.location_id = d.id
     JOIN vg_product_category e ON y.product_id = e.id;

ALTER TABLE vg_stock_lot_gtr_info
  OWNER TO odoo;

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	
  