select *
from portfolioproject..coviddeaths
order by 3,4

--select data we are going to be using
select location,date,total_cases,new_cases,total_deaths,population
from portfolioproject..coviddeaths
order by 1,2

--looking at total cases vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from portfolioproject..coviddeaths
order by 1,2

--looking at total_cases vs population
--shows percentage of population that got covid
select location,date,total_cases,population,(total_cases/population)*100 as percentpopulationinfected
from portfolioproject..coviddeaths
order by 1,2

--looking at countries with highest infection rate compared to population
select location,population,MAX(total_cases) as highestinfectioncount,MAX((total_cases/population))*100 as percentpopulationinfected
from portfolioproject..coviddeaths
group by location,population
order by percentpopulationinfected desc

--showing countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..coviddeaths
group by location
order by totaldeathcount desc

--looking at total population vs vaccinations
--temp table
Create table #percentpopulationvaccinate
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)


insert into #percentpopulationvaccinate
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

select *,(rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinate

--creating view to store data for later visualisations
create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select*
from percentpopulationvaccinated


