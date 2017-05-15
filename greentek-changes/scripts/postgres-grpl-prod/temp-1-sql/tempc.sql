-- Table: stock_move

-- DROP TABLE stock_move;

CREATE TABLE stock_move
(
  id serial NOT NULL,
  origin character varying, -- Source
  product_uos_qty numeric, -- Quantity (UOS)
  create_date timestamp without time zone, -- Creation Date
  move_dest_id integer, -- Destination Move
  product_uom integer NOT NULL, -- Unit of Measure
  price_unit double precision, -- Unit Price
  product_uom_qty numeric NOT NULL, -- Quantity
  company_id integer NOT NULL, -- Company
  date timestamp without time zone NOT NULL, -- Date
  product_qty numeric, -- Quantity
  product_uos integer, -- Product UOS
  location_id integer NOT NULL, -- Source Location
  priority character varying, -- Priority
  picking_type_id integer, -- Picking Type
  partner_id integer, -- Destination Address
  note text, -- Notes
  state character varying, -- Status
  origin_returned_move_id integer, -- Origin return move
  product_packaging integer, -- Prefered Packaging
  date_expected timestamp without time zone NOT NULL, -- Expected Date
  procurement_id integer, -- Procurement
  name character varying NOT NULL, -- Description
  create_uid integer, -- Created by
  warehouse_id integer, -- Warehouse
  inventory_id integer, -- Inventory
  partially_available boolean, -- Partially Available
  propagate boolean, -- Propagate cancel and split
  restrict_partner_id integer, -- Owner
  procure_method character varying NOT NULL, -- Supply Method
  write_uid integer, -- Last Updated by
  restrict_lot_id integer, -- Lot
  group_id integer, -- Procurement Group
  product_id integer NOT NULL, -- Product
  split_from integer, -- Move Split From
  picking_id integer, -- Reference
  location_dest_id integer NOT NULL, -- Destination Location
  write_date timestamp without time zone, -- Last Updated on
  push_rule_id integer, -- Push Rule
  rule_id integer, -- Procurement Rule
  invoice_state character varying NOT NULL, -- Invoice Control
  consumed_for integer, -- Consumed for
  raw_material_production_id integer, -- Production Order for Raw Materials
  production_id integer, -- Production Order for Produced Products
  purchase_line_id integer, -- Purchase Order Line
  weight numeric, -- Weight
  weight_net numeric, -- Net weight
  weight_uom_id integer NOT NULL, -- Unit of Measure
  invoice_line_id integer, -- Invoice Line
  CONSTRAINT stock_move_pkey PRIMARY KEY (id),
  CONSTRAINT stock_move_company_id_fkey FOREIGN KEY (company_id)
      REFERENCES res_company (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_consumed_for_fkey FOREIGN KEY (consumed_for)
      REFERENCES stock_move (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_create_uid_fkey FOREIGN KEY (create_uid)
      REFERENCES res_users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_group_id_fkey FOREIGN KEY (group_id)
      REFERENCES procurement_group (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_inventory_id_fkey FOREIGN KEY (inventory_id)
      REFERENCES stock_inventory (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_invoice_line_id_fkey FOREIGN KEY (invoice_line_id)
      REFERENCES account_invoice_line (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_location_dest_id_fkey FOREIGN KEY (location_dest_id)
      REFERENCES stock_location (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_location_id_fkey FOREIGN KEY (location_id)
      REFERENCES stock_location (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_move_dest_id_fkey FOREIGN KEY (move_dest_id)
      REFERENCES stock_move (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_origin_returned_move_id_fkey FOREIGN KEY (origin_returned_move_id)
      REFERENCES stock_move (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_partner_id_fkey FOREIGN KEY (partner_id)
      REFERENCES res_partner (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_picking_id_fkey FOREIGN KEY (picking_id)
      REFERENCES stock_picking (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_picking_type_id_fkey FOREIGN KEY (picking_type_id)
      REFERENCES stock_picking_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_procurement_id_fkey FOREIGN KEY (procurement_id)
      REFERENCES procurement_order (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_product_id_fkey FOREIGN KEY (product_id)
      REFERENCES product_product (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_product_packaging_fkey FOREIGN KEY (product_packaging)
      REFERENCES product_packaging (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_product_uom_fkey FOREIGN KEY (product_uom)
      REFERENCES product_uom (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_product_uos_fkey FOREIGN KEY (product_uos)
      REFERENCES product_uom (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_production_id_fkey FOREIGN KEY (production_id)
      REFERENCES mrp_production (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_purchase_line_id_fkey FOREIGN KEY (purchase_line_id)
      REFERENCES purchase_order_line (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_push_rule_id_fkey FOREIGN KEY (push_rule_id)
      REFERENCES stock_location_path (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_raw_material_production_id_fkey FOREIGN KEY (raw_material_production_id)
      REFERENCES mrp_production (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_restrict_lot_id_fkey FOREIGN KEY (restrict_lot_id)
      REFERENCES stock_production_lot (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_restrict_partner_id_fkey FOREIGN KEY (restrict_partner_id)
      REFERENCES res_partner (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_rule_id_fkey FOREIGN KEY (rule_id)
      REFERENCES procurement_rule (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_split_from_fkey FOREIGN KEY (split_from)
      REFERENCES stock_move (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_warehouse_id_fkey FOREIGN KEY (warehouse_id)
      REFERENCES stock_warehouse (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_weight_uom_id_fkey FOREIGN KEY (weight_uom_id)
      REFERENCES product_uom (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_move_write_uid_fkey FOREIGN KEY (write_uid)
      REFERENCES res_users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL
)
WITH (
  OIDS=FALSE
);
ALTER TABLE stock_move
  OWNER TO odoo;
COMMENT ON TABLE stock_move
  IS 'Stock Move';
COMMENT ON COLUMN stock_move.origin IS 'Source';
COMMENT ON COLUMN stock_move.product_uos_qty IS 'Quantity (UOS)';
COMMENT ON COLUMN stock_move.create_date IS 'Creation Date';
COMMENT ON COLUMN stock_move.move_dest_id IS 'Destination Move';
COMMENT ON COLUMN stock_move.product_uom IS 'Unit of Measure';
COMMENT ON COLUMN stock_move.price_unit IS 'Unit Price';
COMMENT ON COLUMN stock_move.product_uom_qty IS 'Quantity';
COMMENT ON COLUMN stock_move.company_id IS 'Company';
COMMENT ON COLUMN stock_move.date IS 'Date';
COMMENT ON COLUMN stock_move.product_qty IS 'Quantity';
COMMENT ON COLUMN stock_move.product_uos IS 'Product UOS';
COMMENT ON COLUMN stock_move.location_id IS 'Source Location';
COMMENT ON COLUMN stock_move.priority IS 'Priority';
COMMENT ON COLUMN stock_move.picking_type_id IS 'Picking Type';
COMMENT ON COLUMN stock_move.partner_id IS 'Destination Address ';
COMMENT ON COLUMN stock_move.note IS 'Notes';
COMMENT ON COLUMN stock_move.state IS 'Status';
COMMENT ON COLUMN stock_move.origin_returned_move_id IS 'Origin return move';
COMMENT ON COLUMN stock_move.product_packaging IS 'Prefered Packaging';
COMMENT ON COLUMN stock_move.date_expected IS 'Expected Date';
COMMENT ON COLUMN stock_move.procurement_id IS 'Procurement';
COMMENT ON COLUMN stock_move.name IS 'Description';
COMMENT ON COLUMN stock_move.create_uid IS 'Created by';
COMMENT ON COLUMN stock_move.warehouse_id IS 'Warehouse';
COMMENT ON COLUMN stock_move.inventory_id IS 'Inventory';
COMMENT ON COLUMN stock_move.partially_available IS 'Partially Available';
COMMENT ON COLUMN stock_move.propagate IS 'Propagate cancel and split';
COMMENT ON COLUMN stock_move.restrict_partner_id IS 'Owner ';
COMMENT ON COLUMN stock_move.procure_method IS 'Supply Method';
COMMENT ON COLUMN stock_move.write_uid IS 'Last Updated by';
COMMENT ON COLUMN stock_move.restrict_lot_id IS 'Lot';
COMMENT ON COLUMN stock_move.group_id IS 'Procurement Group';
COMMENT ON COLUMN stock_move.product_id IS 'Product';
COMMENT ON COLUMN stock_move.split_from IS 'Move Split From';
COMMENT ON COLUMN stock_move.picking_id IS 'Reference';
COMMENT ON COLUMN stock_move.location_dest_id IS 'Destination Location';
COMMENT ON COLUMN stock_move.write_date IS 'Last Updated on';
COMMENT ON COLUMN stock_move.push_rule_id IS 'Push Rule';
COMMENT ON COLUMN stock_move.rule_id IS 'Procurement Rule';
COMMENT ON COLUMN stock_move.invoice_state IS 'Invoice Control';
COMMENT ON COLUMN stock_move.consumed_for IS 'Consumed for';
COMMENT ON COLUMN stock_move.raw_material_production_id IS 'Production Order for Raw Materials';
COMMENT ON COLUMN stock_move.production_id IS 'Production Order for Produced Products';
COMMENT ON COLUMN stock_move.purchase_line_id IS 'Purchase Order Line';
COMMENT ON COLUMN stock_move.weight IS 'Weight';
COMMENT ON COLUMN stock_move.weight_net IS 'Net weight';
COMMENT ON COLUMN stock_move.weight_uom_id IS 'Unit of Measure';
COMMENT ON COLUMN stock_move.invoice_line_id IS 'Invoice Line';


-- Index: stock_move_company_id_index

-- DROP INDEX stock_move_company_id_index;

CREATE INDEX stock_move_company_id_index
  ON stock_move
  USING btree
  (company_id);

-- Index: stock_move_create_date_index

-- DROP INDEX stock_move_create_date_index;

CREATE INDEX stock_move_create_date_index
  ON stock_move
  USING btree
  (create_date);

-- Index: stock_move_date_expected_index

-- DROP INDEX stock_move_date_expected_index;

CREATE INDEX stock_move_date_expected_index
  ON stock_move
  USING btree
  (date_expected);

-- Index: stock_move_date_index

-- DROP INDEX stock_move_date_index;

CREATE INDEX stock_move_date_index
  ON stock_move
  USING btree
  (date);

-- Index: stock_move_invoice_state_index

-- DROP INDEX stock_move_invoice_state_index;

CREATE INDEX stock_move_invoice_state_index
  ON stock_move
  USING btree
  (invoice_state COLLATE pg_catalog."default");

-- Index: stock_move_location_dest_id_index

-- DROP INDEX stock_move_location_dest_id_index;

CREATE INDEX stock_move_location_dest_id_index
  ON stock_move
  USING btree
  (location_dest_id);

-- Index: stock_move_location_id_index

-- DROP INDEX stock_move_location_id_index;

CREATE INDEX stock_move_location_id_index
  ON stock_move
  USING btree
  (location_id);

-- Index: stock_move_move_dest_id_index

-- DROP INDEX stock_move_move_dest_id_index;

CREATE INDEX stock_move_move_dest_id_index
  ON stock_move
  USING btree
  (move_dest_id);

-- Index: stock_move_name_index

-- DROP INDEX stock_move_name_index;

CREATE INDEX stock_move_name_index
  ON stock_move
  USING btree
  (name COLLATE pg_catalog."default");

-- Index: stock_move_picking_id_index

-- DROP INDEX stock_move_picking_id_index;

CREATE INDEX stock_move_picking_id_index
  ON stock_move
  USING btree
  (picking_id);

-- Index: stock_move_product_id_index

-- DROP INDEX stock_move_product_id_index;

CREATE INDEX stock_move_product_id_index
  ON stock_move
  USING btree
  (product_id);

-- Index: stock_move_product_location_index

-- DROP INDEX stock_move_product_location_index;

CREATE INDEX stock_move_product_location_index
  ON stock_move
  USING btree
  (product_id, location_id, location_dest_id, company_id, state COLLATE pg_catalog."default");

-- Index: stock_move_production_id_index

-- DROP INDEX stock_move_production_id_index;

CREATE INDEX stock_move_production_id_index
  ON stock_move
  USING btree
  (production_id);

-- Index: stock_move_purchase_line_id_index

-- DROP INDEX stock_move_purchase_line_id_index;

CREATE INDEX stock_move_purchase_line_id_index
  ON stock_move
  USING btree
  (purchase_line_id);

-- Index: stock_move_raw_material_production_id_index

-- DROP INDEX stock_move_raw_material_production_id_index;

CREATE INDEX stock_move_raw_material_production_id_index
  ON stock_move
  USING btree
  (raw_material_production_id);

-- Index: stock_move_state_index

-- DROP INDEX stock_move_state_index;

CREATE INDEX stock_move_state_index
  ON stock_move
  USING btree
  (state COLLATE pg_catalog."default");
  
-- --------------------------------------------  ----------------------  ----------------------  
-- View: vg_xxy_temp

-- DROP VIEW vg_xxy_temp;

CREATE OR REPLACE VIEW vg_xxy_temp AS 
 SELECT i.id,
    l.id AS location_id,
    i.product_id,
    i.name AS description,
        CASE
            WHEN i.state::text = 'done'::text THEN i.product_qty
            ELSE 0::numeric
        END AS picking_qty,
    i.date,
    i.restrict_lot_id AS prodlot_id,
    i.state,
    i.split_from,
    i.origin_returned_move_id,
    i.picking_id,
    l.company_id
   FROM stock_location l,
    stock_move i
  WHERE l.usage::text = 'internal'::text AND i.location_dest_id = l.id AND i.state::text <> 'cancel'::text AND i.company_id = l.company_id
UNION ALL
 SELECT - o.id AS id,
    l.id AS location_id,
    o.product_id,
    o.name AS description,
        CASE
            WHEN o.state::text = 'done'::text THEN - o.product_qty
            ELSE 0::numeric
        END AS picking_qty,
    o.date,
    o.restrict_lot_id AS prodlot_id,
    o.state,
    o.split_from,
    o.origin_returned_move_id,
    o.picking_id,
    l.company_id
   FROM stock_location l,
    stock_move o
  WHERE l.usage::text = 'internal'::text AND o.location_id = l.id AND o.state::text <> 'cancel'::text AND o.company_id = l.company_id;

ALTER TABLE vg_xxy_temp
  OWNER TO odoo;
  
-- --------------------------------------------  ----------------------  ----------------------  
-- View: vg_xxy_temp_2

-- DROP VIEW vg_xxy_temp_2;

CREATE OR REPLACE VIEW vg_xxy_temp_2 AS 
 WITH x AS (
         SELECT vg_xxy_temp.id,
            vg_xxy_temp.location_id,
            vg_xxy_temp.product_id,
            vg_xxy_temp.description,
            vg_xxy_temp.picking_qty,
            vg_xxy_temp.date,
            vg_xxy_temp.prodlot_id,
            vg_xxy_temp.state,
            vg_xxy_temp.split_from,
            vg_xxy_temp.origin_returned_move_id,
            vg_xxy_temp.picking_id,
            vg_xxy_temp.company_id
           FROM vg_xxy_temp
        )
 SELECT a.id,
    a.location_id,
    a.product_id,
    a.description,
    a.picking_qty,
    a.date,
    a.prodlot_id,
    a.state,
    a.split_from,
    a.origin_returned_move_id,
    a.picking_id,
    a.company_id,
    b.lot_id,
    b.product_qty
   FROM x a
     JOIN stock_pack_operation b ON a.picking_id = b.picking_id AND a.product_id = b.product_id AND b.location_dest_id = a.location_id
  WHERE a.prodlot_id IS NULL
UNION
 SELECT a.id,
    a.location_id,
    a.product_id,
    a.description,
    a.picking_qty,
    a.date,
    a.prodlot_id,
    a.state,
    a.split_from,
    a.origin_returned_move_id,
    a.picking_id,
    a.company_id,
    b.lot_id,
    b.product_qty
   FROM x a
     JOIN stock_pack_operation b ON a.picking_id = b.picking_id AND a.product_id = b.product_id AND b.location_id = a.location_id
  WHERE a.prodlot_id IS NULL
UNION
 SELECT a.id,
    a.location_id,
    a.product_id,
    a.description,
    a.picking_qty,
    a.date,
    a.prodlot_id,
    a.state,
    a.split_from,
    a.origin_returned_move_id,
    a.picking_id,
    a.company_id,
    a.prodlot_id AS lot_id,
    a.picking_qty AS product_qty
   FROM x a
  WHERE a.prodlot_id IS NOT NULL;

ALTER TABLE vg_xxy_temp_2
  OWNER TO odoo;

-- --------------------------------------------  ----------------------  ----------------------  
-- View: vg_stock_by_product_stock_history

-- DROP VIEW vg_stock_by_product_stock_history;

CREATE OR REPLACE VIEW vg_stock_by_product_stock_history AS 
 WITH y AS (
         SELECT h.product_id,
            sum(h.quantity) AS qty
           FROM stock_history h,
            stock_move m
          WHERE h.move_id = m.id
          GROUP BY h.product_id
        ), z AS (
         SELECT y.product_id,
            b.product_name,
            b.product_category,
            y.qty
           FROM y
             JOIN vg_product_category b ON b.id = y.product_id
          WHERE y.qty <> 0::double precision
        )
 SELECT z.product_category,
    z.product_name,
    z.qty
   FROM z
  ORDER BY z.product_category, z.product_name;

ALTER TABLE vg_stock_by_product_stock_history
  OWNER TO odoo;
-- --------------------------------------------  ----------------------  ----------------------  

SELECT id, move_id, location_id, company_id, product_id, product_categ_id, 
       quantity, date, price_unit_on_quant, source , sum(quantity) over (partition by product_id order by date , move_id) as cum_qty
  FROM stock_history 
  where product_id = 2069 order by product_id , date desc , move_id desc ;

  
with x as (SELECT id, move_id, location_id, company_id, product_id, product_categ_id, 
       quantity, date, price_unit_on_quant, source , sum(quantity) over (partition by product_id order by date , move_id) as cum_qty
  FROM stock_history 
  where product_id = 2069),
  y as (select * from x where quantity > 0  and cum_qty <= 3 ),
  z as (select * , row_number() over (partition by cum_qty order by product_id , date desc , move_id desc) as rnk from y)
  select * from z where rnk = 1  
  ;
  
  
WITH x
AS (
	SELECT id, move_id, location_id, company_id, product_id, product_categ_id, quantity, DATE, price_unit_on_quant, source, sum(quantity) OVER (
			PARTITION BY product_id ORDER BY DATE, move_id
			) AS cum_qty
	FROM stock_history
	WHERE product_id = 2069
	), y
AS (
	SELECT *
	FROM x
	WHERE quantity > 0
		AND cum_qty <= 3
	), z
AS (
	SELECT *, row_number() OVER (
			PARTITION BY cum_qty ORDER BY product_id, DATE DESC, move_id DESC
			) AS rnk
	FROM y
	)
SELECT *
FROM z
WHERE rnk = 1;  

-- --------------------------------------------  ----------------------  ----------------------  

WITH x
AS (
	SELECT id, move_id, location_id, company_id, product_id, product_categ_id, quantity, DATE, price_unit_on_quant, source, sum(quantity) OVER (
			PARTITION BY product_id ORDER BY DATE, move_id
			) AS cum_qty
	FROM stock_history
	), y
AS (
	SELECT x.*, f.product_category, f.product_name
	FROM x join vg_xxx_stock_by_product_stock_history f
	on x.product_id = f.product_id
	WHERE x.quantity > 0
		AND x.cum_qty <= f.qty
	), z
AS (
	SELECT *, row_number() OVER (
			PARTITION BY y.product_id ,  y.cum_qty order by y.product_id , y.cum_qty , y.date 
			) AS rnk
	FROM y
	)
SELECT *
FROM z
WHERE rnk = 1;  

-- --------------------------------------------  ----------------------  ----------------------  
-- View: vg_stock_by_location_product_stock_history

-- DROP VIEW vg_stock_by_location_product_stock_history;

CREATE OR REPLACE VIEW vg_stock_by_location_product_stock_history AS 
 WITH x AS (
         SELECT stock_history.id,
            stock_history.move_id,
            stock_history.location_id,
            stock_history.company_id,
            stock_history.product_id,
            stock_history.product_categ_id,
            stock_history.quantity,
            stock_history.date,
            stock_history.price_unit_on_quant,
            stock_history.source,
            sum(stock_history.quantity) OVER (PARTITION BY stock_history.product_id ORDER BY stock_history.date, stock_history.move_id) AS cum_qty
           FROM stock_history
        ), y AS (
         SELECT x.id,
            x.move_id,
            x.location_id,
            x.company_id,
            x.product_id,
            x.product_categ_id,
            x.quantity,
            x.date,
            x.price_unit_on_quant,
            x.source,
            x.cum_qty,
            f.product_category,
            f.product_name
           FROM x
             JOIN vg_xxx_stock_by_product_stock_history f ON x.product_id = f.product_id
          WHERE x.quantity > 0::double precision AND x.cum_qty <= f.qty
        ), z AS (
         SELECT y.id,
            y.move_id,
            y.location_id,
            y.company_id,
            y.product_id,
            y.product_categ_id,
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
    l.complete_name AS location,
    z.product_category,
    z.product_name,
    z.quantity
   FROM z
     JOIN stock_location l ON z.location_id = l.id
  WHERE z.rnk = 1;

ALTER TABLE vg_stock_by_location_product_stock_history
  OWNER TO odoo;

  
  
  
-- ---------------------------------------------------------------------------------------------------------
-- View: stock_history

-- DROP VIEW stock_history;

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
			stock_move.restrict_lot_id as prodlot_id,
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
			stock_move.restrict_lot_id as prodlot_id,
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


