--SELECT *
--FROM Coviddeaths
--ORDER BY 3,4

select Location, date, total_cases, total_deaths, population
From Coviddeaths
Order by 1,2


--looking at total cases vs Total deaths
--show likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
From Coviddeaths
where location like '%states%'
Order by 1,2


-- Looking at total cases vs Population
--shows what percentage of pulation got covid
select Location, date, total_cases, population, (total_cases/population)* 100 as percentagePopulationInfected
From Coviddeaths 
where location like '%states%'
Order by 1,2 

--Looking at countries with highest infection rate compared to populations
select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))* 100 as PerecentPopulationinfected
From Coviddeaths
--where location like '%states%'
Group by location, population
order by PerecentPopulationinfected desc

-- Let's break things down by continent

select continent, MAX(total_deaths) as Totaldeathcount
From Coviddeaths
--where location like '%states%'
where continent is null
Group by continent
order by Totaldeathcount desc

--showing the continent with the highest death count per population

select continent, MAX(total_deaths) as Totaldeathcount
From Coviddeaths
--where location like '%states%'
where continent is null
Group by continent
order by Totaldeathcount desc

-- Showing Countries with highest death count per population
select Location, MAX(total_deaths) as Totaldeathcount
From Coviddeaths
--where location like '%states%'
where continent is not null
Group by location
order by Totaldeathcount desc


-- Global numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
--total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
From Coviddeaths
--where location like '%states%'
where continent is not null
--Group by date
Order by 1,2


-- looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Coviddeaths dea
Join covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

--use CTE

With PopvsVac (continent, location, Date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Coviddeaths dea
Join covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--temp tables

create Table #percenPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percenPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Coviddeaths dea
Join covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3

select *,(RollingPeopleVaccinated/population)*100
From #percenPopulationVaccinated


--creating view to store data for later visualizations

create view percenPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Coviddeaths dea
Join covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3


select *
From percenPopulationVaccinated