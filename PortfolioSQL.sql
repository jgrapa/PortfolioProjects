-- SQL Data Exploration Using Covid19 Global Data
-- Skill used: Joins

USE PortfolioSQL;

SELECT *
  FROM PortfolioSQL..CovidDeaths
 WHERE continent IS NOT NULL
ORDER BY 3, 4


-- SELECT DATA TO START WITH

SELECT location,
       date,
       total_cases,
       new_cases,
       total_deaths,
       new_deaths,
       population
  FROM PortfolioSQL..CovidDeaths D
 WHERE continent IS NOT NULL
ORDER BY 1, 2

-- TOTAL CASES VS TOTAL DEATHS
-- Shows what percentage dies when infected with covid per country

SELECT location,
       date,
       total_cases,
       total_deaths,
       (cast (total_deaths AS INT) / total_cases) * 100 AS DeathPercentage
  FROM PortfolioSQL..CovidDeaths D
 WHERE continent IS NOT NULL
ORDER BY 1, 2


-- TOTAL CASES VS POPULATION
-- Shows what percentage of the population got Covid per country

SELECT location,
       date,
       total_cases,
       population,
       (total_cases / population) * 100 AS InfectedPopulationPercentage
  FROM PortfolioSQL..CovidDeaths D
 WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Show countries that has the highest infection rate per population to date
--

SELECT location,
       max (total_cases) AS InfectionCount,
       population,
       (max (total_cases) / population) * 100 AS InfectedPopulationPercentage
  FROM PortfolioSQL..CovidDeaths D
 WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectedPopulationPercentage DESC


-- Show countries that has the highest death per population count to date
--

SELECT location, max (cast (total_deaths AS INT)) AS DeathCount            --,
  --population,
  --(max(total_deaths) / population) * 100 AS DeathPopulationPercentage
  FROM PortfolioSQL..CovidDeaths D
 WHERE continent IS NOT NULL
GROUP BY location
ORDER BY DeathCount DESC


-- Group by Continent
-- Showing the Highest Death Count per Population Grouped by Continent


SELECT continent, max (cast (total_deaths AS INT)) AS TotalDeathCount      --,
  --population,
  --(max(total_deaths) / population) * 100 AS DeathPopulationPercentage
  FROM PortfolioSQL..CovidDeaths D
 WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Total Cases, Total Deaths and Total Death Percentage
--

SELECT sum (new_cases) AS TotalCases,
       sum (cast (new_deaths AS INT)) AS TotalDeaths,
       (sum (cast (new_deaths AS INT)) / sum (new_cases) * 100)
          AS TotalDeathPercentage
  FROM PortfolioSQL..CovidDeaths D
 WHERE continent IS NOT NULL


-- Total Population vs Vaccinations
--
SELECT d.continent,
       d.location,
       d.date,
       d.population,
       v.new_vaccinations,
       sum (cast (v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY D.location, D.DATE) AS PeopleVaccinated
FROM dbo.CovidDeaths D
JOIN dbo.CovidVaccinations v ON D.location = v.location AND D.DATE = v.DATE
WHERE D.continent IS NOT NULL
ORDER BY 2, 3
--
--

-- Show TotalVaccinations by Continent
--

SELECT * FROM CovidVaccinations

SELECT D.continent,
       max (cast (v.total_vaccinations AS BIGINT)) AS TotalVaccinations
  FROM    dbo.CovidDeaths D
       JOIN
          dbo.CovidVaccinations v
       ON D.location = v.location AND D.DATE = v.DATE
 WHERE D.continent IS NOT NULL
GROUP BY D.continent

-- Using TempTable
-- Insert Into

DROP TABLE IF EXISTS #PercentPeopleVaccinated

CREATE TABLE #PercentPeopleVaccinated
(
Continent  NVARCHAR(250),
Location  NVARCHAR(250),
DATE  DATETIME,
POPULATION  NUMERIC,
NewVaccinations  NUMERIC,
PeopleVaccinated  NUMERIC
)

INSERT INTO #PercentPeopleVaccinated
SELECT D.continent,
       D.location,
       D.DATE,
       D.POPULATION,
       v.new_vaccinations,
       sum (cast (v.new_vaccinations AS BIGINT)) OVER (PARTITION BY D.location ORDER BY D.location, D.DATE) AS PeopleVaccinated
FROM dbo.CovidDeaths D
JOIN dbo.CovidVaccinations v ON D.location = v.location AND D.DATE = v.DATE
--HERE D.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (PeopleVaccinated / POPULATION) * 100 AS PercentVaccinated
FROM #PercentPeopleVaccinated

-- Using TempTable
-- Select Into

DROP TABLE IF EXISTS #PercentPeopleVaccinated

SELECT D.continent,
       D.location,
       D.DATE,
       D.POPULATION,
       v.new_vaccinations,
       sum (cast (v.new_vaccinations AS BIGINT)) OVER (PARTITION BY D.location ORDER BY D.location, D.DATE) AS PeopleVaccinated
       INTO #PercentPeopleVaccinated
FROM dbo.CovidDeaths D
JOIN dbo.CovidVaccinations v ON D.location = v.location AND D.DATE = v.DATE
Go

SELECT *, (PeopleVaccinated / POPULATION) * 100 AS PercentVaccinated
  FROM #PercentPeopleVaccinated 
  
-- Using CTE
--

WITH PopulationVaccinated (
        Continent,
        Location,
        DATE,
        POPULATION,
        NewVaccinations,
        PeopleVaccinated)
     AS
        (SELECT D.continent,
                D.location,
                D.DATE,
                D.POPULATION,
                v.new_vaccinations,
                sum (cast (v.new_vaccinations AS BIGINT))
                   OVER (PARTITION BY D.location ORDER BY D.location, D.DATE) AS PeopleVaccinated
FROM dbo.CovidDeaths D
JOIN dbo.CovidVaccinations v ON D.location = v.location AND D.DATE = v.DATE
WHERE D.continent IS NOT NULL
--ORDER BY 2, 3
)

SELECT *, (PeopleVaccinated / POPULATION) * 100 AS PercentVaccinated
  FROM PopulationVaccinated


-- Create View to store for visualizations
--

CREATE VIEW PercentPeopleVax
AS
   SELECT D.continent,
          D.location,
          D.DATE,
          D.POPULATION,
          v.new_vaccinations,
          sum (cast (v.new_vaccinations AS BIGINT))
             OVER (PARTITION BY D.location          ORDER BY D.location, D.DATE) AS PeopleVaccinated

FROM dbo.CovidDeaths D
JOIN dbo.CovidVaccinations v ON D.location = v.location AND D.DATE = v.DATE
WHERE D.continent IS NOT NULL

