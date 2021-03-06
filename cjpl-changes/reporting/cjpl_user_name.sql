CREATE OR REPLACE VIEW public.cjpl_user_name (
    id,
    partner_id,
    active,
    login,
    name,
    login_date,
    x_designation)
AS
 SELECT res_users.id,
    res_users.partner_id,
    res_users.active,
    res_users.login,
    res_partner.name,
    res_users.login_date,
    res_users.x_designation
   FROM res_users
     JOIN res_partner ON res_users.partner_id = res_partner.id;