-- Student Name: Jiawen Li
-- Student Number : K20056947
-- Write your commands and/or comments below
-- take the full join of the date info and country info of the two data mart.
-- combine Dated and date_startd, take the full join them
create table Itimed(dateId int not null auto_increment, date text, year int, month int, week int, day int,
primary key (dateId));
insert into Itimed (date, year, month, week, day) select distinct * from(
(select dateRep as date, year, month, week, day from Dated) 
union 
(select s_date_text, s_year, s_month,s_week, s_day from date_startd)) as time
order by year, month, day;

-- combine countryd and countryTd
/* 
In countryd, countryterritoryCode which is iso in countryTd uniquely define the country
In countryTd, iso='IND','ISR','SDN' refer to more than one country_territory area and who_region,will insert them manually
So, here firstly combine all unique isos in the two tables except 'IND','ISR','SDN', left join countryd & contryTd on iso respectively 
if the country exit in countryTd use the country name in the countryTd else use the name in countryd
Then manually insert the records where iso='IND','ISR','SDN' by left join countryTd and countryd on iso and country name
*/
create table Icountryd(countryid int not null auto_increment, country_territory_area text, geoId varchar(255), iso_3166_1_numeric int, iso varchar(255), 
popData2019 int , continentExp varchar(255), who_region text,
primary key(countryid));

insert into Icountryd (country_territory_area, geoId, iso_3166_1_numeric, iso, popData2019, continentExp, who_region)
select distinct if(isnull(country_territory_area),countriesAndterritories, country_territory_area),
geoId, iso_3166_1_numeric, e.iso, popData2019, continentExp, who_region from
(select * from(
(select distinct iso from (select iso from countryTd union select countryterritoryCode from countryd)as a where iso not in ('IND','ISR','SDN') order by iso) as b 
left join countryd as c on b.iso=c.countryterritoryCode)
) as e
left join
(select * from countryTd) as f
on e.iso=f.iso;
-- manually insert records of iso='IND','ISR','SDN', assume when countryname and iso are the same, their population, continentExp are the same
insert into Icountryd (country_territory_area, geoId, iso_3166_1_numeric, iso, popData2019, continentExp, who_region)
select distinct country_territory_area, geoId, iso_3166_1_numeric, iso, popData2019, continentExp, who_region from
(select * from countryTd where iso in ('IND','ISR','SDN')) as a
left join 
(select * from countryd) as b
on a.country_territory_area=b.countriesAndterritories and a.iso=b.countryterritoryCode;


create table Imeasured as select distinct * from measured;
alter table Imeasured add primary key (who_code);

create table IphsmDetaild as select distinct * from phsmDetaild;
alter table IphsmDetaild add primary key (lineid);


-- fact table 1
create table IcovidDataf (countryid int not null, dateId int not null, cases int, cusum_cases int, deaths int, cusum_deaths int,
foreign key(countryid) references Icountryd(countryid),
foreign key(dateId) references Itimed(dateId));
insert into IcovidDataf(countryid, dateId, cases, cusum_cases, deaths, cusum_deaths)
select countryid, dateId, cases, cusum_cases, deaths, cusum_deaths from 
(select countryid, cases, cusum_cases, deaths, cusum_deaths, dateRep from
(select geoId, cases, cusum_cases, deaths, cusum_deaths, dateRep from covidDataf a left join Dated b on a.dateId=b.dateId) as c
left join Icountryd d on c.geoId=d.geoId) as e
left join Itimed f
on e.dateRep=f.date
order by countryid, dateId;
-- may have some duplicate data about cases and deaths for some country('Israel','Sudan') with iso ('ISR','SDN') since there are more than 1 id for them, so here add a column to show the duplicates, 
-- so that researches can easily excude them when needed;
alter table IcovidDataf add duplicated int default 0;
update IcovidDataf set duplicated= 1 where countryid in (
select countryid from (
select * , rank() over (partition by iso order by countryid) ranking from Icountryd where country_territory_area in ('Israel','Sudan') and iso in ('ISR','SDN')) as a
where ranking >1);

-- since duplicated is a column used as condition in fact table, so we create a dimension table for it and set it as a pk and Fk; 
create table Iduplicated (duplicated int,
primary key (duplicated));
insert into Iduplicated values (0),(1);
alter table IcovidDataf add primary key (countryid, dateId,duplicated);
alter table IcovidDataf add foreign key (duplicated) references Iduplicated(duplicated);


-- fact table 2
create table Iconductf (lineid int not null, countryid int not null, who_code varchar(10) not null, start_date_id int not null, duration bigint,
primary key(lineid, countryid, who_code, start_date_id),
foreign key(lineid) references IphsmDetaild(lineid),
foreign key(countryid) references Icountryd(countryid),
foreign key(who_code) references Imeasured(who_code),
foreign key(start_date_id) references Itimed(dateId));

insert into Iconductf (lineid, countryid, who_code, start_date_id, duration)
select distinct lineid, countryid, who_code, dateId, duration from
(select lineid, who_code, duration, s_date_text, who_region, country_territory_area, iso_3166_1_numeric from 
conductf a, date_startd b, countryTd c 
where a.CTcode=c.CTcode and a.start_time_id=b.s_date_id) as d, Itimed e, Icountryd f
where d.s_date_text=e.date and d.who_region= f.who_region and d.country_territory_area=f.country_territory_area and d.iso_3166_1_numeric=f.iso_3166_1_numeric
order by lineid;
