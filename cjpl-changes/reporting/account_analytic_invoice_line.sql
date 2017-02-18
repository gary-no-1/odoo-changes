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

Date: 2016-02-01 17:23:54
*/


-- ----------------------------
-- Table structure for account_analytic_invoice_line
-- ----------------------------
DROP TABLE IF EXISTS "public"."account_analytic_invoice_line";
CREATE TABLE "public"."account_analytic_invoice_line" (
"id" int4 DEFAULT nextval('account_analytic_invoice_line_id_seq'::regclass) NOT NULL,
"analytic_account_id" int4,
"create_uid" int4,
"create_date" timestamp(6),
"name" text COLLATE "default" NOT NULL,
"price_unit" float8 NOT NULL,
"write_uid" int4,
"uom_id" int4 NOT NULL,
"write_date" timestamp(6),
"quantity" float8 NOT NULL,
"product_id" int4 NOT NULL,
"discount" numeric
)
WITH (OIDS=FALSE)

;
COMMENT ON TABLE "public"."account_analytic_invoice_line" IS 'account.analytic.invoice.line';
COMMENT ON COLUMN "public"."account_analytic_invoice_line"."analytic_account_id" IS 'Analytic Account';
COMMENT ON COLUMN "public"."account_analytic_invoice_line"."create_uid" IS 'Created by';
COMMENT ON COLUMN "public"."account_analytic_invoice_line"."create_date" IS 'Created on';
COMMENT ON COLUMN "public"."account_analytic_invoice_line"."name" IS 'Description';
COMMENT ON COLUMN "public"."account_analytic_invoice_line"."price_unit" IS 'Unit Price';
COMMENT ON COLUMN "public"."account_analytic_invoice_line"."write_uid" IS 'Last Updated by';
COMMENT ON COLUMN "public"."account_analytic_invoice_line"."uom_id" IS 'Unit of Measure';
COMMENT ON COLUMN "public"."account_analytic_invoice_line"."write_date" IS 'Last Updated on';
COMMENT ON COLUMN "public"."account_analytic_invoice_line"."quantity" IS 'Quantity';
COMMENT ON COLUMN "public"."account_analytic_invoice_line"."product_id" IS 'Product';
COMMENT ON COLUMN "public"."account_analytic_invoice_line"."discount" IS 'Discount (%)';

-- ----------------------------
-- Alter Sequences Owned By 
-- ----------------------------

-- ----------------------------
-- Primary Key structure for table account_analytic_invoice_line
-- ----------------------------
ALTER TABLE "public"."account_analytic_invoice_line" ADD PRIMARY KEY ("id");

-- ----------------------------
-- Foreign Key structure for table "public"."account_analytic_invoice_line"
-- ----------------------------
ALTER TABLE "public"."account_analytic_invoice_line" ADD FOREIGN KEY ("uom_id") REFERENCES "public"."product_uom" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."account_analytic_invoice_line" ADD FOREIGN KEY ("create_uid") REFERENCES "public"."res_users" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."account_analytic_invoice_line" ADD FOREIGN KEY ("write_uid") REFERENCES "public"."res_users" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."account_analytic_invoice_line" ADD FOREIGN KEY ("analytic_account_id") REFERENCES "public"."account_analytic_account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "public"."account_analytic_invoice_line" ADD FOREIGN KEY ("product_id") REFERENCES "public"."product_product" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
