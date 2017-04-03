-- View: vg_closing_stock_location_serial_stock_history

DROP VIEW IF EXISTS vg_closing_stock_location_serial_stock_history cascade;
DROP VIEW IF EXISTS stock_lot_history cascade;

-- ------------------------------------------------------------------------------------------------------------------
-- View: stock_lot_history
CREATE OR REPLACE VIEW stock_lot_history AS 
 SELECT min(foo.id) AS id,
    foo.move_id,
    foo.location_id,
    foo.company_id,
    foo.product_id,
    foo.product_categ_id,
    foo.prodlot_id,
    sum(foo.quantity) AS quantity,
    foo.date,
    foo.price_unit_on_quant,
    foo.source
   FROM ( SELECT (stock_move.id::text || '-'::text) || quant.id::text AS id,
            quant.id AS quant_id,
            stock_move.id AS move_id,
            dest_location.id AS location_id,
            dest_location.company_id,
            stock_move.product_id,
            product_template.categ_id AS product_categ_id,
            quant.qty AS quantity,
            stock_move.date,
            quant.cost AS price_unit_on_quant,
            quant.lot_id AS prodlot_id,
            stock_move.origin AS source
           FROM stock_quant quant,
            stock_quant_move_rel,
            stock_move
             LEFT JOIN stock_location dest_location ON stock_move.location_dest_id = dest_location.id
             LEFT JOIN stock_location source_location ON stock_move.location_id = source_location.id
             LEFT JOIN product_product ON product_product.id = stock_move.product_id
             LEFT JOIN product_template ON product_template.id = product_product.product_tmpl_id
          WHERE quant.qty > 0::double precision AND stock_move.state::text = 'done'::text AND (dest_location.usage::text = ANY (ARRAY['internal'::character varying::text, 'transit'::character varying::text])) AND stock_quant_move_rel.quant_id = quant.id AND stock_quant_move_rel.move_id = stock_move.id AND (source_location.company_id IS NULL AND dest_location.company_id IS NOT NULL OR source_location.company_id IS NOT NULL AND dest_location.company_id IS NULL OR source_location.company_id <> dest_location.company_id OR (source_location.usage::text <> ALL (ARRAY['internal'::character varying::text, 'transit'::character varying::text])))
        UNION
         SELECT (('-'::text || stock_move.id::text) || '-'::text) || quant.id::text AS id,
            quant.id AS quant_id,
            stock_move.id AS move_id,
            source_location.id AS location_id,
            source_location.company_id,
            stock_move.product_id,
            product_template.categ_id AS product_categ_id,
            - quant.qty AS quantity,
            stock_move.date,
            quant.cost AS price_unit_on_quant,
            quant.lot_id AS prodlot_id,
            stock_move.origin AS source
           FROM stock_quant quant,
            stock_quant_move_rel,
            stock_move
             LEFT JOIN stock_location source_location ON stock_move.location_id = source_location.id
             LEFT JOIN stock_location dest_location ON stock_move.location_dest_id = dest_location.id
             LEFT JOIN product_product ON product_product.id = stock_move.product_id
             LEFT JOIN product_template ON product_template.id = product_product.product_tmpl_id
          WHERE quant.qty > 0::double precision AND stock_move.state::text = 'done'::text AND (source_location.usage::text = ANY (ARRAY['internal'::character varying::text, 'transit'::character varying::text])) AND stock_quant_move_rel.quant_id = quant.id AND stock_quant_move_rel.move_id = stock_move.id AND (dest_location.company_id IS NULL AND source_location.company_id IS NOT NULL OR dest_location.company_id IS NOT NULL AND source_location.company_id IS NULL OR dest_location.company_id <> source_location.company_id OR (dest_location.usage::text <> ALL (ARRAY['internal'::character varying::text, 'transit'::character varying::text])))) foo
  GROUP BY foo.move_id, foo.location_id, foo.company_id, foo.product_id, foo.product_categ_id, foo.date, foo.price_unit_on_quant, foo.source, foo.prodlot_id;

ALTER TABLE stock_lot_history
  OWNER TO odoo;
COMMENT ON VIEW stock_lot_history
  IS 'created same as stock_history except that prodlot_id is also kept in view
prodlot_is is available in stock_move as well as stock_quant. 
if they are present in both , they are same
if prodlot_id (restrict_lot_id) in stock_move is null , then lot_id in stock_quant usually exists
hence stock_quant.lot_id is used in this view
';

-- ------------------------------------------------------------------------------------------------------------------
-- View: vg_closing_stock_location_serial_stock_history
CREATE OR REPLACE VIEW vg_closing_stock_location_serial_stock_history AS 
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
          WHERE x.quantity > 0::double precision AND x.cum_qty <= f.qty
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
        )
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
  WHERE z.rnk = 1;

ALTER TABLE vg_closing_stock_location_serial_stock_history
  OWNER TO odoo;
