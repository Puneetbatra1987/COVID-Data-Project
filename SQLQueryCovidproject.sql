SELECT *
FROM [Portfolio Project COVID Data].[dbo].['Covid Deaths$']
WHERE continent IS NOT NULL
ORDER BY 3,4

---Data that will be used
SELECT [location],continent, [date],[population],[total_cases],[new_cases],[total_deaths]
FROM [Portfolio Project COVID Data].[dbo].['Covid Deaths$']
WHERE continent IS NOT NULL
ORDER BY 1,2


----Total Cases vs Total Deaths (shows likelihood of death due to COVID)
SELECT [location], continent, [date],[total_cases],[total_deaths],(total_deaths/total_cases)*100  AS percentage_deaths
FROM [Portfolio Project COVID Data].[dbo].['Covid Deaths$']
WHERE continent IS NOT NULL
---WHERE location IS 'Canada'
ORDER BY 1,2

---Total Cases vs Population (Percentage of population that contracted COVID)
SELECT [location], continent, [date],[total_cases],[population],(total_cases/population)*100  AS PercentagePopulationInfected
FROM [Portfolio Project COVID Data].[dbo].['Covid Deaths$']
WHERE continent IS NOT NULL
--WHERE location = 'Canada'
ORDER BY 1,2

---Countries with highest infection rate
SELECT [location], continent,  MAX([total_cases]) AS HighestInfectionCount,[population],MAX((total_cases/population))*100  AS PercentagePopulationInfected
FROM [Portfolio Project COVID Data].[dbo].['Covid Deaths$']
---WHERE location = 'Canada'
WHERE continent IS NOT NULL
GROUP BY continent, location, population
ORDER BY PercentagePopulationInfected DESC

---Countries with highest Death Rate
SELECT [location], continent, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM [Portfolio Project COVID Data].[dbo].['Covid Deaths$']
---WHERE location = 'Canada'
WHERE continent IS NOT NULL
GROUP BY continent, location
ORDER BY HighestDeathCount DESC

---Selecting by Continent
---Continents with highest death count per population
SELECT continent, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM [Portfolio Project COVID Data].[dbo].['Covid Deaths$']
---WHERE location = 'Canada'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

---Global numbers
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100  AS percentage_deaths
FROM [Portfolio Project COVID Data].[dbo].['Covid Deaths$']
WHERE continent IS NOT NULL
---WHERE location IS 'Canada'
--GROUP BY date
ORDER BY 1,2


--Total population vs vaccinations
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dth.location ORDER BY dth.location, dth.date) AS VaccinationRollingCount
---,(VaccinationRollingCount/population)*100
FROM [dbo].['Covid Deaths$'] dth
JOIN [dbo].['NEW-covid-vaccinations'] vac
	ON dth.location = vac.location AND dth.date = vac.date
	WHERE dth.continent IS NOT NULL
	ORDER BY 2,3

---USE CTE
WITH Popvsvac(Continent, Location, Date, Population, NewVaccinations,VaccinationRollingCount)
AS
(
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dth.location ORDER BY dth.location, dth.date) AS VaccinationRollingCount
---,(VaccinationRollingCount/population)*100
FROM [dbo].['Covid Deaths$'] dth
JOIN [dbo].['NEW-covid-vaccinations'] vac
ON dth.location = vac.location AND dth.date = vac.date
WHERE dth.continent IS NOT NULL
---ORDER BY 2,3
	)
SELECT *,(VaccinationRollingCount/Population)*100 
FROM Popvsvac


---TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
VaccinationRollingCount numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dth.location ORDER BY dth.location, dth.date) AS VaccinationRollingCount
---,(VaccinationRollingCount/population)*100
FROM [dbo].['Covid Deaths$'] dth
JOIN [dbo].['NEW-covid-vaccinations'] vac
ON dth.location = vac.location AND dth.date = vac.date
WHERE dth.continent IS NOT NULL

SELECT *,(VaccinationRollingCount/Population)*100 
FROM  #PercentPopulationVaccinated


---CREATE VIEW TO STORE DATA FOR VISUALIZATION

DROP VIEW PercentPopuationVaccinated

CREATE VIEW PercentPopuationVaccinated AS

SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dth.location ORDER BY dth.location, dth.date) AS VaccinationRollingCount
---,(VaccinationRollingCount/population)*100
FROM [dbo].['Covid Deaths$'] dth
JOIN [dbo].['NEW-covid-vaccinations'] vac
ON dth.location = vac.location AND dth.date = vac.date
WHERE dth.continent IS NOT NULL



