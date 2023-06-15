SELECT *
FROM test..covid_deaths_1
ORDER BY 3,4

--SELECT *
--FROM test..covid_vaccination_1
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM test..covid_deaths_1
ORDER BY 1,2

ALTER TABLE test..covid_deaths_1
ALTER COLUMN total_cases FLOAT;

--Looking at Total Cases vs Total Deaths
--Shows Likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Deathpercentage
FROM test..covid_deaths_1
WHERE location LIKE '%states%'
ORDER BY 1,2

--Looking at Total Cases vs population
--shows what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS Deathpercentage
FROM test..covid_deaths_1
WHERE location ='India'
ORDER BY 1,2

--Looking at countries with Highest Infection Rate compared to population

SELECT location,population, MAX(Total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM test..covid_deaths_1
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing the Countires with Highest Death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount 
FROM test..covid_deaths_1
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Break things down by continent

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount 
FROM test..covid_deaths_1
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount 
FROM test..covid_deaths_1
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT location,SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(NEW_CASES)*100 AS deathpercentage
FROM test..covid_deaths_1
GROUP BY location
ORDER BY 1,2

--Looking at Total Population vs Vaccinations

SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingpeopleVaccinated,
--(RollingpeopleVaccinated/population)*100
FROM test..covid_deaths_1 dea
JOIN test..covid_Vaccination_1 vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

WITH PopvsVac (continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingpeopleVaccinated
FROM test..covid_deaths_1 dea
JOIN test..covid_Vaccination_1 vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
)
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE if exists #percentpopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingpeopleVaccinated
FROM test..covid_deaths_1 dea
JOIN test..covid_Vaccination_1 vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null

--CREATING VIEW TO STORE DATA


CREATE VIEW percentpopulationvaccinated as
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingpeopleVaccinated
FROM test..covid_deaths_1 dea
JOIN test..covid_Vaccination_1 vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null

SELECT *
FROM percentpopulationvaccinated