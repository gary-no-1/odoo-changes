-- View: vg_xxx_stock_inventory_stock_line_inventory

DROP VIEW IF EXISTS vg_xxx_stock_inventory_stock_line_inventory;
DROP VIEW IF EXISTS vg_stock_adjustments_all;
DROP VIEW IF EXISTS vg_stock_lot_gtr_info;

CREATE OR REPLACE VIEW vg_xxx_stock_inventory_stock_line_inventory AS 
 SELECT a.id,
    a.name,
    a.state,
    a.date,
    b.prod_lot_id,
    b.location_id,
    b.product_id,
    COALESCE(b.product_qty, 0::numeric) - COALESCE(b.theoretical_qty, 0::numeric) AS qty
   FROM stock_inventory a
     LEFT JOIN stock_inventory_line b ON a.id = b.inventory_id
  WHERE a.state::text = 'done'::text;

ALTER TABLE vg_xxx_stock_inventory_stock_line_inventory
  OWNER TO odoo;

-- --------------------------------------------------------------------------
-- View: vg_stock_adjustments_all


CREATE OR REPLACE VIEW vg_stock_adjustments_all AS 
 SELECT a.id,
    a.create_date,
    a.name,
    a.state,
    a.write_date,
    a.date,
    b.prod_lot_id,
    b.location_id,
    b.product_id,
    COALESCE(b.product_qty, 0::numeric) - COALESCE(b.theoretical_qty, 0::numeric) AS qty,
    c.name AS gtr_no,
    c.x_greentek_lot AS lot_no,
    c.x_greentek_imei AS imei_no,
    c.x_transfer_price_cost AS transfer_price,
    d.complete_name AS location,
    e.product_name,
    e.product_category
   FROM stock_inventory a
     LEFT JOIN stock_inventory_line b ON a.id = b.inventory_id
     LEFT JOIN stock_production_lot c ON b.prod_lot_id = c.id
     JOIN stock_location d ON b.location_id = d.id
     JOIN vg_product_category  e ON b.product_id = e.id
  WHERE a.state::text = 'done'::text;

ALTER TABLE vg_stock_adjustments_all
  OWNER TO odoo;

-- --------------------------------------------------------------------------
-- View: vg_stock_lot_gtr_info


CREATE OR REPLACE VIEW vg_stock_lot_gtr_info AS 
 WITH x AS (
         SELECT f.prod_lot_id,
            min(f.date) AS date
           FROM vg_xxx_stock_inventory_stock_line_inventory f
          GROUP BY f.prod_lot_id
        ), y AS (
         SELECT a.name,
            a.date,
            a.prod_lot_id,
            a.location_id,
            a.product_id,
            a.qty
           FROM vg_xxx_stock_inventory_stock_line_inventory a
             JOIN x ON a.prod_lot_id = x.prod_lot_id AND a.date = x.date
        )
 SELECT y.name AS adj_doc,
    c.name AS gtr_no,
    y.qty,
    c.x_greentek_lot AS lot_no,
    c.x_greentek_imei AS imei_no,
    c.x_transfer_price_cost AS transfer_price,
    d.complete_name AS location,
    e.product_name,
	e.product_category,
    y.prod_lot_id,
    y.location_id,
    y.product_id
   FROM y
     LEFT JOIN stock_production_lot c ON y.prod_lot_id = c.id
     JOIN stock_location d ON y.location_id = d.id
     JOIN vg_product_category e ON y.product_id = e.id;

ALTER TABLE vg_stock_lot_gtr_info
  OWNER TO odoo;
  