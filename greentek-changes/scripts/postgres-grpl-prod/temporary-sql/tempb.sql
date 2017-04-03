WITH y
AS (
	SELECT picking_id, product_id, location_id, sum(qty) AS qty
	FROM vg_xxy_stock_move_by_location
	WHERE prodlot_id IS NULL
	GROUP BY picking_id, product_id, location_id
	)
SELECT a.location_id, a.product_id, a.picking_id, b.lot_id AS prodlot_id, CASE 
		WHEN a.qty < 0::NUMERIC
			THEN (- 1)
		ELSE 1
		END AS stock_qty
FROM y a
INNER JOIN stock_pack_operation b ON a.picking_id = b.picking_id
	AND a.product_id = b.product_id
	AND b.location_dest_id = a.location_id

UNION

SELECT a.location_id, a.product_id, a.picking_id, b.lot_id AS prodlot_id, CASE 
		WHEN a.qty < 0::NUMERIC
			THEN (- 1)
		ELSE 1
		END AS stock_qty
FROM y a
INNER JOIN stock_pack_operation b ON a.picking_id = b.picking_id
	AND a.product_id = b.product_id
	AND b.location_id = a.location_id

UNION

SELECT a.location_id, a.product_id, a.picking_id, a.prodlot_id, a.qty AS stock_qty
FROM vg_xxy_stock_move_by_location a
WHERE a.prodlot_id IS NOT NULL;  


-- -----------------------------------------------------

SELECT a.id, a.origin, 
       a.date, a.product_qty, 
       a.location_id, a.state, 
       a.name, a.warehouse_id, 
       a.restrict_lot_id, 
       a.product_id, a.picking_id, a.location_dest_id, 
       a.invoice_state, a.invoice_line_id,
	   round(b.price_subtotal / b.quantity,0) as unit_sale_price
  FROM stock_move a 
join account_invoice_line b
on a.invoice_line_id = b.id
where a.state <> 'cancel' and a.invoice_state = 'invoiced' and a.origin_returned_move_id is null

with x as (SELECT a.id, a.origin, 
       a.date, a.product_qty, 
       a.location_id, a.state, 
       a.name, a.warehouse_id, 
       a.restrict_lot_id, 
       a.product_id, a.picking_id, a.location_dest_id, 
       a.invoice_state, a.invoice_line_id,
	   round(b.price_subtotal / b.quantity,0) as unit_sale_price
  FROM stock_move a 
join account_invoice_line b
on a.invoice_line_id = b.id
where a.state <> 'cancel' and a.invoice_state = 'invoiced' and a.origin_returned_move_id is null
)
 SELECT i.id,
    l.id AS location_id,
    i.product_id,
        CASE
            WHEN i.state::text = 'done'::text THEN i.product_qty
            ELSE 0::numeric
        END AS qty,
    i.date,
	i.unit_sale_price,
    i.restrict_lot_id AS prodlot_id,
    i.picking_id,
    i.invoice_line_id
   FROM stock_location l,
    x  i
  WHERE l.usage::text = 'internal'::text AND i.location_dest_id = l.id 
UNION ALL
 SELECT o.id,
    l.id AS location_id,
    o.product_id,
        CASE
            WHEN o.state::text = 'done'::text THEN - o.product_qty
            ELSE 0::numeric
        END AS qty,
    o.date,
	o.unit_sale_price,
    o.restrict_lot_id AS prodlot_id,
    o.picking_id,
    o.invoice_line_id
   FROM stock_location l,
    x  o
  WHERE l.usage::text = 'internal'::text AND i.location_dest_id = l.id 












SELECT a.id, a.origin, a.move_dest_id, 
       a.date, a.product_qty, a.origin_returned_move_id,
       a.location_id, a.picking_type_id, a.partner_id, a.state, 
       a.name, a.warehouse_id, 
       a.procure_method, a.restrict_lot_id, 
       a.product_id, a.picking_id, a.location_dest_id, 
       a.invoice_state, a.invoice_line_id,
       b.invoice_id, b.price_unit, b.price_subtotal,b.discount , b.product_id , b.name , b.quantity
  FROM stock_move a -- where a.invoice_line_id is not null;
join account_invoice_line b
on a.invoice_line_id = b.id
where a.product_qty <> b.quantity and a.state <> 'cancel' and a.invoice_state = 'invoiced' and a.origin_returned_move_id is null
order by a.origin;
















WITH x
AS (
	SELECT a.id,
		a.origin,
		a.DATE,
		a.product_qty,
		a.location_id,
		a.STATE,
		a.NAME,
		a.warehouse_id,
		a.restrict_lot_id,
		a.product_id,
		a.picking_id,
		a.location_dest_id,
		a.invoice_state,
		a.invoice_line_id,
		round(b.price_subtotal / b.quantity, 0) AS unit_sale_price
	FROM stock_move a
	INNER JOIN account_invoice_line b ON a.invoice_line_id = b.id
	WHERE a.STATE <> 'cancel'
		AND a.invoice_state = 'invoiced'
		AND a.origin_returned_move_id IS NULL
		AND a.product_qty <> 0
	)
SELECT i.id,
	l.id AS location_id,
	i.product_id,
	CASE 
		WHEN i.STATE::TEXT = 'done'::TEXT
			THEN i.product_qty
		ELSE 0::NUMERIC
		END AS qty,
	i.DATE,
	i.unit_sale_price,
	i.restrict_lot_id AS prodlot_id,
	i.picking_id,
	i.invoice_line_id
FROM stock_location l,
	x i
WHERE l.usage::TEXT = 'internal'::TEXT
	AND i.location_dest_id = l.id

UNION ALL

SELECT o.id,
	l.id AS location_id,
	o.product_id,
	CASE 
		WHEN o.STATE::TEXT = 'done'::TEXT
			THEN - o.product_qty
		ELSE 0::NUMERIC
		END AS qty,
	o.DATE,
	o.unit_sale_price,
	o.restrict_lot_id AS prodlot_id,
	o.picking_id,
	o.invoice_line_id
FROM stock_location l,
	x o
WHERE l.usage::TEXT = 'internal'::TEXT
	AND o.location_dest_id = l.id;
	
	
	
	
	
	
	
CREATE OR REPLACE VIEW vg_xxy_stock_move_by_location_2 AS 
 WITH x AS (
         SELECT vg_xxy_stock_move_by_location.id,
            vg_xxy_stock_move_by_location.location_id,
            vg_xxy_stock_move_by_location.product_id,
            vg_xxy_stock_move_by_location.qty,
            vg_xxy_stock_move_by_location.date,
            vg_xxy_stock_move_by_location.prodlot_id,
            vg_xxy_stock_move_by_location.picking_id,
            vg_xxy_stock_move_by_location.invoice_line_id,
            row_number() OVER (PARTITION BY vg_xxy_stock_move_by_location.picking_id, vg_xxy_stock_move_by_location.product_id) AS rnk
           FROM vg_xxy_stock_move_by_location
        ), y AS (
         SELECT x.id,
            x.location_id,
            x.product_id,
            x.qty,
            x.date,
            x.prodlot_id,
            x.picking_id,
            x.invoice_line_id,
            x.rnk
           FROM x
          WHERE x.rnk = 1
        )
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
   FROM y a
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
   FROM y a
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
   FROM y a
  WHERE a.prodlot_id IS NOT NULL;
	