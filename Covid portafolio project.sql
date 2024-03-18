-- Select data from CovidDeaths where continent is not null and order by the third and fourth columns
SELECT *
FROM PortafolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

-- Select relevant data from CovidDeaths for analysis
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortafolioProject..CovidDeaths
ORDER BY 1, 2

-- Calculate death percentage for Germany
SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/NULLIF(CONVERT(float, total_cases), 0))*100 AS DeathPercentage 
FROM PortafolioProject..CovidDeaths
WHERE location LIKE '%germany%' AND continent IS NOT NULL
ORDER BY 1, 2

-- Calculate percentage of population infected in Germany
SELECT location, date, population, total_cases, (CONVERT(float, total_cases)/NULLIF(CONVERT(float, population), 0))*100 AS PercentPopulationInfectedCountry
FROM PortafolioProject..CovidDeaths
WHERE location LIKE '%germany%' AND continent IS NOT NULL
ORDER BY 1, 2

-- Calculate countries with the highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CONVERT(float, total_cases)/NULLIF(CONVERT(float, population), 0))*100) AS PercentPopulationInfected 
FROM PortafolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Calculate countries with the highest death count per population
SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortafolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- Calculate continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortafolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

-- Calculate global numbers
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(New_cases)*100 AS DeathPercentage
FROM PortafolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Join CovidDeaths and CovidVaccinations to analyze vaccination data
WITH PopVSVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS (
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortafolioProject..CovidDeaths dea
	JOIN PortafolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVSVac

-- Use a Common Table Expression (CTE) to analyze vaccination data
WITH PopVSVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS (
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortafolioProject..CovidDeaths dea
	JOIN PortafolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVSVac

-- Use a temporary table to analyze vaccination data
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent NVARCHAR(255),
	Location NVARCHAR(255),
	Date DATETIME,
	Population NUMERIC,
	New_vaccinations NUMERIC,
	RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortafolioProject..CovidDeaths dea
	JOIN PortafolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Create a view to store vaccination data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortafolioProject..CovidDeaths dea
	JOIN PortafolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated

