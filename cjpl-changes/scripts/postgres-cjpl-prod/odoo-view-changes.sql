sudo -u postgres psql template1
#template1
CREATE USER joomla WITH PASSWORD 'joomla';
GRANT ALL PRIVELEGES ON DATABASE "cjpl-prod" TO joomla;
\q
sudo -u postgres psql cjpl-prod
#cjpl-prod
DROP SCHEMA "odoo-views" cascade;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
   GRANT SELECT ON TABLES TO joomla;

-- ##################################################################   
--   view_cjpl_user_name
-- ##################################################################   
CREATE OR REPLACE VIEW view_cjpl_user_name AS 
 SELECT res_users.id,
    res_users.partner_id,
    res_users.active,
    res_users.login,
    res_partner.name,
    res_users.login_date,
    res_users.x_designation
   FROM res_users
     JOIN res_partner ON res_users.partner_id = res_partner.id;

ALTER TABLE view_cjpl_user_name
  OWNER TO postgres;
GRANT ALL ON TABLE view_cjpl_user_name TO postgres;
GRANT SELECT ON TABLE view_cjpl_user_name TO joomla;

-- ##################################################################   
-- view_cjpl_opportunity
-- ##################################################################   
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
    lpad(substr(crm_lead.ref::text, "position"(crm_lead.ref::text, ','::text) + 1), 4, '0'::text) AS so_number,
    'SO'::text || lpad(substr(crm_lead.ref::text, "position"(crm_lead.ref::text, ','::text) + 1), 3, '0'::text) AS so_number_full,
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
   FROM crm_lead
     JOIN crm_case_stage ON crm_lead.stage_id = crm_case_stage.id
     JOIN view_cjpl_user_name ON crm_lead.user_id = view_cjpl_user_name.id
     JOIN res_country_state ON crm_lead.state_id = res_country_state.id
     JOIN crm_case_section ON crm_lead.section_id = crm_case_section.id
  WHERE crm_lead.active = true
  ORDER BY view_cjpl_user_name.name, crm_case_stage.name;

ALTER TABLE view_cjpl_opportunity
  OWNER TO postgres;
GRANT ALL ON TABLE view_cjpl_opportunity  TO postgres;
GRANT SELECT ON TABLE view_cjpl_opportunity  TO joomla;

-- ##################################################################   
-- view_cjpl_contract_to_invoice_sale_type
-- ##################################################################   
CREATE OR REPLACE VIEW view_cjpl_contract_to_invoice_sale_type AS 
 SELECT date(sale_order.date_order) AS date_order,
    sale_order.name AS so_number,
    sale_order.id AS so_id,
    account_invoice.number AS invoice_number,
    account_invoice.id AS invoice_id,
    account_invoice.date_invoice,
    account_analytic_account.name AS contract_number,
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
     LEFT JOIN sale_order_type ON sale_order.type_id = sale_order_type.id
  WHERE account_invoice.number IS NOT NULL;
  
ALTER TABLE view_cjpl_contract_to_invoice_sale_type
  OWNER TO postgres;
GRANT ALL ON TABLE view_cjpl_contract_to_invoice_sale_type   TO postgres;
GRANT SELECT ON TABLE view_cjpl_contract_to_invoice_sale_type  TO joomla;

-- ##################################################################   
-- view_cjpl_order_to_invoice_sale_type
-- ##################################################################   
CREATE OR REPLACE VIEW view_cjpl_order_to_invoice_sale_type AS 
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

ALTER TABLE view_cjpl_order_to_invoice_sale_type
  OWNER TO postgres;
GRANT ALL ON TABLE view_cjpl_order_to_invoice_sale_type   TO postgres;
GRANT SELECT ON TABLE view_cjpl_order_to_invoice_sale_type   TO joomla;

-- ##################################################################   
-- view_cjpl_invoice_sale_type
-- ##################################################################   
CREATE OR REPLACE VIEW view_cjpl_invoice_sale_type AS 
 SELECT a.date_order,
    a.so_number,
    a.so_id,
    a.invoice_number,
    a.invoice_id,
    a.date_invoice,
    a.contract_number,
    a.contract_id,
    a.sale_type,
    a.invoice_type
   FROM view_cjpl_order_to_invoice_sale_type a
UNION ALL
 SELECT b.date_order,
    b.so_number,
    b.so_id,
    b.invoice_number,
    b.invoice_id,
    b.date_invoice,
    b.contract_number,
    b.contract_id,
    b.sale_type,
    b.invoice_type
   FROM view_cjpl_contract_to_invoice_sale_type b;

ALTER TABLE view_cjpl_invoice_sale_type
  OWNER TO postgres;
GRANT ALL ON TABLE view_cjpl_invoice_sale_type TO postgres;
GRANT SELECT ON TABLE view_cjpl_invoice_sale_type   TO joomla;

-- ##################################################################   
-- view_cjpl_invoice_list
-- ##################################################################   
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
   FROM account_invoice
     JOIN res_partner ON account_invoice.partner_id = res_partner.id
  WHERE account_invoice.state::text <> 'draft'::text AND account_invoice.state::text <> 'cancel'::text
  ORDER BY account_invoice.journal_id, account_invoice.date_invoice, account_invoice.number;

ALTER TABLE view_cjpl_invoice_list
  OWNER TO postgres;
GRANT ALL ON TABLE view_cjpl_invoice_list  TO postgres;
GRANT SELECT ON TABLE view_cjpl_invoice_list   TO joomla;

-- ##################################################################   
-- view_cjpl_order_basic
-- ##################################################################   
CREATE OR REPLACE VIEW view_cjpl_order_basic AS 
 SELECT view_cjpl_user_name.name AS salesperson,
    crm_case_section.name AS team_name,
    sale_order.id,
    sale_order.origin,
    "substring"(sale_order.origin::text, "position"(sale_order.origin::text, ':'::text) + 1)::integer AS opportunity_id,
    date(sale_order.create_date) AS create_date,
    sale_order.client_order_ref,
    sale_order.name AS so_number,
    date(sale_order.date_order) AS order_date,
    sale_order.state AS so_state,
    sale_order.project_id,
        CASE
            WHEN sale_order.project_id IS NULL THEN 'No Contract'::text
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
   FROM sale_order
     JOIN sale_order_type ON sale_order.type_id = sale_order_type.id
     JOIN res_partner ON sale_order.partner_id = res_partner.id
     JOIN view_cjpl_user_name ON sale_order.user_id = view_cjpl_user_name.id
     JOIN crm_case_section ON sale_order.section_id = crm_case_section.id
  ORDER BY view_cjpl_user_name.name, sale_order.date_order, sale_order.name;

ALTER TABLE view_cjpl_order_basic
  OWNER TO postgres;
GRANT ALL ON TABLE view_cjpl_order_basic TO postgres;
GRANT SELECT ON TABLE view_cjpl_order_basic TO joomla;

-- ##################################################################   
-- view_cjpl_opportunity_sale_order
-- ##################################################################   
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
   FROM view_cjpl_opportunity a
     LEFT JOIN view_cjpl_order_basic b ON a.opportunity_id = b.opportunity_id
  ORDER BY a.salesperson, a.create_date;

ALTER TABLE view_cjpl_opportunity_sale_order
  OWNER TO postgres;
GRANT ALL ON TABLE view_cjpl_opportunity_sale_order  TO postgres;
GRANT SELECT ON TABLE view_cjpl_opportunity_sale_order TO joomla;

-- ##################################################################   
-- view_cjpl_sale_orders_with_no_invoices
-- ##################################################################   
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

-- ##################################################################   
-- view_cjpl_contract_basic;
-- ##################################################################   
CREATE OR REPLACE VIEW view_cjpl_contract_basic AS 
 SELECT account_analytic_account.name AS contract_number,
    account_analytic_account.id,
    account_analytic_account.code,
    account_analytic_account.state,
    account_analytic_account.type,
    account_analytic_account.date,
    res_partner.display_name AS partner_name,
    view_cjpl_user_name.name AS salesperson,
    account_journal.name AS sale_journal,
    account_analytic_account.x_kind_attn AS kind_attn,
    account_analytic_account.x_po_ref AS po_ref,
    account_analytic_account.recurring_invoices,
    account_analytic_account.recurring_next_date
   FROM account_analytic_account,
    res_partner,
    view_cjpl_user_name,
    account_journal
  WHERE account_analytic_account.partner_id = res_partner.id AND account_analytic_account.user_id = view_cjpl_user_name.id AND account_journal.id = account_analytic_account.journal_id;

ALTER TABLE view_cjpl_contract_basic
  OWNER TO odoo;
GRANT ALL ON TABLE view_cjpl_contract_basic TO odoo;
GRANT SELECT ON TABLE view_cjpl_contract_basic TO joomla;
