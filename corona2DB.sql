-- Student Name: Jiawen LI
-- Student Number : K20056947
-- Write your commands and/or comments below
#1NF(add pk dateRep,geoId)
create table corona1NF as select * from corona;
alter table corona1NF add primary key (dateRep, geoID);
-- 2NF
create table Date as select distinct dateRep,day,month,year from corona1NF;
alter table Date add primary key (dateRep);
create table country as select distinct geoId, countryterritoryCode,countriesAndTerritories, popData2019,continentExp from corona1NF; 
alter table country add primary key (geoId);
create table covidData as select distinct daterep, geoId, cases, deaths from corona1NF;
alter table covidData add primary key (daterep,geoId);
alter table covidData add foreign key (daterep) references Date(daterep);
alter table covidData add foreign key (geoId) references country(geoId);

-- countriesAndTerritories is fully dependent on geoId
-- 3NF is the same as 2NF 
