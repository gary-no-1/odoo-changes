-- View: stock_lot_history

-- DROP VIEW stock_lot_history;

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
