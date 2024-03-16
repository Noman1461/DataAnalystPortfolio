------------------------------This is my 3rd Project-----------------------------
----------This is Semi-Guided Project, I try to solve the query on my own first---------
----------------------But if I couldn't then I would take help---------------------------
-----------------------This project has a total of 20 tasks----------------------------
--completed tasks 14/20
-----------------------------------------------------------------------------------------

--The dataset is taken from kaggle called: "120 years of Olympics History"
--Link to dataset: https://www.kaggle.com/datasets/heesoo37/120-years-of-olympic-history-athletes-and-results
--Blog used: https://techtfq.com/blog/practice-writing-sql-queries-using-real-dataset
--Data set have two csv files “athlete_events.csv“ and “noc_regions.csv“. 
--The files are converted into XLSX and then imported into Microsoft SQL Server.
--into two separates tables athlete_events renamed as OLYMPICS_HISTORY oh
-- and noc_regions renamed as OLYMPICS_HISTORY_NOC_REGIONS nr
 
----------------------------------------------------------------------------------------

--Task 1:How many olympics games have been held?

select count(distinct(Games)) as TotalNumberOfOlympics
from OLYMPICS_HISTORY

----------------------------------------------------------------------------------------

--Task 2: List down all Olympics games held so far.

select distinct(Games) as OlympicsGamesHeld
from OLYMPICS_HISTORY
order by OlympicsGamesHeld

----------------------------------------------------------------------------------------

--Task 3: Mention the total no of nations who participated in each olympics game?

select Year, count(distinct(NOC)) as TotalNumberOfTeamParticipated
from OLYMPICS_HISTORY
GROUP by Year
order by Year

-- The above query was my solution there was an issue, for most of the cases 
--it gives correct total no of nations participated
-- except for some,i found out that the above query also count the null values also.
-- this problem can be avoid using the count(1) and creating a CTE.

with tot_countries as (
select games, nr.region
from OLYMPICS_HISTORY oh
join OLYMPICS_HISTORY_NOC_REGIONS nr on oh.NOC = nr.NOC
group by Games, nr.region
)

select games, count(1) as TeamsParticipated
from tot_countries
group by games

------------------------------------------------------------------------------------

--Task 4: Which year saw the highest and lowest no of countries participating in olympics

with tot_countries as (
select games, nr.region
from OLYMPICS_HISTORY oh
join OLYMPICS_HISTORY_NOC_REGIONS nr on oh.NOC = nr.NOC
group by Games, nr.region
), counted_countries as (
select games, COUNt(1) as CountriesParticipate
from tot_countries
group by Games
)

select distinct
CONCAT(First_Value(Games) over (order by CountriesParticipate) , '-', 
FIRST_VALUE(CountriesParticipate) over (order by CountriesParticipate )) as lowestParticipation
,concat(first_value(games) over (order by CountriesParticipate desc),'-',
first_value(CountriesParticipate) over (order by CountriesParticipate DESC)) AS HighestCountriesParticipate

/* OUTPUT:
lowestParticipation | HighestCountriesParticipate
1896 Summer-12      | 2016 Summer-204
*/

-------------------------------------------------------------------------------
--Task 5: Which nation has participated in all of the olympic games?
-- i first count the total numbers of Olympics games held so far i.e 51

with tot_countries as (
select team, games, nr.region
from OLYMPICS_HISTORY oh
join OLYMPICS_HISTORY_NOC_REGIONS nr on oh.NOC = nr.NOC
group by Team, Games, nr.region
)
,no_of_olympics as (
-- in this CTE i pull out the teams and the total number of participation 
-- for all the countries and then in the main query just pull result for 51 Participication
select team,count(distinct(games)) as TotalOlympics
from tot_countries
group by team
)



SELECT *
FROM no_of_olympics
where TotalOlympics = '51'


-----------------------------------------------------------------------------------------
--Task 6: Identify the sport which was played in all summer olympics.
-- find the games that has been played in all summer olympics
-- step1: find the count of summer olympics
-- step2: find the countof each olympic games 
-- step3: compare 1 & 2 and find out which sports is equal to the count of summer olympics

with totalSummer as (
select count(distinct(Games)) as summergames --29 olympic games were held in summer
from OLYMPICS_HISTORY
where Season = 'Summer'
)
, SummerGames as (
-- return the count of each olympic games held in summer
select Distinct(Sport), Games
from OLYMPICS_HISTORY
where Season = 'Summer'
)
,SummerCount as (
select sport, count(Games) as Sportcount
from SummerGames
group by Sport
) 

select *
from SummerCount
WHERE Sportcount = '29'  -- beacause we have to find the number of sports that appear in all olympic games i,e 29 games
------------------------------------------------------------------------------------------
--Task 7: Which Sports were just played only once in the olympics

--select top(10)*
--from OLYMPICS_HISTORY


select distinct(sport), Games --<-- run this query to get the distinct sport and years
from OLYMPICS_HISTORY 
where Season = 'Summer'  --<-- then put the same qery in CTE's
order by Games -- removing order by class because can't sort in the CTE

--step 1: give the count of all summer olympics sports

with summerGames as (
select distinct(sport), Games 
from OLYMPICS_HISTORY
where Season = 'Summer'
--order by Games  can't use order by in the cte 
--because cte is to create temporary named result set.
)
, SummerCount as (
select sport, count(Games) as Sportcount -- gives the count of each sport
from summerGames
group by Sport
)

select *
from SummerCount
where Sportcount = 1 --b/c we pull games that are happen only one.

------------------------------------------------------------------------
-- Task 8: Fetch the total no of sports played in each olympic games.
-- take the number of distinct sports played at each olympic game
-- then count all the sport for each year, we can use the goup by clause
-- column needed are Sport,Games, Season

--select top(20)*
--from OLYMPICS_HISTORY

with gamesEachYear as (
select distinct(Sport) as sports, Games
from OLYMPICS_HISTORY
--order by Games
)
, CountGames as (
select  Games, count(sports) as SportCountEachYear
from gamesEachYear
group by Games

)

select *
from CountGames
order by Games
---------------------------------------------------------------------
-- Task 9: Fetch oldest athletes to win a gold medal
-- pull out all information of athelets that are oldest
-- where medal = 'gold'
-- we can use order by on "age"

select *
from OLYMPICS_HISTORY
where Medal = 'Gold' and age = '64'

-- the above was my solution, i did try to solve using CTE
-- but we can't use order by in the CTE. So, i just manually check 
-- the oldest person who won the gold medal and then put that in the where condition
-- i didn't know about the rank() function until now.

with temp as ( 
select ID, Name, Sex,age, Team, Games, Sport, Medal
from OLYMPICS_HISTORY
where cast(age as nvarchar) <> 'NA' -- excluding the data where the age is not availible
), ranking as (
select *, rank() over (order by age desc) as rnk --rank() function that will order by age descending
from temp
where Medal = 'Gold'
)
select *
from ranking
where rnk = 1 -- only pull those data where the rnk is 1. i.e the oldest
------------------------------------------------------
-- Task 10: Find the Ratio of male and female athletes participated in all olympic games.
-- table needed OLYMPICS_HISTORY
-- column needed 'sex'
-- step 1: count the number of males 'M' and females 'F'



with totalCount as (
select sex, count(1) as cnt
from OLYMPICS_HISTORY
group by sex)
,
ratio as (
select *, ROW_NUMBER() over (order by cnt) as rn
from totalCount
),
min_cnt as (
select *
from ratio
where rn = 1
), 
max_cnt as (
select *
from ratio
where rn = 2)

select CONCAT('1: ', round(min_cnt,2)/round(max_cnt,2)) as ratio
from max_cnt, min_cnt

---------------------------------------------------------------------
-- Task 11: Fetch the top 5 athletes who have won the most gold medals.
-- tables used OLYMPICS_HISTORY
-- columns can be ID, name, Team, Medal
-- step 1: count the total number of gold medal won by each person
-- step 2: create a sub CTE GoldCount which ranks the number of gold medal in descending
-- step 3: in the main query pull only those rows where rnk is less than 6.

with GoldMedal as (

select ID, Name, Team, Medal, count(1) as GoldM
from OLYMPICS_HISTORY
where Medal = 'Gold'
group by ID, Name, Team, Medal
)
, GoldCount as (
select *,dense_rank() over (order by GoldM desc) as rnk
from GoldMedal

)

select *
from GoldCount
where rnk <= 5
------------------------------------------------------------
-- Task 12: Fetch the top 5 athletes who have won the most medals
-- table need OLYMPICS_HISTORY
-- columns required are id, name, sport, medal
-- where medal are Gold, Silver, Bronze

with totalMedalSeparate as (
select name,team, count(1) as medalsEarned
from OLYMPICS_HISTORY
where medal in ('Gold','Silver','Bronze')
group by name,Team

), ranking as (
select *, DENSE_RANK() over (order by medalsEarned desc) as rnk
from totalMedalSeparate

)
select *
from ranking
where rnk < 6
--------------------------------------------------------------------------
-- task 13:Fetch the top 5 most successful countries in olympics. 
--Success is defined by no of medals won.
-- table needed  OLYMPICS_HISTORY oh && OLYMPICS_HISTORY_NOC_REGIONS nr
-- column need team, medal , noc (need to join the tables)

with countriesmedal as (
select team, count(1) as medalEarned
from OLYMPICS_HISTORY oh
join OLYMPICS_HISTORY_NOC_REGIONS nr
on oh.NOC = nr.NOC
where oh.Medal in ('Gold', 'Silver', 'Bronze')
group by team
), ranking as (
select *, DENSE_RANK() over (order by medalEarned desc) as rnk
from countriesmedal
)

select *
from ranking
where rnk < 6
----------------------------------------------------------------------
-- TASK 14: Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
-- TABLE NEEDED OLYMPICS_HISTORY oh && OLYMPICS_HISTORY_NOC_REGIONS nr
-- columnn require id, name, team , noc (joining tables), sports, medal, pull those data where Medal <> 'NA'
-- here we would need the PIVOT FUNCTION i.e converting rows into columns 


/* the syntax of PIVOT is write (base query) as BaseTable ,then PIVOT ( pivot query) as PivotTable

SELECT <non-pivoted column>,  

    [pivoted column1], [pivoted column2], ..., 
 
FROM  
    (SELECT <non-pivoted column>,  
        [pivoted column],  
        <value column>  
    FROM <source table>  

    ) AS <alias for the source subquery>  
PIVOT  
( <aggregate function>(<value column>)  FOR  
[<pivoted column>] IN ( [pivoted column1], [pivoted column2], ..., [pivoted columnN] )  
) AS <alias for the pivot table>
*/

--select country, coalesce(Gold,0) as Gold, , COALESCE(Silver, 0) AS Silver
--, COALESCE(Bronze, 0) AS Bronze
--from (
--SELECT nr.region as country, Medal, count(1) as TotalMedal
--FROM OLYMPICS_HISTORY oh 
--join OLYMPICS_HISTORY_NOC_REGIONS nr
--on oh.NOC = nr.NOC
--where Medal <> 'NA'
--group by nr.region, Medal) as basequery

--PIVOT (
--sum(TotalMedal)
--FOR Medal in ('Bronze', 'Gold', 'Silver')
--) as PivotTable
--order by Gold desc, Silver desc, Bronze desc 


-- Similar to enabling the tablefunc extension, 
-- SQL Server has built-in pivot functionality.


SELECT Country
, COALESCE(Gold, 0) AS Gold  -- the coalesce function will convert "null" to 0. 
, COALESCE(Silver, 0) AS Silver
, COALESCE(Bronze, 0) AS Bronze
FROM (
  SELECT nr.region AS Country, Medal
  , COUNT(*) AS TotalMedals
  FROM olympics_history oh
  JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
  WHERE medal <> 'NA'
  GROUP BY nr.region, Medal
) AS BaseTable
PIVOT
(
  SUM(TotalMedals) FOR Medal IN ([Bronze], [Gold], [Silver])
) AS PivotTable
ORDER BY Gold DESC, Silver DESC, Bronze DESC; 

------------------------------------------------------------------
-- Task 15: List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
-- tables needed OLYMPICS_HISTORY oh , OLYMPICS_HISTORY_NOC_REGIONS  nr
-- column needed nr.region, Games, Medal
-- will need to have a PIVOT
-- Step 1: pull medals for each games for each country i.e use filter where Medal <> 'NA'

select Country, 
GameYear,
coalesce(Gold,0) as Gold, 
coalesce(Silver,0) as Silver,
coalesce(Bronze,0) as Bronze
from (
select nr.region as Country, Games as GameYear, Medal, count(1) as MedalCount
from OLYMPICS_HISTORY oh
join OLYMPICS_HISTORY_NOC_REGIONS nr
on oh.NOC = nr.NOC
where Medal <> 'NA'
group by nr.region, Games, Medal
) as BaseTable

PIVOT (
Sum(MedalCount) for Medal in ([Gold],[Silver],[Bronze])
) as PivotTable

-----------------------------------------------------------------
-- Task 16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
-- tables needed OLYMPICS_HISTORY oh , OLYMPICS_HISTORY_NOC_REGIONS  nr
-- column needed nr.region, Games, Medal
-- step 1: pull out Gold, Silver

with temp as (
select Country, 
Games,
coalesce(Gold,0) as Gold,
coalesce(Silver,0) as Silver,
coalesce(Bronze,0) as Bronze
from 
(
select nr.region as Country, Games, Medal, count(1) as MedalCount
from OLYMPICS_HISTORY oh
join OLYMPICS_HISTORY_NOC_REGIONS nr
on oh.NOC = nr.NOC
where medal <> 'NA'
group by nr.region, Games, Medal
) as BaseTable

pivot (
sum(MedalCount) for medal in ([Gold],[Silver],[Bronze])
) as PivotTable

)

select distinct Games, 
concat(first_value(Country) over (partition by Games order by Gold desc),'-',FIRST_VALUE(Gold) over (partition by Games order by Gold desc)) as max_gold
,concat(first_value(Country) over (partition by Games order by Silver desc),'-',FIRST_VALUE(Silver) over (partition by Games order by Silver desc)) as max_silver
,concat(first_value(Country) over (Partition by Games order by Bronze desc),'-',FIRST_VALUE(Bronze) over (partition by Games order by Bronze desc)) as max_bronze
from temp
order by Games
