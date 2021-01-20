-- Student Name: Jiawen Li
-- Student Number : k20056947
-- Write your commands and/or comments below
create table countryTd(
CTcode int not null, who_region text, country_territory_area text, iso_3166_1_numeric int, iso text,
primary key (CTcode)
);
insert into countryTd (CTcode, who_region, country_territory_area, iso_3166_1_numeric, iso) 
select distinct CTcode, who_region, country_territory_area, c.iso_3166_1_numeric, iso 
from countryT c left join isoCode i on c.iso_3166_1_numeric=i.iso_3166_1_numeric;

create table measured as select * from measure;
alter table measured add primary key(who_code);

create table date_startd(
s_date_id int not null auto_increment, s_date_text text, s_date date default null, s_year int default null, s_month int default null, 
s_week int default null, s_day int default null,
primary key (s_date_id));
insert into date_startd(s_date_text, s_date, s_year,s_month,s_week, s_day) 
select distinct date_start, STR_TO_DATE(date_start,'%d/%m/%Y'), year(STR_TO_DATE(date_start,'%d/%m/%Y')),
month(STR_TO_DATE(date_start,'%d/%m/%Y')), week(STR_TO_DATE(date_start,'%d/%m/%Y')), day(STR_TO_DATE(date_start,'%d/%m/%Y')) from phsmDetail 
where date_start != ''
order by STR_TO_DATE(date_start,'%d/%m/%Y');
insert into date_startd(s_date_text) values ('');

create table phsmDetaild(lineid int not null, who_id text, admin_level text, area_covered text, comments text, measure_stage text, prev_measure_number text,
following_measure_number text,reason_ended text, targeted text, enforcement text, non_compliance_penalty text,
primary key (lineid));
insert into phsmDetaild (lineID, who_id, admin_level, area_covered, comments, measure_stage, prev_measure_number, following_measure_number, reason_ended, 
targeted, enforcement, non_compliance_penalty) select distinct lineID, who_id, admin_level, area_covered, comments, measure_stage, prev_measure_number, 
following_measure_number, reason_ended, targeted, enforcement, non_compliance_penalty from phsmDetail;

create table conductf(lineid int not null, CTcode int not null, who_code varchar(10) not null, start_time_id int not null, duration bigint default null,
primary key(lineid, CTcode, who_code, start_time_id),
foreign key (lineid) references phsmDetaild (lineid),
foreign key (CTcode) references countryTd (CTcode),
foreign key (who_code) references measured (who_code),
foreign key (start_time_id) references date_startd (s_date_id));
insert into conductf(lineid, CTcode, who_code, start_time_id, duration) select distinct lineid, CTcode, who_code, s_date_id, 
IF(p.date_start='' or p.date_end='', NULL, TIMESTAMPDIFF(DAY,STR_TO_DATE(p.date_start,'%d/%m/%Y'),STR_TO_DATE(p.date_end,'%d/%m/%Y'))) as duration from
phsmDetail p left join date_startd d on p.date_start=d.s_date_text; 
-- here  i suppose duration is more oftenly used in reasearches