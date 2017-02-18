--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = non_odoo, pg_catalog;

--
-- Data for Name: view_sort_order; Type: TABLE DATA; Schema: non_odoo; Owner: postgres
--

INSERT INTO view_sort_order (id, name, sort_order) VALUES (1, 'view_cjpl_user_name', 10);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (2, 'view_cjpl_xxx_partner_is_a_company', 20);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (3, 'view_cjpl_xxx_partner_is_not_company_but_has_parent', 30);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (4, 'view_cjpl_xxx_partner_is_not_company_with_no_parent', 40);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (5, 'view_cjpl_partner_all_companies', 50);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (6, 'view_cjpl_contract_basic', 60);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (7, 'view_cjpl_xxx_contract_to_invoice_sale_type', 70);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (8, 'view_cjpl_xxx_contract_to_invoice_sale_typology', 80);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (9, 'view_cjpl_xxx_direct_invoice_sale_typology', 90);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (10, 'view_cjpl_xxx_order_to_invoice_sale_typology', 100);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (11, 'view_cjpl_invoice_sale_typology', 110);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (12, 'view_cjpl_opportunity', 120);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (13, 'view_cjpl_order_basic', 130);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (14, 'view_cjpl_opportunity_sale_order', 140);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (15, 'view_cjpl_xxx_invoice_list_all', 150);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (16, 'view_cjpl_invoice_list_final', 160);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (17, 'view_cjpl_sale_orders_invoice_created_no_invoice_number', 170);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (18, 'view_cjpl_sale_orders_with_no_invoices_created', 180);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (19, 'view_cjpl_invoice_list_new', 190);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (20, 'view_cjpl_xxx_invoice_for_tally_1', 200);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (21, 'view_cjpl_xxx_invoice_for_tally_2', 210);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (22, 'view_cjpl_xxx_invoice_for_tally_3', 220);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (23, 'view_cjpl_xxx_partners_transaction_dates', 230);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (24, 'view_cjpl_partners_transaction_dates', 240);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (25, 'view_cjpl_invoice_line_base_tax', 250);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (26, 'view_cjpl_invoice_list', 260);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (27, 'view_cjpl_team_name', 270);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (28, 'view_cjpl_xxx_partner_not_company_no_parent_company', 280);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (29, 'view_cjpl_all_partners_transaction_dates', 290);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (30, 'view_cjpl_invoice_service_tax_list', 300);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (31, 'view_cjpl_invoice_loss_of_assets', 310);
INSERT INTO view_sort_order (id, name, sort_order) VALUES (32, 'view_cjpl_order_basic_with_sale_order_status', 320);


--
-- Name: view_sort_order_id_seq; Type: SEQUENCE SET; Schema: non_odoo; Owner: postgres
--

SELECT pg_catalog.setval('view_sort_order_id_seq', 27, true);


--
-- PostgreSQL database dump complete
--

