Select *
From ProjectPortfolio..CovidDeaths
order by 3,4

--Select *
--From ProjectPortfolio..CovidVaccinations
--order by 3,4

-- Select Data that we'll use.

Select Location, date, total_cases, new_cases, total_deaths, population
From ProjectPortfolio..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths (Focusing on Mexico)
-- Show how likely death is if you contract covid in Mexico.

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
where location = 'Mexico'
order by 1,2

-- Looking at total cases vs population
--Show what percentage of population got covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
where location = 'Mexico'
order by 1,2

-- Looking at Countries with highest infection rate compared to population
--**Tableau Visualization

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
--where location = 'Mexico'
Group by Population, Location
order by PercentPopulationInfected desc

Select Location, Population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
--where location = 'Mexico'
Group by Population, Location, date
order by PercentPopulationInfected desc

-- Looking at countries with highest death count per population

Select Location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- Breaking things down by continent
-- Showing the continents with the highest death count.

Select Location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
Where continent is null
Group by Location
Order by TotalDeathCount desc


-- Per continent: PercentagePopulationInfected

Select continent, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
Where continent is not null
Group by continent
order by PercentPopulationInfected desc

--Per continent: TotalDeathCount
--**Tableau Visualization

SELECT location, SUM(CAST(new_deaths as int)) as TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union','International')
GROUP BY location
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS: Global likelihood to die each die if you contracted covid

Select date, SUM(new_cases) as TotalGlobalCases, SUM(cast(new_deaths as bigint)) as TotalGlobalDeaths, (SUM(cast(total_deaths as bigint))/SUM(total_cases))*100 as GlobalDeathPercentage
From ProjectPortfolio..CovidDeaths
Where continent is not null
Group by date
order by GlobalDeathPercentage desc

-- Total cases worlwide:
--**Tableau Visualization

Select SUM(new_cases) as TotalGlobalCases, SUM(cast(new_deaths as bigint)) as TotalGlobalDeaths, (SUM(cast(total_deaths as bigint))/SUM(total_cases))*100 as GlobalDeathPercentage
From ProjectPortfolio..CovidDeaths
 Where continent is not null


 -- Looking at total population vs vaccionations (Rolling count)

 Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
 , SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
 dea.date) as RollingCountPPLVaccinated
 From ProjectPortfolio..CovidDeaths dea
 Join ProjectPortfolio..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- USE CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingCountPLLVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (int, vac.new_vaccinations)) OVER (PARTITION by dea.Location ORDER BY dea.location, 
     dea.date) as RollingCountPPLVaccinated

FROM ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
    ON dea.location = vac.location 
    and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingCountPLLVaccinated/Population)*100 as PercentagePPLVaccinated
FROM PopVsVac
WHERE Location = 'Mexico'

-- Same but with temp table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingCountPPLVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (int, vac.new_vaccinations)) OVER (PARTITION by dea.Location ORDER BY dea.location, 
     dea.date) as RollingCountPPLVaccinated

FROM ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
    ON dea.location = vac.location 
    and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingCountPPLVaccinated/Population)*100 as PercentagePPLVaccinated
FROM #PercentPopulationVaccinated
ORDER BY Location

-- Creating view to store data for later

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (int, vac.new_vaccinations)) OVER (PARTITION by dea.Location ORDER BY dea.location, 
     dea.date) as RollingCountPPLVaccinated

FROM ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
    ON dea.location = vac.location 
    and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated 






 




