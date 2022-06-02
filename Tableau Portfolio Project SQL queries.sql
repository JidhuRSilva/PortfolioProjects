
/* Queries used for Tableau Project */

--1.
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as  DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--2.
SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is  null
and location not in ('World','European Union', 'International')
and location not like '%income%'
GROUP BY location
ORDER BY TotalDeathCount desc

--3.
SELECT location, population, MAX(total_cases) as HighestInfectioncount, MAX(total_cases)/population *100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--4.
SELECT location, population, date, MAX(total_cases) as HighestInfectioncount, MAX((total_cases)/population) *100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected desc




