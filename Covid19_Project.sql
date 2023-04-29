----Exploring the CovidDeaths table------
select *
from [Portfolio Project]..CovidDeaths
where continent is not null

-----Exploring the CovidVaccinations table----
select *
from [Portfolio Project]..CovidVaccinations
order by 3,4 desc

---Select all the data that we gonna use in the first table -----
select location,date,total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

-------Total cases vs Total deaths--------
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2


------Total cases vs population----------
---show what percentage of the population has been infected with covid
select location, date, total_cases, population, (total_cases/population) * 100 as Population_infect_Percentage
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2 desc

--------------looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as highestinfectioncount,  max((total_cases/population)) * 100 as highestPopulation_infect_Percentage
from [Portfolio Project]..CovidDeaths
where continent is not null
group by location, population
order by highestPopulation_infect_Percentage desc


----SHOWING COUNTRY WITH HIGHEST DEATH COUNT
select location, population,max(cast(total_deaths as int))as highestdeathcount
from [Portfolio Project]..CovidDeaths
where continent is not null                
group by location,population
order by highestdeathcount desc


----SHOWING CONTINENT WITH TOTAL DEATH

select Continent, max(cast(total_deaths as int))as highestdeathcount
from [Portfolio Project]..CovidDeaths
where continent is not null                
group by continent
order by highestdeathcount desc


-------Global numbers
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases) *100 as death_percentage
from [Portfolio Project]..CovidDeaths
where continent is not null


------Looking at total population vs total vaccinations
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
where dea.continent is not null
order by 2,3


----Using cte 
with popvsvac ( continent,location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/ population)*100
from popvsvac


------Using Temp table-------
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *
from PercentPopulationVaccinated