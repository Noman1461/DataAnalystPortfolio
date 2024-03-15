-- New cases and new deaths
--show what percentages of people got Covid

select location, date, population,total_cases,new_cases,new_deaths, (total_cases/population)*100 as casesPercentage
from Deaths
where location like '%states%'

select location, population, max(total_cases) as Max_Cases, (max(total_cases)/population)*100 MaxInfectedPercentage
from Deaths
group by location,population
order by MaxInfectedPercentage desc


/*MAX DEATH PERCENTAGE BY COUNTRY*/

select location, max(cast((total_deaths) as int)) as TotalDeath
from Deaths
where continent is not null and location like 'Pa%'
group by location
order by TotalDeath desc


/*GROUP BY CONTINENT w.r.t deathsCount*/

select location, max(cast((total_deaths) as int)) TotalDeath
from Deaths
where continent is null
group by location

select location, max(cast((total_deaths) as int)) TotalDeath
from Deaths
where location = 'United States'
group by location


/*Now jOINing both death and vaccination table based on location,date*/
select *
from Death dea
join Vaccination vac
on dea.location = vac.location
and dea.date = vac.date
order by location, date

--Looking at the total population vs Vaccination 
-- HINT: The number of column shouldn't be reduced and don't use Group By
select dea.location, dea.date, vac.new_vaccinations
, sum(vac.new_vaccinations) over(partition by(vac.new_vaccinations)
from Death dea
join Vaccination vac
on dea.location = vac.location
and dea.date = vac.date
order by location, date

----------------------------------------------------------------------------

-- Selecting columns from the Deaths (dea) and Vaccination (vac) tables
SELECT 
    dea.location, -- Selecting the location from Deaths table
    dea.date, -- Selecting the date from Deaths table
    dea.population, -- Selecting the population from Deaths table
    CAST(vac.new_vaccinations AS float) AS New_Vaccination, -- Selecting new_vaccinations from Vaccination table and casting it as float

    -- Calculating the cumulative sum of new_vaccinations over each partition of location and ordering by location and date
    SUM(CAST(new_vaccinations AS float)) OVER(PARTITION BY vac.location ORDER BY dea.location, dea.date) AS SumOfVaccination

-- Joining Deaths and Vaccination tables on location and date columns
FROM 
    Deaths dea
JOIN 
    Vaccination vac ON dea.location = vac.location AND dea.date = vac.date

-- Filtering records where continent is not null and location is Pakistan
WHERE 
    dea.continent IS NOT NULL
    AND dea.location = 'Pakistan';

-------------------------------------------------------------------------------------------

-- Joining Deaths and Vaccination table on Location, and date

select *
from Deaths dea
join Vaccination vac
on dea.location = vac.location
and dea.date = vac.date

-- Looking at total people vaccinated v/s total population



WITH PopVsVac (location, date, population, Daily_Vaccination, TotalVaccination) as
(
Select dea.location,dea.date, dea.population, cast(vac.new_vaccinations as float) as New_Vaccination
, sum(cast(new_vaccinations as float)) over(partition by vac.location order by dea.location,dea.date) as SumOfVaccination
from Deaths dea
join Vaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and dea.location = 'Pakistan'
)
select *, (TotalVaccination/population)*100 as PercentageVaccinated
from PopVsVac