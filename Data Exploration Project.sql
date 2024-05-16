SELECT *
FROM PortfolioProject..CovidDeath
order by 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3, 4


--Select the file you want to use 
SELECT location, date, total_cases, new_cases, total_deaths,population
FROM PortfolioProject..CovidDeath
order by 1, 2


-- Total cases vs Total Deaths
-- This shows the likelihood of you dying from covid if contrated in your country
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (CAST(total_deaths AS DECIMAL) / NULLIF(CAST(total_cases AS DECIMAL), 0))*100 AS PercentageDeath
FROM
    PortfolioProject..CovidDeath
WHERE
    location = 'Nigeria'
ORDER BY
    1, 2;

-- Showing the percentage of population that got covid

SELECT
    location, date, population, total_cases,
    ((CAST(total_cases AS DECIMAL) / NULLIF(population, 0)) * 100) AS PercentageInfected
FROM
    PortfolioProject..CovidDeath
----WHERE
--    location = 'Nigeria'
ORDER BY
    1, 2;

-- Countries with Highest Infection Rate
SELECT
    location, population, max(total_cases) as HighestInfectionCount,
    max(((CAST(total_cases AS DECIMAL) / NULLIF(population, 0)) * 100)) AS PercentageInfected
FROM
    PortfolioProject..CovidDeath
--WHERE
--    location = 'Nigeria'
Group by location, population
ORDER BY 4 desc

-- Showing countries with the Highest Death

SELECT
    location, max(cast (total_deaths as int)) as TotalDeaths
FROM
    PortfolioProject..CovidDeath
where continent is not null
Group by location
ORDER BY 2 desc

-- LET'S FILTER BY CONTINENT
-- Showing continent with the highest death count

SELECT
    continent, sum(new_deaths) as TotalDeaths
FROM
    PortfolioProject..CovidDeath
where continent is not null
Group by continent
ORDER BY 2 desc


--- Showing the Death Rate per population

SELECT
    location, population, max(cast (total_deaths as int)) as TotalDeaths,
    max(((CAST(total_deaths AS int) / NULLIF(population, 0)) * 100)) AS PercentageDeath
FROM
    PortfolioProject..CovidDeath
Group by location, population
ORDER BY 4 desc


--GLOBAL NUMBERS
--Showing the death rate on each day

Select date,sum(cast(total_cases as float)) as TotalCases, sum(cast(total_deaths as float)) as TotalDeaths,
	case
		when 
		sum(cast(total_cases as float)) = 0 then 0
		else
		(((sum(cast(total_deaths as float)))/ (sum(cast(total_cases as float)))) )* 100
	end as DeathRate
from PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
group by date
ORDER BY 1,2

-- Total Number of cases, Total Deaths and Death Rate in the whole world


Select sum(cast(new_cases as float)) as TotalCases, sum(cast(new_deaths as float)) as TotalDeaths,
	case
		when 
		sum(cast(new_cases as float)) = 0 then 0
		else
		(((sum(cast(new_deaths as float)))/ (sum(cast(new_cases as float)))) )* 100
	end as DeathRate
from PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
--group by date
ORDER BY 1,2

 --Total Population VS People vaccinated
 --Rolling the number of people vaccinated for each day unto the next day

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population
from PortfolioProject..CovidDeath dea
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- USE CTE
with popvsvac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population
from PortfolioProject..CovidDeath dea
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated/population) * 100
from popvsvac


-- Creating a Temp Table
Drop table if exists #PercentPopulationVaccinated

Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population
from PortfolioProject..CovidDeath dea
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/population) * 100
from #PercentPopulationVaccinated


-- Creating View

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population
from PortfolioProject..CovidDeath dea
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3



select *
from PercentPopulationVaccinated


create view ContinentalDeath 
as
SELECT
    continent, sum(new_deaths) as TotalDeaths
FROM
    PortfolioProject..CovidDeath
where continent is not null
Group by continent
--ORDER BY 2 desc

select * 
from ContinentalDeath