--select * 
--from
--PortfolioProject..CovidDeaths
--order by 3,4

--select * 
--from
--PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from
PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from
PortfolioProject..CovidDeaths
where location like '%nigeria%'
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population) * 100 as DeathPercentage
from
PortfolioProject..CovidDeaths
--where location like '%nigeria%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)) * 100 as PercentPopulationInfected
from
PortfolioProject..CovidDeaths
--where location like '%nigeria%'
Group by location, population
order by PercentPopulationInfected desc


-- Showing the countinents with the highest death count per population

Select location, MAX(cast (Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
Group by location
order by TotalDeathCount desc



Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int)) / SUM (New_Cases)  * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2



Select *
From PortfolioProject..CovidVaccinations







-- Looking at Total Population vs Vaccination 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2, 3


Select *
From PortfolioProject..CovidDeaths



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM ( Cast (vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
 as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2, 3



-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
 (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM ( Cast (vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
 as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population) * 100
from PopvsVac




-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM ( Cast (vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
 as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 

Select *, (RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualization 



Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM ( Cast (vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
 as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select *
From PercentPopulationVaccinated