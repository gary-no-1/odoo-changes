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
LEFT OUTER JOIN "public"."cjpl-order-to-invoice-sale-type" ON 
    "public"."cjpl-invoice-list".invoice_number = "public"."cjpl-order-to-invoice-sale-type".invoice_number
ORDER BY
	"public"."cjpl-invoice-list".journal_id ASC,
	"public"."cjpl-invoice-list".date_invoice ASC,
	"public"."cjpl-invoice-list".invoice_number ASC