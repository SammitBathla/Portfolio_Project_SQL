

SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3, 4




--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3, 4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1, 2

-- Looking at toal cases vs Total Deaths
-- Shows likelihood of dying if you contract in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%india%'
and continent is not null
ORDER BY 1, 2

-- Looking at total cases vs population

SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS PopulationPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1, 2



--Looking at countriea with highest infection rate to population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%india%'
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected desc


-- Showing countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%india%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc


-- Lets's break things down by Continent

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%india%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- showing continents with the highest death count per population


SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%india%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



-- Global numbers



SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2




SELECT *
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date


-- Looking at Total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER(Partition By dea.location ORDER BY dea.location, dea.date ) as RollongPeopleVaccinateed
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Use CTE

WITH PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER(Partition By dea.location ORDER BY dea.location, dea.date ) as RollongPeopleVaccinateed
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp table

DROP TABLE IF EXISTS #PercentagePopulatinVaccinated
CREATE TABLE #PercentagePopulatinVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulatinVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date ) as RollongPeopleVaccinateed
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentagePopulatinVaccinated


--CREATE VIEW to store data for later visualization

CREATE View PercentPopulationVaccinateds
AS SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date ) as RollongPeopleVaccinateed
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

DROP VIEW PercentPopulationVaccinated


SELECT *
FROM PercentPopulationVaccinateds

