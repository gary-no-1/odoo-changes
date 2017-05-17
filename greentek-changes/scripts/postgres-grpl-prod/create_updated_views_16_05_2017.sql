-- View: vg_closing_stock_location_serial_stock_history_2

DROP VIEW IF EXISTS vg_closing_stock_location_serial_stock_history_2;

CREATE OR REPLACE VIEW vg_closing_stock_location_serial_stock_history_2 AS 
 SELECT quant.id + 1000000000 AS id,
    dest_location.id AS location_id,
    quant.product_id,
    product_template.categ_id AS product_categ_id,
    quant.lot_id AS prodlot_id,
    quant.qty AS quantity,
    product_template.name AS product_name,
    product_category.name AS product_category,
    dest_location.complete_name AS location,
    s.name AS gtr_no,
    s.create_date::date AS incoming_date,
    s.x_greentek_lot AS lot_no,
    product_template.list_price,
    s.x_transfer_price_cost AS transfer_price
   FROM stock_quant quant
     JOIN product_product ON product_product.id = quant.product_id
     JOIN stock_location dest_location ON quant.location_id = dest_location.id
     JOIN product_template ON product_template.id = product_product.product_tmpl_id
     JOIN product_category ON product_template.categ_id = product_category.id
     LEFT JOIN stock_production_lot s ON quant.lot_id = s.id
  WHERE quant.qty > 0::double precision AND (dest_location.usage::text = ANY (ARRAY['internal'::character varying::text, 'transit'::character varying::text]));

ALTER TABLE vg_closing_stock_location_serial_stock_history_2
  OWNER TO odoo;
