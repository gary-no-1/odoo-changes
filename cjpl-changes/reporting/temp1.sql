DROP VIEW view_cjpl_partner_is_not_company;
DROP VIEW view_cjpl_partner_is_not_company_but_has_parent;
DROP VIEW view_cjpl_partner_is_not_company_with_no_parent;

DROP VIEW view_cjpl_partner_is_a_company;

CREATE OR REPLACE VIEW view_cjpl_partner_is_a_company AS 
 SELECT a.id,
    a.name AS company_partner_name,
    a.name AS company_name,
    a.x_core_code, 
    b.name as company_state,
    a.parent_id,
    a.is_company
   FROM res_partner a 
   left join res_country_state b on a.state_id = b.id
  WHERE a.is_company;

ALTER TABLE view_cjpl_partner_is_a_company
  OWNER TO odoo;
GRANT ALL ON TABLE view_cjpl_partner_is_a_company TO odoo;
GRANT SELECT ON TABLE view_cjpl_partner_is_a_company TO joomla;


-- View: view_cjpl_partner_is_not_company_but_has_parent


CREATE OR REPLACE VIEW view_cjpl_partner_is_not_company_but_has_parent AS 
 SELECT a.id,
    a.name AS company_partner_name,
    b.company_name,
    b.x_core_code, 
    b.company_state,
    a.parent_id,
    a.is_company
   FROM res_partner a
     LEFT JOIN view_cjpl_partner_is_a_company b ON a.parent_id = b.id
  WHERE NOT a.is_company AND a.parent_id IS NOT NULL;

ALTER TABLE view_cjpl_partner_is_not_company_but_has_parent
  OWNER TO odoo;
GRANT ALL ON TABLE view_cjpl_partner_is_not_company_but_has_parent TO odoo;
GRANT SELECT ON TABLE view_cjpl_partner_is_not_company_but_has_parent TO joomla;

-- View: view_cjpl_partner_is_not_company_with_no_parent


CREATE OR REPLACE VIEW view_cjpl_partner_is_not_company_with_no_parent AS 
 SELECT a.id,
    a.name AS company_partner_name,
    a.name as company_name,
    a.x_core_code, 
    b.name as company_state,
    a.parent_id,
    a.is_company
   FROM res_partner a
   left join res_country_state b on a.state_id = b.id
  WHERE NOT a.is_company AND a.parent_id IS NULL;

ALTER TABLE view_cjpl_partner_is_not_company_with_no_parent
  OWNER TO odoo;
GRANT ALL ON TABLE view_cjpl_partner_is_not_company_with_no_parent TO odoo;
GRANT SELECT ON TABLE view_cjpl_partner_is_not_company_with_no_parent TO joomla;
  
  
 CREATE OR REPLACE VIEW view_cjpl_partner_all_companies AS 
 SELECT a.id,
    a.company_partner_name,
    a.company_name,
	a.x_core_code,
	a.company_state,
    a.parent_id,
    a.is_company
   FROM view_cjpl_partner_is_a_company a
UNION
 SELECT b.id,
    b.company_partner_name,
    b.company_name,
	b.x_core_code,
	b.company_state,
    b.parent_id,
    b.is_company
   FROM view_cjpl_partner_is_not_company_but_has_parent b
UNION
 SELECT c.id,
    c.company_partner_name,
    c.company_name,
	c.x_core_code,
	c.company_state,
    c.parent_id,
    c.is_company
   FROM view_cjpl_partner_is_not_company_with_no_parent c ;
   

ALTER TABLE view_cjpl_partner_all_companies
  OWNER TO postgres;
GRANT ALL ON TABLE view_cjpl_partner_all_companies TO postgres;
GRANT SELECT ON TABLE view_cjpl_partner_all_companies TO joomla;

