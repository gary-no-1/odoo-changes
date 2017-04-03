 WITH x AS (
         SELECT stock_lot_history.id,
            stock_lot_history.move_id,
            stock_lot_history.location_id,
            stock_lot_history.company_id,
            stock_lot_history.product_id,
            stock_lot_history.product_categ_id,
            stock_lot_history.prodlot_id,
            stock_lot_history.quantity,
            stock_lot_history.date,
            stock_lot_history.price_unit_on_quant,
            stock_lot_history.source,
            sum(stock_lot_history.quantity) OVER (PARTITION BY stock_lot_history.product_id ORDER BY stock_lot_history.date, stock_lot_history.move_id) AS cum_qty
           FROM stock_lot_history
        ), y AS (
         SELECT x.id,
            x.move_id,
            x.location_id,
            x.company_id,
            x.product_id,
            x.product_categ_id,
			x.prodlot_id,
            x.quantity,
            x.date,
            x.price_unit_on_quant,
            x.source,
            x.cum_qty,
            f.product_category,
            f.product_name
           FROM x
             JOIN vg_stock_by_product_stock_lot_history f ON x.product_id = f.product_id
          WHERE x.quantity > 0::double precision AND x.cum_qty <= f.qty
        ), z AS (
         SELECT y.id,
            y.move_id,
            y.location_id,
            y.company_id,
            y.product_id,
            y.product_categ_id,
			y.prodlot_id,
            y.quantity,
            y.date,
            y.price_unit_on_quant,
            y.source,
            y.cum_qty,
            y.product_category,
            y.product_name,
            row_number() OVER (PARTITION BY y.product_id, y.cum_qty ORDER BY y.product_id, y.cum_qty, y.date) AS rnk
           FROM y
        )
 SELECT z.id,
    z.move_id,
    z.location_id,
    z.product_id,
    z.product_categ_id,
	z.prodlot_id,
    l.complete_name AS location,
    z.product_category,
    z.product_name,
    z.quantity,
	s.name as gtr_no,
	s.create_date as create_date,
	s.x_greentek_lot as lot_no,
	s.x_transfer_price_cost as transfer_price
   FROM z
     JOIN stock_location l ON z.location_id = l.id
	 left join stock_production_lot s on z.prodlot_id = s.id
  WHERE z.rnk = 1;
  
  
  -- ------------------------------------------------------------------------------------------------------------------------
  
  with x as (SELECT slh.id,
            slh.move_id,
            slh.location_id,
            slh.company_id,
            slh.product_id,
            slh.product_categ_id,
            slh.prodlot_id,
            slh.quantity,
            slh.date,
            sum(slh.quantity) OVER (PARTITION BY slh.product_id, slh.prodlot_id ORDER BY slh.date, slh.move_id) AS cum_qty
           FROM stock_lot_history_2 slh ),
stock_product_lot_sum AS (
         SELECT h.product_id,
		 h.prodlot_id,
            sum(h.quantity) AS qty
           FROM stock_lot_history_2 h,
            stock_move m
          WHERE h.move_id = m.id
          GROUP BY h.product_id , h.prodlot_if
        ), stock_product_lot_non_zero AS (
         SELECT y.product_id,
		 y.prodlot_id
            y.qty
           FROM stock_product_lot_sum y
          WHERE y.qty <> 0::double precision
        )
		select * from stock_product_lot_non_zero
		
-- ----------------------------------------------------------------------------------------------------
	  
WITH slh_cum_qty
AS (
	SELECT slh.id, slh.move_id, slh.location_id, slh.company_id, slh.product_id, slh.product_categ_id, slh.prodlot_id, slh.quantity, slh.DATE, sum(slh.quantity) OVER (
			PARTITION BY slh.product_id, slh.prodlot_id ORDER BY slh.DATE, slh.move_id
			) AS cum_qty
	FROM stock_lot_history slh
	), stock_product_lot_sum
AS (
	SELECT h.product_id, h.prodlot_id, sum(h.quantity) AS qty
	FROM stock_lot_history h, stock_move m
	WHERE h.move_id = m.id
	GROUP BY h.product_id, h.prodlot_id
	), stock_product_lot_non_zero
AS (
	SELECT y.product_id, y.prodlot_id, y.qty
	FROM stock_product_lot_sum y
	WHERE y.qty <> 0::FLOAT
	), slh_less_balance_qty
AS (
	SELECT x.id, x.move_id, x.location_id, x.company_id, x.product_id, x.product_categ_id, x.prodlot_id, x.quantity, x.DATE, x.cum_qty
	FROM slh_cum_qty x
	INNER JOIN stock_product_lot_non_zero f ON x.product_id = f.product_id
		AND x.prodlot_id = f.prodlot_id
	WHERE x.quantity > 0::FLOAT
		AND x.cum_qty <= f.qty
	), slh_less_balance_rank
AS (
	SELECT y.id, y.move_id, y.location_id, y.company_id, y.product_id, y.product_categ_id, y.prodlot_id, y.quantity, y.DATE, y.cum_qty, row_number() OVER (
			PARTITION BY y.product_id, y.prodlot_id, y.cum_qty ORDER BY y.product_id, y.prodlot_id, y.cum_qty, y.DATE DESC
			) AS rnk
	FROM slh_less_balance_qty y
	)
SELECT z.id, z.move_id, z.location_id, z.product_id, z.product_categ_id, z.prodlot_id, l.complete_name AS location, v.product_category, v.product_name, z.quantity, s.NAME AS gtr_no, s.create_date AS create_date, s.x_greentek_lot AS lot_no, s.x_transfer_price_cost AS transfer_price
FROM slh_less_balance_rank z
INNER JOIN stock_location l ON z.location_id = l.id
INNER JOIN vg_product_category v ON z.product_id = v.id
LEFT JOIN stock_production_lot s ON z.prodlot_id = s.id
WHERE rnk = 1;	 