select (select nspname from pg_namespace where oid=f.relnamespace) as foreign_ns,
f.relname as foreign_table,
(select a.attname from pg_attribute a where a.attrelid = f.oid and a.attnum = o.confkey[1] and a.attisdropped = false) as foreign_colname,
(select nspname from pg_namespace where oid=m.relnamespace) as target_ns,
m.relname as target_table,
(select a.attname from pg_attribute a where a.attrelid = m.oid and a.attnum = o.conkey[1] and a.attisdropped = false) as target_colname, o.conname as target_constraint_name from pg_constraint o left join    pg_class c on c.oid = o.conrelid
left join pg_class f on f.oid = o.confrelid left join pg_class m on m.oid = o.conrelid
where o.contype = 'f' and o.conrelid in (select oid from pg_class c where c.relkind = 'r')  and f.relname = 'product_product'


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


DROP VIEW IF EXISTS vg_user_name  cascade;
DROP VIEW IF EXISTS vg_user_name  cascade;
DROP VIEW IF EXISTS  view_grpl_user_name cascade ;
DROP VIEW IF EXISTS  vg_stock_by_location_product_serial cascade ;
DROP VIEW IF EXISTS  vg_stock_by_location_with_price cascade ;
DROP VIEW IF EXISTS  vg_stock_by_product cascade ;
DROP VIEW IF EXISTS  vg_duplicate_product_product_names_with_qty cascade ;
DROP VIEW IF EXISTS  vg_invoice_line_serial_no cascade ;
DROP VIEW IF EXISTS  vg_invoice_portal cascade ;
DROP VIEW IF EXISTS  vg_sale_order_details cascade ;
DROP VIEW IF EXISTS  view_grpl_gtr_no_product_name_status cascade ;
DROP VIEW IF EXISTS  view_grpl_invoice cascade ;
DROP VIEW IF EXISTS  view_grpl_product_gtr_with_location cascade ;
DROP VIEW IF EXISTS  view_grpl_sale_order cascade ;
DROP VIEW IF EXISTS  view_grpl_xxx_serial_lot cascade ;
DROP VIEW IF EXISTS  view_grpl_xxx_stock_by_location cascade ;
DROP VIEW IF EXISTS  view_grpl_xxx_stock_product_by_prodlot cascade ;

-- DROP VIEW view_grpl_user_name;

-- View: vg_user_name

-- DROP VIEW vg_user_name;

CREATE OR REPLACE VIEW vg_user_name AS 
 SELECT r.id,
    r.partner_id,
    r.alias_id,
    r.default_section_id,
    a.name,
    a.display_name,
    b.complete_name AS team_name
   FROM res_users r
     JOIN res_partner a ON a.id = r.partner_id
     LEFT JOIN crm_case_section b ON r.default_section_id = b.id
  ORDER BY r.id;

ALTER TABLE vg_user_name
  OWNER TO postgres;
GRANT ALL ON TABLE vg_user_name TO postgres;
GRANT SELECT ON TABLE vg_user_name TO joomla;

-- View: view_grpl_user_name

-- DROP VIEW view_grpl_user_name;

CREATE OR REPLACE VIEW view_grpl_user_name AS 
 SELECT r.id,
    r.partner_id,
    r.alias_id,
    r.default_section_id,
    a.name,
    a.display_name
   FROM res_users r
     JOIN res_partner a ON a.id = r.partner_id
  ORDER BY r.id;

ALTER TABLE view_grpl_user_name
  OWNER TO postgres;

-- View: vg_stock_by_location_product_serial

-- DROP VIEW vg_stock_by_location_product_serial;

CREATE OR REPLACE VIEW vg_stock_by_location_product_serial AS 
 SELECT a.id,
    a.location_id,
    a.product_id,
    a.prodlot_id,
    b.complete_name AS wh_location,
    c.name_template AS variant_name,
    d.name AS product_name,
    e.name AS gtr_no,
    e.x_greentek_lot AS lot_no,
    e.x_greentek_imei AS imei_no,
    e.x_transfer_price_cost AS transfer_price,
    e.create_date AS stock_start_date,
    d.list_price,
    a.name AS stock_qty,
    round(a.name * d.list_price, 0) AS stock_value
   FROM stock_product_by_location_prodlot a
     LEFT JOIN stock_location b ON a.location_id = b.id
     LEFT JOIN product_product c ON a.product_id = c.id
     LEFT JOIN product_template d ON c.product_tmpl_id = d.id
     LEFT JOIN stock_production_lot e ON a.prodlot_id = e.id
  ORDER BY b.complete_name, d.name, e.name;

ALTER TABLE vg_stock_by_location_product_serial
  OWNER TO odoo;

-- View: vg_stock_by_location_with_price

-- DROP VIEW vg_stock_by_location_with_price;

CREATE OR REPLACE VIEW vg_stock_by_location_with_price AS 
 SELECT a.id,
    a.location_id,
    b.complete_name AS wh_location,
    a.product_id,
    c.name_template AS variant_name,
    d.name AS product_name,
    d.list_price,
    a.name AS stock_qty,
    round(a.name * d.list_price, 0) AS stock_value,
    a.product_qty_pending,
    a.company_id
   FROM stock_product_by_location a
     LEFT JOIN stock_location b ON a.location_id = b.id
     LEFT JOIN product_product c ON a.product_id = c.id
     LEFT JOIN product_template d ON c.product_tmpl_id = d.id;

ALTER TABLE vg_stock_by_location_with_price
  OWNER TO postgres;
GRANT ALL ON TABLE vg_stock_by_location_with_price TO postgres;
GRANT SELECT ON TABLE vg_stock_by_location_with_price TO joomla;

-- View: vg_stock_by_product

-- DROP VIEW vg_stock_by_product;

CREATE OR REPLACE VIEW vg_stock_by_product AS 
 SELECT min(stock_move_by_location.id) AS id,
    stock_move_by_location.product_id,
    sum(stock_move_by_location.name) AS product_qty,
    sum(stock_move_by_location.product_qty_pending) AS product_qty_pending
   FROM stock_move_by_location
  GROUP BY stock_move_by_location.product_id
 HAVING round(sum(stock_move_by_location.name), 4) <> 0::numeric;

ALTER TABLE vg_stock_by_product
  OWNER TO odoo;
  
CREATE OR REPLACE VIEW vg_duplicate_product_names AS 
 SELECT product_template.id,
    product_template.name,
    product_template.create_date,
    product_template.type
   FROM product_template
  WHERE (upper(product_template.name::text) IN ( SELECT upper(product_template_1.name::text) AS up_name
           FROM product_template product_template_1
          GROUP BY upper(product_template_1.name::text)
         HAVING count(*) > 1))
  ORDER BY product_template.name, product_template.create_date;

ALTER TABLE vg_duplicate_product_names
  OWNER TO odoo;

-- View: vg_duplicate_product_product_names_with_qty

-- DROP VIEW vg_duplicate_product_product_names_with_qty;

CREATE OR REPLACE VIEW vg_duplicate_product_product_names_with_qty AS 
 SELECT product_product.id,
    product_product.name_template AS name,
    product_product.create_date,
    vg_stock_by_product.product_qty
   FROM product_product
     LEFT JOIN vg_stock_by_product ON product_product.id = vg_stock_by_product.product_id
  WHERE (upper(product_product.name_template::text) IN ( SELECT upper(product_product_1.name_template::text) AS upper
           FROM product_product product_product_1
          GROUP BY upper(product_product_1.name_template::text)
         HAVING count(*) > 1))
  ORDER BY product_product.name_template, product_product.create_date;

ALTER TABLE vg_duplicate_product_product_names_with_qty
  OWNER TO odoo;

-- View: vg_invoice_line_serial_no

-- DROP VIEW vg_invoice_line_serial_no;

CREATE OR REPLACE VIEW vg_invoice_line_serial_no AS 
 SELECT a.id,
    a.origin,
    a.date,
    a.product_qty,
    a.location_id,
    a.picking_type_id,
    a.partner_id,
    a.state,
    a.name AS product_name,
    a.warehouse_id,
    a.group_id,
    a.picking_id,
    a.location_dest_id,
    a.invoice_state,
    a.invoice_line_id,
    b.product_id,
    b.quantity,
    b.price_unit,
    b.price_subtotal,
    b.discount,
    c.number AS invoice_number,
    c.date_invoice AS invoice_date,
    c.state AS invoice_status,
    e.lot_id,
    f.name AS serial_number,
    f.x_greentek_imei AS imei_no,
    f.x_transfer_price_cost AS transfer_price
   FROM stock_move a
     JOIN account_invoice_line b ON a.invoice_line_id = b.id
     JOIN account_invoice c ON b.invoice_id = c.id
     JOIN stock_quant_move_rel d ON a.id = d.move_id
     JOIN stock_quant e ON e.id = d.quant_id
     JOIN stock_production_lot f ON e.lot_id = f.id
  WHERE a.invoice_line_id IS NOT NULL AND c.state::text <> 'draft'::text AND c.state::text <> 'cancel'::text
  ORDER BY c.date_invoice, c.number;

ALTER TABLE vg_invoice_line_serial_no
  OWNER TO postgres;
GRANT ALL ON TABLE vg_invoice_line_serial_no TO postgres;
GRANT SELECT ON TABLE vg_invoice_line_serial_no TO joomla;

-- View: vg_invoice_portal

-- DROP VIEW vg_invoice_portal;

CREATE OR REPLACE VIEW vg_invoice_portal AS 
 SELECT j.number,
    j.internal_number AS cancel_invoice_number,
    j.date_invoice,
    f.origin AS invoice_so_no,
    j.reference,
    j.name AS reference_description,
    f.product_id,
    f.name AS invoice_product_name,
    f.price_unit AS invoice_unit_rate,
    f.quantity AS invoice_qty,
    f.discount AS invoice_discount,
    f.price_subtotal AS invoice_sub_total,
    h.name AS journal_name,
    a.display_name AS customer_name,
    c.display_name AS portal_name,
    b.name AS tax_name,
    j.state AS invoice_status,
    j.type AS invoice_or_refund,
    j.move_id,
    j.user_id
   FROM account_invoice_line f
     JOIN account_invoice j ON j.id = f.invoice_id
     JOIN account_journal h ON h.id = j.journal_id
     JOIN account_invoice_line_tax i ON i.invoice_line_id = f.id
     LEFT JOIN account_tax b ON b.id = i.tax_id
     JOIN res_partner a ON a.id = j.partner_id
     JOIN res_partner c ON c.id = a.parent_id
  WHERE a.parent_id IS NOT NULL;

ALTER TABLE vg_invoice_portal
  OWNER TO odoo;

-- View: vg_sale_order_details

-- DROP VIEW vg_sale_order_details;

CREATE OR REPLACE VIEW vg_sale_order_details AS 
 SELECT a.name AS sale_order,
    date(a.create_date) AS create_date_so,
    a.create_date::time without time zone AS create_time_so,
    date(a.date_order) AS so_date,
    a.date_order::time without time zone AS so_time,
    date(a.write_date) AS write_date_so,
    a.write_date::time without time zone AS write_time_so,
    a.partner_id,
    a.amount_tax,
    a.amount_untaxed,
    a.state,
    a.create_uid,
    a.section_id,
    a.user_id,
    a.date_confirm,
    a.amount_total,
    a.order_policy,
    a.warehouse_id,
    a.shipped,
    a.type_id,
    b.name AS sale_type,
    c.display_name AS customer,
    d.name AS salesperson,
    e.name AS user_name
   FROM sale_order a
     JOIN sale_order_type b ON a.type_id = b.id
     JOIN res_partner c ON a.partner_id = c.id
     JOIN view_grpl_user_name d ON a.user_id = d.id
     JOIN view_grpl_user_name e ON a.create_uid = e.id
  ORDER BY "substring"(a.name::text, 3, 4)::integer;

ALTER TABLE vg_sale_order_details
  OWNER TO odoo;



-- View: view_grpl_gtr_no_product_name_status

-- DROP VIEW view_grpl_gtr_no_product_name_status;

CREATE OR REPLACE VIEW view_grpl_gtr_no_product_name_status AS 
 SELECT c.id AS prod_id,
    v.id AS gtr_id,
    v.name AS gtr_no,
    w.qty,
    w.in_date,
    c.name_template AS product_name,
    v.x_transfer_price_cost,
    d.list_price,
    v.x_greentek_lot,
    v.x_greentek_imei,
    y.name AS stock_location_name,
    aa.name AS inventory_name,
    aa.state AS inventory_status,
    u.picking_id,
    ab.origin,
    ab.date_done AS picking_dt,
    ab.state AS picking_status,
    ab.name AS challan_no,
    ab.date AS challan_dt,
    ab.partner_id,
    a.name AS customer_name
   FROM product_product c
     JOIN stock_production_lot v ON v.product_id = c.id
     JOIN product_template d ON d.id = c.product_tmpl_id
     JOIN stock_quant w ON w.lot_id = v.id
     JOIN stock_location y ON y.id = w.location_id
     JOIN stock_inventory_line z ON z.prod_lot_id = v.id
     JOIN stock_inventory aa ON aa.id = z.inventory_id
     JOIN stock_pack_operation u ON u.lot_id = w.lot_id
     JOIN stock_picking ab ON ab.id = u.picking_id
     JOIN res_partner a ON a.id = ab.partner_id
  ORDER BY v.id;

ALTER TABLE view_grpl_gtr_no_product_name_status
  OWNER TO postgres;
GRANT ALL ON TABLE view_grpl_gtr_no_product_name_status TO postgres;
GRANT SELECT ON TABLE view_grpl_gtr_no_product_name_status TO joomla;

-- View: view_grpl_invoice

-- DROP VIEW view_grpl_invoice;

CREATE OR REPLACE VIEW view_grpl_invoice AS 
 SELECT j.number,
    j.internal_number AS cancel_invoice_number,
    j.date_invoice,
    f.origin AS invoice_so_no,
    j.reference,
    j.name AS reference_description,
    f.product_id,
    f.name AS invoice_product_name,
    f.price_unit AS invoice_unit_rate,
    f.quantity AS invoice_qty,
    f.discount AS invoice_discount,
    f.price_subtotal AS invoice_sub_total,
    h.name AS journal_name,
    a.name AS customer_name,
    b.name AS tax_name,
    j.state AS invoice_status,
    j.type AS invoice_or_refund,
    j.move_id,
    k.name AS sales_team,
    a.display_name AS customer,
    l.display_name AS sales_person
   FROM account_invoice_line f
     JOIN account_invoice j ON j.id = f.invoice_id
     JOIN account_journal h ON h.id = j.journal_id
     JOIN account_invoice_line_tax i ON i.invoice_line_id = f.id
     JOIN account_tax b ON b.id = i.tax_id
     JOIN res_partner a ON a.id = j.partner_id
     JOIN view_grpl_user_name l ON l.id = j.user_id
     LEFT JOIN crm_case_section k ON k.id = j.section_id;

ALTER TABLE view_grpl_invoice
  OWNER TO postgres;

-- View: view_grpl_product_gtr_with_location

-- DROP VIEW view_grpl_product_gtr_with_location;

CREATE OR REPLACE VIEW view_grpl_product_gtr_with_location AS 
 SELECT ag.product_id,
    ac.product_tmpl_id,
    ag.lot_id,
    ag.in_date,
    aa.name AS grpl_no,
    aa.x_greentek_lot,
    aa.x_greentek_imei,
    aa.x_transfer_price_cost,
    ac.name_template AS product_name,
    ac.active,
    ae.complete_name AS location_name,
    ad.list_price,
    ad.name AS product_temp_name,
    ad.type AS stock_type
   FROM stock_quant ag
     JOIN stock_production_lot aa ON aa.id = ag.lot_id
     JOIN product_product ac ON ac.id = aa.product_id
     JOIN stock_location ae ON ae.id = ag.location_id
     JOIN product_template ad ON ad.id = ac.product_tmpl_id;

ALTER TABLE view_grpl_product_gtr_with_location
  OWNER TO postgres;

-- View: view_grpl_sale_order

-- DROP VIEW view_grpl_sale_order;

CREATE OR REPLACE VIEW view_grpl_sale_order AS 
 SELECT l.name AS so_name,
    l.date_order,
    l.message_last_post,
    l.date_confirm,
    e.product_id,
    e.name AS so_product_name,
    q.name AS sale_location,
    p.name AS warehouse_name,
    l.client_order_ref,
    e.product_uom_qty AS so_qty,
    e.price_unit AS so_unit_price,
    e.discount AS so_discount,
    e.margin,
    a.display_name,
    b.name AS tax_name,
    l.user_id,
    r.display_name AS salesperson,
    e.state AS so_status
   FROM sale_order_line e
     JOIN sale_order l ON l.id = e.order_id
     JOIN res_partner a ON a.id = l.partner_id
     LEFT JOIN sale_order_tax o ON o.order_line_id = e.id
     LEFT JOIN account_tax b ON b.id = o.tax_id
     JOIN stock_warehouse p ON p.id = l.warehouse_id
     JOIN sale_order_type q ON q.id = l.type_id
     JOIN view_grpl_user_name r ON r.id = l.user_id;

ALTER TABLE view_grpl_sale_order
  OWNER TO postgres;


-- View: view_grpl_xxx_serial_lot

-- DROP VIEW view_grpl_xxx_serial_lot;

CREATE OR REPLACE VIEW view_grpl_xxx_serial_lot AS 
 SELECT a.id AS gtrid,
    c.lot_id AS gtr_id,
    a.name AS gtr_no,
    a.product_id,
    b.id,
    c.product_id AS quant_product_id,
    b.name_template AS product_name,
    c.qty,
    a.create_date AS stock_creation_date,
    d.name AS location_name,
    a.x_greentek_lot,
    a.x_greentek_imei,
    a.x_transfer_price_cost,
    c.in_date,
    e.location_id,
    e.date AS pack_date,
    e.location_dest_id
   FROM stock_production_lot a
     JOIN product_product b ON b.id = a.product_id
     JOIN stock_quant c ON c.lot_id = a.id
     JOIN stock_location d ON d.id = c.location_id
     LEFT JOIN stock_pack_operation e ON e.lot_id = a.id;

ALTER TABLE view_grpl_xxx_serial_lot
  OWNER TO postgres;

-- View: view_grpl_xxx_stock_by_location

-- DROP VIEW view_grpl_xxx_stock_by_location;

CREATE OR REPLACE VIEW view_grpl_xxx_stock_by_location AS 
 SELECT a.id,
    a.location_id,
    b.complete_name AS wh_location,
    a.product_id,
    c.name_template AS variant_name,
    d.name AS product_name,
    d.list_price,
    a.name AS stock_qty,
    a.product_qty_pending,
    a.company_id
   FROM stock_product_by_location a
     LEFT JOIN stock_location b ON a.location_id = b.id
     LEFT JOIN product_product c ON a.product_id = c.id
     LEFT JOIN product_template d ON c.product_tmpl_id = d.id;

ALTER TABLE view_grpl_xxx_stock_by_location
  OWNER TO postgres;
GRANT ALL ON TABLE view_grpl_xxx_stock_by_location TO postgres;
GRANT SELECT ON TABLE view_grpl_xxx_stock_by_location TO joomla;

-- View: view_grpl_xxx_stock_product_by_prodlot

-- DROP VIEW view_grpl_xxx_stock_product_by_prodlot;

CREATE OR REPLACE VIEW view_grpl_xxx_stock_product_by_prodlot AS 
 SELECT min(stock_move_by_location.id) AS id,
    stock_move_by_location.product_id,
    stock_move_by_location.prodlot_id,
    sum(stock_move_by_location.name) AS name,
    sum(stock_move_by_location.product_qty_pending) AS product_qty_pending,
    stock_move_by_location.company_id
   FROM stock_move_by_location
  GROUP BY stock_move_by_location.prodlot_id, stock_move_by_location.product_id, stock_move_by_location.company_id
 HAVING round(sum(stock_move_by_location.name), 4) <> 0::numeric;

ALTER TABLE view_grpl_xxx_stock_product_by_prodlot
  OWNER TO postgres;
GRANT ALL ON TABLE view_grpl_xxx_stock_product_by_prodlot TO postgres;
GRANT SELECT ON TABLE view_grpl_xxx_stock_product_by_prodlot TO joomla;
  