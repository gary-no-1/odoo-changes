WITH y
AS (
	WITH x AS (
			SELECT id,
				NAME,
				split_part(NAME::TEXT, '-'::TEXT, 1) AS make,
				split_part(NAME::TEXT, '-'::TEXT, 2) AS model,
				split_part(NAME::TEXT, '-'::TEXT, 3) AS hdd,
				split_part(NAME::TEXT, '-'::TEXT, 4) AS grade,
				upper(split_part(NAME::TEXT, '-'::TEXT, 6)) AS color,
				list_price
			FROM product_template
			WHERE active = true
			)
	SELECT make,
		model,
		hdd,
		CASE WHEN x.grade = 'NO'::TEXT THEN x.list_price ELSE 0::NUMERIC END AS no_list_price,
		CASE WHEN x.grade = 'NS'::TEXT THEN x.list_price ELSE 0::NUMERIC END AS ns_list_price,
		CASE WHEN x.grade = 'NR'::TEXT THEN x.list_price ELSE 0::NUMERIC END AS nr_list_price,
		CASE WHEN x.grade = 'NE'::TEXT THEN x.list_price ELSE 0::NUMERIC END AS ne_list_price,
		CASE WHEN x.grade = 'NW'::TEXT THEN x.list_price ELSE 0::NUMERIC END AS nw_list_price,
		CASE WHEN x.grade = 'NB'::TEXT THEN x.list_price ELSE 0::NUMERIC END AS nb_list_price,
		CASE WHEN x.grade = 'NM'::TEXT THEN x.list_price ELSE 0::NUMERIC END AS nm_list_price
	FROM x
	)
SELECT make,
	model,
	hdd,
	max(no_list_price) AS no_list_price,
	max(ns_list_price) AS ns_list_price,
	max(nr_list_price) AS nr_list_price,
	max(ne_list_price) AS ne_list_price,
	max(nw_list_price) AS nw_list_price,
	max(nb_list_price) AS nb_list_price,
	max(nm_list_price) AS nm_list_price
FROM y
GROUP BY make,
	model,
	hdd;

	
	
	
with y as (	
WITH x
AS (
	SELECT id,
		NAME,
		split_part(NAME::TEXT, '-'::TEXT, 1) AS make,
		split_part(NAME::TEXT, '-'::TEXT, 2) AS model,
		split_part(NAME::TEXT, '-'::TEXT, 3) AS hdd,
		split_part(NAME::TEXT, '-'::TEXT, 4) AS grade,
		upper(split_part(NAME::TEXT, '-'::TEXT, 6)) AS color,
		list_price
	FROM product_template
	WHERE active = true
	)
SELECT DISTINCT make,
	model,
	hdd,
	grade
FROM x )
select make , model , hdd , string_agg(grade,',') as all_grades 
from y group by make , model , hdd




	
	WITH x AS (
			SELECT id,
				NAME,
				split_part(NAME::TEXT, '-'::TEXT, 1) AS make,
				split_part(NAME::TEXT, '-'::TEXT, 2) AS model,
				split_part(NAME::TEXT, '-'::TEXT, 3) AS hdd,
				split_part(NAME::TEXT, '-'::TEXT, 4) AS grade,
				upper(split_part(NAME::TEXT, '-'::TEXT, 6)) AS color,
				list_price
			FROM product_template
			WHERE active = true
			)
select make , model , hdd , distinct grade from x
			
select make , model , hdd , string_agg(grade,',') as all_grades , string_agg(color,',') as all_colors
from x group by make , model , hdd
	
	
	
	WITH x AS (
			SELECT id,
				NAME,
				split_part(NAME::TEXT, '-'::TEXT, 1) AS make,
				split_part(NAME::TEXT, '-'::TEXT, 2) AS model,
				split_part(NAME::TEXT, '-'::TEXT, 3) AS hdd,
				split_part(NAME::TEXT, '-'::TEXT, 4) AS grade,
				upper(split_part(NAME::TEXT, '-'::TEXT, 6)) AS color,
				list_price
			FROM product_template
			WHERE active = true
			)
select make , model , hdd , string_agg(format('%s, %s', grade, color), E'\n') as color_grade
from x group by make , model , hdd