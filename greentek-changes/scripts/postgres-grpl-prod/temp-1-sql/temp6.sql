-- View: vg_xxx_make_model_hdd_1_grade

-- DROP VIEW vg_xxx_make_model_hdd_1_grade;

CREATE OR REPLACE VIEW vg_xxx_make_model_hdd_1_grade AS 
 WITH y AS (
         WITH x AS (
                 SELECT product_template.id,
                    product_template.name,
                    split_part(product_template.name::text, '-'::text, 1) AS make,
                    split_part(product_template.name::text, '-'::text, 2) AS model,
                    split_part(product_template.name::text, '-'::text, 3) AS hdd,
                    split_part(product_template.name::text, '-'::text, 4) AS grade,
                    upper(split_part(product_template.name::text, '-'::text, 6)) AS color,
                    product_template.list_price
                   FROM product_template
                  WHERE product_template.active = true
                )
         SELECT DISTINCT x.make,
            x.model,
            x.hdd,
            x.grade
           FROM x
        )
 SELECT y.make,
    y.model,
    y.hdd,
    string_agg(y.grade, '*'::text ORDER BY y.grade) AS all_grades
   FROM y
  GROUP BY y.make, y.model, y.hdd;

ALTER TABLE vg_xxx_make_model_hdd_1_grade
  OWNER TO odoo;
-- ------------------------------------------------------------------------------------------------
-- View: vg_xxx_make_model_hdd_2_color

-- DROP VIEW vg_xxx_make_model_hdd_2_color;

CREATE OR REPLACE VIEW vg_xxx_make_model_hdd_2_color AS 
 WITH y AS (
         WITH x AS (
                 SELECT product_template.id,
                    product_template.name,
                    split_part(product_template.name::text, '-'::text, 1) AS make,
                    split_part(product_template.name::text, '-'::text, 2) AS model,
                    split_part(product_template.name::text, '-'::text, 3) AS hdd,
                    split_part(product_template.name::text, '-'::text, 4) AS grade,
                    upper(split_part(product_template.name::text, '-'::text, 6)) AS color,
                    product_template.list_price
                   FROM product_template
                  WHERE product_template.active = true
                )
         SELECT DISTINCT x.make,
            x.model,
            x.hdd,
            x.color
           FROM x
        )
 SELECT y.make,
    y.model,
    y.hdd,
    string_agg(y.color, '*'::text ORDER BY y.color) AS all_colors
   FROM y
  GROUP BY y.make, y.model, y.hdd;

ALTER TABLE vg_xxx_make_model_hdd_2_color
  OWNER TO odoo;
-- ------------------------------------------------------------------------------------------------
-- View: vg_xxx_make_model_hdd_3_list_price

-- DROP VIEW vg_xxx_make_model_hdd_3_list_price;

CREATE OR REPLACE VIEW vg_xxx_make_model_hdd_3_list_price AS 
 WITH y AS (
         WITH x AS (
                 SELECT product_template.id,
                    product_template.name,
                    split_part(product_template.name::text, '-'::text, 1) AS make,
                    split_part(product_template.name::text, '-'::text, 2) AS model,
                    split_part(product_template.name::text, '-'::text, 3) AS hdd,
                    split_part(product_template.name::text, '-'::text, 4) AS grade,
                    upper(split_part(product_template.name::text, '-'::text, 6)) AS color,
                    product_template.list_price
                   FROM product_template
                  WHERE product_template.active = true
                )
         SELECT x.make,
            x.model,
            x.hdd,
                CASE
                    WHEN x.grade = 'NO'::text THEN x.list_price
                    ELSE 0::numeric
                END AS no_list_price,
                CASE
                    WHEN x.grade = 'NS'::text THEN x.list_price
                    ELSE 0::numeric
                END AS ns_list_price,
                CASE
                    WHEN x.grade = 'NR'::text THEN x.list_price
                    ELSE 0::numeric
                END AS nr_list_price,
                CASE
                    WHEN x.grade = 'NE'::text THEN x.list_price
                    ELSE 0::numeric
                END AS ne_list_price,
                CASE
                    WHEN x.grade = 'NW'::text THEN x.list_price
                    ELSE 0::numeric
                END AS nw_list_price,
                CASE
                    WHEN x.grade = 'NB'::text THEN x.list_price
                    ELSE 0::numeric
                END AS nb_list_price,
                CASE
                    WHEN x.grade = 'NM'::text THEN x.list_price
                    ELSE 0::numeric
                END AS nm_list_price
           FROM x
        )
 SELECT y.make,
    y.model,
    y.hdd,
    max(y.no_list_price) AS no_list_price,
    max(y.ns_list_price) AS ns_list_price,
    max(y.nr_list_price) AS nr_list_price,
    max(y.ne_list_price) AS ne_list_price,
    max(y.nw_list_price) AS nw_list_price,
    max(y.nb_list_price) AS nb_list_price,
    max(y.nm_list_price) AS nm_list_price
   FROM y
  GROUP BY y.make, y.model, y.hdd;

ALTER TABLE vg_xxx_make_model_hdd_3_list_price
  OWNER TO odoo;
-- ------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW vg_product_mobiles_make_model_hdd AS 
 SELECT a.make,
    a.model,
    a.hdd,
    a.all_grades,
    c.all_colors,
    b.no_list_price,
    b.ns_list_price,
    b.nr_list_price,
    b.ne_list_price,
    b.nw_list_price,
    b.nb_list_price,
    b.nm_list_price
   FROM vg_xxx_make_model_hdd_1_grade a
     JOIN vg_xxx_make_model_hdd_3_list_price b ON a.make = b.make AND a.model = b.model AND a.hdd = b.hdd
     JOIN vg_xxx_make_model_hdd_2_color c ON a.make = c.make AND a.model = c.model AND a.hdd = c.hdd;

ALTER TABLE vg_product_mobiles_make_model_hdd
  OWNER TO odoo;
-- ------------------------------------------------------------------------------------------------
WITH dup AS
(
   SELECT
       *,
       ROW_NUMBER() OVER (PARTITION BY name || product_id::text  ORDER BY name || product_id::text) AS RowNum
   FROM stock_production_lot
) 
update stock_production_lot
set name = name || '-dup'
where id in (select id from dup WHERE RowNum > 1) ;

select * from stock_production_lot where name || product_id::text in 
(select name || product_id::text from stock_production_lot group by name || product_id::text having count(*) > 1)
order by name , product_id  ;


-- ------------------------------------------------------------------------------------------------
WITH x
AS (
	SELECT a.id,
		a.origin,
		a.create_date,
		a.date_done,
		a.write_uid,
		a.partner_id,
		a.picking_type_id,
		a.move_type,
		a.STATE,
		a.create_uid,
		a.min_date,
		a.write_date,
		a.DATE,
		a.NAME AS delivery_note,
		a.recompute_pack_op,
		a.max_date,
		a.group_id,
		a.invoice_state,
		a.reception_to_invoice,
		a.invoice_id,
		b.NAME AS picking_type,
		c.NAME AS warehouse
	FROM stock_picking a
	INNER JOIN stock_picking_type b ON a.picking_type_id = b.id
	INNER JOIN stock_warehouse c ON b.warehouse_id = c.id
	WHERE (current_timestamp::DATE - a.DATE::DATE) < 3
		AND a.STATE <> 'cancel'
	)
SELECT warehouse,
	picking_type,
	delivery_note,
	DATE,
	STATE,
	origin
FROM x
ORDER BY warehouse,
	picking_type,
	delivery_note
	
-- ------------------------------------------------------------------------------------------------
WITH x
AS (
	SELECT a.id,
		a.reference AS sale_order,
		a.origin,
		a.number AS invoice_number,
		a.date_invoice,
		a.partner_id,
		a.journal_id,
		a.amount_untaxed,
		a.amount_tax,
		a.amount_total,
		a.STATE,
		a.move_id,
		a.type,
		a.user_id,
		b.NAME AS saleperson,
		a.section_id,
		a.x_po_ref
	FROM account_invoice a
	INNER JOIN vg_user_name b ON a.user_id = b.id
	WHERE a.STATE <> 'cancel'
		AND a.STATE <> 'draft'
	)
SELECT x.id,
	x.invoice_number,
	x.date_invoice,
	x.amount_untaxed,
	x.amount_tax,
	x.amount_total,
	x.STATE,
	x.type,
	x.saleperson,
	b.invoice_id,
	b.price_unit,
	b.price_subtotal,
	b.discount,
	b.quantity,
	b.product_id,
	b.NAME AS product_desc
FROM x
INNER JOIN account_invoice_line b ON x.id = b.invoice_id
ORDER BY x.date_invoice,
	x.invoice_number;
-- ------------------------------------------------------------------------------------------------

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	

-- View: vg_xxy_stock_move_by_location

DROP VIEW vg_invoice_product_serial_sale_transfer;
DROP VIEW vg_xxy_stock_move_by_location_2;
DROP VIEW vg_xxy_stock_move_by_location;

CREATE OR REPLACE VIEW vg_xxy_stock_move_by_location AS 
 SELECT i.id,
    l.id AS location_id,
    i.product_id,
        CASE
            WHEN i.state::text = 'done'::text THEN i.product_qty
            ELSE 0::numeric
        END AS qty,
    i.date,
    i.restrict_lot_id AS prodlot_id,
    i.picking_id,
    i.invoice_line_id
   FROM stock_location l,
    stock_move i
  WHERE l.usage::text = 'internal'::text AND i.location_dest_id = l.id AND i.state::text <> 'cancel'::text AND i.company_id = l.company_id and i.invoice_state::text = 'invoiced'
UNION ALL
 SELECT o.id AS id,
    l.id AS location_id,
    o.product_id,
        CASE
            WHEN o.state::text = 'done'::text THEN - o.product_qty
            ELSE 0::numeric
        END AS qty,
    o.date,
    o.restrict_lot_id AS prodlot_id,
    o.picking_id,
    o.invoice_line_id
   FROM stock_location l,
    stock_move o
  WHERE l.usage::text = 'internal'::text AND o.location_id = l.id AND o.state::text <> 'cancel'::text AND o.company_id = l.company_id and o.invoice_state::text = 'invoiced';

ALTER TABLE vg_xxy_stock_move_by_location
  OWNER TO odoo;

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	

CREATE OR REPLACE VIEW vg_xxy_stock_move_by_location_2 AS 
 SELECT a.id,
    a.location_id,
    a.product_id,
    a.date,
    a.picking_id,
	a.invoice_line_id,
    b.lot_id AS prodlot_id,
        CASE
            WHEN a.qty < 0::numeric THEN (-1)
            ELSE 1
        END AS stock_qty
   FROM vg_xxy_stock_move_by_location a
     JOIN stock_pack_operation b ON a.picking_id = b.picking_id AND a.product_id = b.product_id AND b.location_dest_id = a.location_id
  WHERE a.prodlot_id IS NULL
UNION
 SELECT a.id,
    a.location_id,
    a.product_id,
    a.date,
    a.picking_id,
	a.invoice_line_id,
    b.lot_id AS prodlot_id,
        CASE
            WHEN a.qty < 0::numeric THEN (-1)
            ELSE 1
        END AS stock_qty
   FROM vg_xxy_stock_move_by_location a
     JOIN stock_pack_operation b ON a.picking_id = b.picking_id AND a.product_id = b.product_id AND b.location_id = a.location_id
  WHERE a.prodlot_id IS NULL
UNION
 SELECT a.id,
    a.location_id,
    a.product_id,
    a.date,
    a.picking_id,
	a.invoice_line_id,
    a.prodlot_id,
    a.qty AS stock_qty
   FROM vg_xxy_stock_move_by_location a
  WHERE a.prodlot_id IS NOT NULL;

ALTER TABLE vg_xxy_stock_move_by_location_2
  OWNER TO postgres;
GRANT ALL ON TABLE vg_xxy_stock_move_by_location_2 TO postgres;

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	


CREATE OR REPLACE VIEW vg_invoice_product_serial_sale_transfer AS 
 WITH x AS (
         SELECT a.id,
            a.reference AS sale_order,
            a.origin,
            a.number AS invoice_number,
            a.date_invoice,
            a.partner_id,
            a.journal_id,
            a.amount_untaxed,
            a.amount_tax,
            a.amount_total,
            a.state,
            a.move_id,
            a.type,
            a.user_id,
            b_1.name AS saleperson,
            a.section_id,
            a.x_po_ref
           FROM account_invoice a
             JOIN vg_user_name b_1 ON a.user_id = b_1.id
          WHERE a.state::text <> 'cancel'::text AND a.state::text <> 'draft'::text
        ), y AS (
         SELECT a.invoice_line_id,
            a.prodlot_id,
            a.stock_qty,
            b_1.name AS gtr_no,
			b_1.x_greentek_lot as lot_no,
            b_1.x_transfer_price_cost AS transfer_price
           FROM vg_xxy_stock_move_by_location_2 a
             JOIN stock_production_lot b_1 ON a.prodlot_id = b_1.id
          WHERE a.invoice_line_id IS NOT NULL
        )
 SELECT x.id,
    x.invoice_number,
    x.date_invoice,
    x.amount_untaxed,
    x.amount_tax,
    x.amount_total,
    x.state as invoice_status,
    x.type as invoice_type,
    x.saleperson,
    b.invoice_id,
    b.price_unit,
    b.price_subtotal,
    b.discount,
    b.quantity,
    b.product_id,
    b.name AS product_desc,
    y.gtr_no,
	y.lot_no,
    y.transfer_price
   FROM x
     JOIN account_invoice_line b ON x.id = b.invoice_id
     LEFT JOIN y ON y.invoice_line_id = b.id
  ORDER BY x.date_invoice, x.invoice_number, b.product_id;

ALTER TABLE vg_invoice_product_serial_sale_transfer
  OWNER TO odoo;

-- -//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\//////////\\\\\\\\\\	








WITH y
AS (
	SELECT a.id,
		a.location_id,
		a.product_id,
		a.DATE,
		a.picking_id,
		a.invoice_line_id,
		a.prodlot_id,
		a.stock_qty,
		b.NAME AS gtr_no,
		b.x_transfer_price_cost AS transfer_price
	FROM vg_xxy_stock_move_by_location_2 a
	INNER JOIN stock_production_lot b ON a.prodlot_id = b.id
	WHERE a.invoice_line_id IS NOT NULL
	)
SELECT *
FROM x
WHERE prodlot_id IS NOT NULL;



























WITH x
AS (
	SELECT a.id,
		a.reference AS sale_order,
		a.origin,
		a.number AS invoice_number,
		a.date_invoice,
		a.partner_id,
		a.journal_id,
		a.amount_untaxed,
		a.amount_tax,
		a.amount_total,
		a.STATE,
		a.move_id,
		a.type,
		a.user_id,
		b.NAME AS saleperson,
		a.section_id,
		a.x_po_ref
	FROM account_invoice a
	INNER JOIN vg_user_name b ON a.user_id = b.id
	WHERE a.STATE <> 'cancel'
		AND a.STATE <> 'draft'
	),
WITH y
AS (
	SELECT a.invoice_line_id,
		a.prodlot_id,
		a.stock_qty,
		b.NAME AS gtr_no,
		b.x_transfer_price_cost AS transfer_price
	FROM vg_xxy_stock_move_by_location_2 a
	INNER JOIN stock_production_lot b ON a.prodlot_id = b.id
	WHERE a.invoice_line_id IS NOT NULL
	)
SELECT x.id,
	x.invoice_number,
	x.date_invoice,
	x.amount_untaxed,
	x.amount_tax,
	x.amount_total,
	x.STATE,
	x.type,
	x.saleperson,
	b.invoice_id,
	b.price_unit,
	b.price_subtotal,
	b.discount,
	b.quantity,
	b.product_id,
	b.NAME AS product_desc,
	y.gtr_no,
	y.transfer_price
FROM x
INNER JOIN account_invoice_line b ON x.id = b.invoice_id
left join y on y.invoice_line_id = b.id
ORDER BY x.date_invoice,
	x.invoice_number;

-- View: vg_all_partners

-- DROP VIEW vg_all_partners;

CREATE OR REPLACE VIEW vg_all_partners AS 
 WITH x AS (
         SELECT a.id,
            a.name AS company_partner_name,
            a.name AS company_name,
            b.name AS company_state,
            a.parent_id,
            a.is_company
           FROM res_partner a
             LEFT JOIN res_country_state b ON a.state_id = b.id
          WHERE a.is_company
        ), y AS (
         SELECT a.id,
            a.name AS company_partner_name,
            x.company_name,
            x.company_state,
            a.parent_id,
            a.is_company
           FROM res_partner a
             LEFT JOIN x ON a.parent_id = x.id
          WHERE NOT a.is_company AND a.parent_id IS NOT NULL
        ), z AS (
         SELECT a.id,
            a.name AS company_partner_name,
            a.name AS company_name,
            b.name AS company_state,
            a.parent_id,
            a.is_company
           FROM res_partner a
             LEFT JOIN res_country_state b ON a.state_id = b.id
          WHERE NOT a.is_company AND a.parent_id IS NULL
        )
 SELECT x.id,
    x.company_partner_name,
    x.company_name,
    x.company_state
   FROM x
UNION
 SELECT y.id,
    y.company_partner_name,
    y.company_name,
    y.company_state
   FROM y
UNION
 SELECT z.id,
    z.company_partner_name,
    z.company_name,
    z.company_state
   FROM z;

ALTER TABLE vg_all_partners
  OWNER TO odoo;
	