-- Function: change_product_id(integer, integer)

-- DROP FUNCTION change_product_id(integer, integer);

CREATE OR REPLACE FUNCTION change_product_id(
    from_id integer,
    to_id integer)
  RETURNS text AS
$BODY$

DECLARE 
 titles TEXT DEFAULT '';
 update_query TEXT DEFAULT '';
 rec_table  RECORD;
 cur_tables CURSOR
 FOR SELECT tc.table_schema, tc.constraint_name, tc.table_name, kcu.column_name, 
 ccu.table_name AS foreign_table_name, ccu.column_name AS foreign_column_name
 FROM information_schema.table_constraints tc
 JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
 JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
 WHERE constraint_type = 'FOREIGN KEY'
 AND ccu.table_name='product_product';
 
BEGIN
   -- https://bowerstudios.com/node/1052 cursor select 
   -- http://errorbank.blogspot.in/2011/03/list-all-foreign-keys-references-for.html -- more cursor select info
   -- http://stackoverflow.com/questions/11948131/postgresql-writing-dynamic-sql-in-stored-procedure-that-returns-a-result-set
   
   -- Open the cursor
   OPEN cur_tables ;
 
   LOOP
    -- fetch row into the film
      FETCH cur_tables INTO rec_table;
    -- exit when no more row to fetch
      EXIT WHEN NOT FOUND;

      update_query := 'UPDATE ' || rec_table.table_name || ' SET ' || rec_table.column_name || ' = $1';
      update_query := update_query || ' WHERE ' || rec_table.column_name || ' = $2';

      titles := titles || rec_table.table_name || ',' ;
--       titles := update_query ;
      EXECUTE update_query
      USING to_id , from_id;
--      EXIT ; 
 
    -- build the output
   END LOOP;
  
   -- Close the cursor
   CLOSE cur_tables;
 
   RETURN titles;
END; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION change_product_id(integer, integer)
  OWNER TO odoo;
