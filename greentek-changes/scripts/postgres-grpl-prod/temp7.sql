-- View: view_cjpl_partner_all_companies

-- DROP VIEW view_cjpl_partner_all_companies;

CREATE OR REPLACE VIEW view_cjpl_partner_all_companies AS 
 SELECT a.id,
    a.company_partner_name,
    a.company_name,
    a.x_core_code,
    a.company_state,
    a.parent_id,
    a.is_company
   FROM view_cjpl_xxx_partner_is_a_company a
UNION
 SELECT b.id,
    b.company_partner_name,
    b.company_name,
    b.x_core_code,
    b.company_state,
    b.parent_id,
    b.is_company
   FROM view_cjpl_xxx_partner_is_not_company_but_has_parent b
UNION
 SELECT c.id,
    c.company_partner_name,
    c.company_name,
    c.x_core_code,
    c.company_state,
    c.parent_id,
    c.is_company
   FROM view_cjpl_xxx_partner_is_not_company_with_no_parent c;

ALTER TABLE view_cjpl_partner_all_companies
  OWNER TO postgres;
GRANT ALL ON TABLE view_cjpl_partner_all_companies TO postgres;
GRANT SELECT ON TABLE view_cjpl_partner_all_companies TO joomla;


with x as 
 (SELECT a.id,
    a.name AS company_partner_name,
    a.name AS company_name,
    b.name AS company_state,
    a.parent_id,
    a.is_company
   FROM res_partner a
     LEFT JOIN res_country_state b ON a.state_id = b.id
  WHERE a.is_company),
  y as (
  SELECT a.id,
    a.name AS company_partner_name,
    x.company_name,
    x.company_state,
    a.parent_id,
    a.is_company
   FROM res_partner a
     LEFT JOIN x ON a.parent_id = x.id
  WHERE NOT a.is_company AND a.parent_id IS NOT NULL),
  z as (
  SELECT a.id,
    a.name AS company_partner_name,
    c.name AS company_name,
    a.x_core_code,
    a.parent_id,
    a.is_company
   FROM res_partner a
     LEFT JOIN res_partner c ON a.parent_id = c.id
  WHERE NOT a.is_company AND a.parent_id IS NOT NULL AND NOT (a.parent_id IN ( SELECT id
           FROM x ))
SELECT x.id,
    x.company_partner_name,
    x.company_name,
    x.company_state,
   FROM x
 SELECT y.id,
    y.company_partner_name,
    y.company_name,
    b.company_state,
   FROM y 
UNION
 SELECT z.id,
    z.company_partner_name,
    z.company_name,
    c.company_state,
   FROM z ;

  
  
  
  with x as 
 (SELECT a.id,
    a.name AS company_partner_name,
    a.name AS company_name,
    b.name AS company_state,
    a.parent_id,
    a.is_company
   FROM res_partner a
     LEFT JOIN res_country_state b ON a.state_id = b.id
  WHERE a.is_company),
  y as (
  SELECT a.id,
    a.name AS company_partner_name,
    x.company_name,
    x.company_state,
    a.parent_id,
    a.is_company
   FROM res_partner a
     LEFT JOIN x ON a.parent_id = x.id
  WHERE NOT a.is_company AND a.parent_id IS NOT NULL),
  z as (
 SELECT a.id,
    a.name AS company_partner_name,
    a.name AS company_name,
    b.name AS company_state,
    a.parent_id,
    a.is_company
   FROM res_partner a
     LEFT JOIN res_country_state b ON a.state_id = b.id
  WHERE NOT a.is_company AND a.parent_id IS NULL)
SELECT x.id,
    x.company_partner_name,
    x.company_name,
    x.company_state
   FROM x
UNION   
 SELECT y.id,
    y.company_partner_name,
    y.company_name,
    y.company_state
   FROM y 
UNION
 SELECT z.id,
    z.company_partner_name,
    z.company_name,
    z.company_state
   FROM z ;
