-- Student Name: Jiawen Li
-- Student Number : K20056947
-- Write your commands and/or comments below
-- question 1:
select distinct * from
(select countriesAndTerritories, continentExp, month, DateRep, cases, cases/popData2019*1000000 as infection_per_million_people,
rank() over (partition by countriesAndTerritories order by cases/popData2019*1000000 desc) as ranking
from covidDataf,countryd, Dated 
where covidDataf.geoId= countryd.geoId and covidDataf.dateId=Dated.dateId) as a
where ranking<11
order by continentExp,countriesAndTerritories,ranking;

-- question 2
-- the first infection case in each continent
select continentExp, dateRep, year, month, countriesAndTerritories, cusum_cases from covidDataf,countryd, Dated 
where covidDataf.geoId= countryd.geoId and covidDataf.dateId=Dated.dateId and cusum_cases>0 and
(continentExp,STR_TO_DATE(dateRep,'%d/%m/%Y')) in (select continentExp, min(STR_TO_DATE(dateRep,'%d/%m/%Y')) as start_date from covidDataf,countryd, Dated 
where covidDataf.geoId= countryd.geoId and covidDataf.dateId=Dated.dateId and cusum_cases>0
group by continentExp)
order by year, month, dateRep, continentExp;

-- the first death case in each continent
select continentExp, dateRep, year, month, countriesAndTerritories, cusum_deaths, cusum_cases from covidDataf,countryd, Dated 
where covidDataf.geoId= countryd.geoId and covidDataf.dateId=Dated.dateId and cusum_deaths>0 and
(continentExp,STR_TO_DATE(dateRep,'%d/%m/%Y')) in (select continentExp, min(STR_TO_DATE(dateRep,'%d/%m/%Y')) as start_date from covidDataf,countryd, Dated 
where covidDataf.geoId= countryd.geoId and covidDataf.dateId=Dated.dateId and cusum_deaths>0
group by continentExp)
order by year, month, dateRep, continentExp;
