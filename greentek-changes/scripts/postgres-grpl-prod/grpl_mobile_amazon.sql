-- View: vg_mobile_amazon_make_model_hdd_color

-- DROP VIEW vg_mobile_amazon_make_model_hdd_color;

CREATE OR REPLACE VIEW vg_mobile_amazon_make_model_hdd_color AS 
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
    y.product_name,
    '__export__.product_template_'::text || y.id AS product_id,
    '__export__.product_template_'::text || min(500000 + y.id) OVER (PARTITION BY y.amazon_name) AS amazon_id
   FROM y;

ALTER TABLE vg_mobile_amazon_make_model_hdd_color
  OWNER TO odoo;
