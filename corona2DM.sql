-- Student Name: Jiawen Li
-- Student Number : K20056947
-- Write your commands and/or comments below
-- weekly data is often used in covid-19 report, so here i include it in the Dated table
create table Dated (dateId int not null auto_increment, dateRep varchar(225), year int, month int, week int, day int,
primary key (dateId));
insert into Dated (dateRep, year, month, week, day) select distinct dateRep, year, month, week(STR_TO_DATE(dateRep,'%d/%m/%Y')),day 
from Date order by year, month, day;

create table countryd (geoId varchar(255) not null, countryterritoryCode varchar(225), countriesAndTerritories varchar(255), popData2019 int, continentExp varchar(255),
primary key (geoId));
insert into countryd (geoId,countryterritoryCode,countriesAndTerritories,popData2019,continentExp) select distinct * from country;

-- the total cases and total deaths are also often used in many reports, so here i also add cusum_cases and cusum_deaths in the fact table.
create table covidDataf (geoId varchar(255) not null, dateId int not null, cases int, cusum_cases int, deaths int, cusum_deaths int,
primary key(geoId, dateId),
foreign key(dateId) references Dated(dateId),
foreign key(geoId) references countryd(geoId));
insert into covidDataf (geoId,dateId,cases,cusum_cases,deaths,cusum_deaths) select geoId, dateId, cases, 
(sum(cases) over(partition by geoId order by dateId rows between unbounded preceding and current row)) as cusum_cases, 
deaths, (sum(deaths) over(partition by geoId order by dateId rows between unbounded preceding and current row)) as cusum_deaths 
from (select geoId,dateId,cases,deaths from covidData c left join Dated d on c.dateRep=d.dateRep) as b;


