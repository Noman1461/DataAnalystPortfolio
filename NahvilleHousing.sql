/*This is my 2nd project in SQL, Here I have NashilleHousing data. 
This project has a lot of data cleaning.*/


select *
from NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------

-- Task 1: Standarize Time Format

select SaleDate, CONVERT(Date, SaleDate)
from NashvilleHousing    /*<-The query gives me 2 col. to one SaleDate in datetime format, another unnamed col. in time format*/

UPDATE NashvilleHousing
SET SaleDate = convert(Date, SaleDate) /*<-- i decided to update the table by changing the SaleDate col. The query executed succesfully 
                                              but it didn't update the table*/

SELECT SaleDate
from NashvilleHousing    /*<- Till now the SaleDate Column is still in Datetime format, despite the update.*/

/*Another thing that we can do alter the SaleDate Format*/

ALTER table NashvilleHousing
ADD SalesDateConverted Date;   /*<-- I add a new col.SalesDateConverted of type Date */

Update NashvilleHousing
set SalesDateConverted = convert(date, SaleDate) /*<--Then i set the table values from SaleDate and convert it's format to 'date' */

select top (100) *
from NashvilleHousing   /*<-- then i select the top 100 rows to look into the table and it works (i.e i new col. added named SalesDateConverted
                               with the type Date*/

---------------------------------------------------------------------------
-- Task 2: Populate Property Address data
select PropertyAddress
from NashvilleHousing 
-- I look for null values and realize some of the propertyAddress Value is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b    /*<-- Did a self join where parcel Id is same 
                                   and the Unique Id is not same */
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null /* only pull those data where PropertAddress is Null*/
/*The above query help me look for the null values and 
create a new column based on ParcelID and UniqueId*/

/*But we want to update the existing Update Column*/
update a   -- we update the table NashvilleHousing a
set PropertyAddress =  ISNULL(a.propertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b    /*<-- Did a self join where parcel Id is same and the Unique Id is not same */
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
/*The above query update the table Property column and successfully populate all the values*/

/*Which I confirm using the below query*/

select PropertyAddress
from NashvilleHousing
where PropertyAddress is null

-------------------------------------------------------------------------------------------
--Task 3(a): Breaking out Propertyaddress into individual columns (address, city, state)

select substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)as Houseaddress
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as CityAddress
from NashvilleHousing  /*<- I have break the address based on the comma delimiter

Now i have to create two new columns in one col. HouseAddress and another CityAddress */

alter table NashvilleHousing
add Houseaddress nvarchar(255); --First column created of type nvarchar(255)

-- now i just have to populate the Houseaddress column using the delimiter ','
update NashvilleHousing
set Houseaddress = substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 


--second column to create Ctyaddress 
alter table NashvilleHousing
add Ctyaddress nvarchar(255);

-- now populate the column using 
--substring(colname, location to delimit, endof of word) %to create a smaller string of propertyAddress
--, charindex() this will give me the number where the ',' is and i want to exclude the comma so '+1'
--, and len() function to run the substring function untill end

update NashvilleHousing
set Ctyaddress = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

------------------------------------------------------
--Task 3(b): Breaking the OwnerAddress with PARSEName 

--parsename only work with '.' ( and it starts from the backwards)
-- so we have to replace our delimiter to '.'
-- using replace(ColumnName,delimiterToBeReplaced, ReplaceWith)

select PARSEName(replace(OwnerAddress,',','.'),3) as OwnerHouse
,PARSEName(replace(OwnerAddress,',','.'),2) as OwnerCity
,PARSEName(replace(OwnerAddress,',','.'),1) as OwnerState
from NashvilleHousing

/*OUTPUT

OwnerHouse     |  OwnerCity | OwnerState

1468  TYNE BLVD |	 NASHVILLE	| TN
4635  MOUNTAINVIEW DR	| NASHVILLE	| TN
1466  TYNE BLVD	 NASHVILLE	 TN
1427  TYNE BLVD	 NASHVILLE	 TN
1431  TYNE BLVD	 NASHVILLE	 TN
1240  SAXON DR	 NASHVILLE	 TN
1238  SAXON DR	 NASHVILLE	 TN */

/*Then I add 3 new Columns using alter table query (similar in task 3(a))
and update the table using UPDATE SET commands
but to avoid the document to be too long i am not including here*/

---------------------------------------------------------------------------------------------

--Task 4: Replace Y with Yes and N with No
--First count how many are Yes,No, Y, N

select SoldAsVacant, COUNT(SoldAsVacant) as DisinctCount
from NashvilleHousing
GROUP BY SoldAsVacant

--OUTPUT
/*
SoldAsVacant | DistinctCount

N	| 399    --have to replace this with No
Yes	| 4623
Y	| 52     --have to replace this with Yes
No	| 51403*/

-- Then I update the Y and N to Yes and No respectively
-- using the case statements 

update NashvilleHousing
set SoldAsVacant = case
when SoldAsVacant = 'Y' THEN 'Yes'
when SoldAsVacant = 'N' THEN 'NO'
else SoldAsVacant
end

-- I again count the SoldAdVacant column Distinct Values and gives:
--OUTPUT
/*
SoldAsVacant | VacantCount

Yes	| 4675
No	| 51802
*/

-------------------------------------------------------------------------
-- Task 5: Removing Duplicates using CTEs

-- CREATING a CTE to do partition using the below columns and 
-- create a new column called ROWNUM
WITH RowNumCTE AS (
select *, ROW_NUMBER() over (partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference order by uniqueID) AS ROWNUM
from NashvilleHousing
--ORDER BY ROWNUM DESC
)

-- then i pull up only those values from column ROWNUM who are more than once i.e duplicates
SELECT *
FROM RowNumCTE
WHERE ROWNUM > 1  -- THERE ARE 104 duplicates rows 

-- using the below query i delete these duplicates

delete 
from RowNumCTE 
where ROWNUM > 1  -- and ofcourse you have to run this query with the CTE

-- i check again and found that all the duplicates were deleted successfully.

---------------------------------------------------------------------------------
-- task 6: delete unused columns

alter table NashvilleHousing
drop column SaleDate

---------------------------------------------------------------------------------------
                                      -- THE END