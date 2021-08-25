/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From [Portfolio Project]..CovidDeath
Where continent is not null 
order by 3,4



-- 1. Getting relevant Data to start exploration

Select Location, date, total_cases, total_deaths, population
From [Portfolio Project]..CovidDeath
Where continent is not null 
order by 1,2


-- 2. Calcuting covid death percaentage based on total cases in India (~1.34%)

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From [Portfolio Project]..CovidDeath
Where location like '%ndia%'
and continent is not null 
order by 1,2


-- 3. Calculating countries with max deaths due to covid

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeath
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- 4. Calculating Death rate due to covid in countries based on population

Select Location, Population, MAX(total_cases) as Max_cases, MAX(total_deaths) as Max_deaths , Avg((total_cases/population))*100 as Avg_death_rate
From [Portfolio Project]..CovidDeath
Group by Location, Population
order by Avg_death_rate desc


-- 5. Calcuting covid infection rate in India (~2.35%)

Select Location, date, Population, total_cases, (total_cases/population)*100 as Infection_rate
From [Portfolio Project]..CovidDeath
Where location like '%india%'
order by 1,2


-- 6. Countries with Highest Infection Rate compared to population

Select Location, Population, MAX(total_cases) as Highest_cases,  Max((total_cases/population))*100 as Infection_rate
From [Portfolio Project]..CovidDeath
Group by Location, Population
order by Infection_rate desc


-- 7. Contintents with the highest death count compared to population

Select continent, MAX(cast(Total_deaths as int)) as Total_Death_Count
From [Portfolio Project]..CovidDeath
Where continent is not null 
Group by continent
order by Total_Death_Count desc


-- 8. GLOBAL Death_rate

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeath
where continent is not null 


-- 9. Percentage of Population that has recieved at least 1 Covid Vaccine in India

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, (SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date))/dea.population*100 as Total_People_Vaccinated
From [Portfolio Project]..CovidDeath dea
Join [Portfolio Project]..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%india%'
order by 2,3


--10. Using CTE to perform Calculation on Partition By in previous query

With PopVacc (Continent, Location, Date, Population, New_Vaccinations, Total_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, (SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date))/dea.population*100 as Total_People_Vaccinated
From [Portfolio Project]..CovidDeath dea
Join [Portfolio Project]..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%india%'
--order by 2,3
)
Select * from PopVacc


-- 11. -- Using Temporary Table to perform Calculation on Partition By in previous query

DROP Table if exists Total_People_Vaccinated
Create Table Total_People_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Total_People_Vaccinated float
)

Insert into Total_People_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, (SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date))/dea.population*100 as Total_People_Vaccinated
From [Portfolio Project]..CovidDeath dea
Join [Portfolio Project]..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%india%'
order by 2,3

Select * From Total_People_Vaccinated


-- 12. Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, (SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date))/dea.population*100 as Total_People_Vaccinated
From [Portfolio Project]..CovidDeath dea
Join [Portfolio Project]..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%india%'

Drop View PercentPopulationVaccinated
Select * from PercentPopulationVaccinated

