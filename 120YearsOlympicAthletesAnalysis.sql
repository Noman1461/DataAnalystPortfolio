-- TASK 13: Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
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
