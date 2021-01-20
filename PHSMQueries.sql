-- Student Name: Jiawen Li
-- Student Number : k20056947
-- Write your commands and/or comments below
-- Question 1:
select a.who_region, who_category, who_measure, implement_country_number, implement_country_number/total_country_number as cover_percentage, ranking, total_record_number from 
((select who_region, who_category, who_measure, count(distinct country_territory_area) as implement_country_number, 
rank() over (partition by who_region order by count(distinct country_territory_area) desc) as ranking, count(lineid) as total_record_number from 
conductf c, countryTd co, measured m where c.CTcode=co.CTcode and c.who_code=m.who_code 
group by who_region, who_category, who_measure) as a
left join (select who_region, count(distinct country_territory_area) as total_country_number from countryTd group by who_region) as b
on a.who_region=b.who_region)
where ranking <11
order by who_region, cover_percentage desc, who_measure;


-- Question 2:
select * from 
(select country_territory_area, s_year, s_month, s_week, who_category, count(lineid) as count from 
conductf c, countryTd co, date_startd d, measured m where c.CTcode=co.CTcode and c.start_time_id=d.s_date_id and c.who_code=m.who_code
group by country_territory_area, s_year, s_month, s_week, who_category with rollup) as c
where not isnull(country_territory_area) and not isnull(s_year) and not isnull(s_month)
order by country_territory_area, s_year, s_month, s_week, count desc, who_category;