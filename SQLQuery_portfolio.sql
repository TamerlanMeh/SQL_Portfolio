


select*
From Portfolio_project..CovidDeaths$
where continent is not null
--Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_project.dbo.CovidDeaths$
where continent is not null
order by 1,2

-- Looking at Total cases vs Total deaths
-- Here it shows likelyhood of death from covid for given timeline in Azerbaijan

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from Portfolio_project.dbo.CovidDeaths$
where location like '%Azerbaijan%'
order by 1,2


--Looking at total cases vs population
--It shows portion of population got infected

select location, date, total_cases, new_cases, population, (total_cases/population)*100 as infection_percentage
from Portfolio_project.dbo.CovidDeaths$
where location like '%Azerbaijan%'
order by 1,2


-- Showing the countries with the highest percentage of population got infected

select location, population, Max(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as infection_percentage
from Portfolio_project.dbo.CovidDeaths$
where continent is not null
Group by location, population
order by infection_percentage Desc


--Showing the countries with the highest death count 

Select location, max(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_project..CovidDeaths$
where continent is not null
Group by location
order by TotalDeathCount desc



--Showing the continents with highest death count

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio_project..CovidDeaths$
WHERE continent IS NULL
  AND location NOT IN ('International', 'World')
GROUP BY location
ORDER BY TotalDeathCount DESC


--Showing the countriest with the highest death rate in percentage

SELECT location, MAX(CAST(total_deaths AS DECIMAL) / CAST(population AS DECIMAL) * 100) AS HighestDeathRate
FROM Portfolio_project.dbo.CovidDeaths$
Where location NOT IN ('International', 'World')
GROUP BY location
ORDER BY HighestDeathRate DESC


-- Global numbers


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio_project..CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--Looking at total population vs vaccination
--First starting with rolling people vaccinated by date

Select Death.continent, Death.location, Death.date, Death.population, Vaccin.new_vaccinations, 
Sum(Cast(Vaccin.new_vaccinations as int)) over (partition by Death.location order by Death.date ) as RollingPeopleVaccinated
From Portfolio_project..CovidDeaths$ Death 
Join Portfolio_project..CovidVaccinations$  Vaccin
	on Death.location = Vaccin.location
	and Death.date = Vaccin.date
	Where Death.continent is not null
	Order by 2,3

-- There are two ways to find out vaccination rate. 
-- Let's try using CTE first

With  PopvsVac ( continent, location, date, population, RollingPeopleVaccinated, new_vaccinations)
AS
( 
Select Death.continent, Death.location, Death.date, Death.population, Vaccin.new_vaccinations, 
Sum(Cast(Vaccin.new_vaccinations as int)) over (partition by Death.location order by Death.date ) as RollingPeopleVaccinated
From Portfolio_project..CovidDeaths$ Death 
Join Portfolio_project..CovidVaccinations$  Vaccin
	on Death.location = Vaccin.location
	and Death.date = Vaccin.date
	Where Death.continent is not null
	)

Select*, (RollingPeopleVaccinated/population)*100 as Vaccinationrate
From PopvsVac


-- Let's try doing same using TEMP Table
Drop Table If Exists #Percent_Population_Vaccinated

Create Table #Percent_Population_Vaccinated 
( continent nvarchar(255), location nvarchar(255), date datetime, population numeric, RollingPeopleVaccinated numeric, new_vaccinations numeric)

Insert into #Percent_Population_Vaccinated
Select Death.continent, Death.location, Death.date, Death.population, Vaccin.new_vaccinations, 
Sum(Cast(Vaccin.new_vaccinations as int)) over (partition by Death.location order by Death.date ) as RollingPeopleVaccinated
From Portfolio_project..CovidDeaths$ Death 
Join Portfolio_project..CovidVaccinations$  Vaccin
	on Death.location = Vaccin.location
	and Death.date = Vaccin.date
	Where Death.continent is not null

Select*, (RollingPeopleVaccinated/population)*100 as Vaccinationrate
From #Percent_Population_Vaccinated



--Creating View to store data for later visualization

Create View Percent_Population_Vaccinated 
as
Select Death.continent, Death.location, Death.date, Death.population, Vaccin.new_vaccinations, 
Sum(Cast(Vaccin.new_vaccinations as int)) over (partition by Death.location order by Death.date ) as RollingPeopleVaccinated
From Portfolio_project..CovidDeaths$ Death 
Join Portfolio_project..CovidVaccinations$  Vaccin
	on Death.location = Vaccin.location
	and Death.date = Vaccin.date
	Where Death.continent is not null

Select*
From Percent_Population_Vaccinated