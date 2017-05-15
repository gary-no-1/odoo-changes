-- View: vg_closing_stock_location_serial_stock_history_2

-- DROP VIEW vg_closing_stock_location_serial_stock_history_2;

CREATE OR REPLACE VIEW vg_closing_stock_location_serial_stock_history_2 AS 
 WITH slh_cum_qty AS (
         SELECT slh.id,
            slh.move_id,
            slh.location_id,
            slh.company_id,
            slh.product_id,
            slh.product_categ_id,
            slh.prodlot_id,
            slh.quantity,
            slh.date,
            sum(slh.quantity) OVER (PARTITION BY slh.product_id, slh.prodlot_id ORDER BY slh.date, slh.move_id) AS cum_qty
           FROM stock_lot_history slh
        ), stock_product_lot_sum AS (
         SELECT h.product_id,
            h.prodlot_id,
            sum(h.quantity) AS qty
           FROM stock_lot_history h,
            stock_move m
          WHERE h.move_id = m.id
          GROUP BY h.product_id, h.prodlot_id
        ), stock_product_lot_non_zero AS (
         SELECT y.product_id,
            y.prodlot_id,
            y.qty
           FROM stock_product_lot_sum y
          WHERE y.qty <> 0::double precision
        ), slh_less_balance_qty AS (
         SELECT x.id,
            x.move_id,
            x.location_id,
            x.company_id,
            x.product_id,
            x.product_categ_id,
            x.prodlot_id,
            x.quantity,
            x.date,
            x.cum_qty
           FROM slh_cum_qty x
             JOIN stock_product_lot_non_zero f ON x.product_id = f.product_id AND x.prodlot_id = f.prodlot_id
          WHERE x.quantity > 0::double precision AND x.cum_qty <= f.qty AND x.cum_qty > 0::double precision
        ), slh_less_balance_rank AS (
         SELECT y.id,
            y.move_id,
            y.location_id,
            y.company_id,
            y.product_id,
            y.product_categ_id,
            y.prodlot_id,
            y.quantity,
            y.date,
            y.cum_qty,
            row_number() OVER (PARTITION BY y.product_id, y.prodlot_id, y.cum_qty ORDER BY y.product_id, y.prodlot_id, y.cum_qty, y.date DESC) AS rnk
           FROM slh_less_balance_qty y
        ), slh_closing_with_errors as (
 SELECT z.id,
    z.move_id,
    z.location_id,
    z.product_id,
    z.product_categ_id,
    z.prodlot_id,
    l.complete_name AS location,
    v.product_category,
    v.product_name,
    z.quantity,
    s.name AS gtr_no,
    s.create_date::date AS incoming_date,
    s.x_greentek_lot AS lot_no,
    s.x_transfer_price_cost AS transfer_price
   FROM slh_less_balance_rank z
     JOIN stock_location l ON z.location_id = l.id
     JOIN vg_product_category v ON z.product_id = v.id
     LEFT JOIN stock_production_lot s ON z.prodlot_id = s.id
  WHERE z.rnk = 1)
  select location_id, product_id, prodlot_id, prodlot_categ_id, location, product_category, product_name, quantity,
  gtr_no, incoming_date, lot_no, transfer_price from slh_closing_with_errors
  where prodlot_id not in (28814,22995,34852,16480,16477,16475,16473,16428,16426,16423,16421,16372,16315,16307,16303,16297,16295,16269,16234,16221,48063)
  ;

ALTER TABLE vg_closing_stock_location_serial_stock_history_2
  OWNER TO odoo;
