/*
Navicat PGSQL Data Transfer

Source Server         : odoo
Source Server Version : 90310
Source Host           : 192.168.1.6:5432
Source Database       : cjpl-prod
Source Schema         : public

Target Server Type    : PGSQL
Target Server Version : 90310
File Encoding         : 65001

Date: 2016-02-01 17:27:58
*/


-- ----------------------------
-- Table structure for account_analytic_account
-- ----------------------------
DROP TABLE IF EXISTS "public"."account_analytic_account";
CREATE TABLE "public"."account_analytic_account" (
"id" int4 DEFAULT nextval('account_analytic_account_id_seq'::regclass) NOT NULL,
"code" varchar COLLATE "default",
"create_date" timestamp(6),
"quantity_max" float8,
"write_uid" int4,
"currency_id" int4,
"partner_id" int4,
"create_uid" int4,
"user_id" int4,
"date_start" date,
"message_last_post" timestamp(6),
"company_id" int4,
"parent_id" int4,
"state" varchar COLLATE "default" NOT NULL,
"manager_id" int4,
"type" varchar COLLATE "default" NOT NULL,
"description" text COLLATE "default",
"write_date" timestamp(6),
"date" date,
"name" varchar COLLATE "default" NOT NULL,
"template_id" int4,
"use_timesheets" bool,
"amount_max" float8,
"pricelist_id" int4,
"to_invoice" int4,
"is_overdue_quantity" bool,
"hours_qtt_est" float8,
"recurring_next_date" date,
"fix_price_invoices" bool,
"invoice_on_timesheets" bool,
"recurring_invoices" bool,
"recurring_interval" int4,
"recurring_rule_type" varchar COLLATE "default",
"use_tasks" bool,
"journal_id" int4,
"use_issues" bool,
"x_kind_attn" varchar COLLATE "default",
"x_po_ref" varchar COLLATE "default",
"x_saleorder_upload" varchar COLLATE "default",
"x_contract_invoiceline" varchar COLLATE "default",
"x_saleorder_number" varchar COLLATE "default"
)
WITH (OIDS=FALSE)

;
COMMENT ON TABLE "public"."account_analytic_account" IS 'Analytic Account';
COMMENT ON COLUMN "public"."account_analytic_account"."code" IS 'Reference';
COMMENT ON COLUMN "public"."account_analytic_account"."create_date" IS 'Created on';
COMMENT ON COLUMN "public"."account_analytic_account"."quantity_max" IS 'Prepaid Service Units';
COMMENT ON COLUMN "public"."account_analytic_account"."write_uid" IS 'Last Updated by';
COMMENT ON COLUMN "public"."account_analytic_account"."currency_id" IS 'Currency';
COMMENT ON COLUMN "public"."account_analytic_account"."partner_id" IS 'Customer';
COMMENT ON COLUMN "public"."account_analytic_account"."create_uid" IS 'Created by';
COMMENT ON COLUMN "public"."account_analytic_account"."user_id" IS 'Project Manager';
COMMENT ON COLUMN "public"."account_analytic_account"."date_start" IS 'Start Date';
COMMENT ON COLUMN "public"."account_analytic_account"."message_last_post" IS 'Last Message Date';
COMMENT ON COLUMN "public"."account_analytic_account"."company_id" IS 'Company';
COMMENT ON COLUMN "public"."account_analytic_account"."parent_id" IS 'Parent Analytic Account';
COMMENT ON COLUMN "public"."account_analytic_account"."state" IS 'Status';
COMMENT ON COLUMN "public"."account_analytic_account"."manager_id" IS 'Account Manager';
COMMENT ON COLUMN "public"."account_analytic_account"."type" IS 'Type of Account';
COMMENT ON COLUMN "public"."account_analytic_account"."description" IS 'Description';
COMMENT ON COLUMN "public"."account_analytic_account"."write_date" IS 'Last Updated on';
COMMENT ON COLUMN "public"."account_analytic_account"."date" IS 'Expiration Date';
COMMENT ON COLUMN "public"."account_analytic_account"."name" IS 'Account/Contract Name';
COMMENT ON COLUMN "public"."account_analytic_account"."template_id" IS 'Template of Contract';
COMMENT ON COLUMN "public"."account_analytic_account"."use_timesheets" IS 'Timesheets';
COMMENT ON COLUMN "public"."account_analytic_account"."amount_max" IS 'Max. Invoice Price';
COMMENT ON COLUMN "public"."account_analytic_account"."pricelist_id" IS 'Pricelist';
COMMENT ON COLUMN "public"."account_analytic_account"."to_invoice" IS 'Timesheet Invoicing Ratio';
COMMENT ON COLUMN "public"."account_analytic_account"."is_overdue_quantity" IS 'Overdue Quantity';
COMMENT ON COLUMN "public"."account_analytic_account"."hours_qtt_est" IS 'Estimation of Hours to Invoice';
COMMENT ON COLUMN "public"."account_analytic_account"."recurring_next_date" IS 'Date of Next Invoice';
COMMENT ON COLUMN "public"."account_analytic_account"."fix_price_invoices" IS 'Fixed Price';
COMMENT ON COLUMN "public"."account_analytic_account"."invoice_on_timesheets" IS 'On Timesheets';
COMMENT ON COLUMN "public"."account_analytic_account"."recurring_invoices" IS 'Generate recurring invoices automatically';
COMMENT ON COLUMN "public"."account_analytic_account"."recurring_interval" IS 'Repeat Every';
COMMENT ON COLUMN "public"."account_analytic_account"."recurring_rule_type" IS 'Recurrency';
COMMENT ON COLUMN "public"."account_analytic_account"."use_tasks" IS 'Tasks';
COMMENT ON COLUMN "public"."account_analytic_account"."journal_id" IS 'Journal';
COMMENT ON COLUMN "public"."account_analytic_account"."use_issues" IS 'Issues';
COMMENT ON COLUMN "public"."account_analytic_account"."x_kind_attn" IS 'Contact (Kind Attn:)';
COMMENT ON COLUMN "public"."account_analytic_account"."x_po_ref" IS 'P.O. Number';
COMMENT ON COLUMN "public"."account_analytic_account"."x_saleorder_upload" IS 'SaleOrder Line Upload Template';
COMMENT ON COLUMN "public"."account_analytic_account"."x_contract_invoiceline" IS 'Contract Sale Order Link';
COMMENT ON COLUMN "public"."account_analytic_account"."x_saleorder_number" IS 'Confirm Sale Order Number';

-- ----------------------------
-- Alter Sequences Owned By 
-- ----------------------------

-- ----------------------------
-- Indexes structure for table account_analytic_account
-- ----------------------------
CREATE INDEX "account_analytic_account_code_index" ON "public"."account_analytic_account" USING btree ("code");
CREATE INDEX "account_analytic_account_date_index" ON "public"."account_analytic_account" USING btree ("date");
CREATE INDEX "account_analytic_account_parent_id_index" ON "public"."account_analytic_account" USING btree ("parent_id");

-- ----------------------------
-- Triggers structure for table account_analytic_account
-- ----------------------------
CREATE TRIGGER "Contract Update from Sales order" AFTER INSERT OR UPDATE OF "x_saleorder_number" ON "public"."account_analytic_account"
FOR EACH ROW
EXECUTE PROCEDURE "so_contract_transfer3"();

-- ----------------------------
-- Primary Key structure for table account_analytic_account
-- ----------------------------
ALTER TABLE "public"."account_analytic_account" ADD PRIMARY KEY ("id");

-- ----------------------------
-- Foreign Key structure for table "public"."account_analytic_account"
-- ----------------------------
ALTER TABLE "public"."account_analytic_account" ADD FOREIGN KEY ("parent_id") REFERENCES "public"."account_analytic_account" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."account_analytic_account" ADD FOREIGN KEY ("to_invoice") REFERENCES "public"."hr_timesheet_invoice_factor" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."account_analytic_account" ADD FOREIGN KEY ("write_uid") REFERENCES "public"."res_users" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."account_analytic_account" ADD FOREIGN KEY ("partner_id") REFERENCES "public"."res_partner" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."account_analytic_account" ADD FOREIGN KEY ("journal_id") REFERENCES "public"."account_journal" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."account_analytic_account" ADD FOREIGN KEY ("pricelist_id") REFERENCES "public"."product_pricelist" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."account_analytic_account" ADD FOREIGN KEY ("currency_id") REFERENCES "public"."res_currency" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."account_analytic_account" ADD FOREIGN KEY ("manager_id") REFERENCES "public"."res_users" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."account_analytic_account" ADD FOREIGN KEY ("company_id") REFERENCES "public"."res_company" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."account_analytic_account" ADD FOREIGN KEY ("template_id") REFERENCES "public"."account_analytic_account" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."account_analytic_account" ADD FOREIGN KEY ("create_uid") REFERENCES "public"."res_users" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."account_analytic_account" ADD FOREIGN KEY ("user_id") REFERENCES "public"."res_users" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
