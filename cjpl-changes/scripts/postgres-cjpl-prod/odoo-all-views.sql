-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_user_name AS 
 SELECT res_users.id,
    res_users.partner_id,
    res_users.active,
    res_users.login,
    res_partner.name,
    res_users.login_date,
    res_users.x_designation
   FROM (res_users
     JOIN res_partner ON ((res_users.partner_id = res_partner.id)));
 ALTER TABLE view_cjpl_user_name OWNER TO postgres;
 GRANT ALL ON view_cjpl_user_name TO postgres;
 GRANT SELECT ON view_cjpl_user_name TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_xxx_partner_is_a_company AS 
 SELECT a.id,
    a.name AS company_partner_name,
    a.name AS company_name,
    a.x_core_code,
    b.name AS company_state,
    a.parent_id,
    a.is_company
   FROM (res_partner a
     LEFT JOIN res_country_state b ON ((a.state_id = b.id)))
  WHERE a.is_company;
 ALTER TABLE view_cjpl_xxx_partner_is_a_company OWNER TO postgres;
 GRANT ALL ON view_cjpl_xxx_partner_is_a_company TO postgres;
 GRANT SELECT ON view_cjpl_xxx_partner_is_a_company TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_xxx_partner_is_not_company_but_has_parent AS 
 SELECT a.id,
    a.name AS company_partner_name,
    b.company_name,
    b.x_core_code,
    b.company_state,
    a.parent_id,
    a.is_company
   FROM (res_partner a
     LEFT JOIN view_cjpl_xxx_partner_is_a_company b ON ((a.parent_id = b.id)))
  WHERE ((NOT a.is_company) AND (a.parent_id IS NOT NULL));
 ALTER TABLE view_cjpl_xxx_partner_is_not_company_but_has_parent OWNER TO postgres;
 GRANT ALL ON view_cjpl_xxx_partner_is_not_company_but_has_parent TO postgres;
 GRANT SELECT ON view_cjpl_xxx_partner_is_not_company_but_has_parent TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_xxx_partner_is_not_company_with_no_parent AS 
 SELECT a.id,
    a.name AS company_partner_name,
    a.name AS company_name,
    a.x_core_code,
    b.name AS company_state,
    a.parent_id,
    a.is_company
   FROM (res_partner a
     LEFT JOIN res_country_state b ON ((a.state_id = b.id)))
  WHERE ((NOT a.is_company) AND (a.parent_id IS NULL));
 ALTER TABLE view_cjpl_xxx_partner_is_not_company_with_no_parent OWNER TO postgres;
 GRANT ALL ON view_cjpl_xxx_partner_is_not_company_with_no_parent TO postgres;
 GRANT SELECT ON view_cjpl_xxx_partner_is_not_company_with_no_parent TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_partner_all_companies AS 
 SELECT a.id,
    a.company_partner_name,
    a.company_name,
    a.x_core_code,
    a.company_state,
    a.parent_id,
    a.is_company
   FROM view_cjpl_xxx_partner_is_a_company a
UNION
 SELECT b.id,
    b.company_partner_name,
    b.company_name,
    b.x_core_code,
    b.company_state,
    b.parent_id,
    b.is_company
   FROM view_cjpl_xxx_partner_is_not_company_but_has_parent b
UNION
 SELECT c.id,
    c.company_partner_name,
    c.company_name,
    c.x_core_code,
    c.company_state,
    c.parent_id,
    c.is_company
   FROM view_cjpl_xxx_partner_is_not_company_with_no_parent c;
 ALTER TABLE view_cjpl_partner_all_companies OWNER TO postgres;
 GRANT ALL ON view_cjpl_partner_all_companies TO postgres;
 GRANT SELECT ON view_cjpl_partner_all_companies TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_contract_basic AS 
 SELECT account_analytic_account.name AS contract_number,
    account_analytic_account.id,
    account_analytic_account.code,
    account_analytic_account.state AS status,
    account_analytic_account.type,
    date(account_analytic_account.create_date) AS create_date,
    account_analytic_account.date_start AS from_date,
    account_analytic_account.date AS to_date,
    res_partner.display_name AS partner_name,
    view_cjpl_user_name.name AS salesperson,
    account_journal.name AS sale_journal,
    account_analytic_account.x_kind_attn AS kind_attn,
    account_analytic_account.x_po_ref AS po_ref,
        CASE
            WHEN (account_analytic_account.recurring_invoices IS TRUE) THEN 'Create Invoice'::text
            ELSE 'No Invoicing'::text
        END AS invoice_status,
    account_analytic_account.recurring_rule_type,
    account_analytic_account.recurring_next_date
   FROM account_analytic_account,
    res_partner,
    view_cjpl_user_name,
    account_journal
  WHERE (((account_analytic_account.partner_id = res_partner.id) AND (account_analytic_account.user_id = view_cjpl_user_name.id)) AND (account_journal.id = account_analytic_account.journal_id));
 ALTER TABLE view_cjpl_contract_basic OWNER TO postgres;
 GRANT ALL ON view_cjpl_contract_basic TO postgres;
 GRANT SELECT ON view_cjpl_contract_basic TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_xxx_contract_to_invoice_sale_type AS 
 SELECT date(sale_order.date_order) AS date_order,
    sale_order.name AS so_number,
    sale_order.id AS so_id,
    account_invoice.number AS invoice_number,
    account_invoice.id AS invoice_id,
    account_invoice.date_invoice,
    account_analytic_account.name AS contract_number,
    account_invoice.contract_id,
        CASE
            WHEN (sale_order.name IS NULL) THEN 'Rental'::character varying
            ELSE sale_order_type.name
        END AS sale_type,
        CASE
            WHEN (sale_order.name IS NULL) THEN quote_literal('Direct Contract'::text)
            ELSE quote_literal('Order Contract'::text)
        END AS invoice_type
   FROM (((account_analytic_account
     JOIN account_invoice ON ((account_invoice.contract_id = account_analytic_account.id)))
     LEFT JOIN sale_order ON ((sale_order.project_id = account_analytic_account.id)))
     LEFT JOIN sale_order_type ON ((sale_order.type_id = sale_order_type.id)))
  WHERE (account_invoice.number IS NOT NULL);
 ALTER TABLE view_cjpl_xxx_contract_to_invoice_sale_type OWNER TO postgres;
 GRANT ALL ON view_cjpl_xxx_contract_to_invoice_sale_type TO postgres;
 GRANT SELECT ON view_cjpl_xxx_contract_to_invoice_sale_type TO joomla;

-- ------------------------------------------------------------
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
            WHEN (sale_order.name IS NULL) THEN 'Rental'::character varying
            ELSE sale_order_type.name
        END AS sale_type,
        CASE
            WHEN (sale_order.name IS NULL) THEN quote_literal('Direct Contract'::text)
            ELSE quote_literal('Order Contract'::text)
        END AS invoice_type
   FROM ((((account_analytic_account
     JOIN account_invoice ON ((account_invoice.contract_id = account_analytic_account.id)))
     LEFT JOIN sale_order ON ((sale_order.project_id = account_analytic_account.id)))
     LEFT JOIN account_journal ON ((account_invoice.journal_id = account_journal.id)))
     LEFT JOIN sale_order_type ON ((sale_order.type_id = sale_order_type.id)));
 ALTER TABLE view_cjpl_xxx_contract_to_invoice_sale_typology OWNER TO postgres;
 GRANT ALL ON view_cjpl_xxx_contract_to_invoice_sale_typology TO postgres;
 GRANT SELECT ON view_cjpl_xxx_contract_to_invoice_sale_typology TO joomla;

-- ------------------------------------------------------------
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
   FROM (account_invoice
     JOIN account_journal ON ((account_invoice.journal_id = account_journal.id)))
  WHERE ((account_invoice.contract_id IS NULL) AND (NOT (account_invoice.id IN ( SELECT sale_order_invoice_rel.invoice_id
           FROM sale_order_invoice_rel))));
 ALTER TABLE view_cjpl_xxx_direct_invoice_sale_typology OWNER TO postgres;
 GRANT ALL ON view_cjpl_xxx_direct_invoice_sale_typology TO postgres;
 GRANT SELECT ON view_cjpl_xxx_direct_invoice_sale_typology TO joomla;

-- ------------------------------------------------------------
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
   FROM ((((sale_order
     JOIN sale_order_invoice_rel ON ((sale_order_invoice_rel.order_id = sale_order.id)))
     JOIN account_invoice ON ((sale_order_invoice_rel.invoice_id = account_invoice.id)))
     LEFT JOIN account_journal ON ((account_invoice.journal_id = account_journal.id)))
     JOIN sale_order_type ON ((sale_order.type_id = sale_order_type.id)));
 ALTER TABLE view_cjpl_xxx_order_to_invoice_sale_typology OWNER TO postgres;
 GRANT ALL ON view_cjpl_xxx_order_to_invoice_sale_typology TO postgres;
 GRANT SELECT ON view_cjpl_xxx_order_to_invoice_sale_typology TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_invoice_sale_typology AS 
 SELECT a.invoice_number,
    a.invoice_id,
    a.date_invoice,
    a.so_number,
    a.so_id,
    a.date_order,
    a.contract_number,
    a.contract_id,
    a.sale_type,
    a.invoice_type,
    a.invoice_status,
    a.journal_name
   FROM view_cjpl_xxx_order_to_invoice_sale_typology a
UNION ALL
 SELECT b.invoice_number,
    b.invoice_id,
    b.date_invoice,
    b.so_number,
    b.so_id,
    b.date_order,
    b.contract_number,
    b.contract_id,
    b.sale_type,
    b.invoice_type,
    b.invoice_status,
    b.journal_name
   FROM view_cjpl_xxx_contract_to_invoice_sale_typology b
UNION ALL
 SELECT c.invoice_number,
    c.invoice_id,
    c.date_invoice,
    c.so_number,
    c.so_id,
    c.date_order,
    c.contract_number,
    c.contract_id,
    c.sale_type,
    c.invoice_type,
    c.invoice_status,
    c.journal_name
   FROM view_cjpl_xxx_direct_invoice_sale_typology c;
 ALTER TABLE view_cjpl_invoice_sale_typology OWNER TO postgres;
 GRANT ALL ON view_cjpl_invoice_sale_typology TO postgres;
 GRANT SELECT ON view_cjpl_invoice_sale_typology TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_opportunity AS 
 SELECT view_cjpl_user_name.name AS salesperson,
    crm_lead.code AS lead_number,
    crm_lead.id AS opportunity_id,
    date(crm_lead.date_closed) AS date_closed,
    date(crm_lead.create_date) AS create_date,
    crm_lead.date_deadline,
    date(crm_lead.date_last_stage_update) AS date_last_stage_update,
    crm_lead.day_close,
    crm_lead.active,
    crm_lead.day_open,
    crm_lead.contact_name,
    crm_lead.city,
    crm_lead.opt_out,
    date(crm_lead.date_open) AS date_open,
    crm_lead.partner_name,
    crm_lead.planned_revenue,
    crm_lead.priority,
    crm_lead.ref,
    lpad(substr((crm_lead.ref)::text, ("position"((crm_lead.ref)::text, ','::text) + 1)), 4, '0'::text) AS so_number,
    ('SO'::text || lpad(substr((crm_lead.ref)::text, ("position"((crm_lead.ref)::text, ','::text) + 1)), 3, '0'::text)) AS so_number_full,
    crm_lead.description,
    crm_lead.street2,
    crm_case_section.name AS team_name,
    crm_lead.phone,
    crm_lead.probability,
    crm_lead.date_action,
    crm_lead.name,
    crm_lead.mobile,
    crm_lead.type,
    crm_lead.street,
    crm_lead.source_id,
    res_country_state.name AS state,
    crm_lead.email_from,
    crm_lead.referred,
    crm_lead.weighted_planned_revenue,
    crm_case_stage.name AS stage
   FROM ((((crm_lead
     JOIN crm_case_stage ON ((crm_lead.stage_id = crm_case_stage.id)))
     JOIN view_cjpl_user_name ON ((crm_lead.user_id = view_cjpl_user_name.id)))
     JOIN res_country_state ON ((crm_lead.state_id = res_country_state.id)))
     JOIN crm_case_section ON ((crm_lead.section_id = crm_case_section.id)))
  WHERE (crm_lead.active = true)
  ORDER BY view_cjpl_user_name.name, crm_case_stage.name;
 ALTER TABLE view_cjpl_opportunity OWNER TO postgres;
 GRANT ALL ON view_cjpl_opportunity TO postgres;
 GRANT SELECT ON view_cjpl_opportunity TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_order_basic AS 
 SELECT view_cjpl_user_name.name AS salesperson,
    crm_case_section.name AS team_name,
    sale_order.id,
    sale_order.origin,
    ("substring"((sale_order.origin)::text, ("position"((sale_order.origin)::text, ':'::text) + 1)))::integer AS opportunity_id,
    date(sale_order.create_date) AS create_date,
    sale_order.client_order_ref,
    sale_order.name AS so_number,
    date(sale_order.date_order) AS order_date,
    sale_order.state AS so_state,
    sale_order.project_id,
        CASE
            WHEN (sale_order.project_id IS NULL) THEN 'No Contract'::text
            ELSE 'Contract'::text
        END AS contract_status,
    sale_order.amount_tax,
    sale_order.amount_untaxed,
    sale_order.amount_total,
    sale_order.payment_term,
    sale_order.note,
    sale_order.date_confirm,
    sale_order.order_policy,
    sale_order.picking_policy,
    sale_order.shipped,
    sale_order.x_coordinator_approve,
    sale_order.x_road_permit,
    sale_order.margin,
    date(sale_order.x_rental_start_date) AS rental_start_date,
    date(sale_order.x_rental_end_date) AS rental_end_date,
    sale_order.x_minimum_contract_period,
    sale_order.x_recur_inv,
    sale_order_type.name AS order_type,
    sale_order.partner_id,
    res_partner.name AS order_party_name,
    res_partner.street,
    res_partner.city,
    res_partner.display_name
   FROM ((((sale_order
     JOIN sale_order_type ON ((sale_order.type_id = sale_order_type.id)))
     JOIN res_partner ON ((sale_order.partner_id = res_partner.id)))
     JOIN view_cjpl_user_name ON ((sale_order.user_id = view_cjpl_user_name.id)))
     JOIN crm_case_section ON ((sale_order.section_id = crm_case_section.id)))
  ORDER BY view_cjpl_user_name.name, sale_order.date_order, sale_order.name;
 ALTER TABLE view_cjpl_order_basic OWNER TO postgres;
 GRANT ALL ON view_cjpl_order_basic TO postgres;
 GRANT SELECT ON view_cjpl_order_basic TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_opportunity_sale_order AS 
 SELECT a.salesperson,
    a.opportunity_id,
    b.opportunity_id AS order_opportunity_id,
    a.create_date,
    a.contact_name,
    a.partner_name,
    a.team_name,
    a.name,
    a.stage,
    a.planned_revenue,
    b.client_order_ref,
    b.so_number,
    b.order_date,
    b.so_state,
    b.contract_status,
    b.amount_tax,
    b.amount_untaxed,
    b.amount_total,
    b.date_confirm,
    b.rental_start_date,
    b.rental_end_date,
    b.order_type,
    b.order_party_name
   FROM (view_cjpl_opportunity a
     LEFT JOIN view_cjpl_order_basic b ON ((a.opportunity_id = b.opportunity_id)))
  ORDER BY a.salesperson, a.create_date;
 ALTER TABLE view_cjpl_opportunity_sale_order OWNER TO postgres;
 GRANT ALL ON view_cjpl_opportunity_sale_order TO postgres;
 GRANT SELECT ON view_cjpl_opportunity_sale_order TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_xxx_invoice_list_all AS 
 SELECT a.number AS invoice_number,
    a.id AS invoice_id,
    a.internal_number,
    a.date_invoice,
    date(a.create_date) AS date_invoice_created,
    b.company_name AS customer,
    b.x_core_code AS core_code,
    a.amount_untaxed,
    a.amount_tax,
    a.amount_total,
    date(a.x_bill_period_from) AS bill_period_from,
    date(a.x_bill_period_to) AS bill_period_to,
    a.x_po_ref AS po_ref,
    a.journal_id
   FROM (account_invoice a
     LEFT JOIN view_cjpl_partner_all_companies b ON ((a.partner_id = b.id)));
 ALTER TABLE view_cjpl_xxx_invoice_list_all OWNER TO postgres;
 GRANT ALL ON view_cjpl_xxx_invoice_list_all TO postgres;
 GRANT SELECT ON view_cjpl_xxx_invoice_list_all TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_invoice_list_final AS 
 SELECT b.invoice_id,
    a.so_number,
    a.date_order,
    b.core_code,
    b.customer,
    b.po_ref,
    a.contract_number,
    a.sale_type,
    b.invoice_number,
    b.internal_number,
    b.date_invoice,
    b.date_invoice_created,
    b.amount_untaxed,
    b.amount_tax,
    b.amount_total,
    b.bill_period_from,
    b.bill_period_to,
    a.invoice_type,
    a.invoice_status,
    a.journal_name
   FROM (view_cjpl_xxx_invoice_list_all b
     JOIN view_cjpl_invoice_sale_typology a ON ((b.invoice_id = a.invoice_id)));
 ALTER TABLE view_cjpl_invoice_list_final OWNER TO postgres;
 GRANT ALL ON view_cjpl_invoice_list_final TO postgres;
 GRANT SELECT ON view_cjpl_invoice_list_final TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_sale_orders_invoice_created_no_invoice_number AS 
 SELECT a.salesperson,
    a.team_name,
    a.so_number,
    a.id,
    a.order_date,
    a.order_party_name,
    a.so_state,
    a.contract_status
   FROM view_cjpl_order_basic a
  WHERE (a.id IN ( SELECT b.so_id
           FROM view_cjpl_invoice_sale_typology b
          WHERE ((b.so_id IS NOT NULL) AND (b.invoice_number IS NULL))))
  ORDER BY a.so_number;
 ALTER TABLE view_cjpl_sale_orders_invoice_created_no_invoice_number OWNER TO postgres;
 GRANT ALL ON view_cjpl_sale_orders_invoice_created_no_invoice_number TO postgres;
 GRANT SELECT ON view_cjpl_sale_orders_invoice_created_no_invoice_number TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_sale_orders_with_no_invoices_created AS 
 SELECT a.salesperson,
    a.team_name,
    a.so_number,
    a.id,
    a.order_date,
    a.order_party_name,
    a.so_state,
    a.contract_status
   FROM view_cjpl_order_basic a
  WHERE (NOT (a.id IN ( SELECT b.so_id
           FROM view_cjpl_invoice_sale_typology b
          WHERE (b.so_id IS NOT NULL))))
  ORDER BY a.so_number;
 ALTER TABLE view_cjpl_sale_orders_with_no_invoices_created OWNER TO postgres;
 GRANT ALL ON view_cjpl_sale_orders_with_no_invoices_created TO postgres;
 GRANT SELECT ON view_cjpl_sale_orders_with_no_invoices_created TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_invoice_list_new AS 
 SELECT a.number AS invoice_number,
    a.date_invoice,
    a.amount_untaxed,
    a.amount_tax,
    a.amount_total,
    date(a.x_bill_period_from) AS bill_period_from,
    date(a.x_bill_period_to) AS bill_period_to,
    a.x_po_ref AS po_ref,
    b.company_name AS customer,
    b.x_core_code AS core_code,
    a.journal_id
   FROM (account_invoice a
     LEFT JOIN view_cjpl_partner_all_companies b ON ((a.partner_id = b.id)))
  WHERE (((a.state)::text <> 'draft'::text) AND ((a.state)::text <> 'cancel'::text))
  ORDER BY a.journal_id, a.date_invoice, a.number;
 ALTER TABLE view_cjpl_invoice_list_new OWNER TO postgres;
 GRANT ALL ON view_cjpl_invoice_list_new TO postgres;
 GRANT SELECT ON view_cjpl_invoice_list_new TO joomla;

-- ------------------------------------------------------------
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
   FROM ((account_invoice a
     JOIN view_cjpl_partner_all_companies b ON ((a.partner_id = b.id)))
     JOIN view_cjpl_invoice_sale_typology c ON ((a.id = c.invoice_id)))
  WHERE (a.number IS NOT NULL)
  ORDER BY a.number;
 ALTER TABLE view_cjpl_xxx_invoice_for_tally_1 OWNER TO postgres;
 GRANT ALL ON view_cjpl_xxx_invoice_for_tally_1 TO postgres;
 GRANT SELECT ON view_cjpl_xxx_invoice_for_tally_1 TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_xxx_invoice_for_tally_2 AS 
 SELECT t.invoice_id,
    max((
        CASE
            WHEN (t."row" = 1) THEN t.name
            ELSE NULL::character varying
        END)::text) AS a_tax_type,
    max(
        CASE
            WHEN (t."row" = 1) THEN t.base
            ELSE NULL::numeric
        END) AS a_base_amount,
    max(
        CASE
            WHEN (t."row" = 1) THEN t.tax_amount
            ELSE NULL::numeric
        END) AS a_tax_amount,
    max((
        CASE
            WHEN (t."row" = 2) THEN t.name
            ELSE NULL::character varying
        END)::text) AS b_tax_type,
    max(
        CASE
            WHEN (t."row" = 2) THEN t.base
            ELSE NULL::numeric
        END) AS b_base_amount,
    max(
        CASE
            WHEN (t."row" = 2) THEN t.tax_amount
            ELSE NULL::numeric
        END) AS b_tax_amount,
    max((
        CASE
            WHEN (t."row" = 3) THEN t.name
            ELSE NULL::character varying
        END)::text) AS c_tax_type,
    max(
        CASE
            WHEN (t."row" = 3) THEN t.base
            ELSE NULL::numeric
        END) AS c_base_amount,
    max(
        CASE
            WHEN (t."row" = 3) THEN t.tax_amount
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
 ALTER TABLE view_cjpl_xxx_invoice_for_tally_2 OWNER TO postgres;
 GRANT ALL ON view_cjpl_xxx_invoice_for_tally_2 TO postgres;
 GRANT SELECT ON view_cjpl_xxx_invoice_for_tally_2 TO joomla;

-- ------------------------------------------------------------
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
   FROM (view_cjpl_xxx_invoice_for_tally_1 a
     LEFT JOIN view_cjpl_xxx_invoice_for_tally_2 b ON ((a.id = b.invoice_id)))
  ORDER BY a.number;
 ALTER TABLE view_cjpl_xxx_invoice_for_tally_3 OWNER TO postgres;
 GRANT ALL ON view_cjpl_xxx_invoice_for_tally_3 TO postgres;
 GRANT SELECT ON view_cjpl_xxx_invoice_for_tally_3 TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_xxx_partners_transaction_dates AS 
 SELECT b.id,
    b.company_partner_name,
    b.company_name,
    c.min_order_date,
    c.max_order_date,
    c.order_count,
    e.min_lead_date,
    e.max_lead_date,
    e.lead_count,
    g.min_invoice_date,
    g.max_invoice_date,
    g.invoice_count
   FROM (((view_cjpl_partner_all_companies b
     LEFT JOIN ( SELECT a.partner_id,
            min(date(a.create_date)) AS min_order_date,
            max(date(a.create_date)) AS max_order_date,
            count(*) AS order_count
           FROM sale_order a
          WHERE ((a.state)::text <> 'cancel'::text)
          GROUP BY a.partner_id) c ON ((b.id = c.partner_id)))
     LEFT JOIN ( SELECT d.partner_id,
            min(date(d.create_date)) AS min_lead_date,
            max(date(d.create_date)) AS max_lead_date,
            count(*) AS lead_count
           FROM crm_lead d
          GROUP BY d.partner_id) e ON ((b.id = e.partner_id)))
     LEFT JOIN ( SELECT f.partner_id,
            min(f.date_invoice) AS min_invoice_date,
            max(f.date_invoice) AS max_invoice_date,
            count(*) AS invoice_count
           FROM account_invoice f
          WHERE ((f.number IS NOT NULL) AND ((f.state)::text = 'open'::text))
          GROUP BY f.partner_id) g ON ((b.id = g.partner_id)))
  ORDER BY b.company_name;
 ALTER TABLE view_cjpl_xxx_partners_transaction_dates OWNER TO postgres;
 GRANT ALL ON view_cjpl_xxx_partners_transaction_dates TO postgres;
 GRANT SELECT ON view_cjpl_xxx_partners_transaction_dates TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_partners_transaction_dates AS 
 SELECT a.id,
    a.company_partner_name,
    a.company_name,
    a.min_order_date,
    a.max_order_date,
    a.order_count,
    a.min_lead_date,
    a.max_lead_date,
    a.lead_count,
    a.min_invoice_date,
    a.max_invoice_date,
    a.invoice_count,
    LEAST(a.min_order_date, a.min_lead_date, a.min_invoice_date) AS min_trans_date,
    GREATEST(a.max_order_date, a.max_lead_date, a.max_invoice_date) AS max_trans_date
   FROM view_cjpl_xxx_partners_transaction_dates a
  WHERE (((a.order_count + a.lead_count) + a.invoice_count) > 0)
  ORDER BY a.company_name;
 ALTER TABLE view_cjpl_partners_transaction_dates OWNER TO postgres;
 GRANT ALL ON view_cjpl_partners_transaction_dates TO postgres;
 GRANT SELECT ON view_cjpl_partners_transaction_dates TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_invoice_line_base_tax AS 
 SELECT DISTINCT g.id,
    g.partner_id,
    g.commercial_partner_id,
    g.number AS print_number,
    g.internal_number,
    g.date_invoice,
    g.state AS status,
    g.origin AS so_number,
    g.amount_untaxed AS invoice_amount_wo_tax,
    g.amount_tax AS invoice_tax,
    g.amount_total AS invoice_amount_total,
    g.x_bill_period_from,
    g.x_bill_period_to,
    g.journal_id AS line_journal_id,
    i.account_id,
    i.invoice_id AS invoice_id_line,
    i.base_code_id AS line_base_code,
    i.name AS tax_name,
    i.base_amount AS line_base_amount,
    i.tax_amount AS line_tax_amount
   FROM (account_invoice g
     JOIN account_invoice_tax i ON ((g.id = i.invoice_id)));
 ALTER TABLE view_cjpl_invoice_line_base_tax OWNER TO postgres;
 GRANT ALL ON view_cjpl_invoice_line_base_tax TO postgres;
 GRANT SELECT ON view_cjpl_invoice_line_base_tax TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_invoice_list AS 
 SELECT account_invoice.number AS invoice_number,
    account_invoice.date_invoice,
    account_invoice.amount_untaxed,
    account_invoice.amount_tax,
    account_invoice.amount_total,
    date(account_invoice.x_bill_period_from) AS bill_period_from,
    date(account_invoice.x_bill_period_to) AS bill_period_to,
    account_invoice.x_po_ref AS po_ref,
    res_partner.name AS customer,
    res_partner.x_core_code AS core_code,
    account_invoice.journal_id
   FROM (account_invoice
     JOIN res_partner ON ((account_invoice.partner_id = res_partner.id)))
  WHERE (((account_invoice.state)::text <> 'draft'::text) AND ((account_invoice.state)::text <> 'cancel'::text))
  ORDER BY account_invoice.journal_id, account_invoice.date_invoice, account_invoice.number;
 ALTER TABLE view_cjpl_invoice_list OWNER TO postgres;
 GRANT ALL ON view_cjpl_invoice_list TO postgres;
 GRANT SELECT ON view_cjpl_invoice_list TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_team_name AS 
 SELECT crm_case_section.id AS section_id,
    crm_case_section.complete_name AS team_name,
    crm_case_section.user_id AS manager_id
   FROM crm_case_section
  ORDER BY crm_case_section.id;
 ALTER TABLE view_cjpl_team_name OWNER TO postgres;
 GRANT ALL ON view_cjpl_team_name TO postgres;
 GRANT SELECT ON view_cjpl_team_name TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_cjpl_xxx_partner_not_company_no_parent_company AS 
 SELECT a.id,
    a.name AS company_partner_name,
    c.name AS company_name,
    a.x_core_code,
    a.parent_id,
    a.is_company
   FROM (res_partner a
     LEFT JOIN res_partner c ON ((a.parent_id = c.id)))
  WHERE (((NOT a.is_company) AND (a.parent_id IS NOT NULL)) AND (NOT (a.parent_id IN ( SELECT b.id
           FROM view_cjpl_xxx_partner_is_a_company b))));
 ALTER TABLE view_cjpl_xxx_partner_not_company_no_parent_company OWNER TO postgres;
 GRANT ALL ON view_cjpl_xxx_partner_not_company_no_parent_company TO postgres;
 GRANT SELECT ON view_cjpl_xxx_partner_not_company_no_parent_company TO joomla;

