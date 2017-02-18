/*
Navicat PGSQL Data Transfer

Source Server         : odoo
Source Server Version : 90310
Source Host           : 10.0.0.115:5432
Source Database       : cjpl-prod
Source Schema         : odoo-views

Target Server Type    : PGSQL
Target Server Version : 90310
File Encoding         : 65001

Date: 2016-02-06 18:48:43
*/


-- ----------------------------
-- View structure for view_cjpl_contract_to_invoice_sale_type
-- ----------------------------
CREATE OR REPLACE VIEW "odoo-views"."view_cjpl_contract_to_invoice_sale_type" AS 
 SELECT date(sale_order.date_order) AS date_order,
    sale_order.name AS so_number,
    account_invoice.number AS invoice_number,
    account_invoice.date_invoice,
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

-- ----------------------------
-- View structure for view_cjpl_invoice_list
-- ----------------------------
CREATE OR REPLACE VIEW "odoo-views"."view_cjpl_invoice_list" AS 
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

-- ----------------------------
-- View structure for view_cjpl_invoice_sale_type
-- ----------------------------
CREATE OR REPLACE VIEW "odoo-views"."view_cjpl_invoice_sale_type" AS 
 SELECT view_cjpl_order_to_invoice_sale_type.date_order,
    view_cjpl_order_to_invoice_sale_type.so_number,
    view_cjpl_order_to_invoice_sale_type.invoice_number,
    view_cjpl_order_to_invoice_sale_type.date_invoice,
    view_cjpl_order_to_invoice_sale_type.sale_type,
    view_cjpl_order_to_invoice_sale_type.invoice_type
   FROM "odoo-views".view_cjpl_order_to_invoice_sale_type
UNION ALL
 SELECT view_cjpl_contract_to_invoice_sale_type.date_order,
    view_cjpl_contract_to_invoice_sale_type.so_number,
    view_cjpl_contract_to_invoice_sale_type.invoice_number,
    view_cjpl_contract_to_invoice_sale_type.date_invoice,
    view_cjpl_contract_to_invoice_sale_type.sale_type,
    view_cjpl_contract_to_invoice_sale_type.invoice_type
   FROM "odoo-views".view_cjpl_contract_to_invoice_sale_type;

-- ----------------------------
-- View structure for view_cjpl_opportunity
-- ----------------------------
CREATE OR REPLACE VIEW "odoo-views"."view_cjpl_opportunity" AS 
 SELECT view_cjpl_user_name.name AS salesperson,
    crm_lead.id AS opportunity_id,
    date(crm_lead.date_closed) AS date_closed,
    date(crm_lead.create_date) AS create_date,
    crm_lead.date_deadline,
    date(crm_lead.date_last_stage_update) AS date_last_stage_update,
    crm_lead.day_close,
    crm_lead.active,
    crm_lead.day_open,
    crm_lead.contact_name,
    crm_lead.partner_id,
    crm_lead.city,
    crm_lead.user_id,
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
     JOIN "odoo-views".view_cjpl_user_name ON ((crm_lead.user_id = view_cjpl_user_name.id)))
     JOIN res_country_state ON ((crm_lead.state_id = res_country_state.id)))
     JOIN crm_case_section ON ((crm_lead.section_id = crm_case_section.id)))
  WHERE (crm_lead.active = true)
  ORDER BY view_cjpl_user_name.name, crm_case_stage.name;

-- ----------------------------
-- View structure for view_cjpl_opportunity_sale_order
-- ----------------------------
CREATE OR REPLACE VIEW "odoo-views"."view_cjpl_opportunity_sale_order" AS 
 SELECT view_cjpl_opportunity.salesperson,
    view_cjpl_opportunity.opportunity_id,
    view_cjpl_order_basic.opportunity_id AS order_opportunity_id,
    view_cjpl_opportunity.create_date,
    view_cjpl_opportunity.contact_name,
    view_cjpl_opportunity.partner_name,
    view_cjpl_opportunity.team_name,
    view_cjpl_opportunity.name,
    view_cjpl_opportunity.stage,
    view_cjpl_opportunity.planned_revenue,
    view_cjpl_order_basic.client_order_ref,
    view_cjpl_order_basic.so_number,
    view_cjpl_order_basic.order_date,
    view_cjpl_order_basic.so_state,
    view_cjpl_order_basic.contract_status,
    view_cjpl_order_basic.amount_tax,
    view_cjpl_order_basic.amount_untaxed,
    view_cjpl_order_basic.amount_total,
    view_cjpl_order_basic.date_confirm,
    view_cjpl_order_basic.rental_start_date,
    view_cjpl_order_basic.rental_end_date,
    view_cjpl_order_basic.order_type,
    view_cjpl_order_basic.order_party_name
   FROM ("odoo-views".view_cjpl_opportunity
     LEFT JOIN "odoo-views".view_cjpl_order_basic ON ((view_cjpl_opportunity.opportunity_id = view_cjpl_order_basic.opportunity_id)))
  ORDER BY view_cjpl_opportunity.salesperson, view_cjpl_opportunity.create_date;

-- ----------------------------
-- View structure for view_cjpl_order_basic
-- ----------------------------
CREATE OR REPLACE VIEW "odoo-views"."view_cjpl_order_basic" AS 
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
     JOIN "odoo-views".view_cjpl_user_name ON ((sale_order.user_id = view_cjpl_user_name.id)))
     JOIN crm_case_section ON ((sale_order.section_id = crm_case_section.id)))
  ORDER BY view_cjpl_user_name.name, sale_order.date_order, sale_order.name;

-- ----------------------------
-- View structure for view_cjpl_order_to_invoice_sale_type
-- ----------------------------
CREATE OR REPLACE VIEW "odoo-views"."view_cjpl_order_to_invoice_sale_type" AS 
 SELECT date(sale_order.date_order) AS date_order,
    sale_order.name AS so_number,
    account_invoice.number AS invoice_number,
    account_invoice.date_invoice,
    sale_order_type.name AS sale_type,
    quote_literal('SaleOrder'::text) AS invoice_type
   FROM (((sale_order
     JOIN sale_order_invoice_rel ON ((sale_order_invoice_rel.order_id = sale_order.id)))
     JOIN account_invoice ON ((sale_order_invoice_rel.invoice_id = account_invoice.id)))
     JOIN sale_order_type ON ((sale_order.type_id = sale_order_type.id)))
  WHERE (account_invoice.number IS NOT NULL);

-- ----------------------------
-- View structure for view_cjpl_order_to_invoice_sale_type_old
-- ----------------------------
CREATE OR REPLACE VIEW "odoo-views"."view_cjpl_order_to_invoice_sale_type_old" AS 
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

-- ----------------------------
-- View structure for view_cjpl_user_name
-- ----------------------------
CREATE OR REPLACE VIEW "odoo-views"."view_cjpl_user_name" AS 
 SELECT res_users.id,
    res_users.partner_id,
    res_users.active,
    res_users.login,
    res_partner.name,
    res_users.login_date,
    res_users.x_designation
   FROM (res_users
     JOIN res_partner ON ((res_users.partner_id = res_partner.id)));

-- ----------------------------
-- Alter Sequences Owned By 
-- ----------------------------
