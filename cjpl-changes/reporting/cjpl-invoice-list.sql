CREATE OR REPLACE VIEW "public"."cjpl-invoice-list" AS 
SELECT
	account_invoice. NUMBER AS invoice_number,
	account_invoice.date_invoice,
	account_invoice.amount_untaxed,
	account_invoice.amount_tax,
	account_invoice.amount_total,
	DATE (
		account_invoice.x_bill_period_from
	) AS bill_period_from,
	DATE (
		account_invoice.x_bill_period_to
	) AS bill_period_to,
	account_invoice.x_po_ref AS po_ref,
	res_partner. NAME AS customer,
	res_partner.x_core_code AS core_code,
	account_invoice.journal_id
FROM
	(
		account_invoice
		JOIN res_partner ON (
			(
				account_invoice.partner_id = res_partner. ID
			)
		)
	)
WHERE
	(
		(
			(account_invoice. STATE) :: TEXT <> 'draft' :: TEXT
		)
		AND (
			(account_invoice. STATE) :: TEXT <> 'cancel' :: TEXT
		)
	)
ORDER BY
	account_invoice.journal_id,
	account_invoice.date_invoice,
	account_invoice. NUMBER;;
