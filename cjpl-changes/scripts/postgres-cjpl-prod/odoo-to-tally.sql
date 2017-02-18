-- View: view_cjpl_xxx_invoice_for_tally_1

-- DROP VIEW view_cjpl_xxx_invoice_for_tally_1;

CREATE OR REPLACE VIEW view_cjpl_xxx_invoice_for_tally_1 AS 
 SELECT a.id,
    a.number,
    a.date_invoice,
    b.company_name,
    a.amount_untaxed,
    a.amount_tax,
    a.amount_total,
    c.so_number,
    c.sale_type,
    a.x_po_ref
   FROM account_invoice a
     JOIN view_cjpl_partner_all_companies b ON a.partner_id = b.id
     JOIN view_cjpl_invoice_sale_typology c ON a.id = c.invoice_id
  WHERE a.number IS NOT NULL
  ORDER BY a.number;

ALTER TABLE view_cjpl_xxx_invoice_for_tally_1
  OWNER TO odoo;

-- --------------------------------------------------------------------------------------------------------------------------------  
-- View: view_cjpl_xxx_invoice_for_tally_2

-- DROP VIEW view_cjpl_xxx_invoice_for_tally_2;

CREATE OR REPLACE VIEW view_cjpl_xxx_invoice_for_tally_2 AS 
 SELECT t.invoice_id,
    max(
        CASE
            WHEN t."row" = 1 THEN t.name
            ELSE NULL::character varying
        END::text) AS a_tax_type,
    max(
        CASE
            WHEN t."row" = 1 THEN t.base
            ELSE NULL::numeric
        END) AS a_base_amount,
    max(
        CASE
            WHEN t."row" = 1 THEN t.tax_amount
            ELSE NULL::numeric
        END) AS a_tax_amount,
    max(
        CASE
            WHEN t."row" = 2 THEN t.name
            ELSE NULL::character varying
        END::text) AS b_tax_type,
    max(
        CASE
            WHEN t."row" = 2 THEN t.base
            ELSE NULL::numeric
        END) AS b_base_amount,
    max(
        CASE
            WHEN t."row" = 2 THEN t.tax_amount
            ELSE NULL::numeric
        END) AS b_tax_amount,
    max(
        CASE
            WHEN t."row" = 3 THEN t.name
            ELSE NULL::character varying
        END::text) AS c_tax_type,
    max(
        CASE
            WHEN t."row" = 3 THEN t.base
            ELSE NULL::numeric
        END) AS c_base_amount,
    max(
        CASE
            WHEN t."row" = 3 THEN t.tax_amount
            ELSE NULL::numeric
        END) AS c_tax_amount
   FROM ( SELECT account_invoice_tax.invoice_id,
            account_invoice_tax.name,
            account_invoice_tax.base,
            account_invoice_tax.amount,
            account_invoice_tax.tax_amount,
            row_number() OVER (PARTITION BY account_invoice_tax.invoice_id) AS "row"
           FROM account_invoice_tax) t
  GROUP BY t.invoice_id;

ALTER TABLE view_cjpl_xxx_invoice_for_tally_2
  OWNER TO odoo;

-- View: view_cjpl_xxx_invoice_for_tally_3

-- --------------------------------------------------------------------------------------------------------------------------------  
-- DROP VIEW view_cjpl_xxx_invoice_for_tally_3;

CREATE OR REPLACE VIEW view_cjpl_xxx_invoice_for_tally_3 AS 
 SELECT a.id,
    a.number,
    a.date_invoice,
    a.company_name,
    a.amount_untaxed,
    a.amount_tax,
    a.amount_total,
    a.so_number,
    a.sale_type,
    a.x_po_ref,
    b.a_tax_type,
    b.a_base_amount,
    b.a_tax_amount,
    b.b_tax_type,
    b.b_base_amount,
    b.b_tax_amount,
    b.c_tax_type,
    b.c_base_amount,
    b.c_tax_amount
   FROM view_cjpl_xxx_invoice_for_tally_1 a
     LEFT JOIN view_cjpl_xxx_invoice_for_tally_2 b ON a.id = b.invoice_id
  ORDER BY a.number;

ALTER TABLE view_cjpl_xxx_invoice_for_tally_3
  OWNER TO odoo;
  