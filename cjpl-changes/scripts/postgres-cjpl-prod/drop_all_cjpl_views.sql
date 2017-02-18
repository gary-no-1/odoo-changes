-- run pgadmin and execute this script using f8 
-- text output will be script to drop all views
-- run this output at 10.0.0.10 using psql -d myDataBase -a -f outputOfThisFile
select 'DROP VIEW IF EXISTS ' || table_name || ' cascade;'
from INFORMATION_SCHEMA.views 
       JOIN non_odoo.view_sort_order 
         ON table_name = non_odoo.view_sort_order.NAME 
WHERE  table_name LIKE 'view_cjpl%' 
ORDER  BY non_odoo.view_sort_order.sort_order desc , 
          table_name; 