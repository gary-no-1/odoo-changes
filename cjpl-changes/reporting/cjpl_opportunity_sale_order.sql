CREATE OR REPLACE VIEW public.cjpl_opportunity_sale_order (
    salesperson,
    opportunity_id,
    order_opportunity_id,
    create_date,
    contact_name,
    partner_name,
    team_name,
    name,
    stage,
    planned_revenue,
    client_order_ref,
    so_number,
    order_date,
    so_state,
    contract_status,
    amount_tax,
    amount_untaxed,
    amount_total,
    date_confirm,
    rental_start_date,
    rental_end_date,
    order_type,
    order_party_name)
AS
 SELECT cjpl_opportunity.salesperson,
    cjpl_opportunity.opportunity_id,
    cjpl_order_basic.opportunity_id AS order_opportunity_id,
    cjpl_opportunity.create_date,
    cjpl_opportunity.contact_name,
    cjpl_opportunity.partner_name,
    cjpl_opportunity.team_name,
    cjpl_opportunity.name,
    cjpl_opportunity.stage,
    cjpl_opportunity.planned_revenue,
    cjpl_order_basic.client_order_ref,
    cjpl_order_basic.so_number,
    cjpl_order_basic.order_date,
    cjpl_order_basic.so_state,
    cjpl_order_basic.contract_status,
    cjpl_order_basic.amount_tax,
    cjpl_order_basic.amount_untaxed,
    cjpl_order_basic.amount_total,
    cjpl_order_basic.date_confirm,
    cjpl_order_basic.rental_start_date,
    cjpl_order_basic.rental_end_date,
    cjpl_order_basic.order_type,
    cjpl_order_basic.order_party_name
   FROM cjpl_opportunity
     LEFT JOIN cjpl_order_basic ON cjpl_opportunity.opportunity_id = cjpl_order_basic.opportunity_id
  ORDER BY cjpl_opportunity.salesperson, cjpl_opportunity.create_date;