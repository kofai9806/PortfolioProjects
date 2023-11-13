SELECT *
FROM PortfolioPrpject..CovidDeath
Order by 3, 4

--SELECT *
--FROM [PortfolioPrpject].[dbo].[CovidVaccinations]

--select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioPrpject..CovidDeath
Order by 1, 2

--looking at Total Cases vs Total_Deaths (this section gives me error when excute...)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
FROM PortfolioPrpject..CovidDeath
Where location like '%states%'
and  continent is not null
Order by 1, 2

--looking at Total Cases vs Population
--shows what population got covid
SELECT location, date, population, total_cases,  (total_cases/population)* 100 as PercentPopulationCount
FROM PortfolioPrpject..CovidDeath
--Where location like '%states%'
Order by 1, 2

--looking at country with high infection Rate compared to popluation 

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100 as PercentPopulationCount
FROM PortfolioPrpject..CovidDeath
--Where location like '%states%'
Group by location, population
Order by PercentPopulationCount desc

--showing the country with highest Death Count Per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioPrpject..CovidDeath
--Where location like '%states%'
Where continent is not NULL
Group by location
Order by TotalDeathCount desc

--Let's Break things down by Continent
--THE TWO STEPS ARE THE SAME COUNT/DATA
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioPrpject..CovidDeath
--Where location like '%states%'
Where continent is not NULL
Group by continent
Order by TotalDeathCount desc

--Showing the continet with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioPrpject..CovidDeath
--Where location like '%states%'
Where continent is not NULL
Group by continent
Order by TotalDeathCount desc

--Global Number 

SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as DeathPercentage
FROM PortfolioPrpject..CovidDeath
--Where location like '%states%'
Where continent is not NULL
Group by date
Order by 1, 2

--JOINING THE TWO TABLES TOGETHER CovidDeaths vs CovidVaccinations
--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioPrpject..CovidDeath dea
JOIN PortfolioPrpject..CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not NULL
Order by 2, 3

--let use CTE's

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioPrpject..CovidDeath dea
JOIN PortfolioPrpject..CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not NULL
--Order by 2, 3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP_TABLE ( This temp_table gives me errors each time)

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioPrpject..CovidDeath dea
JOIN PortfolioPrpject..CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
--Where dea.continent is not NULL
--Order by 2, 3

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating views to store data for later visualizations

create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioPrpject..CovidDeath dea
JOIN PortfolioPrpject..CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
--Where dea.continent is not NULL
--Order by 2, 3

select *
from [PortfolioPrpject].[dbo].[PercentPopulationVaccinated]