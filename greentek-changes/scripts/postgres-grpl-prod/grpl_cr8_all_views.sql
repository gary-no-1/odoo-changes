-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_user_name AS 
 SELECT r.id,
    r.partner_id,
    r.alias_id,
    r.default_section_id,
    a.name,
    a.display_name,
    b.complete_name AS team_name
   FROM ((res_users r
     JOIN res_partner a ON ((a.id = r.partner_id)))
     LEFT JOIN crm_case_section b ON ((r.default_section_id = b.id)))
  ORDER BY r.id;
 ALTER TABLE vg_user_name OWNER TO postgres;
 GRANT ALL ON vg_user_name TO postgres;
 GRANT ALL ON vg_user_name TO odoo;
 GRANT SELECT ON vg_user_name TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_grpl_user_name AS 
 SELECT r.id,
    r.partner_id,
    r.alias_id,
    r.default_section_id,
    a.name,
    a.display_name
   FROM (res_users r
     JOIN res_partner a ON ((a.id = r.partner_id)))
  ORDER BY r.id;
 ALTER TABLE view_grpl_user_name OWNER TO postgres;
 GRANT ALL ON view_grpl_user_name TO postgres;
 GRANT ALL ON view_grpl_user_name TO odoo;
 GRANT SELECT ON view_grpl_user_name TO joomla;

-- ------------------------------------------------------------
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
    round((a.name * d.list_price), 0) AS stock_value
   FROM ((((stock_product_by_location_prodlot a
     LEFT JOIN stock_location b ON ((a.location_id = b.id)))
     LEFT JOIN product_product c ON ((a.product_id = c.id)))
     LEFT JOIN product_template d ON ((c.product_tmpl_id = d.id)))
     LEFT JOIN stock_production_lot e ON ((a.prodlot_id = e.id)))
  ORDER BY b.complete_name, d.name, e.name;
 ALTER TABLE vg_stock_by_location_product_serial OWNER TO postgres;
 GRANT ALL ON vg_stock_by_location_product_serial TO postgres;
 GRANT ALL ON vg_stock_by_location_product_serial TO odoo;
 GRANT SELECT ON vg_stock_by_location_product_serial TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_stock_by_location_with_price AS 
 SELECT a.id,
    a.location_id,
    b.complete_name AS wh_location,
    a.product_id,
    c.name_template AS variant_name,
    d.name AS product_name,
    d.list_price,
    a.name AS stock_qty,
    round((a.name * d.list_price), 0) AS stock_value,
    a.product_qty_pending,
    a.company_id
   FROM (((stock_product_by_location a
     LEFT JOIN stock_location b ON ((a.location_id = b.id)))
     LEFT JOIN product_product c ON ((a.product_id = c.id)))
     LEFT JOIN product_template d ON ((c.product_tmpl_id = d.id)));
 ALTER TABLE vg_stock_by_location_with_price OWNER TO postgres;
 GRANT ALL ON vg_stock_by_location_with_price TO postgres;
 GRANT ALL ON vg_stock_by_location_with_price TO odoo;
 GRANT SELECT ON vg_stock_by_location_with_price TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_stock_by_product AS 
 SELECT min(stock_move_by_location.id) AS id,
    stock_move_by_location.product_id,
    sum(stock_move_by_location.name) AS product_qty,
    sum(stock_move_by_location.product_qty_pending) AS product_qty_pending
   FROM stock_move_by_location
  GROUP BY stock_move_by_location.product_id
 HAVING (round(sum(stock_move_by_location.name), 4) <> (0)::numeric);
 ALTER TABLE vg_stock_by_product OWNER TO postgres;
 GRANT ALL ON vg_stock_by_product TO postgres;
 GRANT ALL ON vg_stock_by_product TO odoo;
 GRANT SELECT ON vg_stock_by_product TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_duplicate_product_product_names_with_qty AS 
 SELECT product_product.id,
    product_product.name_template AS name,
    product_product.create_date,
    vg_stock_by_product.product_qty
   FROM (product_product
     LEFT JOIN vg_stock_by_product ON ((product_product.id = vg_stock_by_product.product_id)))
  WHERE (upper((product_product.name_template)::text) IN ( SELECT upper((product_product_1.name_template)::text) AS upper
           FROM product_product product_product_1
          GROUP BY upper((product_product_1.name_template)::text)
         HAVING (count(*) > 1)))
  ORDER BY product_product.name_template, product_product.create_date;
 ALTER TABLE vg_duplicate_product_product_names_with_qty OWNER TO postgres;
 GRANT ALL ON vg_duplicate_product_product_names_with_qty TO postgres;
 GRANT ALL ON vg_duplicate_product_product_names_with_qty TO odoo;
 GRANT SELECT ON vg_duplicate_product_product_names_with_qty TO joomla;

-- ------------------------------------------------------------
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
   FROM (((((stock_move a
     JOIN account_invoice_line b ON ((a.invoice_line_id = b.id)))
     JOIN account_invoice c ON ((b.invoice_id = c.id)))
     JOIN stock_quant_move_rel d ON ((a.id = d.move_id)))
     JOIN stock_quant e ON ((e.id = d.quant_id)))
     JOIN stock_production_lot f ON ((e.lot_id = f.id)))
  WHERE (((a.invoice_line_id IS NOT NULL) AND ((c.state)::text <> 'draft'::text)) AND ((c.state)::text <> 'cancel'::text))
  ORDER BY c.date_invoice, c.number;
 ALTER TABLE vg_invoice_line_serial_no OWNER TO postgres;
 GRANT ALL ON vg_invoice_line_serial_no TO postgres;
 GRANT ALL ON vg_invoice_line_serial_no TO odoo;
 GRANT SELECT ON vg_invoice_line_serial_no TO joomla;

-- ------------------------------------------------------------
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
   FROM ((((((account_invoice_line f
     JOIN account_invoice j ON ((j.id = f.invoice_id)))
     JOIN account_journal h ON ((h.id = j.journal_id)))
     JOIN account_invoice_line_tax i ON ((i.invoice_line_id = f.id)))
     LEFT JOIN account_tax b ON ((b.id = i.tax_id)))
     JOIN res_partner a ON ((a.id = j.partner_id)))
     JOIN res_partner c ON ((c.id = a.parent_id)))
  WHERE (a.parent_id IS NOT NULL);
 ALTER TABLE vg_invoice_portal OWNER TO postgres;
 GRANT ALL ON vg_invoice_portal TO postgres;
 GRANT ALL ON vg_invoice_portal TO odoo;
 GRANT SELECT ON vg_invoice_portal TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_sale_order_details AS 
 SELECT a.name AS sale_order,
    date(a.create_date) AS create_date_so,
    (a.create_date)::time without time zone AS create_time_so,
    date(a.date_order) AS so_date,
    (a.date_order)::time without time zone AS so_time,
    date(a.write_date) AS write_date_so,
    (a.write_date)::time without time zone AS write_time_so,
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
   FROM ((((sale_order a
     JOIN sale_order_type b ON ((a.type_id = b.id)))
     JOIN res_partner c ON ((a.partner_id = c.id)))
     JOIN view_grpl_user_name d ON ((a.user_id = d.id)))
     JOIN view_grpl_user_name e ON ((a.create_uid = e.id)))
  ORDER BY ("substring"((a.name)::text, 3, 4))::integer;
 ALTER TABLE vg_sale_order_details OWNER TO postgres;
 GRANT ALL ON vg_sale_order_details TO postgres;
 GRANT ALL ON vg_sale_order_details TO odoo;
 GRANT SELECT ON vg_sale_order_details TO joomla;

-- ------------------------------------------------------------
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
   FROM (((((((((product_product c
     JOIN stock_production_lot v ON ((v.product_id = c.id)))
     JOIN product_template d ON ((d.id = c.product_tmpl_id)))
     JOIN stock_quant w ON ((w.lot_id = v.id)))
     JOIN stock_location y ON ((y.id = w.location_id)))
     JOIN stock_inventory_line z ON ((z.prod_lot_id = v.id)))
     JOIN stock_inventory aa ON ((aa.id = z.inventory_id)))
     JOIN stock_pack_operation u ON ((u.lot_id = w.lot_id)))
     JOIN stock_picking ab ON ((ab.id = u.picking_id)))
     JOIN res_partner a ON ((a.id = ab.partner_id)))
  ORDER BY v.id;
 ALTER TABLE view_grpl_gtr_no_product_name_status OWNER TO postgres;
 GRANT ALL ON view_grpl_gtr_no_product_name_status TO postgres;
 GRANT ALL ON view_grpl_gtr_no_product_name_status TO odoo;
 GRANT SELECT ON view_grpl_gtr_no_product_name_status TO joomla;

-- ------------------------------------------------------------
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
   FROM (((((((account_invoice_line f
     JOIN account_invoice j ON ((j.id = f.invoice_id)))
     JOIN account_journal h ON ((h.id = j.journal_id)))
     JOIN account_invoice_line_tax i ON ((i.invoice_line_id = f.id)))
     JOIN account_tax b ON ((b.id = i.tax_id)))
     JOIN res_partner a ON ((a.id = j.partner_id)))
     JOIN view_grpl_user_name l ON ((l.id = j.user_id)))
     LEFT JOIN crm_case_section k ON ((k.id = j.section_id)));
 ALTER TABLE view_grpl_invoice OWNER TO postgres;
 GRANT ALL ON view_grpl_invoice TO postgres;
 GRANT ALL ON view_grpl_invoice TO odoo;
 GRANT SELECT ON view_grpl_invoice TO joomla;

-- ------------------------------------------------------------
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
   FROM ((((stock_quant ag
     JOIN stock_production_lot aa ON ((aa.id = ag.lot_id)))
     JOIN product_product ac ON ((ac.id = aa.product_id)))
     JOIN stock_location ae ON ((ae.id = ag.location_id)))
     JOIN product_template ad ON ((ad.id = ac.product_tmpl_id)));
 ALTER TABLE view_grpl_product_gtr_with_location OWNER TO postgres;
 GRANT ALL ON view_grpl_product_gtr_with_location TO postgres;
 GRANT ALL ON view_grpl_product_gtr_with_location TO odoo;
 GRANT SELECT ON view_grpl_product_gtr_with_location TO joomla;

-- ------------------------------------------------------------
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
   FROM (((((((sale_order_line e
     JOIN sale_order l ON ((l.id = e.order_id)))
     JOIN res_partner a ON ((a.id = l.partner_id)))
     LEFT JOIN sale_order_tax o ON ((o.order_line_id = e.id)))
     LEFT JOIN account_tax b ON ((b.id = o.tax_id)))
     JOIN stock_warehouse p ON ((p.id = l.warehouse_id)))
     JOIN sale_order_type q ON ((q.id = l.type_id)))
     JOIN view_grpl_user_name r ON ((r.id = l.user_id)));
 ALTER TABLE view_grpl_sale_order OWNER TO postgres;
 GRANT ALL ON view_grpl_sale_order TO postgres;
 GRANT ALL ON view_grpl_sale_order TO odoo;
 GRANT SELECT ON view_grpl_sale_order TO joomla;

-- ------------------------------------------------------------
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
   FROM ((((stock_production_lot a
     JOIN product_product b ON ((b.id = a.product_id)))
     JOIN stock_quant c ON ((c.lot_id = a.id)))
     JOIN stock_location d ON ((d.id = c.location_id)))
     LEFT JOIN stock_pack_operation e ON ((e.lot_id = a.id)));
 ALTER TABLE view_grpl_xxx_serial_lot OWNER TO postgres;
 GRANT ALL ON view_grpl_xxx_serial_lot TO postgres;
 GRANT ALL ON view_grpl_xxx_serial_lot TO odoo;
 GRANT SELECT ON view_grpl_xxx_serial_lot TO joomla;

-- ------------------------------------------------------------
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
   FROM (((stock_product_by_location a
     LEFT JOIN stock_location b ON ((a.location_id = b.id)))
     LEFT JOIN product_product c ON ((a.product_id = c.id)))
     LEFT JOIN product_template d ON ((c.product_tmpl_id = d.id)));
 ALTER TABLE view_grpl_xxx_stock_by_location OWNER TO postgres;
 GRANT ALL ON view_grpl_xxx_stock_by_location TO postgres;
 GRANT ALL ON view_grpl_xxx_stock_by_location TO odoo;
 GRANT SELECT ON view_grpl_xxx_stock_by_location TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW view_grpl_xxx_stock_product_by_prodlot AS 
 SELECT min(stock_move_by_location.id) AS id,
    stock_move_by_location.product_id,
    stock_move_by_location.prodlot_id,
    sum(stock_move_by_location.name) AS name,
    sum(stock_move_by_location.product_qty_pending) AS product_qty_pending,
    stock_move_by_location.company_id
   FROM stock_move_by_location
  GROUP BY stock_move_by_location.prodlot_id, stock_move_by_location.product_id, stock_move_by_location.company_id
 HAVING (round(sum(stock_move_by_location.name), 4) <> (0)::numeric);
 ALTER TABLE view_grpl_xxx_stock_product_by_prodlot OWNER TO postgres;
 GRANT ALL ON view_grpl_xxx_stock_product_by_prodlot TO postgres;
 GRANT ALL ON view_grpl_xxx_stock_product_by_prodlot TO odoo;
 GRANT SELECT ON view_grpl_xxx_stock_product_by_prodlot TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_xxx_stock_location_make_model_1 AS 
 SELECT vg_stock_by_location_with_price.wh_location,
    vg_stock_by_location_with_price.product_name,
    split_part((vg_stock_by_location_with_price.product_name)::text, '-'::text, 1) AS make,
    split_part((vg_stock_by_location_with_price.product_name)::text, '-'::text, 2) AS model,
    split_part((vg_stock_by_location_with_price.product_name)::text, '-'::text, 3) AS hdd,
    split_part((vg_stock_by_location_with_price.product_name)::text, '-'::text, 4) AS grade,
    upper(split_part((vg_stock_by_location_with_price.product_name)::text, '-'::text, 6)) AS color,
    vg_stock_by_location_with_price.list_price,
    vg_stock_by_location_with_price.stock_qty,
    vg_stock_by_location_with_price.stock_value,
    vg_stock_by_location_with_price.product_qty_pending,
    vg_stock_by_location_with_price.company_id
   FROM vg_stock_by_location_with_price;
 ALTER TABLE vg_xxx_stock_location_make_model_1 OWNER TO postgres;
 GRANT ALL ON vg_xxx_stock_location_make_model_1 TO postgres;
 GRANT ALL ON vg_xxx_stock_location_make_model_1 TO odoo;
 GRANT SELECT ON vg_xxx_stock_location_make_model_1 TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_xxx_stock_location_make_model_2 AS 
 SELECT vg_xxx_stock_location_make_model_1.wh_location,
    vg_xxx_stock_location_make_model_1.product_name,
    vg_xxx_stock_location_make_model_1.make,
    vg_xxx_stock_location_make_model_1.model,
    vg_xxx_stock_location_make_model_1.hdd,
    vg_xxx_stock_location_make_model_1.grade,
    vg_xxx_stock_location_make_model_1.color,
        CASE
            WHEN (vg_xxx_stock_location_make_model_1.grade = 'NO'::text) THEN vg_xxx_stock_location_make_model_1.stock_qty
            ELSE (0)::numeric
        END AS no_qty,
        CASE
            WHEN (vg_xxx_stock_location_make_model_1.grade = 'NS'::text) THEN vg_xxx_stock_location_make_model_1.stock_qty
            ELSE (0)::numeric
        END AS ns_qty,
        CASE
            WHEN (vg_xxx_stock_location_make_model_1.grade = 'NR'::text) THEN vg_xxx_stock_location_make_model_1.stock_qty
            ELSE (0)::numeric
        END AS nr_qty,
        CASE
            WHEN (vg_xxx_stock_location_make_model_1.grade = 'NE'::text) THEN vg_xxx_stock_location_make_model_1.stock_qty
            ELSE (0)::numeric
        END AS ne_qty,
        CASE
            WHEN (vg_xxx_stock_location_make_model_1.grade = 'NW'::text) THEN vg_xxx_stock_location_make_model_1.stock_qty
            ELSE (0)::numeric
        END AS nw_qty,
        CASE
            WHEN (vg_xxx_stock_location_make_model_1.grade = 'NB'::text) THEN vg_xxx_stock_location_make_model_1.stock_qty
            ELSE (0)::numeric
        END AS nb_qty,
        CASE
            WHEN (vg_xxx_stock_location_make_model_1.grade = 'NM'::text) THEN vg_xxx_stock_location_make_model_1.stock_qty
            ELSE (0)::numeric
        END AS nm_qty,
    vg_xxx_stock_location_make_model_1.list_price,
    vg_xxx_stock_location_make_model_1.stock_qty,
    vg_xxx_stock_location_make_model_1.stock_value,
    vg_xxx_stock_location_make_model_1.product_qty_pending,
    vg_xxx_stock_location_make_model_1.company_id
   FROM vg_xxx_stock_location_make_model_1;
 ALTER TABLE vg_xxx_stock_location_make_model_2 OWNER TO postgres;
 GRANT ALL ON vg_xxx_stock_location_make_model_2 TO postgres;
 GRANT ALL ON vg_xxx_stock_location_make_model_2 TO odoo;
 GRANT SELECT ON vg_xxx_stock_location_make_model_2 TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_xxx_location_product_sale_date AS 
 SELECT i.id,
    i.origin,
    i.product_uom,
    i.company_id,
    i.date,
    i.product_qty,
    i.location_id,
    i.picking_type_id,
    i.state,
    i.restrict_lot_id,
    i.product_id,
    i.picking_id,
    i.location_dest_id,
    i.invoice_state,
    i.invoice_line_id,
    l.complete_name AS wh_location,
    m.code,
    m.name AS picking_type,
    a.name_template AS product_name
   FROM (((stock_move i
     JOIN stock_location l ON ((i.location_id = l.id)))
     JOIN stock_picking_type m ON ((i.picking_type_id = m.id)))
     JOIN product_product a ON ((i.product_id = a.id)))
  WHERE (((((i.state)::text <> 'cancel'::text) AND ((i.invoice_state)::text = 'invoiced'::text)) AND (i.invoice_line_id IS NOT NULL)) AND ((m.name)::text = 'Delivery Orders'::text));
 ALTER TABLE vg_xxx_location_product_sale_date OWNER TO postgres;
 GRANT ALL ON vg_xxx_location_product_sale_date TO postgres;
 GRANT ALL ON vg_xxx_location_product_sale_date TO odoo;
 GRANT SELECT ON vg_xxx_location_product_sale_date TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_xxx_location_product_last_sale_date AS 
 SELECT vg_xxx_location_product_sale_date.wh_location,
    vg_xxx_location_product_sale_date.product_name,
    max(vg_xxx_location_product_sale_date.date) AS last_sale_date
   FROM vg_xxx_location_product_sale_date
  GROUP BY vg_xxx_location_product_sale_date.wh_location, vg_xxx_location_product_sale_date.product_name;
 ALTER TABLE vg_xxx_location_product_last_sale_date OWNER TO postgres;
 GRANT ALL ON vg_xxx_location_product_last_sale_date TO postgres;
 GRANT ALL ON vg_xxx_location_product_last_sale_date TO odoo;
 GRANT SELECT ON vg_xxx_location_product_last_sale_date TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_xxx_stock_location_product_serial_make_model AS 
 SELECT vg_stock_by_location_product_serial.wh_location,
    vg_stock_by_location_product_serial.product_name,
    split_part((vg_stock_by_location_product_serial.product_name)::text, '-'::text, 1) AS make,
    split_part((vg_stock_by_location_product_serial.product_name)::text, '-'::text, 2) AS model,
    split_part((vg_stock_by_location_product_serial.product_name)::text, '-'::text, 3) AS hdd,
    split_part((vg_stock_by_location_product_serial.product_name)::text, '-'::text, 4) AS grade,
    upper(split_part((vg_stock_by_location_product_serial.product_name)::text, '-'::text, 6)) AS color,
    vg_stock_by_location_product_serial.gtr_no,
    vg_stock_by_location_product_serial.stock_start_date,
    vg_xxx_location_product_last_sale_date.last_sale_date,
    vg_stock_by_location_product_serial.list_price,
    vg_stock_by_location_product_serial.stock_qty,
        CASE
            WHEN (vg_stock_by_location_product_serial.stock_start_date IS NOT NULL) THEN date_part('day'::text, age(now(), (vg_stock_by_location_product_serial.stock_start_date)::timestamp with time zone))
            ELSE (60)::double precision
        END AS age
   FROM (vg_stock_by_location_product_serial
     LEFT JOIN vg_xxx_location_product_last_sale_date ON ((((vg_xxx_location_product_last_sale_date.wh_location)::text = (vg_stock_by_location_product_serial.wh_location)::text) AND ((vg_xxx_location_product_last_sale_date.product_name)::text = (vg_stock_by_location_product_serial.product_name)::text))));
 ALTER TABLE vg_xxx_stock_location_product_serial_make_model OWNER TO postgres;
 GRANT ALL ON vg_xxx_stock_location_product_serial_make_model TO postgres;
 GRANT ALL ON vg_xxx_stock_location_product_serial_make_model TO odoo;
 GRANT SELECT ON vg_xxx_stock_location_product_serial_make_model TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_stock_location_make_model_hdd_grade_color_ageing AS 
 SELECT vg_xxx_stock_location_product_serial_make_model.wh_location,
    vg_xxx_stock_location_product_serial_make_model.make,
    vg_xxx_stock_location_product_serial_make_model.model,
    vg_xxx_stock_location_product_serial_make_model.hdd,
    vg_xxx_stock_location_product_serial_make_model.grade,
    vg_xxx_stock_location_product_serial_make_model.color,
    max(vg_xxx_stock_location_product_serial_make_model.list_price) AS rsp,
    sum(vg_xxx_stock_location_product_serial_make_model.stock_qty) AS stock_qty,
    max(vg_xxx_stock_location_product_serial_make_model.last_sale_date) AS last_sale_date,
    (avg(vg_xxx_stock_location_product_serial_make_model.age))::bigint AS age
   FROM vg_xxx_stock_location_product_serial_make_model
  GROUP BY vg_xxx_stock_location_product_serial_make_model.wh_location, vg_xxx_stock_location_product_serial_make_model.make, vg_xxx_stock_location_product_serial_make_model.model, vg_xxx_stock_location_product_serial_make_model.hdd, vg_xxx_stock_location_product_serial_make_model.grade, vg_xxx_stock_location_product_serial_make_model.color
 HAVING (sum(vg_xxx_stock_location_product_serial_make_model.stock_qty) > (0)::numeric);
 ALTER TABLE vg_stock_location_make_model_hdd_grade_color_ageing OWNER TO postgres;
 GRANT ALL ON vg_stock_location_make_model_hdd_grade_color_ageing TO postgres;
 GRANT ALL ON vg_stock_location_make_model_hdd_grade_color_ageing TO odoo;
 GRANT SELECT ON vg_stock_location_make_model_hdd_grade_color_ageing TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_stock_location_make_model_hdd_ageing AS 
 SELECT vg_xxx_stock_location_product_serial_make_model.wh_location,
    vg_xxx_stock_location_product_serial_make_model.make,
    vg_xxx_stock_location_product_serial_make_model.model,
    vg_xxx_stock_location_product_serial_make_model.hdd,
    max(vg_xxx_stock_location_product_serial_make_model.list_price) AS rsp,
    sum(vg_xxx_stock_location_product_serial_make_model.stock_qty) AS stock_qty,
    max(vg_xxx_stock_location_product_serial_make_model.last_sale_date) AS last_sale_date,
    (avg(vg_xxx_stock_location_product_serial_make_model.age))::bigint AS age
   FROM vg_xxx_stock_location_product_serial_make_model
  GROUP BY vg_xxx_stock_location_product_serial_make_model.wh_location, vg_xxx_stock_location_product_serial_make_model.make, vg_xxx_stock_location_product_serial_make_model.model, vg_xxx_stock_location_product_serial_make_model.hdd
 HAVING (sum(vg_xxx_stock_location_product_serial_make_model.stock_qty) > (0)::numeric);
 ALTER TABLE vg_stock_location_make_model_hdd_ageing OWNER TO postgres;
 GRANT ALL ON vg_stock_location_make_model_hdd_ageing TO postgres;
 GRANT ALL ON vg_stock_location_make_model_hdd_ageing TO odoo;
 GRANT SELECT ON vg_stock_location_make_model_hdd_ageing TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_xxx_stock_location_product_serial_make_model_2 AS 
 WITH l AS (
         SELECT a.id,
            a.location_id,
            a.product_id,
            a.prodlot_id,
            e.name AS gtr_no,
            e.x_greentek_lot AS lot_no,
            e.x_transfer_price_cost AS transfer_price,
                CASE
                    WHEN (e.create_date IS NOT NULL) THEN date_part('day'::text, age(now(), (e.create_date)::timestamp with time zone))
                    ELSE (60)::double precision
                END AS age,
            a.name AS stock_qty
           FROM (stock_product_by_location_prodlot a
             LEFT JOIN stock_production_lot e ON ((a.prodlot_id = e.id)))
        ), s AS (
         SELECT i.location_id,
            i.product_id,
            max(i.date) AS last_sale_date
           FROM (stock_move i
             JOIN stock_picking_type m ON ((i.picking_type_id = m.id)))
          WHERE (((((i.state)::text <> 'cancel'::text) AND ((i.invoice_state)::text = 'invoiced'::text)) AND (i.invoice_line_id IS NOT NULL)) AND ((m.name)::text = 'Delivery Orders'::text))
          GROUP BY i.location_id, i.product_id
        )
 SELECT l.id,
    l.location_id,
    l.product_id,
    l.prodlot_id,
    r.complete_name AS wh_location,
    d.name AS product_name,
    split_part((d.name)::text, '-'::text, 1) AS make,
    split_part((d.name)::text, '-'::text, 2) AS model,
    split_part((d.name)::text, '-'::text, 3) AS hdd,
    split_part((d.name)::text, '-'::text, 4) AS grade,
    upper(split_part((d.name)::text, '-'::text, 6)) AS color,
    d.list_price,
    l.gtr_no,
    l.lot_no,
    l.transfer_price,
    l.age,
    l.stock_qty,
    s.last_sale_date
   FROM ((((l
     LEFT JOIN s ON (((l.location_id = s.location_id) AND (l.product_id = s.product_id))))
     JOIN product_product c ON ((l.product_id = c.id)))
     JOIN product_template d ON ((c.product_tmpl_id = d.id)))
     JOIN stock_location r ON ((l.location_id = r.id)));
 ALTER TABLE vg_xxx_stock_location_product_serial_make_model_2 OWNER TO postgres;
 GRANT ALL ON vg_xxx_stock_location_product_serial_make_model_2 TO postgres;
 GRANT ALL ON vg_xxx_stock_location_product_serial_make_model_2 TO odoo;
 GRANT SELECT ON vg_xxx_stock_location_product_serial_make_model_2 TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_stock_location_make_model_hdd_grade_color_ageing_2 AS 
 WITH s AS (
         SELECT a.wh_location,
            a.make,
            a.model,
            a.hdd,
            a.grade,
            a.color,
            max(a.list_price) AS rsp,
            max(a.age) AS max_age,
            avg(a.age) AS avg_age,
            sum(a.stock_qty) AS stock_qty,
            max(a.last_sale_date) AS last_sale_date
           FROM vg_xxx_stock_location_product_serial_make_model_2 a
          GROUP BY a.wh_location, a.make, a.model, a.hdd, a.grade, a.color
         HAVING (sum(a.stock_qty) > (0)::numeric)
        ), u AS (
         WITH t AS (
                 SELECT b.wh_location,
                    b.make,
                    b.model,
                    b.hdd,
                    b.grade,
                    b.color,
                    max(b.age) AS max_age
                   FROM vg_xxx_stock_location_product_serial_make_model_2 b
                  GROUP BY b.wh_location, b.make, b.model, b.hdd, b.grade, b.color
                )
         SELECT x.wh_location,
            x.make,
            x.model,
            x.hdd,
            x.grade,
            x.color,
            sum(x.stock_qty) AS max_age_stock_qty
           FROM (vg_xxx_stock_location_product_serial_make_model_2 x
             JOIN t ON (((((((((x.wh_location)::text = (t.wh_location)::text) AND (x.make = t.make)) AND (t.model = x.model)) AND (t.hdd = x.hdd)) AND (t.grade = x.grade)) AND (t.color = x.color)) AND (x.age = t.max_age))))
          GROUP BY x.wh_location, x.make, x.model, x.hdd, x.grade, x.color
        )
 SELECT s.wh_location,
    s.make,
    s.model,
    s.hdd,
    s.grade,
    s.color,
    s.rsp,
    s.max_age,
    u.max_age_stock_qty,
    (s.avg_age)::integer AS avg_age,
    s.stock_qty,
    s.last_sale_date
   FROM (s
     JOIN u ON ((((((((s.wh_location)::text = (u.wh_location)::text) AND (s.make = u.make)) AND (s.model = u.model)) AND (s.hdd = u.hdd)) AND (s.grade = u.grade)) AND (s.color = u.color))));
 ALTER TABLE vg_stock_location_make_model_hdd_grade_color_ageing_2 OWNER TO postgres;
 GRANT ALL ON vg_stock_location_make_model_hdd_grade_color_ageing_2 TO postgres;
 GRANT ALL ON vg_stock_location_make_model_hdd_grade_color_ageing_2 TO odoo;
 GRANT SELECT ON vg_stock_location_make_model_hdd_grade_color_ageing_2 TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_users_stock_locations AS 
 SELECT d.name AS user_name,
    array_to_string(array_agg(b.complete_name ORDER BY b.complete_name), '*'::text) AS locations
   FROM (((stock_location_users_rel a
     JOIN stock_location b ON ((b.id = a.slid)))
     JOIN res_users c ON ((a.user_id = c.id)))
     JOIN res_partner d ON ((c.partner_id = d.id)))
  GROUP BY d.name
  ORDER BY d.name;
 ALTER TABLE vg_users_stock_locations OWNER TO postgres;
 GRANT ALL ON vg_users_stock_locations TO postgres;
 GRANT ALL ON vg_users_stock_locations TO odoo;
 GRANT SELECT ON vg_users_stock_locations TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_stock_locations_users AS 
 SELECT b.complete_name,
    array_to_string(array_agg(d.name ORDER BY d.name), '*'::text) AS users
   FROM (((stock_location_users_rel a
     JOIN stock_location b ON ((b.id = a.slid)))
     JOIN res_users c ON ((a.user_id = c.id)))
     JOIN res_partner d ON ((c.partner_id = d.id)))
  GROUP BY b.complete_name
  ORDER BY b.complete_name;
 ALTER TABLE vg_stock_locations_users OWNER TO postgres;
 GRANT ALL ON vg_stock_locations_users TO postgres;
 GRANT ALL ON vg_stock_locations_users TO odoo;
 GRANT SELECT ON vg_stock_locations_users TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_stock_location_make_model_with_grade AS 
 SELECT vg_xxx_stock_location_make_model_2.wh_location,
    vg_xxx_stock_location_make_model_2.make,
    vg_xxx_stock_location_make_model_2.model,
    vg_xxx_stock_location_make_model_2.hdd,
    sum(vg_xxx_stock_location_make_model_2.no_qty) AS no_qty,
    sum(vg_xxx_stock_location_make_model_2.ns_qty) AS ns_qty,
    sum(vg_xxx_stock_location_make_model_2.nr_qty) AS nr_qty,
    sum(vg_xxx_stock_location_make_model_2.ne_qty) AS ne_qty,
    sum(vg_xxx_stock_location_make_model_2.nw_qty) AS nw_qty,
    sum(vg_xxx_stock_location_make_model_2.nb_qty) AS nb_qty,
    sum(vg_xxx_stock_location_make_model_2.nm_qty) AS nm_qty,
    max(vg_xxx_stock_location_make_model_2.list_price) AS list_price,
    sum(vg_xxx_stock_location_make_model_2.stock_qty) AS stock_qty
   FROM vg_xxx_stock_location_make_model_2
  GROUP BY vg_xxx_stock_location_make_model_2.wh_location, vg_xxx_stock_location_make_model_2.make, vg_xxx_stock_location_make_model_2.model, vg_xxx_stock_location_make_model_2.hdd;
 ALTER TABLE vg_stock_location_make_model_with_grade OWNER TO postgres;
 GRANT ALL ON vg_stock_location_make_model_with_grade TO postgres;
 GRANT ALL ON vg_stock_location_make_model_with_grade TO odoo;
 GRANT SELECT ON vg_stock_location_make_model_with_grade TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_xxx_stock_move_by_location AS 
 SELECT a.id,
    a.location_id,
    a.product_id,
    a.description,
    a.date,
    a.picking_id,
    a.company_id,
    b.lot_id AS prodlot_id,
        CASE
            WHEN (a.name < (0)::numeric) THEN (-1)
            ELSE 1
        END AS stock_qty
   FROM (stock_move_by_location a
     JOIN stock_pack_operation b ON ((((a.picking_id = b.picking_id) AND (a.product_id = b.product_id)) AND (b.location_dest_id = a.location_id))))
  WHERE (a.prodlot_id IS NULL)
UNION
 SELECT a.id,
    a.location_id,
    a.product_id,
    a.description,
    a.date,
    a.picking_id,
    a.company_id,
    b.lot_id AS prodlot_id,
        CASE
            WHEN (a.name < (0)::numeric) THEN (-1)
            ELSE 1
        END AS stock_qty
   FROM (stock_move_by_location a
     JOIN stock_pack_operation b ON ((((a.picking_id = b.picking_id) AND (a.product_id = b.product_id)) AND (b.location_id = a.location_id))))
  WHERE (a.prodlot_id IS NULL)
UNION
 SELECT a.id,
    a.location_id,
    a.product_id,
    a.description,
    a.date,
    a.picking_id,
    a.company_id,
    a.prodlot_id,
    a.name AS stock_qty
   FROM stock_move_by_location a
  WHERE (a.prodlot_id IS NOT NULL);
 ALTER TABLE vg_xxx_stock_move_by_location OWNER TO postgres;
 GRANT ALL ON vg_xxx_stock_move_by_location TO postgres;
 GRANT ALL ON vg_xxx_stock_move_by_location TO odoo;
 GRANT SELECT ON vg_xxx_stock_move_by_location TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_xxx_stock_location_product_serial_make_model_3 AS 
 WITH l AS (
         SELECT a.id,
            a.location_id,
            a.product_id,
            a.prodlot_id,
            e.name AS gtr_no,
            e.x_greentek_lot AS lot_no,
            e.x_transfer_price_cost AS transfer_price,
                CASE
                    WHEN (e.create_date IS NOT NULL) THEN date_part('day'::text, age(now(), (e.create_date)::timestamp with time zone))
                    ELSE (60)::double precision
                END AS age,
            a.stock_qty
           FROM (vg_xxx_stock_move_by_location a
             LEFT JOIN stock_production_lot e ON ((a.prodlot_id = e.id)))
        ), s AS (
         SELECT i.location_id,
            i.product_id,
            max(i.date) AS last_sale_date
           FROM (stock_move i
             JOIN stock_picking_type m ON ((i.picking_type_id = m.id)))
          WHERE (((((i.state)::text <> 'cancel'::text) AND ((i.invoice_state)::text = 'invoiced'::text)) AND (i.invoice_line_id IS NOT NULL)) AND ((m.name)::text = 'Delivery Orders'::text))
          GROUP BY i.location_id, i.product_id
        )
 SELECT l.id,
    l.location_id,
    l.product_id,
    l.prodlot_id,
    r.complete_name AS wh_location,
    d.name AS product_name,
    split_part((d.name)::text, '-'::text, 1) AS make,
    split_part((d.name)::text, '-'::text, 2) AS model,
    split_part((d.name)::text, '-'::text, 3) AS hdd,
    split_part((d.name)::text, '-'::text, 4) AS grade,
    upper(split_part((d.name)::text, '-'::text, 6)) AS color,
    d.list_price,
    l.gtr_no,
    l.lot_no,
    l.transfer_price,
    l.age,
    l.stock_qty,
    s.last_sale_date
   FROM ((((l
     LEFT JOIN s ON (((l.location_id = s.location_id) AND (l.product_id = s.product_id))))
     JOIN product_product c ON ((l.product_id = c.id)))
     JOIN product_template d ON ((c.product_tmpl_id = d.id)))
     JOIN stock_location r ON ((l.location_id = r.id)));
 ALTER TABLE vg_xxx_stock_location_product_serial_make_model_3 OWNER TO postgres;
 GRANT ALL ON vg_xxx_stock_location_product_serial_make_model_3 TO postgres;
 GRANT ALL ON vg_xxx_stock_location_product_serial_make_model_3 TO odoo;
 GRANT SELECT ON vg_xxx_stock_location_product_serial_make_model_3 TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_stock_location_make_model_hdd_ageing_2 AS 
 WITH s AS (
         SELECT a.wh_location,
            a.make,
            a.model,
            a.hdd,
            max(a.list_price) AS rsp,
            max(a.age) AS max_age,
            avg(a.age) AS avg_age,
            sum(a.stock_qty) AS stock_qty,
            max(a.last_sale_date) AS last_sale_date
           FROM vg_xxx_stock_location_product_serial_make_model_2 a
          GROUP BY a.wh_location, a.make, a.model, a.hdd
         HAVING (sum(a.stock_qty) > (0)::numeric)
        ), u AS (
         WITH t AS (
                 SELECT b.wh_location,
                    b.make,
                    b.model,
                    b.hdd,
                    max(b.age) AS max_age
                   FROM vg_xxx_stock_location_product_serial_make_model_2 b
                  GROUP BY b.wh_location, b.make, b.model, b.hdd
                )
         SELECT x.wh_location,
            x.make,
            x.model,
            x.hdd,
            sum(x.stock_qty) AS max_age_stock_qty
           FROM (vg_xxx_stock_location_product_serial_make_model_2 x
             JOIN t ON (((((((x.wh_location)::text = (t.wh_location)::text) AND (x.make = t.make)) AND (t.model = x.model)) AND (t.hdd = x.hdd)) AND (x.age = t.max_age))))
          GROUP BY x.wh_location, x.make, x.model, x.hdd
        )
 SELECT s.wh_location,
    s.make,
    s.model,
    s.hdd,
    s.rsp,
    s.max_age,
    u.max_age_stock_qty,
    (s.avg_age)::integer AS avg_age,
    s.stock_qty,
    s.last_sale_date
   FROM (s
     JOIN u ON ((((((s.wh_location)::text = (u.wh_location)::text) AND (s.make = u.make)) AND (s.model = u.model)) AND (s.hdd = u.hdd))));
 ALTER TABLE vg_stock_location_make_model_hdd_ageing_2 OWNER TO postgres;
 GRANT ALL ON vg_stock_location_make_model_hdd_ageing_2 TO postgres;
 GRANT ALL ON vg_stock_location_make_model_hdd_ageing_2 TO odoo;
 GRANT SELECT ON vg_stock_location_make_model_hdd_ageing_2 TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_stock_location_make_model_hdd_ageing_3 AS 
 WITH s AS (
         SELECT a.wh_location,
            a.make,
            a.model,
            a.hdd,
            max(a.list_price) AS rsp,
            max(a.age) AS max_age,
            avg(a.age) AS avg_age,
            sum(a.stock_qty) AS stock_qty,
            max(a.last_sale_date) AS last_sale_date
           FROM vg_xxx_stock_location_product_serial_make_model_3 a
          GROUP BY a.wh_location, a.make, a.model, a.hdd
         HAVING (sum(a.stock_qty) > (0)::numeric)
        ), u AS (
         WITH t AS (
                 SELECT b.wh_location,
                    b.make,
                    b.model,
                    b.hdd,
                    max(b.age) AS max_age
                   FROM vg_xxx_stock_location_product_serial_make_model_3 b
                  GROUP BY b.wh_location, b.make, b.model, b.hdd
                )
         SELECT x.wh_location,
            x.make,
            x.model,
            x.hdd,
            sum(x.stock_qty) AS max_age_stock_qty
           FROM (vg_xxx_stock_location_product_serial_make_model_3 x
             JOIN t ON (((((((x.wh_location)::text = (t.wh_location)::text) AND (x.make = t.make)) AND (t.model = x.model)) AND (t.hdd = x.hdd)) AND (x.age = t.max_age))))
          GROUP BY x.wh_location, x.make, x.model, x.hdd
        )
 SELECT s.wh_location,
    s.make,
    s.model,
    s.hdd,
    s.rsp,
    s.max_age,
    u.max_age_stock_qty,
    (s.avg_age)::integer AS avg_age,
    s.stock_qty,
    s.last_sale_date
   FROM (s
     JOIN u ON ((((((s.wh_location)::text = (u.wh_location)::text) AND (s.make = u.make)) AND (s.model = u.model)) AND (s.hdd = u.hdd))));
 ALTER TABLE vg_stock_location_make_model_hdd_ageing_3 OWNER TO postgres;
 GRANT ALL ON vg_stock_location_make_model_hdd_ageing_3 TO postgres;
 GRANT ALL ON vg_stock_location_make_model_hdd_ageing_3 TO odoo;
 GRANT SELECT ON vg_stock_location_make_model_hdd_ageing_3 TO joomla;

-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vg_stock_location_make_model_hdd_grade_color_ageing_3 AS 
 WITH s AS (
         SELECT a.wh_location,
            a.make,
            a.model,
            a.hdd,
            a.grade,
            a.color,
            max(a.list_price) AS rsp,
            max(a.age) AS max_age,
            avg(a.age) AS avg_age,
            sum(a.stock_qty) AS stock_qty,
            max(a.last_sale_date) AS last_sale_date
           FROM vg_xxx_stock_location_product_serial_make_model_3 a
          GROUP BY a.wh_location, a.make, a.model, a.hdd, a.grade, a.color
         HAVING (sum(a.stock_qty) > (0)::numeric)
        ), u AS (
         WITH t AS (
                 SELECT b.wh_location,
                    b.make,
                    b.model,
                    b.hdd,
                    b.grade,
                    b.color,
                    max(b.age) AS max_age
                   FROM vg_xxx_stock_location_product_serial_make_model_3 b
                  GROUP BY b.wh_location, b.make, b.model, b.hdd, b.grade, b.color
                )
         SELECT x.wh_location,
            x.make,
            x.model,
            x.hdd,
            x.grade,
            x.color,
            sum(x.stock_qty) AS max_age_stock_qty
           FROM (vg_xxx_stock_location_product_serial_make_model_3 x
             JOIN t ON (((((((((x.wh_location)::text = (t.wh_location)::text) AND (x.make = t.make)) AND (t.model = x.model)) AND (t.hdd = x.hdd)) AND (t.grade = x.grade)) AND (t.color = x.color)) AND (x.age = t.max_age))))
          GROUP BY x.wh_location, x.make, x.model, x.hdd, x.grade, x.color
        )
 SELECT s.wh_location,
    s.make,
    s.model,
    s.hdd,
    s.grade,
    s.color,
    s.rsp,
    s.max_age,
    u.max_age_stock_qty,
    (s.avg_age)::integer AS avg_age,
    s.stock_qty,
    s.last_sale_date
   FROM (s
     JOIN u ON ((((((((s.wh_location)::text = (u.wh_location)::text) AND (s.make = u.make)) AND (s.model = u.model)) AND (s.hdd = u.hdd)) AND (s.grade = u.grade)) AND (s.color = u.color))));
 ALTER TABLE vg_stock_location_make_model_hdd_grade_color_ageing_3 OWNER TO postgres;
 GRANT ALL ON vg_stock_location_make_model_hdd_grade_color_ageing_3 TO postgres;
 GRANT ALL ON vg_stock_location_make_model_hdd_grade_color_ageing_3 TO odoo;
 GRANT SELECT ON vg_stock_location_make_model_hdd_grade_color_ageing_3 TO joomla;

