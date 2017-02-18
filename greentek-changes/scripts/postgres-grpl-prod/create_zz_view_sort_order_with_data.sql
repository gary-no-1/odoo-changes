--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.13
-- Dumped by pg_dump version 9.5.0

-- Started on 2016-10-25 13:04:56

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

--
-- TOC entry 5008 (class 0 OID 1753064)
-- Dependencies: 1224
-- Data for Name: zz_view_sort_order; Type: TABLE DATA; Schema: public; Owner: odoo
--

-- Table: zz_view_sort_order

DROP TABLE IF EXISTS zz_view_sort_order;

CREATE TABLE zz_view_sort_order
(
  id serial NOT NULL,
  name text,
  sort_order integer,
  CONSTRAINT view_sort_order_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE zz_view_sort_order
  OWNER TO odoo;
  
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (1, 'vg_user_name', 10);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (2, 'view_grpl_user_name', 20);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (3, 'vg_stock_by_location_product_serial', 30);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (4, 'vg_stock_by_location_with_price', 40);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (5, 'vg_stock_by_product', 50);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (6, 'vg_duplicate_product_product_names_with_qty', 60);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (7, 'vg_invoice_line_serial_no', 70);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (8, 'vg_invoice_portal', 80);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (9, 'vg_sale_order_details', 90);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (10, 'view_grpl_gtr_no_product_name_status', 100);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (11, 'view_grpl_invoice', 110);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (12, 'view_grpl_product_gtr_with_location', 120);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (13, 'view_grpl_sale_order', 130);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (14, 'view_grpl_xxx_serial_lot', 140);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (15, 'view_grpl_xxx_stock_by_location', 150);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (16, 'view_grpl_xxx_stock_product_by_prodlot', 160);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (17, 'vg_xxx_stock_location_make_model_1', 170);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (18, 'vg_xxx_stock_location_make_model_2', 180);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (19, 'vg_xxx_location_product_sale_date', 190);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (20, 'vg_xxx_location_product_last_sale_date', 200);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (21, 'vg_xxx_stock_location_product_serial_make_model', 210);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (22, 'vg_stock_location_make_model_hdd_grade_color_ageing', 220);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (23, 'vg_stock_location_make_model_hdd_ageing', 230);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (24, 'vg_xxx_stock_location_product_serial_make_model_2', 240);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (25, 'vg_stock_location_make_model_hdd_grade_color_ageing_2', 250);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (26, 'vg_users_stock_locations', 260);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (27, 'vg_stock_locations_users', 270);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (28, 'vg_stock_location_make_model_with_grade', 280);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (29, 'vg_xxx_stock_move_by_location', 290);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (30, 'vg_xxx_stock_location_product_serial_make_model_3', 300);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (31, 'vg_stock_location_make_model_hdd_ageing_2', 310);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (32, 'vg_stock_location_make_model_hdd_ageing_3', 320);
INSERT INTO zz_view_sort_order (id, name, sort_order) VALUES (33, 'vg_stock_location_make_model_hdd_grade_color_ageing_3', 330);

--
-- TOC entry 5014 (class 0 OID 0)
-- Dependencies: 1223
-- Name: zz_view_sort_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: odoo
--

SELECT pg_catalog.setval('zz_view_sort_order_id_seq', 24, true);


-- Completed on 2016-10-17 21:13:13

--
-- PostgreSQL database dump complete
--

