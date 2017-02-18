SELECT
FROM
"public".sale_order
INNER JOIN "public".account_analytic_account ON "public".sale_order.project_id = "public".account_analytic_account."id"
INNER JOIN "public".account_invoice ON "public".account_invoice.contract_id = "public".account_analytic_account."id"


 SELECT date(sale_order.date_order) AS date_order,
    sale_order.name AS so_number,
    sale_order_invoice_rel.invoice_id,
    account_invoice.number AS invoice_number,
    sale_order_type.name AS sale_type
   FROM (((sale_order
     JOIN sale_order_invoice_rel ON ((sale_order_invoice_rel.order_id = sale_order.id)))
     JOIN account_invoice ON ((sale_order_invoice_rel.invoice_id = account_invoice.id)))
     JOIN sale_order_type ON ((sale_order.type_id = sale_order_type.id)))
  WHERE (account_invoice.number IS NOT NULL);
  
  
  SELECT
	"public"."cjpl-invoice-list".invoice_number,
	"public"."cjpl-invoice-list".date_invoice,
	"public"."cjpl-invoice-list".amount_untaxed,
	"public"."cjpl-invoice-list".amount_tax,
	"public"."cjpl-invoice-list".amount_total,
	"public"."cjpl-invoice-list".bill_period_from,
	"public"."cjpl-invoice-list".bill_period_to,
	"public"."cjpl-invoice-list".po_ref,
	"public"."cjpl-invoice-list".customer,
	"public"."cjpl-invoice-list".core_code,
	"public"."cjpl-order-to-invoice-sale-type".sale_type,
	"public"."cjpl-order-to-invoice-sale-type".so_number,
	"public"."cjpl-order-to-invoice-sale-type".date_order
FROM
	"public"."cjpl-invoice-list"
LEFT OUTER JOIN "public"."cjpl-order-to-invoice-sale-type" ON "public"."cjpl-invoice-list".invoice_number = "public"."cjpl-order-to-invoice-sale-type".invoice_number
ORDER BY
	"public"."cjpl-invoice-list".journal_id ASC,
	"public"."cjpl-invoice-list".date_invoice ASC,
	"public"."cjpl-invoice-list".invoice_number ASC