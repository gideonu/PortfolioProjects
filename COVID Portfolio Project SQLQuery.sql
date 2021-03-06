Select *
From PortfolioProjects..CovidDeaths
Where Continent is not Null
Order By 3,4

--Select *
--From PortfolioProjects..CovidVaccinations
--Order By 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths
Where Continent is not Null
Order by 1,2

--Total Cases Vs Total Deaths
--DeathPercentage shows the likelihood someone dying from COVID-19

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercntage
From PortfolioProjects..CovidDeaths
Where Location like '%Nigeria%' And 
 Continent is not Null
Order by 1,2

--Total cases Vs Population
--Percentage of Population who got Covid-19

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
Where Location like '%states%' And 
 Continent is not Null
Order by 1,2



-- Countries With the Highest Infection Rate Compare to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
--Where Location like '%states%'
Where Continent is not Null
Group by Location, Population 
Order by PercentPopulationInfected Desc


-- Countries With the Highest Death Count per Population

Select Location, MAX(Cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where Location like '%states%'
Where Continent is not Null
Group by Location 
Order by TotalDeathCount Desc

--Breaking Things Down by Continents
-- Showing the Continents with the Highest Death Count per Population

Select continent, MAX(Cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where Location like '%states%'
Where Continent is not Null
Group by continent
Order by TotalDeathCount Desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
Where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
