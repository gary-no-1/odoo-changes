with last_sale_data as (	
SELECT i.location_id,
	i.product_id,
	max(i.DATE) AS last_sale_date
FROM stock_move i
INNER JOIN stock_picking_type m ON i.picking_type_id = m.id
WHERE i.STATE::TEXT <> 'cancel'::TEXT
	AND i.invoice_state::TEXT = 'invoiced'::TEXT
	AND i.invoice_line_id IS NOT NULL
	AND m.NAME::TEXT = 'Delivery Orders'::TEXT
GROUP BY i.location_id,
	i.product_id );

with location_product_serial as (
SELECT a.id,
	a.location_id,
	a.product_id,
	a.prodlot_id,
	e.NAME AS gtr_no,
	e.x_greentek_lot AS lot_no,
	e.x_transfer_price_cost AS transfer_price,
	CASE 
		WHEN e.create_date IS NOT NULL
			THEN date_part('day'::TEXT, age(now(), e.create_date::TIMESTAMP WITH TIME zone))
		ELSE 60::FLOAT
		END AS age,
	a.NAME AS stock_qty
FROM stock_product_by_location_prodlot a
LEFT JOIN stock_production_lot e ON a.prodlot_id = e.id) ;		


WITH l
AS (
	SELECT a.id,
		a.location_id,
		a.product_id,
		a.prodlot_id,
		e.NAME AS gtr_no,
		e.x_greentek_lot AS lot_no,
		e.x_transfer_price_cost AS transfer_price,
		CASE 
			WHEN e.create_date IS NOT NULL
				THEN date_part('day'::TEXT, age(now(), e.create_date::TIMESTAMP WITH TIME zone))
			ELSE 60::FLOAT
			END AS age,
		a.NAME AS stock_qty
	FROM stock_product_by_location_prodlot a
	LEFT JOIN stock_production_lot e ON a.prodlot_id = e.id
	),
s
AS (
	SELECT i.location_id,
		i.product_id,
		max(i.DATE) AS last_sale_date
	FROM stock_move i
	INNER JOIN stock_picking_type m ON i.picking_type_id = m.id
	WHERE i.STATE::TEXT <> 'cancel'::TEXT
		AND i.invoice_state::TEXT = 'invoiced'::TEXT
		AND i.invoice_line_id IS NOT NULL
		AND m.NAME::TEXT = 'Delivery Orders'::TEXT
	GROUP BY i.location_id,
		i.product_id
	)
SELECT l.id,
	l.location_id,
	l.product_id,
	l.prodlot_id,
	l.gtr_no,
	l.lot_no,
	l.transfer_price,
	l.age,
	l.stock_qty,
	s.last_sale_date
FROM l
INNER JOIN s ON l.location_id = s.location_id
	AND l.product_id = s.product_id;
	
	
	
WITH l
AS (
	SELECT a.id,
		a.location_id,
		a.product_id,
		a.prodlot_id,
		e.NAME AS gtr_no,
		e.x_greentek_lot AS lot_no,
		e.x_transfer_price_cost AS transfer_price,
		CASE 
			WHEN e.create_date IS NOT NULL
				THEN date_part('day'::TEXT, age(now(), e.create_date::TIMESTAMP WITH TIME zone))
			ELSE 60::FLOAT
			END AS age,
		a.NAME AS stock_qty
	FROM stock_product_by_location_prodlot a
	LEFT JOIN stock_production_lot e ON a.prodlot_id = e.id
	),
s
AS (
	SELECT i.location_id,
		i.product_id,
		max(i.DATE) AS last_sale_date
	FROM stock_move i
	INNER JOIN stock_picking_type m ON i.picking_type_id = m.id
	WHERE i.STATE::TEXT <> 'cancel'::TEXT
		AND i.invoice_state::TEXT = 'invoiced'::TEXT
		AND i.invoice_line_id IS NOT NULL
		AND m.NAME::TEXT = 'Delivery Orders'::TEXT
	GROUP BY i.location_id,
		i.product_id
	)
SELECT l.id,
	l.location_id,
	l.product_id,
	l.prodlot_id,
	r.complete_name AS wh_location,
	d.NAME AS product_name,
	split_part(d.NAME::TEXT, '-'::TEXT, 1) AS make,
	split_part(d.NAME::TEXT, '-'::TEXT, 2) AS model,
	split_part(d.NAME::TEXT, '-'::TEXT, 3) AS hdd,
	split_part(d.NAME::TEXT, '-'::TEXT, 4) AS grade,
	upper(split_part(d.NAME::TEXT, '-'::TEXT, 6)) AS color,
	d.list_price,
	l.gtr_no,
	l.lot_no,
	l.transfer_price,
	l.age,
	l.stock_qty,
	s.last_sale_date
FROM l
LEFT JOIN s ON l.location_id = s.location_id
	AND l.product_id = s.product_id
INNER JOIN product_product c ON l.product_id = c.id
INNER JOIN product_template d ON c.product_tmpl_id = d.id
INNER JOIN stock_location r ON l.location_id = r.id;	


SELECT *
FROM information_schema.view_table_usage
WHERE table_name IN (
		SELECT view_name
		FROM information_schema.view_table_usage
		)
	AND view_schema = 'public'
ORDER BY view_name,
	table_name;
	
WITH t
AS (
	SELECT wh_location,
		product_name,
		max(age) AS max_age
	FROM vg_xxx_stock_location_product_serial_make_model_2
	GROUP BY wh_location,
		product_name
	)
SELECT x.wh_location,
	x.product_name,
	count(*) AS ctr
FROM vg_xxx_stock_location_product_serial_make_model_2 x
INNER JOIN t ON x.wh_location = t.wh_location
	AND x.product_name = t.product_name
	AND x.age = t.max_age
GROUP BY x.wh_location,
	x.product_name ;	
	
	
	
WITH s
AS (
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
	GROUP BY a.wh_location,
		a.make,
		a.model,
		a.hdd,
		a.grade,
		a.color
	),
u
AS (
	WITH t AS (
			SELECT b.wh_location,
				b.make,
				b.model,
				b.hdd,
				b.grade,
				b.color,
				max(b.age) AS max_age
			FROM vg_xxx_stock_location_product_serial_make_model_2 b
			GROUP BY b.wh_location,
				b.make,
				b.model,
				b.hdd,
				b.grade,
				b.color
			)
	SELECT x.wh_location,
		x.make,
		x.model,
		x.hdd,
		x.grade,
		x.color,
		count(*) AS max_age_stock_qty
	FROM vg_xxx_stock_location_product_serial_make_model_2 x
	INNER JOIN t ON x.wh_location::TEXT = t.wh_location::TEXT
		AND x.make = t.make
		AND t.model = x.model
		AND t.hdd = x.hdd
		AND t.grade = x.grade
		AND t.color = x.color
		AND x.age = t.max_age
	GROUP BY x.wh_location,
		x.make,
		x.model,
		x.hdd,
		x.grade,
		x.color
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
	s.avg_age,
	s.stock_qty,
	s.last_sale_date
FROM s
INNER JOIN u ON s.wh_location = u.wh_location
	AND s.make = u.make
	AND s.model = u.model
	AND s.hdd = u.hdd
	AND s.grade = u.grade
	AND s.color = u.color;	