  CREATE OR REPLACE VIEW "odoo-views".view_cjpl_order_to_invoice_sale_type2 AS 
 SELECT date(sale_order.date_order) AS date_order,
    sale_order.name AS so_number,
    sale_order.id AS so_id,
    account_invoice.number AS invoice_number,
    account_invoice.id AS invoice_id,
    account_invoice.date_invoice,
    NULL::integer AS contract_id,
    NULL::character varying AS contract_number,
    sale_order_type.name AS sale_type,
    quote_literal('Sale Order'::text) AS invoice_type
   FROM sale_order
     JOIN sale_order_invoice_rel ON sale_order_invoice_rel.order_id = sale_order.id
     JOIN account_invoice ON sale_order_invoice_rel.invoice_id = account_invoice.id
     JOIN sale_order_type ON sale_order.type_id = sale_order_type.id
  WHERE account_invoice.number IS NOT NULL;

  
  CREATE OR REPLACE VIEW "odoo-views"."view_cjpl_contract_to_invoice_sale_type2" AS 
 SELECT date(sale_order.date_order) AS date_order,
    sale_order.name AS so_number,
	sale_order.id AS so_id,
    account_invoice.number AS invoice_number,
    account_invoice.id AS invoice_id,
    account_invoice.date_invoice,
	account_invoice.contract_id AS contract_id,
	account_analytic_account.name AS contract_number,
    sale_order_type.name AS sale_type,
        CASE
            WHEN (sale_order.name IS NULL) THEN quote_literal('Direct Contract'::text)
            ELSE quote_literal('Order Contract'::text)
        END AS invoice_type
   FROM (((account_analytic_account
     JOIN account_invoice ON ((account_invoice.contract_id = account_analytic_account.id)))
     LEFT JOIN sale_order ON ((sale_order.project_id = account_analytic_account.id)))
     LEFT JOIN sale_order_type ON ((sale_order.type_id = sale_order_type.id)))
  WHERE (account_invoice.number IS NOT NULL)
  ORDER BY account_invoice.number;
