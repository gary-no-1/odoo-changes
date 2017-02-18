-- ------------------------------------------------------------
-- View: vg_duplicate_product_names

DROP VIEW vg_duplicate_product_names;

CREATE OR REPLACE VIEW vg_duplicate_product_names AS 
 SELECT product_template.id,
    product_template.name,
    product_template.create_date,
    product_template.type
   FROM product_template
  WHERE (upper(btrim(product_template.name::text)) IN ( SELECT upper(btrim(product_template_1.name::text)) AS up_name
           FROM product_template product_template_1
		   WHERE active
          GROUP BY upper(btrim(product_template_1.name::text))
         HAVING count(*) > 1))
  ORDER BY product_template.name, product_template.create_date;

ALTER TABLE vg_duplicate_product_names
  OWNER TO odoo;

-- ------------------------------------------------------------
-- View: vg_duplicate_product_names_2

DROP VIEW vg_duplicate_product_names_2;

CREATE OR REPLACE VIEW vg_duplicate_product_names_2 AS 
 SELECT product_product.id,
    product_product.name_template,
    product_product.create_date
   FROM product_product
  WHERE (upper(btrim(product_product.name_template::text)) IN ( SELECT upper(btrim(product_product_1.name_template::text)) AS up_name
           FROM product_product product_product_1
		   WHERE active
          GROUP BY upper(btrim(product_product_1.name_template::text))
         HAVING count(*) > 1))
  ORDER BY product_product.name_template, product_product.create_date;

ALTER TABLE vg_duplicate_product_names_2
  OWNER TO odoo;

-- ------------------------------------------------------------
-- Function: batch_remove_duplicate()

-- DROP FUNCTION batch_remove_duplicate();

CREATE OR REPLACE FUNCTION batch_remove_duplicate()
  RETURNS text AS
$BODY$


DECLARE 
 item_count float4 := 0;
 dont_use TEXT DEFAULT 'DONT USE ';
 titles_brd TEXT DEFAULT '';
 update_query_brd TEXT DEFAULT '';
 rec_table_brd  RECORD;
 cur_table_brd CURSOR
 FOR SELECT tc.from as from_int, tc.to as to_int
 FROM zz_remove_duplicates tc;
 
BEGIN
   -- Open the cursor
   OPEN cur_table_brd ;
 
   LOOP
    -- fetch row into the film
      FETCH cur_table_brd INTO rec_table_brd;
    -- exit when no more row to fetch
      EXIT WHEN NOT FOUND;

      titles_brd := '' ;

      update_query_brd := 'select change_product_id( ' || rec_table_brd.from_int || ' , ' || rec_table_brd.to_int || ')';
      EXECUTE update_query_brd ;

      item_count := item_count + 1;
--      EXIT ; 

      update_query_brd := 'update product_product set active = false where id = ' || rec_table_brd.from_int ;
      EXECUTE update_query_brd ;

      update_query_brd := 'update product_template as pt set active = false  ' ;
      update_query_brd := update_query_brd || ' from product_product pp where pt.id = pp.product_tmpl_id ' ;
      update_query_brd := update_query_brd || ' and pp.id = ' || rec_table_brd.from_int ;

      titles_brd := titles_brd || update_query_brd  || ',' ;
      EXECUTE update_query_brd ;
--      EXIT ; 

    -- build the output
   END LOOP;
  
   -- Close the cursor
   CLOSE cur_table_brd;
 
   RETURN item_count;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION batch_remove_duplicate()
  OWNER TO odoo;
