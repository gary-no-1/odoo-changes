
DROP VIEW IF EXISTS vg_mobile_amazon_make_model_hdd_color;
DROP VIEW IF EXISTS vg_amazon_sku_laptop;
DROP VIEW IF EXISTS vg_amazon_sku_laptop_old;
DROP VIEW IF EXISTS vg_amazon_sku_mobile;
DROP VIEW IF EXISTS vg_amazon_sku_tablet;

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	

-- View: vg_amazon_sku_laptop_old

CREATE OR REPLACE VIEW vg_amazon_sku_laptop_old AS 
 WITH i AS (
         WITH h AS (
                 SELECT f.id,
                    f.name AS product_name,
                    g.name AS category,
                    split_part(f.name::text, '-'::text, 1) AS make,
                    split_part(f.name::text, '-'::text, 2) AS model,
                    split_part(f.name::text, '-'::text, 5) AS ram,
                    split_part(f.name::text, '-'::text, 6) AS hdd,
                    split_part(f.name::text, '-'::text, 9) AS screen,
                    split_part(f.name::text, '-'::text, 10) AS color,
                    split_part(f.name::text, '-'::text, 11) AS grade
                   FROM product_template f
                     JOIN product_category g ON f.categ_id = g.id
                  WHERE f.active AND upper(g.name::text) = ANY (ARRAY['LAPTOPS OLD'::text, 'PHABLET'::text]))
         SELECT h.id,
		    h.category,
            h.product_name,
            (((((((((h.make || '-'::text) || h.model) || '-'::text) || h.hdd) || '-'::text) || h.ram) || '-'::text) || h.screen) || '-'::text) || h.color AS amazon_name
           FROM h
          WHERE h.grade = ANY (ARRAY['NO'::text, 'NS'::text])
        )
 SELECT i.amazon_name,
    i.category,
    i.product_name,
    '__export__.product_template_'::text || i.id AS product_id,
    '__export__.product_template_'::text || min(500000 + i.id) OVER (PARTITION BY i.amazon_name) AS amazon_id
   FROM i;

ALTER TABLE vg_amazon_sku_laptop_old
  OWNER TO odoo;

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	

-- View: vg_amazon_sku_mobile
CREATE OR REPLACE VIEW vg_amazon_sku_mobile AS 
 WITH y AS (
         WITH x AS (
                 SELECT d.id,
                    d.name AS product_name,
                    c.name AS category,
                    split_part(d.name::text, '-'::text, 1) AS make,
                    split_part(d.name::text, '-'::text, 2) AS model,
                    split_part(d.name::text, '-'::text, 3) AS hdd,
                    split_part(d.name::text, '-'::text, 4) AS grade,
                    upper(split_part(d.name::text, '-'::text, 6)) AS color
                   FROM product_template d
                     JOIN product_category c ON d.categ_id = c.id
                  WHERE d.active AND (c.name::text <> ALL (ARRAY['Accessories'::character varying::text, 'Tablets'::character varying::text, 'Laptops'::character varying::text, 'IT Equipments'::character varying::text, 'Printer Cartridge'::character varying::text]))
                )
         SELECT x.id,
            x.category,
            x.product_name,
            x.make,
            x.model,
            x.hdd,
            x.grade,
            x.color,
            (((((x.make || '-'::text) || x.model) || '-'::text) || x.hdd) || '-'::text) || x.color AS amazon_name
           FROM x
          WHERE x.grade = ANY (ARRAY['NO'::text, 'NS'::text])
        )
 SELECT y.amazon_name,
    y.category,
    y.product_name,
    '__export__.product_template_'::text || y.id AS product_id,
    '__export__.product_template_'::text || min(500000 + y.id) OVER (PARTITION BY y.amazon_name) AS amazon_id
   FROM y;

ALTER TABLE vg_amazon_sku_mobile
  OWNER TO postgres;
GRANT ALL ON TABLE vg_amazon_sku_mobile TO postgres;
GRANT ALL ON TABLE vg_amazon_sku_mobile TO odoo;
GRANT SELECT ON TABLE vg_amazon_sku_mobile TO joomla;

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	

-- View: vg_amazon_sku_tablet

CREATE OR REPLACE VIEW vg_amazon_sku_tablet AS 
 WITH i AS (
         WITH h AS (
                 SELECT f.id,
                    f.name AS product_name,
                    g.name AS category,
                    split_part(f.name::text, '-'::text, 1) AS make,
                    split_part(f.name::text, '-'::text, 2) AS model,
                    split_part(f.name::text, '-'::text, 5) AS ram,
                    split_part(f.name::text, '-'::text, 3) AS hdd,
                    split_part(f.name::text, '-'::text, 7) AS screen,
                    split_part(f.name::text, '-'::text, 6) AS color,
                    split_part(f.name::text, '-'::text, 4) AS grade
                   FROM product_template f
                     JOIN product_category g ON f.categ_id = g.id
                  WHERE f.active AND upper(g.name::text) = 'TABLETS'::text
                )
         SELECT h.id,
            h.category,
            h.product_name,
            (((((((((h.make || '-'::text) || h.model) || '-'::text) || h.hdd) || '-'::text) || h.ram) || '-'::text) || h.screen) || '-'::text) || h.color AS amazon_name
           FROM h
          WHERE h.grade = ANY (ARRAY['NO'::text, 'NS'::text])
        )
 SELECT i.amazon_name,
    i.category,
    i.product_name,
    '__export__.product_template_'::text || i.id AS product_id,
    '__export__.product_template_'::text || min(500000 + i.id) OVER (PARTITION BY i.amazon_name) AS amazon_id
   FROM i;

ALTER TABLE vg_amazon_sku_tablet
  OWNER TO postgres;
GRANT ALL ON TABLE vg_amazon_sku_tablet TO postgres;
GRANT ALL ON TABLE vg_amazon_sku_tablet TO odoo;
GRANT SELECT ON TABLE vg_amazon_sku_tablet TO joomla;

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	

CREATE OR REPLACE VIEW vg_amazon_sku_laptop AS 
 WITH i AS (
         WITH h AS (
                 SELECT f.id,
                    f.name AS product_name,
                    g.name AS category,
                    split_part(f.name::text, '-'::text, 1) AS make,
                    split_part(f.name::text, '-'::text, 2) AS model,
                    split_part(f.name::text, '-'::text, 3) AS proc,
                    split_part(f.name::text, '-'::text, 4) AS proc_no,
                    split_part(f.name::text, '-'::text, 5) AS ram,
                    split_part(f.name::text, '-'::text, 6) AS hdd,
                    split_part(f.name::text, '-'::text, 7) AS screen,
                    split_part(f.name::text, '-'::text, 8) AS os,
                    split_part(f.name::text, '-'::text, 9) AS color,
                    split_part(f.name::text, '-'::text, 10) AS grade
                   FROM product_template f
                     JOIN product_category g ON f.categ_id = g.id
                  WHERE f.active AND (upper(g.name::text) = ANY (ARRAY['LAPTOPS'::text, 'XXXYYY'::text]))
                )
         SELECT h.id,
            h.category,
            h.product_name,
            (((((((((((((((h.make || '-'::text) || h.model) || '-'::text) || h.proc) || '-'::text) || h.proc_no) || '-'::text) || h.ram) || '-'::text) || h.hdd) || '-'::text) || h.screen) || '-'::text) || h.os) || '-'::text) || h.color AS amazon_name
           FROM h
          WHERE h.grade = ANY (ARRAY['NO'::text, 'NS'::text])
        )
 SELECT i.amazon_name,
    i.product_name,
    i.category,
    '__export__.product_template_'::text || i.id AS product_id,
    '__export__.product_template_'::text || min(500000 + i.id) OVER (PARTITION BY i.amazon_name) AS amazon_id
   FROM i;

ALTER TABLE vg_amazon_sku_laptop
  OWNER TO postgres;
GRANT ALL ON TABLE vg_amazon_sku_laptop TO odoo;

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	

-- View: vg_mobile_amazon_make_model_hdd_color
CREATE OR REPLACE VIEW vg_mobile_amazon_make_model_hdd_color AS 
 SELECT vg_amazon_sku_tablet.amazon_name,
    vg_amazon_sku_tablet.product_name,
    vg_amazon_sku_tablet.category,
    vg_amazon_sku_tablet.product_id,
    vg_amazon_sku_tablet.amazon_id
   FROM vg_amazon_sku_tablet
UNION
 SELECT vg_amazon_sku_laptop.amazon_name,
    vg_amazon_sku_laptop.product_name,
    vg_amazon_sku_laptop.category,
    vg_amazon_sku_laptop.product_id,
    vg_amazon_sku_laptop.amazon_id
   FROM vg_amazon_sku_laptop
UNION
 SELECT vg_amazon_sku_laptop_old.amazon_name,
    vg_amazon_sku_laptop_old.product_name,
    vg_amazon_sku_laptop_old.category,
    vg_amazon_sku_laptop_old.product_id,
    vg_amazon_sku_laptop_old.amazon_id
   FROM vg_amazon_sku_laptop_old
UNION
 SELECT vg_amazon_sku_mobile.amazon_name,
    vg_amazon_sku_mobile.product_name,
    vg_amazon_sku_mobile.category,
    vg_amazon_sku_mobile.product_id,
    vg_amazon_sku_mobile.amazon_id
   FROM vg_amazon_sku_mobile;

ALTER TABLE vg_mobile_amazon_make_model_hdd_color
  OWNER TO postgres;
GRANT ALL ON TABLE vg_mobile_amazon_make_model_hdd_color TO postgres;
GRANT ALL ON TABLE vg_mobile_amazon_make_model_hdd_color TO odoo;
GRANT SELECT ON TABLE vg_mobile_amazon_make_model_hdd_color TO joomla;

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	
  