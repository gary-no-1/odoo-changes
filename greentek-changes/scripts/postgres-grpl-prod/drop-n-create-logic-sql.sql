select 'DROP VIEW IF EXISTS ' || name || ' cascade;'
from zz_view_sort_order 
ORDER  BY sort_order desc , name; 


SELECT '-- ' || repeat('--',30) || E'\n' || 'CREATE OR REPLACE VIEW ' || table_name || ' AS ' || E'\n' || view_definition  || E'\n' ||
' ALTER TABLE ' || table_name || ' OWNER TO postgres;' || E'\n' ||
' GRANT ALL ON ' || table_name || ' TO postgres;' || E'\n' ||
' GRANT ALL ON ' || table_name || ' TO odoo;' || E'\n' ||
' GRANT SELECT ON ' || table_name || ' TO joomla;' || E'\n'
FROM   information_schema.views 
       JOIN zz_view_sort_order 
         ON table_name = zz_view_sort_order.NAME 
ORDER  BY zz_view_sort_order.sort_order, 
          table_name; 