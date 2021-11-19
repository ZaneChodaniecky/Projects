SELECT * 
From CovidData..Covid_Deaths
WHERE continent is not null
order by 3,4


--Select Data that we will be using
Select location,date,total_cases,new_cases,total_deaths,population
from CovidData..Covid_Deaths
order by location,date

-- Looking at Total Cases vs Total Deaths

SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Pct
FROM CovidData..Covid_Deaths
WHERE location like '%states%'
ORDER BY location,date

--Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PctPopulationInfected
FROM CovidData..Covid_Deaths
GROUP BY location,population
ORDER BY PctPopulationInfected desc

--Break things down by continent
SELECT location, MAX(population) as Max_Population,MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((total_deaths/population)*100) as PctPopulationDeath
FROM CovidData..Covid_Deaths
where continent is null
GROUP BY location
ORDER BY PctPopulationDeath desc



--Countries with highest death rate
SELECT location, population, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((total_deaths/population)*100) as PctPopulationDeath
FROM CovidData..Covid_Deaths
where continent is not null
GROUP BY location,population
ORDER BY PctPopulationDeath desc


--Global Numbers
SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths,
(SUM(cast(new_deaths as int)) / SUM(New_Cases))*100 as DeathPct--, MAX((total_deaths/population)*100) as PctPopulationDeath
FROM CovidData..Covid_Deaths
where continent is not null and new_cases is not null and new_deaths is not null
GROUP BY date
ORDER BY date


--Total population vs vaccinations
Select die.continent, die.location, die.date, die.population, vax.new_vaccinations,
 SUM(convert(bigint,vax.new_vaccinations)) OVER (Partition by die.location ORDER BY die.location, die.date) as rolling_total_vax
FROM Covid_Deaths as die
Join Covid_Vaccinations as vax
on die.location = vax.location and die.date = vax.date
WHERE die.continent is not null
ORDER BY 2,3


--Total vaccinated percent use CTE
with PopVax (continent, location, date, population, new_vaccinations, rolling_total_vax) 
as 
(
Select die.continent, die.location, die.date, die.population, vax.new_vaccinations,
SUM(convert(bigint,vax.new_vaccinations)) OVER (Partition by die.location ORDER BY die.location, die.date) as rolling_total_vax
FROM Covid_Deaths as die
Join Covid_Vaccinations as vax
on die.location = vax.location and die.date = vax.date
WHERE die.continent is not null
)

Select *, (rolling_total_vax/population) as total_vax_pct
From PopVax
WHERE rolling_total_vax is not null
ORDER BY location, date

--Total vaccinated percent use Temp Table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rolling_total_vax numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT die.continent, die.location, die.date, die.population, vax.new_vaccinations,
SUM(convert(bigint,vax.new_vaccinations)) OVER (Partition by die.location ORDER BY die.location, die.date) AS rolling_total_vax
FROM Covid_Deaths AS die
Join Covid_Vaccinations AS vax
ON die.location = vax.location and die.date = vax.date
WHERE die.continent is not null

SELECT *, (rolling_total_vax/population) AS total_vax_pct
FROM #PercentPopulationVaccinated

--Create views
CREATE VIEW PercentPopulationVaccinated as 
SELECT die.continent, die.location, die.date, die.population, vax.new_vaccinations,
SUM(convert(bigint,vax.new_vaccinations)) OVER (Partition by die.location ORDER BY die.location, die.date) AS rolling_total_vax
FROM Covid_Deaths AS die
Join Covid_Vaccinations AS vax
ON die.location = vax.location and die.date = vax.date
WHERE die.continent is not null