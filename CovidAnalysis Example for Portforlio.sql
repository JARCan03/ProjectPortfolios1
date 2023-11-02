	--Select *
	-- From dbo.CovidVaccinations$
	-- order by 3, 4
	 

	--Select *
	-- From COVIDCASES.dbo.CovidDeaths$
	-- order by 3, 4


	---Select [location], [date], total_tests,new_cases, total_deaths, [population]
	-- From dbo.CovidDeaths$
	-- order by 1, 2

--total cases vs total deaths in USA for example

Select [location], [date], total_cases,new_cases, total_deaths, [population],  (total_deaths/total_cases)*100 as DeathPercentage
	 From dbo.CovidDeaths$
	 Where Location like  '%states%'
	 order by 1, 2

	 
---Total Cases vs total population
Select continent, [date],total_cases,new_cases, total_deaths, [population],  (total_deaths/total_cases)*100 as DeathPercentage
	 From dbo.CovidDeaths$
	 Where continent = 'Asia'
	 order by 1, 2

--- Continents with Highest Infection Rate compared to population
Select Continent, MAX(total_cases) as HighestInfectionCount, [population],  MAX((total_cases/population))*100 as InfectionPercentage
	 From dbo.CovidDeaths$
	 Where continent = 'Asia'
	 Group by continent, total_cases, [population]
	 order by InfectionPercentage desc

--Location with Highest IR compared to popu
Select [Location], [population], MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
--MAX((total_cases/population))*100 as InfectionPercentage
	 From dbo.CovidDeaths$
	 Group by [Location], [population]
	 Order by PercentPopulationInfected desc

--Countries with highest death count per population
Select continent as Continent, MAX(cast(total_deaths as int)) as [Total Death Count]
	 From dbo.CovidDeaths$
	 where continent is not null
	 Group by [continent] 
	 Order by [Total Death Count] desc
	--Select *
	-- From COVIDCASES.dbo.CovidDeaths$
	-- where continent is not null
	-- order by 3, 4

--Showing continent with highest death count
Select continent as Continent, MAX(cast(total_deaths as int)) as [Total Death Count]
	 From dbo.CovidDeaths$
	 where continent is not null
	 Group by [continent] 
	 Order by [Total Death Count] desc

--Global Numbers
Select SUM(new_cases) as [total cases], SUM(cast(new_deaths as int)) as [total deaths], SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
	 From dbo.CovidDeaths$
	 where continent is not null--[total cases], [total deaths], DeathPercentage is not null
	--group by [date]
	 order by 1, 2


	---Total population vs vaccination

Select *
From dbo.CovidDeaths$ as DEA
Join dbo.CovidVaccinations$ as VAC
 On DEA.location = VAC.location
 and DEA.date = VAC.date

 Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
 , SUM(convert (int, VAC.new_vaccinations)) OVER (Partition by DEA.location Order by DEA.Location, DEA.date) as [Rolling people Vaccinated]
From dbo.CovidDeaths$ as DEA
Join dbo.CovidVaccinations$ as VAC
 On DEA.location = VAC.location
 and DEA.date = VAC.date
 Where DEA.continent is not null
 order by 2, 3
 
--Create CTE
With PopVsVac (continent, location, date, population, [Rolling people Vaccinated],new_vaccinations)
as
(
Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
 , SUM(convert (int, VAC.new_vaccinations)) OVER (Partition by DEA.location Order by DEA.Location, DEA.date) as [Rolling people Vaccinated]
From dbo.CovidDeaths$ as DEA
Join dbo.CovidVaccinations$ as VAC
 On DEA.location = VAC.location
 and DEA.date = VAC.date
 Where DEA.continent is not null
 )

 SELECT *, ([Rolling people Vaccinated]/population)*100 as VacPerPopPercentage
 From PopVsVac

 ---TempTable
 DROP Table if exists #PercPopVaccinated
 Create Table #PercPopVaccinated
 (
 [continent] nvarchar(255),
 [location] nvarchar(255),
 date datetime,
 Population numeric,
 New_vaccinations numeric,
 [Rolling people Vaccinated] numeric
 )
Insert into #PercPopVaccinated
Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
 , SUM(convert (int, VAC.new_vaccinations)) OVER (Partition by DEA.location Order by DEA.Location, DEA.date) as [Rolling people Vaccinated]
From dbo.CovidDeaths$ as DEA
Join dbo.CovidVaccinations$ as VAC
 On DEA.location = VAC.location
 and DEA.date = VAC.date
--- Where DEA.continent is not null

--Create view to store data for visualization
Create view PercPopVaccinated as
Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
 , SUM(convert (int, VAC.new_vaccinations)) OVER (Partition by DEA.location Order by DEA.Location, DEA.date) as [Rolling people Vaccinated]
From dbo.CovidDeaths$ as DEA
Join dbo.CovidVaccinations$ as VAC
 On DEA.location = VAC.location
 and DEA.date = VAC.date
 Where DEA.continent is not null
 --Order by 2,3

 Select *
 From PercPopVaccinated	