

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from portfoliodatabase..covid_deaths
where location  like '%Nigeria%' and continent is not null
order by 1, 2

select location, date, total_cases, population, (total_cases/population)*100 PopulationPercentageInfected
from portfoliodatabase..covid_deaths
where location  like '%Nigeria%' and continent is not null
order by 1, 2

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 
PopulationPercentageInfected
from portfoliodatabase..covid_deaths
where continent is not null
group by location, population
order by PopulationPercentageInfected desc


select location, max(cast(total_deaths as bigint)) as TotalDeathsCount
from portfoliodatabase..covid_deaths
where continent is not null
group by location
order by TotalDeathsCount desc

select continent, max(cast(total_deaths as bigint)) as TotalDeathsCount
from portfoliodatabase..covid_deaths
where continent is not null
group by continent
order by TotalDeathsCount desc

select sum(new_cases) total_cases, sum(cast(new_deaths as bigint)) total_deaths, (sum(cast(new_deaths as bigint))/ sum(new_cases))*100 DeathPercentage
from portfoliodatabase..covid_deaths
--where location  like '%Nigeria%' and continent is not null
where continent is not null
--group by date
order by 1, 2

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from portfoliodatabase..covid_vaccinations as vac
join portfoliodatabase..covid_deaths as dea
	on vac.location=dea.location
	and vac.date=dea.date
where dea.continent is not null
order by 2,3
--CTE
with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from portfoliodatabase..covid_vaccinations as vac
join portfoliodatabase..covid_deaths as dea
	on vac.location=dea.location
	and vac.date=dea.date
where dea.continent is not null
--order by 2,3
)
select*,(RollingPeopleVaccinated/population)*100
from popvsvac

--#temp
create table #percentagepopulationvaccinated
( continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccinations numeric,
RollingPeopleVaccinated numeric)
insert into #percentagepopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from portfoliodatabase..covid_vaccinations as vac
join portfoliodatabase..covid_deaths as dea
	on vac.location=dea.location
	and vac.date=dea.date
where dea.continent is not null
--order by 2,3
select*, (RollingPeopleVaccinated/population)*100 as percentagevaccinated
from #percentagepopulationvaccinated

create view percentagepopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from portfoliodatabase..covid_vaccinations as vac
join portfoliodatabase..covid_deaths as dea
	on vac.location=dea.location
	and vac.date=dea.date
where dea.continent is not null
--order by 2,3


