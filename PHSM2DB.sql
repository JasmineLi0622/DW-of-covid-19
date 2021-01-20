-- Student Name: Jiawen Li
-- Student Number : k20056947
-- Write your commands and/or comments below

-- find some duplicate data in the PHSM,in lineid (14263,14267,20580,20581,20582) all the attributes except lineid are the same as that of another record,so here i drop those lines
-- since they may influence the results such as counts.
/*
create table duplicates as select count(distinct lineid) as c, who_id, who_region,country_territory_area, iso, iso_3166_1_numeric,admin_level,area_coverd,who_code,who_category,who_subcategory,who_measure,comments,date_start,measure_stage,prev_measure_number,following_measure_number,date_end,reason_ended,targeted,enforcement,non_compliance_penalty from PHSM group by who_id, who_region,country_territory_area, iso, iso_3166_1_numeric,admin_level,area_covered,who_code,wh_category,who_subcategory,who_measure,comments,date_start,measure_stage,prev_measure_number,following_measure_number,date_end,reason_ended,targeted,enforcementnon_compliance_penalty having c>1;
select lineid from PHSM where who_id in (select who_id from duplicates);
drop table duplicates;
*/
delete from PHSM where lineid in (14263,14267,20580,20581,20582);

-- PK of 1NF is lineID, so there is no PD, and 2NF is the same as 1NF
-- 3NF
/*
assumptions: 
1. who_id can related to more than 1 (who_region,country_territory_area,iso_3166_1_numeric) in the future 
2. (who_id, who_code) can related to more than 1 (admin_level,area_covered) in the future
*/
create table isoCode as select distinct iso_3166_1_numeric, iso from PHSM;
alter table isoCode add primary key(iso_3166_1_numeric);

create table countryT(CTcode int not null auto_increment,
who_region text, country_territory_area text,iso_3166_1_numeric int, primary key (CTcode));
insert into countryT(who_region, country_territory_area, iso_3166_1_numeric) select distinct who_region, country_territory_area, iso_3166_1_numeric from PHSM;
alter table countryT add foreign key(iso_3166_1_numeric) references isoCode (iso_3166_1_numeric);

create table measure as select distinct who_code, who_category, who_subcategory, who_measure from PHSM;
alter table measure modify who_code varchar(10);
alter table measure add primary key(who_code);

create table phsmDetail as select distinct lineID, who_id, CTcode, admin_level, area_covered, who_code, comments, date_start, measure_stage, prev_measure_number, 
following_measure_number, date_end, reason_ended, targeted, enforcement, non_compliance_penalty 
from PHSM p left join countryT c on p.who_region=c.who_region and p.country_territory_area=c.country_territory_area and p.iso_3166_1_numeric=c.iso_3166_1_numeric;
alter table phsmDetail add primary key(lineID);
alter table phsmDetail modify who_code varchar(10);
alter table phsmDetail add foreign key(who_code) references measure (who_code);
alter table phsmDetail add foreign key(CTcode) references countryT (CTcode);