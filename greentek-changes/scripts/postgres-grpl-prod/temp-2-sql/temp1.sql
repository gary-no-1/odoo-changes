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

-- -------------------------------------------

-- View: stock_history

-- DROP VIEW stock_history;

CREATE OR REPLACE VIEW stock_history AS 
 SELECT min(foo.id) AS id,
    foo.move_id,
    foo.location_id,
    foo.company_id,
    foo.product_id,
    foo.product_categ_id,
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
            stock_move.origin AS source
           FROM stock_quant quant,
            stock_quant_move_rel,
            stock_move
             LEFT JOIN stock_location source_location ON stock_move.location_id = source_location.id
             LEFT JOIN stock_location dest_location ON stock_move.location_dest_id = dest_location.id
             LEFT JOIN product_product ON product_product.id = stock_move.product_id
             LEFT JOIN product_template ON product_template.id = product_product.product_tmpl_id
          WHERE quant.qty > 0::double precision AND stock_move.state::text = 'done'::text AND (source_location.usage::text = ANY (ARRAY['internal'::character varying::text, 'transit'::character varying::text])) AND stock_quant_move_rel.quant_id = quant.id AND stock_quant_move_rel.move_id = stock_move.id AND (dest_location.company_id IS NULL AND source_location.company_id IS NOT NULL OR dest_location.company_id IS NOT NULL AND source_location.company_id IS NULL OR dest_location.company_id <> source_location.company_id OR (dest_location.usage::text <> ALL (ARRAY['internal'::character varying::text, 'transit'::character varying::text])))) foo
  GROUP BY foo.move_id, foo.location_id, foo.company_id, foo.product_id, foo.product_categ_id, foo.date, foo.price_unit_on_quant, foo.source;

ALTER TABLE stock_history
  OWNER TO odoo;

-- -----------------------------------------------------------------
-- View: stock_history
-- DROP VIEW stock_history;
CREATE
	OR REPLACE VIEW stock_history AS

SELECT min(foo.id) AS id,
	foo.move_id,
	foo.location_id,
	foo.company_id,
	foo.product_id,
	foo.product_categ_id,
	sum(foo.quantity) AS quantity,
	foo.DATE,
	foo.price_unit_on_quant,
	foo.source
FROM (
	SELECT (stock_move.id::TEXT || '-'::TEXT) || quant.id::TEXT AS id,
		quant.id AS quant_id,
		stock_move.id AS move_id,
		dest_location.id AS location_id,
		dest_location.company_id,
		stock_move.product_id,
		product_template.categ_id AS product_categ_id,
		quant.qty AS quantity,
		stock_move.DATE,
		quant.cost AS price_unit_on_quant,
		stock_move.origin AS source
	FROM stock_quant quant,
		stock_quant_move_rel,
		stock_move
	LEFT JOIN stock_location dest_location
		ON stock_move.location_dest_id = dest_location.id
	LEFT JOIN stock_location source_location
		ON stock_move.location_id = source_location.id
	LEFT JOIN product_product
		ON product_product.id = stock_move.product_id
	LEFT JOIN product_template
		ON product_template.id = product_product.product_tmpl_id
	WHERE quant.qty > 0::FLOAT
		AND stock_move.STATE::TEXT = 'done'::TEXT
		AND (dest_location.usage::TEXT = ANY (ARRAY ['internal'::character varying::text, 'transit'::character varying::text]))
		AND stock_quant_move_rel.quant_id = quant.id
		AND stock_quant_move_rel.move_id = stock_move.id
		AND (
			source_location.company_id IS NULL
			AND dest_location.company_id IS NOT NULL
			OR source_location.company_id IS NOT NULL
			AND dest_location.company_id IS NULL
			OR source_location.company_id <> dest_location.company_id
			OR (source_location.usage::TEXT <> ALL (ARRAY ['internal'::character varying::text, 'transit'::character varying::text]))
			)
	
	UNION
	
	SELECT (('-'::TEXT || stock_move.id::TEXT) || '-'::TEXT) || quant.id::TEXT AS id,
		quant.id AS quant_id,
		stock_move.id AS move_id,
		source_location.id AS location_id,
		source_location.company_id,
		stock_move.product_id,
		product_template.categ_id AS product_categ_id,
		- quant.qty AS quantity,
		stock_move.DATE,
		quant.cost AS price_unit_on_quant,
		stock_move.origin AS source
	FROM stock_quant quant,
		stock_quant_move_rel,
		stock_move
	LEFT JOIN stock_location source_location
		ON stock_move.location_id = source_location.id
	LEFT JOIN stock_location dest_location
		ON stock_move.location_dest_id = dest_location.id
	LEFT JOIN product_product
		ON product_product.id = stock_move.product_id
	LEFT JOIN product_template
		ON product_template.id = product_product.product_tmpl_id
	WHERE quant.qty > 0::FLOAT
		AND stock_move.STATE::TEXT = 'done'::TEXT
		AND (source_location.usage::TEXT = ANY (ARRAY ['internal'::character varying::text, 'transit'::character varying::text]))
		AND stock_quant_move_rel.quant_id = quant.id
		AND stock_quant_move_rel.move_id = stock_move.id
		AND (
			dest_location.company_id IS NULL
			AND source_location.company_id IS NOT NULL
			OR dest_location.company_id IS NOT NULL
			AND source_location.company_id IS NULL
			OR dest_location.company_id <> source_location.company_id
			OR (dest_location.usage::TEXT <> ALL (ARRAY ['internal'::character varying::text, 'transit'::character varying::text]))
			)
	) foo
GROUP BY foo.move_id,
	foo.location_id,
	foo.company_id,
	foo.product_id,
	foo.product_categ_id,
	foo.DATE,
	foo.price_unit_on_quant,
	foo.source;

ALTER TABLE stock_history OWNER TO odoo;



-- -------------------------------------------------------------------------
WITH x
AS (
	SELECT a.id,
		a.DATE,
		a.picking_id,
		a.origin,
		a.product_qty,
		a.restrict_lot_id,
		a.location_id,
		a.STATE,
		source_location.usage AS source,
		a.location_dest_id,
		dest_location.usage AS destination,
		a.invoice_line_id
	FROM stock_move a
	LEFT JOIN stock_location dest_location
		ON a.location_dest_id = dest_location.id
	LEFT JOIN stock_location source_location
		ON a.location_id = source_location.id
	),
y
AS (
	SELECT *
	FROM x
	WHERE (
			source = 'customer'
			OR destination = 'customer'
			)
		AND STATE = 'done'
	)
SELECT y.*,
    quant.lot_id,
	quant.qty AS quantity
FROM y,
	stock_quant quant,
	stock_quant_move_rel
WHERE stock_quant_move_rel.quant_id = quant.id
	AND stock_quant_move_rel.move_id = y.id;

-- ------------------------------------------------------------
with x1 as (
SELECT a.id,
	a.create_date AS so_create,
	a.date_order AS so_date,
	a.write_date so_write,
	a.date_confirm AS so_confirm,
	a.NAME AS sale_order_number,
	b.display_name AS so_create_name,
	c.display_name AS so_user_name,
	d.display_name AS so_write_name
FROM sale_order a
LEFT JOIN vg_user_name b
	ON a.create_uid = b.id
LEFT JOIN vg_user_name c
	ON a.user_id = c.id
LEFT JOIN vg_user_name d
	ON a.write_uid = d.id),
	x2 as 
	(select x1.id , sol.id as sol_id
	from x1 join sale_order_line sol on x1.id = sol.order_id),
	x3 as (select x2.id , x2.sol_id , pro.id as pro_id
	from x2 join procurement_order pro on x2.sol_id = pro.sale_line_id),
	x4 as (select 
	select * from x3
	
	
	
SELECT so.NAME

FROM stock_picking sp

INNER JOIN stock_move sm

ON sp.id = sm.picking_id

INNER JOIN procurement_order po

ON sm.procurement_id = po.id

INNER JOIN sale_order_line sol

ON po.sale_line_id = sol.id

INNER JOIN sale_order so

ON sol.order_id = so.id	



with x
as (
	select so.name as sale_order,
		so.create_uid as so_create_uid,
		so.create_date as so_create,
		so.write_uid as so_write_uid,
		so.write_date so_write,
		so.user_id as so_user_id,
		so.date_order as so_date,
		so.date_confirm as so_confirm,
		sp.name as stock_picking,
		sp.create_uid as sp_create_uid,
		sp.create_date as sp_create,
		sp.write_uid as sp_write_uid,
		sp.write_date as sp_write,
		sp.date_done as sp_date_transfer,
		ai.number as invoice_number,
		ai.date_invoice as invoice_date,
		ai.create_uid as ai_create_uid,
		ai.create_date as ai_create,
		ai.write_uid as ai_write_uid,
		ai.write_date ai_write,
		ai.user_id as ai_user_id
	from stock_picking sp
	inner join stock_move sm
		on sp.id = sm.picking_id
	inner join procurement_order po
		on sm.procurement_id = po.id
	inner join sale_order_line sol
		on po.sale_line_id = sol.id
	inner join sale_order so
		on sol.order_id = so.id
	inner join account_invoice ai
		on sp.invoice_id = ai.id
	),
y
as (
	select x.*,
		row_number() over (partition by x.sale_order) as rnk
	from x
	),
a
as (
	select *
	from y
	where rnk = 1
	)
select a.sale_order,
	b.display_name as so_create_user,
	a.so_create,
	d.display_name as so_write_user,
	a.so_write,
	c.display_name as so_user,
	a.so_date,
	a.so_confirm,
	a.stock_picking,
	e.display_name as sp_create_user,
	a.sp_create,
	f.display_name as sp_write_user,
	a.sp_write_uid,
	a.sp_write,
	a.sp_date_transfer,
	a.invoice_number,
	a.invoice_date,
	a.ai_create_uid,
	a.ai_create,
	a.ai_write_uid,
	a.ai_write,
	a.ai_user_id
from a
left join vg_user_name b
	on a.so_create_uid = b.id
left join vg_user_name c
	on a.so_user_id = c.id
left join vg_user_name d
	on a.so_write_uid = d.id	
left join vg_user_name e
	on a.sp_create_uid = e.id
left join vg_user_name f
	on a.so_write_uid = f.id
