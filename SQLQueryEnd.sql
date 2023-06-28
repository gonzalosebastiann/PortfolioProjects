select *
from PortfolioProject..CovidDeaths$
order by 3, 4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3, 4

--select data we are going to be using

 select location, date, population, total_cases, new_cases, total_deaths, population
 from PortfolioProject..CovidDeaths$
 Order by 1, 2

 --Looking at total_cases vs total_deaths 
 --Show what % of the population got covid

 select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage 
 from PortfolioProject..CovidDeaths$
 --where location like '%states%'
 Order by 1, 2

 -- Looking at the countries with the highest infection rate compared to population

 select location, population, MAX(total_cases), MAX((total_cases/population)*100) as InfectedPercentage 
 from PortfolioProject..CovidDeaths$
 GROUP BY location, population
 Order by InfectedPercentage desc

 --Showing countries with highest death count per population

 select location, MAX(CAST(total_deaths as int)) as MaxTotalDeaths
 from PortfolioProject..CovidDeaths$
  Where continent is null
 Group by location


 --pt2

 Select SUM(MaxTotalDeaths) as TotalMaxDeaths
 From (
 select location, continent, MAX(CAST(total_deaths as int)) as MaxTotalDeaths
 from PortfolioProject..CovidDeaths$
-- Where continent like '%north%'
 Group by location, continent
 ) as MaxDeathsByCountry


 --Now by continents

  select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
 from PortfolioProject..CovidDeaths$
 Where continent is not null
 Group by continent
 Order by TotalDeathCount desc

 --pt2

 select *
from PortfolioProject..CovidDeaths$
order by 3, 4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3, 4

--select data we are going to be using

 select location, date, population, total_cases, new_cases, total_deaths, population
 from PortfolioProject..CovidDeaths$
 Order by 1, 2

 --Looking at total_cases vs total_deaths 
 --Show what % of the population got covid

 select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage 
 from PortfolioProject..CovidDeaths$
 --where location like '%states%'
 Order by 1, 2

 -- Looking at the countries with the highest infection rate compared to population

 select location, population, MAX(total_cases), MAX((total_cases/population)*100) as InfectedPercentage 
 from PortfolioProject..CovidDeaths$
 GROUP BY location, population
 Order by InfectedPercentage desc

 --Showing highest death count in each continent

  select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
 from PortfolioProject..CovidDeaths$
 Where continent is not null
 Group by continent
 Order by TotalDeathCount desc

 
 --Shows the sum of highest death count of each country per continent

 select location, MAX(CAST(total_deaths as int)) as MaxTotalDeaths
 from PortfolioProject..CovidDeaths$
 Where continent is null
 Group by location
 Order by 2 desc

 --pt2

 Select SUM(MaxTotalDeaths) as TotalMaxDeaths
 From (
 select location, continent, MAX(CAST(total_deaths as int)) as MaxTotalDeaths
 from PortfolioProject..CovidDeaths$
-- Where continent like '%north%'
 Group by location, continent
 ) as MaxDeathsByCountry

 -- GLOBAL NUMBERS

 select SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
 from PortfolioProject..CovidDeaths$
 Where continent is not null
-- Group by date
 Order by 1,2 

 --

 select date, new_cases, cast(new_deaths as int)
 from PortfolioProject..CovidDeaths$
 Where continent is not null
 Group by date, new_cases, new_deaths
 Order by 1 

 -- Looking at total population v new vaccination per day

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3

--Pt2. It adds up (partition by)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacc
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3

--CTE

With PopVsVacc (continent, location, date, population, new_vaccionations, RollingPeopleVacc)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacc 
from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3
)
Select * , (RollingPeopleVacc/population)*100
From PopVsVacc
Order by 2,3 

--Temp Table

Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVacc numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacc 
from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3

Select * , (RollingPeopleVacc/population)*100
From #PercentPopulationVaccinated
Order by 2,3 


--Temp Table(IF U WANT TO CHANGE SUM)

--Drop table if exists #PercentPopulationVaccinated at the start

--Creating view to store data for later visualizations

Create view PercentPopulationVaxx as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacc 
from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3

select*
from PercentPopulationVaxx


