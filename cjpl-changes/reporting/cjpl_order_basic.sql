CREATE OR REPLACE VIEW public.cjpl_order_basic (
    salesperson,
    team_name,
    id,
    origin,
    opportunity_id,
    create_date,
    client_order_ref,
    so_number,
    order_date,
    so_state,
    project_id,
    contract_status,
    amount_tax,
    amount_untaxed,
    amount_total,
    payment_term,
    note,
    date_confirm,
    order_policy,
    picking_policy,
    shipped,
    x_coordinator_approve,
    x_road_permit,
    margin,
    rental_start_date,
    rental_end_date,
    x_minimum_contract_period,
    x_recur_inv,
    order_type,
    partner_id,
    order_party_name,
    street,
    city,
    display_name)
AS
 SELECT cjpl_user_name.name AS salesperson,
    crm_case_section.name AS team_name,
    sale_order.id,
    sale_order.origin,
    "substring"(sale_order.origin::text, "position"(sale_order.origin::text, ':'::text) + 1)::integer AS opportunity_id,
    date(sale_order.create_date) AS create_date,
    sale_order.client_order_ref,
    sale_order.name AS so_number,
    date(sale_order.date_order) AS order_date,
    sale_order.state AS so_state,
    sale_order.project_id,
        CASE
            WHEN sale_order.project_id IS NULL THEN 'No Contract'::text
            ELSE 'Contract'::text
        END AS contract_status,
    sale_order.amount_tax,
    sale_order.amount_untaxed,
    sale_order.amount_total,
    sale_order.payment_term,
    sale_order.note,
    sale_order.date_confirm,
    sale_order.order_policy,
    sale_order.picking_policy,
    sale_order.shipped,
    sale_order.x_coordinator_approve,
    sale_order.x_road_permit,
    sale_order.margin,
    date(sale_order.x_rental_start_date) AS rental_start_date,
    date(sale_order.x_rental_end_date) AS rental_end_date,
    sale_order.x_minimum_contract_period,
    sale_order.x_recur_inv,
    sale_order_type.name AS order_type,
    sale_order.partner_id,
    res_partner.name AS order_party_name,
    res_partner.street,
    res_partner.city,
    res_partner.display_name
   FROM sale_order
     JOIN sale_order_type ON sale_order.type_id = sale_order_type.id
     JOIN res_partner ON sale_order.partner_id = res_partner.id
     JOIN cjpl_user_name ON sale_order.user_id = cjpl_user_name.id
     JOIN crm_case_section ON sale_order.section_id = crm_case_section.id
  ORDER BY cjpl_user_name.name, sale_order.date_order, sale_order.name;