CREATE OR REPLACE FUNCTION so_contract_transfer3()
  RETURNS trigger AS
     'BEGIN 
	    INSERT INTO account_analytic_invoice_line (name, price_unit,uom_id,product_id, quantity, analytic_account_id)  
		SELECT sale_order_line.name, sale_order_line.price_unit, sale_order_line.product_uom, sale_order_line.product_id, sale_order_line.product_uom_qty, account_analytic_account.id    
		FROM public.sale_order_line, public.account_analytic_account, public.sale_order   
		WHERE  sale_order_line.order_id = sale_order.id AND 
		sale_order.name = account_analytic_account.name AND 
		NEW.name=NEW.x_saleorder_number AND
		not exists (select * from account_analytic_invoice_line where analytic_account_id = account_analytic_account.id  );
		RETURN NULL;
      END;'
	  
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION so_contract_transfer3()
  OWNER TO postgres;
  
-- ------------------------------------------------------------------------------------------------------  
-- Function: upd_contract_from_sale_order()

-- DROP FUNCTION upd_contract_from_sale_order();

CREATE OR REPLACE FUNCTION upd_contract_from_sale_order()
  RETURNS trigger AS
$BODY$
DECLARE 
   this_po_ref varchar;
   this_id integer;
BEGIN
  
    IF (NEW.state = 'manual') THEN
       IF (NEW.project_id is not NULL) THEN
           this_id = NEW.project_id;
           this_po_ref = NEW.client_order_ref;
           
           UPDATE account_analytic_account 
           SET x_po_ref = this_po_ref
           WHERE id = this_id;
           
       END IF;
    END IF;

    RETURN NEW;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION upd_contract_from_sale_order()
  OWNER TO odoo;

-- ------------------------------------------------------------------------------------------------------  

-- Trigger: trig_sale_order_au on sale_order

-- DROP TRIGGER trig_sale_order_au ON sale_order;

CREATE TRIGGER trig_sale_order_au
  AFTER UPDATE
  ON sale_order
  FOR EACH ROW
  EXECUTE PROCEDURE upd_contract_from_sale_order();

-- ------------------------------------------------------------------------------------------------------  
-- Function: upd_account_invoice_from_so_contract()

-- DROP FUNCTION upd_account_invoice_from_so_contract();

CREATE OR REPLACE FUNCTION upd_account_invoice_from_so_contract()
  RETURNS trigger AS
$BODY$
DECLARE 
   this_id integer;
   this_project_id integer;
   this_invoice_id integer;
   this_order_id integer;
   this_origin varchar;
   contract_info record;
   so_info record;
   exist_so boolean;
BEGIN
-- this is invoice made from contract
   IF NEW.contract_id IS NOT NULL THEN
       this_id = NEW.contract_id ;
        
       select id, x_po_ref , manager_id , x_kind_attn , x_last_inv_to
       from account_analytic_account into contract_info
       where id = this_id;
   
       this_project_id = contract_info.id;
   
       select section_id
       from sale_order into so_info
       where project_id = this_project_id LIMIT 1;

       NEW.user_id := contract_info.manager_id;
       NEW.x_po_ref := contract_info.x_po_ref;
       NEW.x_kind_attn := contract_info.x_kind_attn;
       NEW.section_id := so_info.section_id;
       IF contract_info.x_last_inv_to IS NOT NULL THEN
          NEW.x_bill_period_from := (contract_info.x_last_inv_to + 1)::timestamp;
          NEW.x_bill_period_to := (contract_info.x_last_inv_to + 31)::timestamp;
       END IF;
   
       RETURN NEW ;
   END IF ;

-- this is invoice made from order

--    this_invoice_id = NEW.id;
--    select exists (select true from sale_order_invoice_rel  where invoice_id = this_invoice_id) into exist_so;

-- sale_order_invoice_rel is not getting written at this stage , hence use sale order # passed into invoice.origin to get sale order 
    this_origin = NEW.origin;
    select exists (select true from sale_order  where name = this_origin) into exist_so;

    IF exist_so THEN
--        select order_id  from sale_order_invoice_rel  where invoice_id = this_invoice_id into this_order_id;
       select id  from sale_order  where name  = this_origin  into this_order_id;
       select client_order_ref, user_id, section_id
       from sale_order into so_info
       where id = this_order_id	;

--        NEW.user_id := so_info.user_id;
       NEW.x_po_ref := so_info.client_order_ref;
--       NEW.section_id := so_info.section_id;

       RETURN NEW ;
    END IF;

    RETURN NEW;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION upd_account_invoice_from_so_contract()
  OWNER TO odoo;

-- ------------------------------------------------------------------------------------------------------  

-- Trigger: trig_account_invoice_bi on account_invoice

-- DROP TRIGGER trig_account_invoice_bi ON account_invoice;

CREATE TRIGGER trig_account_invoice_bi
  BEFORE INSERT
  ON account_invoice
  FOR EACH ROW
  EXECUTE PROCEDURE upd_account_invoice_from_so_contract();

-- ------------------------------------------------------------------------------------------------------  
-- Function: upd_account_analytic_account_from_invoice()

-- DROP FUNCTION upd_account_analytic_account_from_invoice();

CREATE OR REPLACE FUNCTION upd_account_analytic_account_from_invoice()
  RETURNS trigger AS
$BODY$
DECLARE 
   this_id integer;
   this_bill_from date;
   this_bill_to date;
BEGIN
-- this is invoice made from contract , invoice # must exist and bill_period_from is reqd {specifies NON-sale invoice}
   IF NEW.contract_id IS NOT NULL THEN
       IF NEW.number IS NOT NULL THEN
          IF NEW.x_bill_period_from IS NOT NULL THEN   
                 this_id = NEW.contract_id ;
                 this_bill_from = NEW.x_bill_period_from;
                 this_bill_to = NEW.x_bill_period_to;

                 UPDATE account_analytic_account 
                 SET x_bill_period_from = this_bill_from,
                 x_bill_period_to = this_bill_to
                 WHERE id = this_id;

          END IF;
       END IF;
   END IF;
   RETURN NEW;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION upd_account_analytic_account_from_invoice()
  OWNER TO odoo;

-- ------------------------------------------------------------------------------------------------------  

CREATE TRIGGER trig_account_invoice_au
  AFTER UPDATE OF number
  ON account_invoice
  FOR EACH ROW
  EXECUTE PROCEDURE upd_account_analytic_account_from_invoice();
