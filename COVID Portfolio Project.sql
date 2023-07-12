select *
from PortfolioProject..CovidDeaths
order by 3,4

select *
from PortfolioProject..CovidVaccinations
order by 3,4

--select data that we are going to be using

select location, date, total_cases, total_deaths
from PortfolioProject..CovidDeaths
order by 1,2


select location, date, total_cases, total_deaths, convert(float,total_deaths)/convert(float,total_cases)  *100 as DeathPersentage
from PortfolioProject..CovidDeaths
order by 1,2

-- looking at total cases vs total Deaths
--showing likehood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, convert(float,total_deaths)/convert(float,total_cases)  *100 as DeathPersentage
from PortfolioProject..CovidDeaths
where location = 'United states'
order by 1,2


--looking at the total cases vs the population
--show what percantage of population got covid
select location, date, population , total_cases, total_deaths, convert(float,total_deaths)/convert(float,total_cases) *100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2


--looking at the total cases vs the population

select location,population ,Max(total_cases)as HighestInfectionCount,Max(total_cases/population) *100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location,population
order by PercentPopulationInfected desc

-- Showing the countries with the highest death count per population

select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--Looking at total Population vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint, new_vaccinations)) over (Partition by dea.location) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3


--USE CTE

With PopvsVac (continent ,Location,Date, Population ,New_Vaccinations, RolliungPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint, new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)
Select *, (RolliungPeopleVaccinated/Population)*100
from PopvsVac

--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert Into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint, new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.Date)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualisations

Create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint, new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

	Select*
	From PercentPopulationVaccinated