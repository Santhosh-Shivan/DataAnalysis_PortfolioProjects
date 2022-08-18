Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3, 4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you get covid in your country
Select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

-- Looking at Total Cases vs Population

Select location, date, total_cases,  population, (total_cases/population)*100 as CovidPercentage
From PortfolioProject..CovidDeaths
--where location like '%india%'
order by 1,2

-- Looking at countries with highest infection rate relative to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CovidPercentage
From PortfolioProject..CovidDeaths
--where location like '%india%'
group by location, population
order by CovidPercentage desc

-- Showing Countries with Highest Death Count per population

Select location, population, MAX(cast(total_deaths as int)) as TotalDeaths, MAX(cast(total_deaths as int)/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by location, population
order by DeathPercentage desc

-- Continent

Select location, population, MAX(cast(total_deaths as int)) as TotalDeaths, MAX(cast(total_deaths as int)/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is null
group by location, population
order by DeathPercentage desc

Select continent,  MAX(cast(total_deaths as int)) as TotalDeaths, MAX(cast(total_deaths as int)/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by DeathPercentage desc


-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
--group by date
order by 1




-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- Creating View to store data for visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated
