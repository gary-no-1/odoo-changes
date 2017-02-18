/*
Navicat PGSQL Data Transfer

Source Server         : odoo
Source Server Version : 90310
Source Host           : 192.168.1.4:5432
Source Database       : cjpl-prod
Source Schema         : public

Target Server Type    : PGSQL
Target Server Version : 90310
File Encoding         : 65001

Date: 2016-01-27 11:33:41
*/


-- ----------------------------
-- Table structure for crm_lead
-- ----------------------------
DROP TABLE IF EXISTS "public"."crm_lead";
CREATE TABLE "public"."crm_lead" (
"id" int4 DEFAULT nextval('crm_lead_id_seq'::regclass) NOT NULL,
"date_closed" timestamp(6),
"create_date" timestamp(6),
"date_deadline" date,
"color" int4,
"country_id" int4,
"date_last_stage_update" timestamp(6),
"date_action_last" timestamp(6),
"campaign_id" int4,
"day_close" numeric,
"write_uid" int4,
"active" bool,
"day_open" numeric,
"contact_name" varchar(64) COLLATE "default",
"partner_id" int4,
"date_action_next" timestamp(6),
"city" varchar COLLATE "default",
"user_id" int4,
"opt_out" bool,
"date_open" timestamp(6),
"title" int4,
"partner_name" varchar(64) COLLATE "default",
"planned_revenue" float8,
"message_last_post" timestamp(6),
"company_id" int4,
"priority" varchar COLLATE "default",
"email_cc" text COLLATE "default",
"ref" varchar COLLATE "default",
"planned_cost" float8,
"function" varchar COLLATE "default",
"fax" varchar COLLATE "default",
"zip" varchar(24) COLLATE "default",
"description" text COLLATE "default",
"create_uid" int4,
"street2" varchar COLLATE "default",
"ref2" varchar COLLATE "default",
"section_id" int4,
"title_action" varchar COLLATE "default",
"phone" varchar COLLATE "default",
"probability" float8,
"write_date" timestamp(6),
"payment_mode" int4,
"date_action" date,
"name" varchar COLLATE "default" NOT NULL,
"stage_id" int4,
"medium_id" int4,
"mobile" varchar COLLATE "default",
"type" varchar COLLATE "default",
"street" varchar COLLATE "default",
"message_bounce" int4,
"source_id" int4,
"state_id" int4,
"email_from" varchar(128) COLLATE "default",
"referred" varchar COLLATE "default",
"weighted_planned_revenue" float8
)
WITH (OIDS=FALSE)

;
COMMENT ON TABLE "public"."crm_lead" IS 'Lead/Opportunity';
COMMENT ON COLUMN "public"."crm_lead"."date_closed" IS 'Closed';
COMMENT ON COLUMN "public"."crm_lead"."create_date" IS 'Creation Date';
COMMENT ON COLUMN "public"."crm_lead"."date_deadline" IS 'Expected Closing';
COMMENT ON COLUMN "public"."crm_lead"."color" IS 'Color Index';
COMMENT ON COLUMN "public"."crm_lead"."country_id" IS 'Country';
COMMENT ON COLUMN "public"."crm_lead"."date_last_stage_update" IS 'Last Stage Update';
COMMENT ON COLUMN "public"."crm_lead"."date_action_last" IS 'Last Action';
COMMENT ON COLUMN "public"."crm_lead"."campaign_id" IS 'Campaign';
COMMENT ON COLUMN "public"."crm_lead"."day_close" IS 'Days to Close';
COMMENT ON COLUMN "public"."crm_lead"."write_uid" IS 'Last Updated by';
COMMENT ON COLUMN "public"."crm_lead"."active" IS 'Active';
COMMENT ON COLUMN "public"."crm_lead"."day_open" IS 'Days to Assign';
COMMENT ON COLUMN "public"."crm_lead"."contact_name" IS 'Contact Name';
COMMENT ON COLUMN "public"."crm_lead"."partner_id" IS 'Partner';
COMMENT ON COLUMN "public"."crm_lead"."date_action_next" IS 'Next Action';
COMMENT ON COLUMN "public"."crm_lead"."city" IS 'City';
COMMENT ON COLUMN "public"."crm_lead"."user_id" IS 'Salesperson';
COMMENT ON COLUMN "public"."crm_lead"."opt_out" IS 'Opt-Out';
COMMENT ON COLUMN "public"."crm_lead"."date_open" IS 'Assigned';
COMMENT ON COLUMN "public"."crm_lead"."title" IS 'Title';
COMMENT ON COLUMN "public"."crm_lead"."partner_name" IS 'Customer Name';
COMMENT ON COLUMN "public"."crm_lead"."planned_revenue" IS 'Expected Revenue';
COMMENT ON COLUMN "public"."crm_lead"."message_last_post" IS 'Last Message Date';
COMMENT ON COLUMN "public"."crm_lead"."company_id" IS 'Company';
COMMENT ON COLUMN "public"."crm_lead"."priority" IS 'Priority';
COMMENT ON COLUMN "public"."crm_lead"."email_cc" IS 'Global CC';
COMMENT ON COLUMN "public"."crm_lead"."ref" IS 'Reference';
COMMENT ON COLUMN "public"."crm_lead"."planned_cost" IS 'Planned Costs';
COMMENT ON COLUMN "public"."crm_lead"."function" IS 'Function';
COMMENT ON COLUMN "public"."crm_lead"."fax" IS 'Fax';
COMMENT ON COLUMN "public"."crm_lead"."zip" IS 'Zip';
COMMENT ON COLUMN "public"."crm_lead"."description" IS 'Notes';
COMMENT ON COLUMN "public"."crm_lead"."create_uid" IS 'Created by';
COMMENT ON COLUMN "public"."crm_lead"."street2" IS 'Street2';
COMMENT ON COLUMN "public"."crm_lead"."ref2" IS 'Reference 2';
COMMENT ON COLUMN "public"."crm_lead"."section_id" IS 'Sales Team';
COMMENT ON COLUMN "public"."crm_lead"."title_action" IS 'Next Action';
COMMENT ON COLUMN "public"."crm_lead"."phone" IS 'Phone';
COMMENT ON COLUMN "public"."crm_lead"."probability" IS 'Success Rate (%)';
COMMENT ON COLUMN "public"."crm_lead"."write_date" IS 'Update Date';
COMMENT ON COLUMN "public"."crm_lead"."payment_mode" IS 'Payment Mode';
COMMENT ON COLUMN "public"."crm_lead"."date_action" IS 'Next Action Date';
COMMENT ON COLUMN "public"."crm_lead"."name" IS 'Subject';
COMMENT ON COLUMN "public"."crm_lead"."stage_id" IS 'Stage';
COMMENT ON COLUMN "public"."crm_lead"."medium_id" IS 'Channel';
COMMENT ON COLUMN "public"."crm_lead"."mobile" IS 'Mobile';
COMMENT ON COLUMN "public"."crm_lead"."type" IS 'Type';
COMMENT ON COLUMN "public"."crm_lead"."street" IS 'Street';
COMMENT ON COLUMN "public"."crm_lead"."message_bounce" IS 'Bounce';
COMMENT ON COLUMN "public"."crm_lead"."source_id" IS 'Source';
COMMENT ON COLUMN "public"."crm_lead"."state_id" IS 'State';
COMMENT ON COLUMN "public"."crm_lead"."email_from" IS 'Email';
COMMENT ON COLUMN "public"."crm_lead"."referred" IS 'Referred By';
COMMENT ON COLUMN "public"."crm_lead"."weighted_planned_revenue" IS 'Weighted expected revenue';

-- ----------------------------
-- Alter Sequences Owned By 
-- ----------------------------

-- ----------------------------
-- Indexes structure for table crm_lead
-- ----------------------------
CREATE INDEX "crm_lead_company_id_index" ON "public"."crm_lead" USING btree ("company_id");
CREATE INDEX "crm_lead_date_action_index" ON "public"."crm_lead" USING btree ("date_action");
CREATE INDEX "crm_lead_date_last_stage_update_index" ON "public"."crm_lead" USING btree ("date_last_stage_update");
CREATE INDEX "crm_lead_email_from_index" ON "public"."crm_lead" USING btree ("email_from");
CREATE INDEX "crm_lead_name_index" ON "public"."crm_lead" USING btree ("name");
CREATE INDEX "crm_lead_partner_id_index" ON "public"."crm_lead" USING btree ("partner_id");
CREATE INDEX "crm_lead_partner_name_index" ON "public"."crm_lead" USING btree ("partner_name");
CREATE INDEX "crm_lead_priority_index" ON "public"."crm_lead" USING btree ("priority");
CREATE INDEX "crm_lead_section_id_index" ON "public"."crm_lead" USING btree ("section_id");
CREATE INDEX "crm_lead_stage_id_index" ON "public"."crm_lead" USING btree ("stage_id");
CREATE INDEX "crm_lead_type_index" ON "public"."crm_lead" USING btree ("type");
CREATE INDEX "crm_lead_user_id_index" ON "public"."crm_lead" USING btree ("user_id");

-- ----------------------------
-- Checks structure for table crm_lead
-- ----------------------------
ALTER TABLE "public"."crm_lead" ADD CHECK (((probability >= (0)::double precision) AND (probability <= (100)::double precision)));

-- ----------------------------
-- Primary Key structure for table crm_lead
-- ----------------------------
ALTER TABLE "public"."crm_lead" ADD PRIMARY KEY ("id");

-- ----------------------------
-- Foreign Key structure for table "public"."crm_lead"
-- ----------------------------
ALTER TABLE "public"."crm_lead" ADD FOREIGN KEY ("title") REFERENCES "public"."res_partner_title" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."crm_lead" ADD FOREIGN KEY ("company_id") REFERENCES "public"."res_company" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."crm_lead" ADD FOREIGN KEY ("partner_id") REFERENCES "public"."res_partner" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."crm_lead" ADD FOREIGN KEY ("campaign_id") REFERENCES "public"."crm_tracking_campaign" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."crm_lead" ADD FOREIGN KEY ("country_id") REFERENCES "public"."res_country" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."crm_lead" ADD FOREIGN KEY ("user_id") REFERENCES "public"."res_users" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."crm_lead" ADD FOREIGN KEY ("section_id") REFERENCES "public"."crm_case_section" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."crm_lead" ADD FOREIGN KEY ("payment_mode") REFERENCES "public"."crm_payment_mode" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."crm_lead" ADD FOREIGN KEY ("write_uid") REFERENCES "public"."res_users" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."crm_lead" ADD FOREIGN KEY ("create_uid") REFERENCES "public"."res_users" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."crm_lead" ADD FOREIGN KEY ("state_id") REFERENCES "public"."res_country_state" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."crm_lead" ADD FOREIGN KEY ("medium_id") REFERENCES "public"."crm_tracking_medium" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."crm_lead" ADD FOREIGN KEY ("source_id") REFERENCES "public"."crm_tracking_source" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."crm_lead" ADD FOREIGN KEY ("stage_id") REFERENCES "public"."crm_case_stage" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
