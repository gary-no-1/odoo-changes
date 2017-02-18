-- Function: update_price_duplicate()

-- DROP FUNCTION update_price_duplicate();

CREATE OR REPLACE FUNCTION update_price_duplicate()
  RETURNS text AS
$BODY$


DECLARE 
 item_count float4 := 0;
 from_id integer ;
 to_id integer ;
 trf_list_price float4 := 0 ;
 dont_use TEXT DEFAULT 'DONT USE ';
 titles_upr TEXT DEFAULT '';
 select_query_upr TEXT DEFAULT '';
 update_query_upr TEXT DEFAULT '';
 rec_table_upr  RECORD;
 pt_record RECORD ;
 cur_table_upr CURSOR
 FOR SELECT tc.from as from_int, tc.to as to_int
 FROM zz_remove_duplicates tc;
 
BEGIN
   -- Open the cursor
   OPEN cur_table_upr ;
 
   LOOP
    -- fetch row into the film
      FETCH cur_table_upr INTO rec_table_upr;
    -- exit when no more row to fetch
      EXIT WHEN NOT FOUND;

      titles_upr := '' ;

      from_id := rec_table_upr.from_int ;
      
      SELECT id, list_price FROM product_template where id in 
	  (select product_tmpl_id from product_product where id = from_id) into pt_record  ;
      
      trf_list_price := pt_record.list_price ;

      update_query_upr := 'update product_template as pt set list_price = trf_list_price ' ;
      update_query_upr := update_query_upr || ' from product_product pp where pt.id = pp.product_tmpl_id ' ;
      update_query_upr := update_query_upr || ' and pp.id = ' || rec_table_upr.from_int ;      
      
      item_count := item_count + 1;
--      EXIT ; 

   END LOOP;
  
   -- Close the cursor
   CLOSE cur_table_upr;
 
   RETURN item_count;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION update_price_duplicate()
  OWNER TO odoo;
