WITH t
AS (
	SELECT location_id,
		product_id,
		prodlot_id,
		DATE,
		sum(NAME) OVER (
			PARTITION BY location_id,
			product_id,
			prodlot_id ORDER BY DATE
			) AS ldg_amt
	FROM stk_mat_loc_product_lot
	)
SELECT t.location_id,
	b.complete_name AS wh_location,
	t.product_id,
	d.NAME AS product_name,
	t.prodlot_id,
	t.DATE,
	t.ldg_amt
FROM t
LEFT JOIN stock_location b ON t.location_id = b.id
LEFT JOIN product_product c ON t.product_id = c.id
LEFT JOIN product_template d ON c.product_tmpl_id = d.id
WHERE t.ldg_amt < 0
	AND t.prodlot_id IS NULL;
	
-- -------------------------------------------------------------------------------------------------------	
WITH t
AS (
	SELECT location_id,
		product_id,
		DATE,
		sum(NAME) OVER (
			PARTITION BY location_id,
			product_id ORDER BY DATE
			) AS ldg_amt
	FROM stk_mat_loc_product
	)
SELECT t.location_id,
	b.complete_name AS wh_location,
	t.product_id,
	d.NAME AS product_name,
	t.DATE,
	t.ldg_amt
FROM t
LEFT JOIN stock_location b ON t.location_id = b.id
LEFT JOIN product_product c ON t.product_id = c.id
LEFT JOIN product_template d ON c.product_tmpl_id = d.id
WHERE t.ldg_amt < 0;
	
-- -------------------------------------------------------------------------------------------------------	
CREATE MATERIALIZED VIEW stk_mat_loc_product_lot AS

SELECT stock_move_by_location.id,
	stock_move_by_location.location_id,
	stock_move_by_location.product_id,
	stock_move_by_location.description,
	stock_move_by_location.NAME,
	stock_move_by_location.product_qty_pending,
	stock_move_by_location.DATE,
	stock_move_by_location.prodlot_id,
	stock_move_by_location.picking_id,
	stock_move_by_location.company_id
FROM stock_move_by_location
ORDER BY stock_move_by_location.location_id,
	stock_move_by_location.product_id,
	stock_move_by_location.prodlot_id,
	stock_move_by_location.DATE
WITH DATA;

ALTER TABLE stk_mat_loc_product_lot OWNER TO odoo;
	
-- -------------------------------------------------------------------------------------------------------	
CREATE MATERIALIZED VIEW stk_mat_loc_product AS

SELECT stock_move_by_location.id,
	stock_move_by_location.location_id,
	stock_move_by_location.product_id,
	stock_move_by_location.description,
	stock_move_by_location.NAME,
	stock_move_by_location.product_qty_pending,
	stock_move_by_location.DATE,
	stock_move_by_location.prodlot_id,
	stock_move_by_location.picking_id,
	stock_move_by_location.company_id
FROM stock_move_by_location
ORDER BY stock_move_by_location.location_id,
	stock_move_by_location.product_id,
	stock_move_by_location.DATE
WITH DATA;

ALTER TABLE stk_mat_loc_product OWNER TO odoo;
	
-- -------------------------------------------------------------------------------------------------------	
SELECT a.* , b.lot_id
  FROM stock_move_by_location a 
  join stock_pack_operation b
  on a.picking_id = b.picking_id and a.product_id = b.product_id and b.location_id = a.location_id
  where a.prodlot_id is null 

SELECT a.* , b.lot_id
  FROM stock_move_by_location a 
  join stock_pack_operation b
  on a.picking_id = b.picking_id and a.product_id = b.product_id and b.location_dest_id = a.location_id
  where a.prodlot_id is null 
  
SELECT id, location_id, product_id, description, name, product_qty_pending, 
       date, prodlot_id, picking_id, company_id
  FROM stock_move_by_location;

SELECT a.id, a.location_id, a.product_id, a.description, name, product_qty_pending, 
       a.date, prodlot_id, a.picking_id, a.company_id , b.lot_id as prodlot_id , case name < 0 then -1 else 1 end as name
  FROM stock_move_by_location a 
  join stock_pack_operation b
  on a.picking_id = b.picking_id and a.product_id = b.product_id and b.location_id = a.location_id
  where a.prodlot_id is null 

SELECT a.id,
	a.location_id,
	a.product_id,
	a.description,
	NAME AS old_qty,
	product_qty_pending,
	a.DATE,
	prodlot_id,
	a.picking_id,
	a.company_id,
	b.lot_id AS prodlot_id,
	CASE 
		WHEN a.NAME < 0
			THEN - 1
		ELSE 1
		END AS stock_qty
FROM stock_move_by_location a
INNER JOIN stock_pack_operation b ON a.picking_id = b.picking_id
	AND a.product_id = b.product_id
	AND b.location_id = a.location_id
WHERE a.prodlot_id IS NULL  

CREATE TABLE stock_pack_operation
(
  id serial NOT NULL,
  create_date timestamp without time zone, -- Created on
  result_package_id integer, -- Destination Package
  write_uid integer, -- Last Updated by
  currency integer, -- Currency
  package_id integer, -- Source Package
  cost double precision, -- Cost
  product_qty numeric NOT NULL, -- Quantity
  lot_id integer, -- Lot/Serial Number
  location_id integer NOT NULL, -- Source Location
  create_uid integer, -- Created by
  qty_done numeric, -- Quantity Processed
  owner_id integer, -- Owner
  write_date timestamp without time zone, -- Last Updated on
  date timestamp without time zone NOT NULL, -- Date
  product_id integer, -- Product
  product_uom_id integer, -- Product Unit of Measure
  location_dest_id integer NOT NULL, -- Destination Location
  processed character varying NOT NULL, -- Has been processed?
  picking_id integer NOT NULL, -- Stock Picking
  CONSTRAINT stock_pack_operation_pkey PRIMARY KEY (id),
  CONSTRAINT stock_pack_operation_create_uid_fkey FOREIGN KEY (create_uid)
      REFERENCES res_users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_pack_operation_currency_fkey FOREIGN KEY (currency)
      REFERENCES res_currency (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT stock_pack_operation_location_dest_id_fkey FOREIGN KEY (location_dest_id)
      REFERENCES stock_location (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_pack_operation_location_id_fkey FOREIGN KEY (location_id)
      REFERENCES stock_location (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_pack_operation_lot_id_fkey FOREIGN KEY (lot_id)
      REFERENCES stock_production_lot (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_pack_operation_owner_id_fkey FOREIGN KEY (owner_id)
      REFERENCES res_partner (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_pack_operation_package_id_fkey FOREIGN KEY (package_id)
      REFERENCES stock_quant_package (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_pack_operation_picking_id_fkey FOREIGN KEY (picking_id)
      REFERENCES stock_picking (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_pack_operation_product_id_fkey FOREIGN KEY (product_id)
      REFERENCES product_product (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT stock_pack_operation_product_uom_id_fkey FOREIGN KEY (product_uom_id)
      REFERENCES product_uom (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT stock_pack_operation_result_package_id_fkey FOREIGN KEY (result_package_id)
      REFERENCES stock_quant_package (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT stock_pack_operation_write_uid_fkey FOREIGN KEY (write_uid)
      REFERENCES res_users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL
)
WITH (
  OIDS=FALSE
);
ALTER TABLE stock_pack_operation
  OWNER TO odoo;
  
with t as 
(select a.id , a.lot_id , a.picking_id , b.restrict_lot_id
from stock_pack_operation a
join stock_move b
on a.picking_id = b.picking_id where b.restrict_lot_id is null and a.lot_id is not null)
select t.picking_id , count(distinct t.lot_id)  from t group by t.picking_id having count(distinct t.lot_id) > 100 ;

-- select * from stock_picking where id = 193 ;

-- select sum(product_uom_qty) from stock_move where picking_id = 193 ;

select * from stock_pack_operation where picking_id = 193 ;


--

 SELECT a.id,
    a.location_id,
    a.product_id,
    a.description,
    a.date,
    a.picking_id,
    a.company_id,
    b.lot_id AS prodlot_id,
        CASE
            WHEN a.name < 0::numeric THEN (-1)
            ELSE 1
        END AS stock_qty
   FROM stock_move_by_location a
     JOIN stock_pack_operation b ON a.picking_id = b.picking_id AND a.product_id = b.product_id AND b.location_dest_id = a.location_id
  WHERE a.prodlot_id IS NULL
UNION
 SELECT a.id,
    a.location_id,
    a.product_id,
    a.description,
    a.date,
    a.picking_id,
    a.company_id,
    b.lot_id AS prodlot_id,
        CASE
            WHEN a.name < 0::numeric THEN (-1)
            ELSE 1
        END AS stock_qty
   FROM stock_move_by_location a
     JOIN stock_pack_operation b ON a.picking_id = b.picking_id AND a.product_id = b.product_id AND b.location_id = a.location_id
  WHERE a.prodlot_id IS NULL;
UNION
 SELECT a.id,
    a.location_id,
    a.product_id,
    a.description,
    a.date,
    a.picking_id,
    a.company_id,
    b.lot_id AS prodlot_id,
	a.name as stock_qty
   FROM stock_move_by_location a
  WHERE a.prodlot_id IS not NULL;
