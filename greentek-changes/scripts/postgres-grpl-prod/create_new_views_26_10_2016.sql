-- ------------------------------------------------------------
-- View: public.vg_duplicate_product_names_2

DROP VIEW IF EXISTS public.vg_duplicate_product_names_2;

CREATE OR REPLACE VIEW public.vg_duplicate_product_names_2 AS
 SELECT product_product.id,
    product_product.name_template,
    product_product.create_date
   FROM product_product
  WHERE (upper(product_product.name_template::text) IN ( SELECT upper(product_product_1.name_template::text) AS up_name
           FROM product_product product_product_1
          GROUP BY upper(product_product_1.name_template::text)
         HAVING count(*) > 1))
  ORDER BY product_product.name_template, product_product.create_date;

ALTER TABLE public.vg_duplicate_product_names_2
    OWNER TO odoo;

-- ------------------------------------------------------------
DROP VIEW IF EXISTS public.vg_location_product_negative_ledger;

CREATE OR REPLACE VIEW public.vg_location_product_negative_ledger AS
WITH t
AS (
	SELECT location_id,
		product_id,
		DATE,
		sum(NAME) OVER (
			PARTITION BY location_id,
			product_id ORDER BY DATE
			) AS ldg_amt
	FROM stock_move_by_location 
	ORDER BY location_id, product_id, DATE
	)
SELECT t.location_id,
	b.complete_name AS wh_location,
	t.product_id,
	d.NAME AS product_name,
	t.DATE,
	t.ldg_amt
FROM t
LEFT JOIN stock_location b ON t.location_id = b.id
LEFT JOIN product_product c ON t.product_id = c.id
LEFT JOIN product_template d ON c.product_tmpl_id = d.id
WHERE t.ldg_amt < 0;

ALTER TABLE public.vg_location_product_negative_ledger
    OWNER TO odoo;

-- ------------------------------------------------------------
DROP VIEW IF EXISTS public.vg_location_product_lot_negative_ledger;

CREATE OR REPLACE VIEW public.vg_location_product_lot_negative_ledger AS

WITH t
AS (
	SELECT location_id,
		product_id,
		prodlot_id,
		DATE,
		sum(NAME) OVER (
			PARTITION BY location_id,
			product_id,
			prodlot_id ORDER BY DATE
			) AS ldg_amt
	FROM stock_move_by_location 
	ORDER BY location_id, product_id, prodlot_id, DATE
	)
SELECT t.location_id,
	b.complete_name AS wh_location,
	t.product_id,
	d.NAME AS product_name,
	t.prodlot_id,
	t.DATE,
	t.ldg_amt
FROM t
LEFT JOIN stock_location b ON t.location_id = b.id
LEFT JOIN product_product c ON t.product_id = c.id
LEFT JOIN product_template d ON c.product_tmpl_id = d.id
WHERE t.ldg_amt < 0
	AND t.prodlot_id IS NULL;

ALTER TABLE public.vg_location_product_lot_negative_ledger
    OWNER TO odoo;
-- ------------------------------------------------------------
	