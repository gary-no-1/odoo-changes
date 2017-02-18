-- View: view_cjpl_xxx_contract_to_invoice_sale_typology

-- DROP VIEW view_cjpl_xxx_contract_to_invoice_sale_typology;

CREATE OR REPLACE VIEW view_cjpl_xxx_contract_to_invoice_sale_typology AS 
 SELECT date(sale_order.date_order) AS date_order,
    sale_order.name AS so_number,
    sale_order.id AS so_id,
    account_invoice.number AS invoice_number,
    account_invoice.id AS invoice_id,
    account_invoice.date_invoice,
    account_analytic_account.name AS contract_number,
    account_invoice.state AS invoice_status,
    account_journal.name AS journal_name,
    account_invoice.contract_id,
        CASE
            WHEN sale_order.name IS NULL THEN 'Rental'::character varying
            ELSE sale_order_type.name
        END AS sale_type,
        CASE
            WHEN sale_order.name IS NULL THEN quote_literal('Direct Contract'::text)
            ELSE quote_literal('Order Contract'::text)
        END AS invoice_type
   FROM account_analytic_account
     JOIN account_invoice ON account_invoice.contract_id = account_analytic_account.id
     LEFT JOIN sale_order ON sale_order.project_id = account_analytic_account.id
     LEFT JOIN account_journal ON account_invoice.journal_id = account_journal.id
     LEFT JOIN sale_order_type ON sale_order.type_id = sale_order_type.id;

ALTER TABLE view_cjpl_xxx_contract_to_invoice_sale_typology
  OWNER TO postgres;
GRANT ALL ON TABLE view_cjpl_xxx_contract_to_invoice_sale_typology TO postgres;
GRANT SELECT ON TABLE view_cjpl_xxx_contract_to_invoice_sale_typology TO joomla;

-- View: view_cjpl_xxx_direct_invoice_sale_typology

-- DROP VIEW view_cjpl_xxx_direct_invoice_sale_typology;

CREATE OR REPLACE VIEW view_cjpl_xxx_direct_invoice_sale_typology AS 
 SELECT NULL::date AS date_order,
    NULL::character varying AS so_number,
    NULL::integer AS so_id,
    account_invoice.number AS invoice_number,
    account_invoice.id AS invoice_id,
    account_invoice.date_invoice,
    NULL::integer AS contract_id,
    NULL::character varying AS contract_number,
    account_invoice.state AS invoice_status,
    account_journal.name AS journal_name,
    NULL::character varying AS sale_type,
    quote_literal('Direct Sale'::text) AS invoice_type
   FROM account_invoice
     JOIN account_journal ON account_invoice.journal_id = account_journal.id
  WHERE account_invoice.contract_id IS NULL AND NOT (account_invoice.id IN ( SELECT sale_order_invoice_rel.invoice_id
           FROM sale_order_invoice_rel));

ALTER TABLE view_cjpl_xxx_direct_invoice_sale_typology
  OWNER TO postgres;
GRANT ALL ON TABLE view_cjpl_xxx_direct_invoice_sale_typology TO postgres;
GRANT SELECT ON TABLE view_cjpl_xxx_direct_invoice_sale_typology TO joomla;

-- View: view_cjpl_xxx_order_to_invoice_sale_typology

-- DROP VIEW view_cjpl_xxx_order_to_invoice_sale_typology;

CREATE OR REPLACE VIEW view_cjpl_xxx_order_to_invoice_sale_typology AS 
 SELECT date(sale_order.date_order) AS date_order,
    sale_order.name AS so_number,
    sale_order.id AS so_id,
    account_invoice.number AS invoice_number,
    account_invoice.id AS invoice_id,
    account_invoice.date_invoice,
    NULL::integer AS contract_id,
    NULL::character varying AS contract_number,
    account_invoice.state AS invoice_status,
    account_journal.name AS journal_name,
    sale_order_type.name AS sale_type,
    quote_literal('Sale Order'::text) AS invoice_type
   FROM sale_order
     JOIN sale_order_invoice_rel ON sale_order_invoice_rel.order_id = sale_order.id
     JOIN account_invoice ON sale_order_invoice_rel.invoice_id = account_invoice.id
     LEFT JOIN account_journal ON account_invoice.journal_id = account_journal.id
     JOIN sale_order_type ON sale_order.type_id = sale_order_type.id;

ALTER TABLE view_cjpl_xxx_order_to_invoice_sale_typology
  OWNER TO postgres;
GRANT ALL ON TABLE view_cjpl_xxx_order_to_invoice_sale_typology TO postgres;
GRANT SELECT ON TABLE view_cjpl_xxx_order_to_invoice_sale_typology TO joomla;

-- View: view_cjpl_sale_orders_with_no_invoices

-- DROP VIEW view_cjpl_sale_orders_with_no_invoices;

CREATE OR REPLACE VIEW view_cjpl_sale_orders_with_no_invoices AS 
 SELECT a.salesperson,
    a.team_name,
    a.so_number,
    a.id,
    a.order_date,
    a.order_party_name,
    a.so_state,
    a.contract_status
   FROM view_cjpl_order_basic a
  WHERE NOT (a.id IN ( SELECT b.so_id
           FROM view_cjpl_invoice_sale_type b
          WHERE b.so_id IS NOT NULL))
  ORDER BY a.so_number;

ALTER TABLE view_cjpl_sale_orders_with_no_invoices
  OWNER TO postgres;
GRANT ALL ON TABLE view_cjpl_sale_orders_with_no_invoices TO postgres;
GRANT SELECT ON TABLE view_cjpl_sale_orders_with_no_invoices TO joomla;
