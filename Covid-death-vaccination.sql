--1. Overview NOT NULL with continent
SELECT * FROM PortfolioProject.dbo.Covideaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT * FROM PortfolioProject.dbo.Covivaccinations
ORDER BY 3,4

--2.1. Looking at Total Cases vs Total Deaths
--2.2. Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, new_cases, total_deaths,population, (total_deaths/total_cases)*100 AS Death_percen
FROM PortfolioProject..Covideaths
WHERE location like '%state%'
ORDER BY 1,2

--3.1. Looking at the Total Cases vs Population
--3.2 Shows what percentage of population got Covid

SELECT location, date, total_cases,population, (total_cases/population)*100 AS cases_perc
FROM PortfolioProject..Covideaths
WHERE location like '%state%'
ORDER BY 1,2

--4. Looking at the Countries with Highest Infection Rate Compared to Population

SELECT location, population, Max(total_cases) AS HighestInfectioncount, Max((total_cases/population))*100 AS Perc_PopulationInfect
FROM PortfolioProject..Covideaths
GROUP BY location, population
ORDER BY Perc_PopulationInfect desc

--5.1. Showing Countries with Highest Death Count per Population
--5.2. CAST để đọc integer

SELECT location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..Covideaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- Let's breaking things down by continent


--6. Showing continents with Highest Death Count per Population
SELECT location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..Covideaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--7. GLOBAL NUMBER PER DATE
SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS CaseperDeath
FROM PortfolioProject..Covideaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--8. GLOBAL NUMBER IN TOTAL
SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS CaseperDeath
FROM PortfolioProject..Covideaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--9. Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location)
FROM PortfolioProject..Covideaths dea
JOIN PortfolioProject..Covivaccinations vac
On dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--10. Accrued people vaccinated each day
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, Accrued_peoplevaccnated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Accrued_peoplevaccnated
-- ORDER BY for last column is cummulative per row
FROM PortfolioProject..Covideaths dea
JOIN PortfolioProject..Covivaccinations vac
On dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (Accrued_peoplevaccnated/Population)*100 AS perc_accruedvacc
FROM PopvsVac

--11. TEMP TABLE

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Accrued_peoplevaccnated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Accrued_peoplevaccnated
FROM PortfolioProject..Covideaths dea
JOIN PortfolioProject..Covivaccinations vac
On dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (Accrued_peoplevaccnated/Population)*100
FROM #PercentagePopulationVaccinated


--12. Creating View to store data for later visualization

CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Accrued_peoplevaccnated
FROM PortfolioProject..Covideaths dea
JOIN PortfolioProject..Covivaccinations vac
On dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM PortfolioProject.dbo.Covideaths