/*Covid- 19 Data Exploration
Skills used : Joins,  CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types */

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--Select data that we are going to start with
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Total Cases vs Total Deaths
--Shows likelihood of dying if someone contracts covid in United Arab Emirates
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%United Arab Emirates%'
and continent is not null
ORDER BY 1,2

--Total Cases vs Population
--Shows what percentage of population is infected with Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Countries with highest infection rate compared to population
SELECT location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Breaking things down by Continent
--Showing continents with highest deaths
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Total Population vs Vaccinations
--Shows Percentage of Population that has recieved atleast one dose of covid vaccine
SELECT dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations,
  SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
      ON dea.location = vac.location
	  AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Using CTE to perform calculations on Partition By in previous query
WITH PopvsVac (Continent, Locaiton, Date, Population, New_vaccinations, RollingPeopleVaccinated) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations,
  SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
      ON dea.location = vac.location
	  AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
FROM PopvsVac

--Using Temp Table to perform calculation on Partition By on previous query
Drop Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations,
  SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
      ON dea.location = vac.location
	  AND dea.date = vac.date
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualisations
CREATE VIEW RollingPeopleVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations,
  SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
      ON dea.location = vac.location
	  AND dea.date = vac.date
WHERE dea.continent is not null









