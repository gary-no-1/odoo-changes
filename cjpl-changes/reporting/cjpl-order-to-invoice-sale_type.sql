CREATE OR REPLACE VIEW "public"."cjpl-order-to-invoice-sale-type" AS 
SELECT
	DATE (sale_order.date_order) AS date_order,
	sale_order. NAME AS so_number,
	sale_order_invoice_rel.invoice_id,
	account_invoice. NUMBER AS invoice_number,
	sale_order_type. NAME AS sale_type
FROM
	(
		(
			(
				sale_order
				JOIN sale_order_invoice_rel ON (
					(
						sale_order_invoice_rel.order_id = sale_order. ID
					)
				)
			)
			JOIN account_invoice ON (
				(
					sale_order_invoice_rel.invoice_id = account_invoice. ID
				)
			)
		)
		JOIN sale_order_type ON (
			(
				sale_order.type_id = sale_order_type. ID
			)
		)
	)
WHERE
	(
		account_invoice. NUMBER IS NOT NULL
	);;
