SELECT *
FROM PortafolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4


--SELECT *
--FROM PortafolioProject..CovidVaccinations
--ORDER BY 3,4


-- Select Data that we aere going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortafolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases VS Total Deaths
-- Likelihood of dying by covid per country
SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage 
FROM PortafolioProject..CovidDeaths
WHERE location like '%germany%' AND continent is not null
ORDER BY 1,2


--Looking at Total Cases vs Population
-- Percentage of population got Covid

SELECT location, date, population, total_cases,  (CONVERT(float, total_cases)/NULLIF(CONVERT(float,population),0))*100 AS PercentPopulationInfectedCountry
FROM PortafolioProject..CovidDeaths
WHERE location like '%germany%' AND continent is not null
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((CONVERT(float, total_cases)/NULLIF(CONVERT(float,population),0))*100) AS PercentPopulationInfected 
FROM PortafolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with the Highest Death Count per Population

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortafolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 DESC

-- Highest Death by continent

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortafolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC

--Continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortafolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC

-- Global Numbers

SELECT  SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(New_cases)*100 AS DeathPercentage
FROM PortafolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
		AS RollingPeopleVaccinated
FROM PortafolioProject..CovidDeaths dea
JOIN PortafolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Use CTE

WITH PopVSVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS (
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
			AS RollingPeopleVaccinated
	FROM PortafolioProject..CovidDeaths dea
	JOIN PortafolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVSVac

-- TempTable
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
			AS RollingPeopleVaccinated
	FROM PortafolioProject..CovidDeaths dea
	JOIN PortafolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations

CREATE VIEW  PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
			AS RollingPeopleVaccinated
	FROM PortafolioProject..CovidDeaths dea
	JOIN PortafolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated
