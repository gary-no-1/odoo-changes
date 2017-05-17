https://github.com/odoo/odoo/pull/14973/files
https://github.com/numerigraphe/odoo/blob/d7f1fdfec9894b2081b6109bf2fca54145739511/addons/stock_account/wizard/stock_valuation_history.py

CREATE MATERIALIZED VIEW stock_history AS (
              SELECT MIN(id) as id,
                move_id,
                location_id,
                company_id,
                product_id,
                product_categ_id,
                SUM(quantity) as quantity,
                date,
                SUM(price_unit_on_quant * quantity) / SUM(quantity) as price_unit_on_quant,
                source
                FROM
                (
                -- WE START FROM THE STOCK QUANTS
                (SELECT
                    quant.id + 1000000000 AS id,
                    NULL::INT AS move_id,
                    dest_location.id AS location_id,
                    dest_location.company_id AS company_id,
                    quant.product_id AS product_id,
                    product_template.categ_id AS product_categ_id,
                    quant.qty AS quantity,
            quant.lot_id AS prodlot_id,
                    NULL::TIMESTAMP AS date,
                    quant.cost AS price_unit_on_quant,
                    'Current stock'::TEXT AS source
                FROM
                    stock_quant as quant
                JOIN
                    product_product ON product_product.id = quant.product_id
                JOIN
                   stock_location dest_location ON quant.location_id = dest_location.id
                JOIN
                    product_template ON product_template.id = product_product.product_tmpl_id
                WHERE quant.qty>0 AND
                    dest_location.usage IN ('internal', 'transit')
                ) UNION ALL
                -- We subtract the entering moves as we go back in time
                (SELECT
                    stock_move.id AS id,
                    stock_move.id AS move_id,
                    dest_location.id AS location_id,
                    dest_location.company_id AS company_id,
                    stock_move.product_id AS product_id,
                    product_template.categ_id AS product_categ_id,
                    - quant.qty AS quantity,
                    stock_move.date AS date,
                    quant.cost as price_unit_on_quant,
                    COALESCE(stock_move.origin, stock_move.name) AS source
                FROM
                    stock_move
                JOIN
                    stock_quant_move_rel on stock_quant_move_rel.move_id = stock_move.id
                JOIN
                    stock_quant as quant on stock_quant_move_rel.quant_id = quant.id
                JOIN
                   stock_location dest_location ON stock_move.location_dest_id = dest_location.id
                JOIN
                    stock_location source_location ON stock_move.location_id = source_location.id
                JOIN
                    product_product ON product_product.id = stock_move.product_id
                JOIN
                    product_template ON product_template.id = product_product.product_tmpl_id
                WHERE quant.qty>0 AND stock_move.state = 'done' AND dest_location.usage in ('internal', 'transit')
                  AND (
                    (source_location.company_id is null and dest_location.company_id is not null) or
                    (source_location.company_id is not null and dest_location.company_id is null) or
                    source_location.company_id != dest_location.company_id or
                    source_location.usage not in ('internal', 'transit'))
                ) UNION ALL
                -- We add back outgoing moves as we go back in time
                (SELECT
                    (-1) * stock_move.id AS id,
                    stock_move.id AS move_id,
                    source_location.id AS location_id,
                    source_location.company_id AS company_id,
                    stock_move.product_id AS product_id,
                    product_template.categ_id AS product_categ_id,
                    quant.qty AS quantity,
                    stock_move.date AS date,
                    quant.cost as price_unit_on_quant,
                    COALESCE(stock_move.origin, stock_move.name) AS source
                FROM
                    stock_move
                JOIN
                    stock_quant_move_rel on stock_quant_move_rel.move_id = stock_move.id
                JOIN
                    stock_quant as quant on stock_quant_move_rel.quant_id = quant.id
                JOIN
                    stock_location source_location ON stock_move.location_id = source_location.id
                JOIN
                    stock_location dest_location ON stock_move.location_dest_id = dest_location.id
                JOIN
                    product_product ON product_product.id = stock_move.product_id
                JOIN
                    product_template ON product_template.id = product_product.product_tmpl_id
                WHERE quant.qty>0 AND stock_move.state = 'done' AND source_location.usage in ('internal', 'transit')
                 AND (
                    (dest_location.company_id is null and source_location.company_id is not null) or
                    (dest_location.company_id is not null and source_location.company_id is null) or
                    dest_location.company_id != source_location.company_id or
                    dest_location.usage not in ('internal', 'transit'))
                ))
                AS foo
                GROUP BY move_id, location_id, company_id, product_id, product_categ_id, date, source
            ) WITH DATA""")