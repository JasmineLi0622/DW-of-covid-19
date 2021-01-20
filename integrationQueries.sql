-- Student Name: Jiawen Li
-- Student Number : K20056947
-- Write your commands and/or comments below

-- Question1
-- find out which day the first case in china appears: 31/12/2019
select date from Itimed where 
dateId = (select dateId from IcovidDataf where countryid in (select countryid from Icountryd where country_territory_area='China') and cusum_cases>0 order by dateId limit 1);
-- answer question 1
-- there are some countries' cusum cases are null for some specific date, here if the corona dataset contain that country, we set the cusum cases to be 0, if do not contain that country,
-- we leave cusum cases as null
select j.countryid, country_territory_area, iso, date, days_after_first_case, who_category, who_measure, targeted, If (isnull(cusum_cases) and j.countryid in (select distinct countryid from IcovidDataf),0,cusum_cases) as cusum_cases,cusum_cases_CN from
(select countryid, country_territory_area, iso, h.dateId, date, days_after_first_case, who_category, who_measure, targeted, cusum_cases_CN  from 
(select a.countryid, country_territory_area, iso, a.start_date_id as dateId, date, TIMESTAMPDIFF(DAY,STR_TO_DATE('31/12/2019','%d/%m/%Y'),STR_TO_DATE(date,'%d/%m/%Y')) as days_after_first_case, 
who_category, who_measure, targeted from 
(select * from Iconductf where (countryid,start_date_id) in (select countryid, min(start_date_id) from Iconductf where start_date_id !=1 group by countryid)) as a,
Imeasured b, Icountryd c, Itimed d, IphsmDetaild e
where a.lineid=e.lineid and a.countryid=c.countryid and a.who_code= b.who_code and a.start_date_id=d.dateid) as h 
left join (select cusum_cases as cusum_cases_CN, dateId from IcovidDataf where countryid in (select countryid from Icountryd where country_territory_area='China')) as i 
on h.dateId=i.dateId) as j
left join IcovidDataf k
on j.countryid=k.countryid and j.dateId=k.dateId
order by days_after_first_case, countryid;

-- question 2
select x.year, x.month, who_category, who_measure, count, month_case_in_CN, case_change_CN, case_change_rate_CN, month_case_in_other, 
case_change_other,case_change_rate_other from

(select year, month, who_category, who_measure, count(who_measure) as count from Iconductf a, Itimed b, Imeasured c 
where a.start_date_id=b.dateid and countryid in (select countryid from Icountryd where country_territory_area='China') and a.who_code=c.who_code
group by year, month, who_category,who_measure
order by year, month, count desc) as x,

(select f.year, f.month, f.month_case_in_CN, 
if (isnull(g.month_case_in_CN), f.month_case_in_CN, (f.month_case_in_CN-g.month_case_in_CN)) as case_change_CN,
if (isnull(g.month_case_in_CN), null, (f.month_case_in_CN-g.month_case_in_CN)/g.month_case_in_CN) as case_change_rate_CN from 
(select year, month, sum(cases) as month_case_in_CN from 
IcovidDataf d, Itimed e 
where countryid in (select countryid from Icountryd where country_territory_area='China') and d.dateId=e.dateId
group by year, month) as f
left join
(select year, month, sum(cases) as month_case_in_CN from 
IcovidDataf d, Itimed e 
where countryid in (select countryid from Icountryd where country_territory_area='China') and d.dateId=e.dateId
group by year, month) as g
on f.month=g.month-11 or f.month=g.month+1
) as y,

(select j.year, j.month, j.month_case_in_other, 
if (isnull(k.month_case_in_other), j.month_case_in_other, (j.month_case_in_other-k.month_case_in_other)) as case_change_other,
if (isnull(k.month_case_in_other), null, (j.month_case_in_other-k.month_case_in_other)/k.month_case_in_other) as case_change_rate_other from 
(select year, month, sum(cases) as month_case_in_other from 
IcovidDataf h, Itimed i 
where countryid in (select countryid from Icountryd where country_territory_area!='China') and h.dateId=i.dateId and duplicated=0
group by year, month) as j
left join
(select year, month, sum(cases) as month_case_in_other from 
IcovidDataf h, Itimed i 
where countryid in (select countryid from Icountryd where country_territory_area!='China') and h.dateId=i.dateId and duplicated=0
group by year, month) as k
on j.month=k.month-11 or j.month=k.month+1) as z

where x.year=y.year and x.year=z.year and x.month=y.month and x.month=z.month
order by year, month, count desc;


