-- FUNCTION: public.batch_remove_duplicate()

-- DROP FUNCTION public.batch_remove_duplicate();

CREATE OR REPLACE FUNCTION public.batch_remove_duplicate(
	)
RETURNS text
    LANGUAGE 'plpgsql'
    COST 100.0

AS $function$


DECLARE 
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

--      titles_brd := titles_brd || update_query_brd  || ',' ;
--       titles_brd := update_query_brd ;
      EXECUTE update_query_brd ;
--      EXIT ; 

      update_query_brd := 'update product_product set name_template = ''' || dont_use  || ''' || name_template where id = ' || rec_table_brd.from_int ;

--      titles_brd := titles_brd || update_query_brd  || ',' ;
      EXECUTE update_query_brd ;
--      EXIT ; 

      update_query_brd := 'update product_template as pt set name = ''' || dont_use  || ''' || name ' ;
      update_query_brd := update_query_brd || ' from product_product pp where pt.id = pp.product_tmpl_id ' ;
      update_query_brd := update_query_brd || ' and pp.id = ' || rec_table_brd.from_int ;

      titles_brd := titles_brd || update_query_brd  || ',' ;
      EXECUTE update_query_brd ;
--      EXIT ; 

    -- build the output
   END LOOP;
  
   -- Close the cursor
   CLOSE cur_table_brd;
 
   RETURN titles_brd;
END; 
$function$;

ALTER FUNCTION public.batch_remove_duplicate()
    OWNER TO odoo;
