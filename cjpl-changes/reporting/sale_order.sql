/*
Navicat PGSQL Data Transfer

Source Server         : odoo
Source Server Version : 90310
Source Host           : 192.168.1.8:5432
Source Database       : cjpl-prod
Source Schema         : public

Target Server Type    : PGSQL
Target Server Version : 90310
File Encoding         : 65001

Date: 2016-02-05 23:59:46
*/


-- ----------------------------
-- Table structure for sale_order
-- ----------------------------
DROP TABLE IF EXISTS "public"."sale_order";
CREATE TABLE "public"."sale_order" (
"id" int4 DEFAULT nextval('sale_order_id_seq'::regclass) NOT NULL,
"origin" varchar COLLATE "default",
"create_date" timestamp(6),
"write_uid" int4,
"client_order_ref" varchar COLLATE "default",
"date_order" timestamp(6) NOT NULL,
"partner_id" int4 NOT NULL,
"amount_tax" numeric,
"procurement_group_id" int4,
"fiscal_position" int4,
"amount_untaxed" numeric,
"payment_term" int4,
"message_last_post" timestamp(6),
"company_id" int4,
"note" text COLLATE "default",
"state" varchar COLLATE "default",
"pricelist_id" int4 NOT NULL,
"create_uid" int4,
"section_id" int4,
"write_date" timestamp(6),
"partner_invoice_id" int4 NOT NULL,
"user_id" int4,
"date_confirm" date,
"amount_total" numeric,
"project_id" int4,
"name" varchar COLLATE "default" NOT NULL,
"partner_shipping_id" int4 NOT NULL,
"order_policy" varchar COLLATE "default" NOT NULL,
"campaign_id" int4,
"medium_id" int4,
"source_id" int4,
"picking_policy" varchar COLLATE "default" NOT NULL,
"incoterm" int4,
"warehouse_id" int4 NOT NULL,
"shipped" bool,
"carrier_id" int4,
"x_order_type" varchar COLLATE "default",
"x_coordinator_approve" bool,
"x_road_permit" varchar COLLATE "default",
"ignore_exceptions" bool,
"main_exception_id" int4,
"margin" numeric,
"x_rental_start_date" timestamp(6),
"x_rental_end_date" timestamp(6),
"x_minimum_contract_period" varchar COLLATE "default",
"type_id" int4,
"partner_order_id" int4,
"x_recur_inv" varchar COLLATE "default"
)
WITH (OIDS=FALSE)

;
COMMENT ON TABLE "public"."sale_order" IS 'Sales Order';
COMMENT ON COLUMN "public"."sale_order"."origin" IS 'Source Document';
COMMENT ON COLUMN "public"."sale_order"."create_date" IS 'Creation Date';
COMMENT ON COLUMN "public"."sale_order"."write_uid" IS 'Last Updated by';
COMMENT ON COLUMN "public"."sale_order"."client_order_ref" IS 'Reference/Description';
COMMENT ON COLUMN "public"."sale_order"."date_order" IS 'Date';
COMMENT ON COLUMN "public"."sale_order"."partner_id" IS 'Customer';
COMMENT ON COLUMN "public"."sale_order"."amount_tax" IS 'Taxes';
COMMENT ON COLUMN "public"."sale_order"."procurement_group_id" IS 'Procurement group';
COMMENT ON COLUMN "public"."sale_order"."fiscal_position" IS 'Fiscal Position';
COMMENT ON COLUMN "public"."sale_order"."amount_untaxed" IS 'Untaxed Amount';
COMMENT ON COLUMN "public"."sale_order"."payment_term" IS 'Payment Term';
COMMENT ON COLUMN "public"."sale_order"."message_last_post" IS 'Last Message Date';
COMMENT ON COLUMN "public"."sale_order"."company_id" IS 'Company';
COMMENT ON COLUMN "public"."sale_order"."note" IS 'Terms and conditions';
COMMENT ON COLUMN "public"."sale_order"."state" IS 'Status';
COMMENT ON COLUMN "public"."sale_order"."pricelist_id" IS 'Pricelist';
COMMENT ON COLUMN "public"."sale_order"."create_uid" IS 'Created by';
COMMENT ON COLUMN "public"."sale_order"."section_id" IS 'Sales Team';
COMMENT ON COLUMN "public"."sale_order"."write_date" IS 'Last Updated on';
COMMENT ON COLUMN "public"."sale_order"."partner_invoice_id" IS 'Invoice Address';
COMMENT ON COLUMN "public"."sale_order"."user_id" IS 'Salesperson';
COMMENT ON COLUMN "public"."sale_order"."date_confirm" IS 'Confirmation Date';
COMMENT ON COLUMN "public"."sale_order"."amount_total" IS 'Total';
COMMENT ON COLUMN "public"."sale_order"."project_id" IS 'Contract / Analytic';
COMMENT ON COLUMN "public"."sale_order"."name" IS 'Order Reference';
COMMENT ON COLUMN "public"."sale_order"."partner_shipping_id" IS 'Delivery Address';
COMMENT ON COLUMN "public"."sale_order"."order_policy" IS 'Create Invoice';
COMMENT ON COLUMN "public"."sale_order"."campaign_id" IS 'Campaign';
COMMENT ON COLUMN "public"."sale_order"."medium_id" IS 'Channel';
COMMENT ON COLUMN "public"."sale_order"."source_id" IS 'Source';
COMMENT ON COLUMN "public"."sale_order"."picking_policy" IS 'Shipping Policy';
COMMENT ON COLUMN "public"."sale_order"."incoterm" IS 'Incoterm';
COMMENT ON COLUMN "public"."sale_order"."warehouse_id" IS 'Warehouse';
COMMENT ON COLUMN "public"."sale_order"."shipped" IS 'Delivered';
COMMENT ON COLUMN "public"."sale_order"."carrier_id" IS 'Delivery Method';
COMMENT ON COLUMN "public"."sale_order"."x_order_type" IS 'Sale Type';
COMMENT ON COLUMN "public"."sale_order"."x_coordinator_approve" IS 'Sales Approved';
COMMENT ON COLUMN "public"."sale_order"."x_road_permit" IS 'Road Permit Availability';
COMMENT ON COLUMN "public"."sale_order"."ignore_exceptions" IS 'Ignore Exceptions';
COMMENT ON COLUMN "public"."sale_order"."main_exception_id" IS 'Main Exception';
COMMENT ON COLUMN "public"."sale_order"."margin" IS 'Margin';
COMMENT ON COLUMN "public"."sale_order"."x_rental_start_date" IS 'Rental Start Date';
COMMENT ON COLUMN "public"."sale_order"."x_rental_end_date" IS 'Rental End Date';
COMMENT ON COLUMN "public"."sale_order"."x_minimum_contract_period" IS 'Minimum Contract Period';
COMMENT ON COLUMN "public"."sale_order"."type_id" IS 'Type';
COMMENT ON COLUMN "public"."sale_order"."partner_order_id" IS 'Ordering Contact';
COMMENT ON COLUMN "public"."sale_order"."x_recur_inv" IS 'Recurring Invoice';

-- ----------------------------
-- Alter Sequences Owned By 
-- ----------------------------

-- ----------------------------
-- Indexes structure for table sale_order
-- ----------------------------
CREATE INDEX "sale_order_create_date_index" ON "public"."sale_order" USING btree ("create_date");
CREATE INDEX "sale_order_date_confirm_index" ON "public"."sale_order" USING btree ("date_confirm");
CREATE INDEX "sale_order_date_order_index" ON "public"."sale_order" USING btree ("date_order");
CREATE INDEX "sale_order_name_index" ON "public"."sale_order" USING btree ("name");
CREATE INDEX "sale_order_partner_id_index" ON "public"."sale_order" USING btree ("partner_id");
CREATE INDEX "sale_order_state_index" ON "public"."sale_order" USING btree ("state");
CREATE INDEX "sale_order_user_id_index" ON "public"."sale_order" USING btree ("user_id");

-- ----------------------------
-- Uniques structure for table sale_order
-- ----------------------------
ALTER TABLE "public"."sale_order" ADD UNIQUE ("name", "company_id");

-- ----------------------------
-- Primary Key structure for table sale_order
-- ----------------------------
ALTER TABLE "public"."sale_order" ADD PRIMARY KEY ("id");

-- ----------------------------
-- Foreign Key structure for table "public"."sale_order"
-- ----------------------------
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("section_id") REFERENCES "public"."crm_case_section" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("main_exception_id") REFERENCES "public"."sale_exception" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("project_id") REFERENCES "public"."account_analytic_account" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("partner_invoice_id") REFERENCES "public"."res_partner" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("carrier_id") REFERENCES "public"."delivery_carrier" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("company_id") REFERENCES "public"."res_company" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("partner_order_id") REFERENCES "public"."res_partner" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("incoterm") REFERENCES "public"."stock_incoterms" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("partner_shipping_id") REFERENCES "public"."res_partner" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("type_id") REFERENCES "public"."sale_order_type" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("create_uid") REFERENCES "public"."res_users" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("user_id") REFERENCES "public"."res_users" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("procurement_group_id") REFERENCES "public"."procurement_group" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("medium_id") REFERENCES "public"."crm_tracking_medium" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("source_id") REFERENCES "public"."crm_tracking_source" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("write_uid") REFERENCES "public"."res_users" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("pricelist_id") REFERENCES "public"."product_pricelist" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("partner_id") REFERENCES "public"."res_partner" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("fiscal_position") REFERENCES "public"."account_fiscal_position" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("campaign_id") REFERENCES "public"."crm_tracking_campaign" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("payment_term") REFERENCES "public"."account_payment_term" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."sale_order" ADD FOREIGN KEY ("warehouse_id") REFERENCES "public"."stock_warehouse" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
