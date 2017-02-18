-- run pgadmin and execute this script using f8 
-- text output will be script to create all views
-- run this output at 10.0.0.10 using psql -d myDataBase -a -f outputOfThisFile

--  select '-- ' || repeat('--',30) || E'\n' || 'CREATE OR REPLACE VIEW ' || table_name || ' AS ' || E'\n' || view_definition  || E'\n' ||
--  ' ALTER TABLE ' || table_name || ' OWNER TO postgres;' || E'\n' ||
--  ' GRANT ALL ON ' || table_name || ' TO postgres;' || E'\n' ||
--  ' GRANT SELECT ON ' || table_name || ' TO joomla;' || E'\n'
--  from INFORMATION_SCHEMA.views where table_name like 'view_cjpl%';

SELECT '-- ' || repeat('--',30) || E'\n' || 'CREATE OR REPLACE VIEW ' || table_name || ' AS ' || E'\n' || view_definition  || E'\n' ||
' ALTER TABLE ' || table_name || ' OWNER TO postgres;' || E'\n' ||
' GRANT ALL ON ' || table_name || ' TO postgres;' || E'\n' ||
' GRANT SELECT ON ' || table_name || ' TO joomla;' || E'\n'
FROM   information_schema.views 
       JOIN non_odoo.view_sort_order 
         ON table_name = non_odoo.view_sort_order.NAME 
WHERE  table_name LIKE 'view_cjpl%' 
ORDER  BY non_odoo.view_sort_order.sort_order, 
          table_name; 