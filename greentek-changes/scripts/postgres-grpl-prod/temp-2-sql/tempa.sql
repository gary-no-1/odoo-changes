-- View: vg_amazon_sku_laptop

-- DROP VIEW vg_amazon_sku_laptop;

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
                    split_part(f.name::text, '-'::text, 9) AS color
                   FROM product_template f
                     JOIN product_category g ON f.categ_id = g.id
                  WHERE f.active AND (upper(g.name::text) = ANY (ARRAY['LAPTOPS'::text, 'PHABLET'::text]))
                )
         SELECT h.id,
            h.category,
            h.product_name,
            (((((((((h.make || '-'::text) || h.model) || '-'::text) || h.hdd) || '-'::text) || h.ram) || '-'::text) || h.screen) || '-'::text) || h.color AS amazon_name
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
GRANT ALL ON TABLE vg_amazon_sku_laptop TO postgres;
GRANT ALL ON TABLE vg_amazon_sku_laptop TO odoo;
GRANT SELECT ON TABLE vg_amazon_sku_laptop TO joomla;


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
                  WHERE f.active AND (upper(g.name::text) = ANY (ARRAY['LAPTOPS'::text, 'PHABLET'::text]))
                )
         SELECT h.id,
            h.category,
            h.product_name,
            h.make || '-' || h.model || '-' || h.proc || '-' || h.proc_no || '-' || h.ram || '-' || h.hdd || '-' || h.screen || '-' || h.os || '-' || h.color AS amazon_name
           FROM h
          WHERE h.grade = ANY (ARRAY['NO'::text, 'NS'::text])
        )
 SELECT i.amazon_name,
    i.product_name,
    i.category,
    '__export__.product_template_'::text || i.id AS product_id,
    '__export__.product_template_'::text || min(500000 + i.id) OVER (PARTITION BY i.amazon_name) AS amazon_id
   FROM i;
