/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [Row ID]
      ,[Order ID]
      ,[Order Date]
      ,[Ship Date]
      ,[Ship Mode]
      ,[Customer ID]
      ,[Customer Name]
      ,[Segment]
      ,[City]
      ,[State]
      ,[Country]
      ,[Postal Code]
      ,[Market]
      ,[Region]
      ,[Product ID]
      ,[Category]
      ,[Sub-Category]
      ,[Product Name]
      ,[Sales]
      ,[Quantity]
      ,[Discount]
      ,[Profit]
      ,[Shipping Cost]
      ,[Order Priority]
  FROM [Project4].[dbo].[SuperStore]



-- CROSS APPLY, stored procedure, pivot, string split function, function, Table valued function, do it also for lower upper functions USING THESE ONES
-- ALL FUNCTIONS FROM BOOK, PAGE AND FROM INTERNET AND LOOK FOR NEW INSPIRATIONS AFTER SOME TIME!
-- MAKING STATISTICAL DESCRIPTIONS USING TABLE VALUED FUNCTIONS!! TO SHOW BETWEEN YEARS, VARIANCE AND LOOK AT PAGES

SELECT *
FROM [Project4].[dbo].[SuperStore]



ALTER TABLE [Project4].[dbo].[SuperStore]
DROP COLUMN 
--1. CLEANING, EXPLORATION AND MODIFICATION OF DATA
--1.a) REMOVED UNUSED COLUMN
ALTER TABLE [Project4].[dbo].[SuperStore]
DROP COLUMN [Row ID]

ALTER TABLE [Project4].[dbo].[SuperStore]
DROP COLUMN [Order Date]

ALTER TABLE [Project4].[dbo].[SuperStore]
DROP COLUMN [Ship Date]

ALTER TABLE [Project4].[dbo].[SuperStore]
DROP COLUMN [Postal Code]


--1.b) Add new columns for modified Postal Code and Date
--1.c) Add new columns
ALTER TABLE [Project4].[dbo].[SuperStore]
ADD PostalCode varchar(30)

ALTER TABLE [Project4].[dbo].[SuperStore]
ADD OrderDate date

ALTER TABLE [Project4].[dbo].[SuperStore]
ADD ShipDate date

ALTER TABLE [Project4].[dbo].[SuperStore]
ADD YearOfOrderDate int

ALTER TABLE [Project4].[dbo].[SuperStore]
ADD YearOfShipDate int


--1.d) UPDATE NEW COLUMNS

UPDATE [Project4].[dbo].[SuperStore]
SET [PostalCode] = COALESCE(CAST([Postal Code] as varchar(30)), 'No Available') 

UPDATE [Project4].[dbo].[SuperStore]
SET [OrderDate] = CONVERT(date,[Order Date])

UPDATE [Project4].[dbo].[SuperStore]
SET [ShipDate] = CONVERT(date, [Ship Date])

UPDATE [Project4].[dbo].[SuperStore]
SET [YearOfOrderDate] = year([OrderDate])

UPDATE [Project4].[dbo].[SuperStore]
SET [YearOfShipDate] = year([ShipDate])

--2. Spliting Order ID, Customer ID, Customer Name and Producit ID into parts
SELECT [Order ID],[Customer ID],[Customer Name], [Product ID]
FROM [Project4].[dbo].[SuperStore]

--2.a) Spliting Customer Name into First Name and Second Name

SELECT CAST([Customer Name] AS VARCHAR(30)) as [Customer Name], 
		CAST(TRIM(LEFT([Customer Name],CHARINDEX(' ', [Customer Name]))) AS VARCHAR(30)) as [Customer First Name],
		CAST(TRIM(RIGHT([Customer Name], LEN([Customer Name]) - CHARINDEX(' ', [Customer Name]))) AS VARCHAR(30)) as [Customer Second Name],
		CAST(LTRIM(RTRIM((CHARINDEX(' ', [Customer Name])))) AS INT) as [Quantity of Letters], 
		CAST(LTRIM(RTRIM((CHARINDEX(' ',REVERSE([Customer Name]))))) AS INT)	 as [Quantity of Letters]
FROM  [Project4].[dbo].[SuperStore]

-- Spliting Customer name into First Name and Second name using STRING SPLIT, CROSS APPLY AND Pivot
CREATE VIEW CustomerInformation AS 
	SELECT DISTINCT [Customer ID], VALUE
	FROM [Project4].[dbo].[SuperStore]
	CROSS APPLY
	STRING_SPLIT([Customer Name], ' ')

--Creating Row Number to assign a sequential integer to my customers in order to create Pivot
WITH CreatingRowNumber AS (	
SELECT *, ROW_NUMBER() OVER(PARTITION BY [Customer ID] ORDER BY [Customer ID]) as RowNumber
FROM CustomerInformation
)
SELECT UPPER([1]) as [First Name], UPPER([2]) as [Last Name]
FROM CreatingRowNumber
PIVOT
(MAX(VALUE)
FOR RowNumber in ([1], [2])) as PvT



--2b) Spliting Customer ID into parts
SELECT CAST([Customer ID] AS VARCHAR(30)) as [Customer ID], 
	CAST(TRIM(SUBSTRING([Customer ID],1, CHARINDEX('-', [Customer ID]) -1)) AS VARCHAR(30)) as [First Part],
	CAST(TRIM(RIGHT([Customer ID],LEN([Customer ID]) - CHARINDEX('-',[Customer ID]))) AS INT) as [Second Part]
FROM [Project4].[dbo].[SuperStore]


--2c) Spliting Order ID into parts
SELECT CAST([Order ID] AS VARCHAR(30)) as [Order ID],
	CAST(TRIM(LEFT([Order ID],CHARINDEX('-',[Order ID])-1)) AS VARCHAR(30)) as [First Part], 
	CAST(TRIM(SUBSTRING([Order ID], CHARINDEX('-',[Order ID])+1, LEN([Order ID]) - CHARINDEX('-', REVERSE([Order ID])) - CHARINDEX('-', [Order Id]))) AS INT) as [Second Part],
	CAST(TRIM(RIGHT([Order ID],CHARINDEX('-', REVERSE([Order ID]))-1)) AS INT) as [Third Part],
	CAST(LTRIM(RTRIM((LEN([Order ID])))) AS INT) as [Quantity of Letters],
	CAST(LTRIM(RTRIM((CHARINDEX('-', REVERSE([Order ID]))))) AS INT) as [Quantity of Letters],
	CAST(LTRIM(RTRIM(CHARINDEX('-', [Order Id]))) AS INT) as [Quantity of Letters],
	CAST(LTRIM(RTRIM(LEN([Order ID]) - CHARINDEX('-', REVERSE([Order ID])) - CHARINDEX('-', [Order Id]))) AS INT) as [Quantity of Letters]
FROM [Project4].[dbo].[SuperStore]


--2.d)Spliting Product ID into parts
SELECT CAST([Product ID] AS VARCHAR(30)) as [Product ID],
	CAST(TRIM(LEFT([Product ID], CHARINDEX('-',[Product ID])-1)) AS VARCHAR(30)) as [First Part],
	CAST(TRIM(SUBSTRING([Product ID], CHARINDEX('-', [Product ID])+1, LEN([Product ID]) - CHARINDEX('-',[Product ID])-CHARINDEX('-',REVERSE([Product ID])))) AS VARCHAR(30)) as [Second Part],
	CAST(TRIM(RIGHT([Product ID],CHARINDEX('-', REVERSE([Product ID]))-1)) AS INT) as [Third Part],
	CAST(LTRIM(RTRIM((LEN([Product ID])))) AS INT) as [Quantity of Letters],
	CAST(LTRIM(RTRIM((CHARINDEX('-',[Product ID])))) AS INT) as [Quantity of Letters],
	CAST(LTRIM(RTRIM(CHARINDEX('-',REVERSE([Order ID])))) AS INT) as [Quantity of Letters]
FROM  [Project4].[dbo].[SuperStore]





SELECT *
FROM [Project4].[dbo].[SuperStore]

--4. DATA EXPLORATION
--4.a)The quantity of Customers 
SELECT COUNT( distinct [Customer Name]) as [Quantity of Customers]
FROM  [Project4].[dbo].[SuperStore]

--4.b) Sales of Customer by Segment.
--4.c) Creaate Function in order to return data of a table type - 
--4. Look at top 25 % of Customer by Sales
DROP TABLE IF EXISTS #CustomerOfSales
CREATE TABLE #CustomerOfSales (
	[Customer Name] varchar(max),
	[Sales] int
)

INSERT INTO #CustomerOfSales
	SELECT DISTINCT [Customer Name], SUM([Sales]) OVER(PARTITION BY [Customer Name]) as Sales
	FROM [Project4].[dbo].[SuperStore]
	ORDER By [Sales] DESC


WITH Top25CustomerBySales AS (
SELECT *, FORMAT(CUME_DIST() OVER (ORDER BY [Sales] DESC),'P2')  as [Cumulative distribution]
FROM  #CustomerOfSales
)
SELECT *
FROM Top25CustomerBySales
WHERE [Cumulative distribution] < '25%' AND [Customer Name] != 'Michael Oakman'
ORDER BY [Sales] DESC





--4.b) Sales of Customer by Segment.
--4.c) Creaate Function in order to return data of a table type - 
CREATE FUNCTION SalesOfCustomerBySegmentAndYears (
@segment varchar(500),
@startyear int,
@endyear int
)
RETURNS TABLE 
AS
RETURN
	SELECT DISTINCT 
			[Customer Name],
			[Segment],
			SUM(Sales) OVER (PARTITION BY [Customer Name]) as [Sales]
	FROM  
		[Project4].[dbo].[SuperStore]

	WHERE 
		Segment = @segment AND
		YearOfOrderDate between @startyear AND @endyear;

-- Home Office
SELECT *
FROM SalesOfCustomerBySegmentAndYears('Home Office',2011,2014)
ORDER BY [Sales] DESC

SELECT *
FROM SalesOfCustomerBySegmentAndYears('Home Office',2011,2011)
ORDER BY [Sales] DESC

SELECT *
FROM SalesOfCustomerBySegmentAndYears('Home Office',2012,2012)
ORDER BY [Sales] DESC

SELECT *
FROM SalesOfCustomerBySegmentAndYears('Home Office',2013,2013)
ORDER BY [Sales] DESC

SELECT *
FROM SalesOfCustomerBySegmentAndYears('Home Office',2014,2014)
ORDER BY [Sales] DESC

--Consumer

SELECT *
FROM SalesOfCustomerBySegmentAndYears('Consumer',2011,2014)
ORDER BY [Sales] DESC

SELECT *
FROM SalesOfCustomerBySegmentAndYears('Consumer',2011,2011)
ORDER BY [Sales] DESC

SELECT *
FROM SalesOfCustomerBySegmentAndYears('Consumer',2012,2012)
ORDER BY [Sales] DESC

SELECT *
FROM SalesOfCustomerBySegmentAndYears('Consumer',2013,2013)
ORDER BY [Sales] DESC

SELECT *
FROM SalesOfCustomerBySegmentAndYears('Consumer',2014,2014)
ORDER BY [Sales] DESC

--Corporate

SELECT *
FROM SalesOfCustomerBySegmentAndYears('Corporate',2011,2014)
ORDER BY [Sales] DESC

SELECT *
FROM SalesOfCustomerBySegmentAndYears('Corporate',2011,2011)
ORDER BY [Sales] DESC

SELECT *
FROM SalesOfCustomerBySegmentAndYears('Corporate',2012,2012)
ORDER BY [Sales] DESC

SELECT *
FROM SalesOfCustomerBySegmentAndYears('Corporate',2013,2013)
ORDER BY [Sales] DESC

SELECT *
FROM SalesOfCustomerBySegmentAndYears('Corporate',2014,2014)
ORDER BY [Sales] DESC



-- TOP10 Customer in each Segment
CREATE PROCEDURE TOP10CustomerInEachSegment @Segment varchar(30)
AS	
	SELECT DISTINCT TOP 10 with TIES
		[Customer Name], [Segment],SUM(Sales) OVER (PARTITION BY [Customer Name]) as [Sales]
	FROM [Project4].[dbo].[SuperStore]
	WHERE Segment =  @Segment
	ORDER BY [Sales] DESC
GO

EXEC TOP10CustomerInEachSegment @Segment = 'Home Office'
EXEC TOP10CustomerInEachSegment @Segment = 'Consumer'
EXEC TOP10CustomerInEachSegment @Segment = 'Corporate'

-- Customer with Sales greater than Average
CREATE PROCEDURE CustomerWithSalesGreaterThanAverage @Segment varchar(30)
AS
	SELECT DISTINCT
		[Customer Name], [Segment],SUM(Sales) OVER (PARTITION BY [Customer Name]) as [Sales]
	FROM [Project4].[dbo].[SuperStore]
	WHERE Sales > (SELECT AVG(Sales) FROM [Project4].[dbo].[SuperStore]) AND Segment = @Segment
	ORDER BY [Sales] DESC
GO

EXEC CustomerWithSalesGreaterThanAverage @Segment = 'Home Office'
EXEC CustomerWithSalesGreaterThanAverage @Segment = 'Consumer'
EXEC CustomerWithSalesGreaterThanAverage @Segment = 'Corporate'

-- Customer with The highest and lowest Sales and Ranking
DROP TABLE IF EXISTS #CustomerBySegment
CREATE TABLE #CustomerBySegment (
	[Customer Name] VARCHAR(MAX),
	[Segment] VARCHAR(MAX),
	[Sales] INT
);

INSERT INTO #CustomerBySegment
	SELECT DISTINCT [Customer Name], 
		[Segment],
		SUM(Sales) OVER (PARTITION BY [Customer Name]) as [Sales]
	FROM [Project4].[dbo].[SuperStore]
	ORDER BY Segment DESC, Sales DESC


-- Rankign Customer by Segment
CREATE PROCEDURE RankingOfCustomer @Segment varchar(MAX)
AS
	SELECT RANK() OVER (PARTITION BY [Segment] ORDER BY Sales DESC) as Ranking, 
		[Customer Name], 
		[Segment], 
		[Sales]
	FROM #CustomerBySegment
	WHERE [Segment] = @Segment;
GO
		
EXEC RankingOfCustomer @Segment = 'Consumer'
EXEC RankingOfCustomer @Segment = 'Corporate'
EXEC RankingOfCustomer @Segment = 'Home Office'


-- The greatest and lowest Sales by Segment
WITH GreatestSales ([Segment], [Customer with the greatest Sales],[Sales]) AS 
(
SELECT DISTINCT
	[Segment],
	FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Sales] DESC) as [Customer with the greatest Sales],
	MAX(Sales) OVER (PARTITION BY [Segment]) as [Sales]
FROM #CustomerBySegment
), LowestSales ([Segment],[Customer with the lowest Sales],[Sales]) AS
(
SELECT DISTINCT 
	[Segment],
	LAST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Sales] DESC 
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Sales],
	MIN(Sales) OVER (PARTITION BY [Segment]) as [Sales]
FROM #CustomerBySegment
)
SELECT *
FROM GreatestSales  G
	LEFT JOIN LowestSales L
		 ON G.Segment = L.Segment
-- MODIYFING IT BY CASE???
DROP PROCEDURE GroupOfCustomerBySegment
CREATE PROCEDURE GroupOfCustomerBySegment @Segment varchar(MAX)
AS
	SELECT [Customer Name],
	NTILE(3) OVER (ORDER BY Sales DESC) as [Group of Customer]
	FROM #CustomerBySegment
	WHERE [Segment] = @Segment
GO
/*
1  - High Sales , 2- Mid Sales , 1 - Low Sales by Segment
*/
EXEC GroupOfCustomerBySegment @Segment = 'Consumer'
EXEC GroupOfCustomerBySegment @Segment = 'Corporate'
EXEC GroupOfCustomerBySegment @Segment = 'Home Office'


-- USING SUBQUERY FOR AVERAGE!!!

--4.d) Sales of Customer by Category 
--4.e) Create Procedure to store the code
--4. Sales of Customer by Category betweeen 2011 and 2014
SELECT DISTINCT [Customer Name], 
		[Category],
		SUM(Sales) OVER (PARTITION BY [Customer Name]) as Sales
FROM [Project4].[dbo].[SuperStore]

DROP PROCEDURE SalesOfCustomerByCategory

CREATE PROCEDURE SalesOfCustomerByCategory @Category varchar(30), @StartYear int, @EndYear int
AS
SELECT DISTINCT [Customer Name], [Category], SUM(Sales) OVER (PARTITION BY [Customer Name]) as Sales
FROM [Project4].[dbo].[SuperStore]
WHERE [Category] = @Category AND YearOfOrderDate BETWEEN @StartYear AND @EndYear
ORDER BY Sales DESC
GO

EXEC SalesOfCustomerByCategory @Category = 'Furniture', @StartYear = 2011, @EndYear = 2014;

EXEC SalesOfCustomerByCategory @Category = 'Office Supplies', @StartYear = 2011, @EndYear = 2014;

EXEC SalesOfCustomerByCategory @Category = 'Technology', @StartYear = 2011, @EndYear = 2014;

--4. Sales of Customer by Category with Sales greater than Average in all years
CREATE FUNCTION SalesOfCustomerByCategoryGreaterThanAve (
@Category varchar(max)
)
RETURNS TABLE
AS
RETURN
SELECT DISTINCT [Customer Name], 
				[Category],
				SUM(Sales) OVER (PARTITION BY [Customer Name]) as Sales
FROM [Project4].[dbo].[SuperStore]
WHERE [Category] = @Category AND Sales > (SELECT AVG(Sales) FROM [Project4].[dbo].[SuperStore]);

SELECT *
FROM SalesOfCustomerByCategoryGreaterThanAve('Furniture')	
ORDER BY Sales DESC

SELECT *
FROM SalesOfCustomerByCategoryGreaterThanAve('Office Supplies')	
ORDER BY Sales DESC

SELECT *
FROM SalesOfCustomerByCategoryGreaterThanAve('Technology')	
ORDER BY Sales DESC


-- TOP 10 Costumer by Category 
DROP PROCEDURE Top10CustomerByCategoryInYears
CREATE PROCEDURE Top10CustomerByCategory @Category varchar(30)
AS
	SELECT DISTINCT TOP 10 WITH TIES
	[Customer Name], 
	[Category], 
	SUM(Sales) OVER (PARTITION BY [Customer Name]) as Sales
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Category] = @Category 
	ORDER BY Sales DESC 
GO

EXEC Top10CustomerByCategory @Category = 'Furniture'
EXEC Top10CustomerByCategory @Category = 'Office Supplies'
EXEC Top10CustomerByCategory @Category = 'Technology'

-- TOP 10 Costumer by Category year by year Analysis it and try to pivot it! if it does not work, just try to make it once again then UNPIVOT!!

CREATE FUNCTION Top10CustomerByCategoryInYear
(
    @Category varchar(MAX),
    @StartYear int,
    @EndYear int
)
RETURNS TABLE
AS RETURN

    WITH L0 AS (
        SELECT @StartYear - 1 + ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS Year
            FROM (VALUES(1),(1),(1),(1),(1),(1),(1),(1),
                        (1),(1),(1),(1),(1),(1),(1),(1),
                        (1),(1),(1),(1),(1),(1),(1),(1),
                        (1),(1),(1),(1),(1),(1),(1),(1)) AS D(c)
    ),
    Years AS (
        SELECT * FROM L0 WHERE Year <= @EndYear
    )
    SELECT
        s.[Customer Name], 
        @Category AS [Category], 
        s.Sales,
        y.Year
    FROM Years y
    CROSS APPLY (
        SELECT TOP 10 WITH TIES
            [Customer Name],
            SUM(Sales) AS Sales
        FROM [Project4].[dbo].[SuperStore] s
        WHERE [Category] = @Category
          AND y.Year = s.YearOfOrderDate
        GROUP BY [Customer Name]
        ORDER BY Sales DESC
    ) s;

GO
-- TOP10 Customer by Category year by year LOOK AT STACK OVER FLOW!! TRY TO PIVOT IT !! USE CASE??
SELECT *
FROM Top10CustomerByCategoryInYear('Furniture',2011,2014)

SELECT *
FROM Top10CustomerByCategoryInYear('Office Supplies',2011,2014)

SELECT *
FROM Top10CustomerByCategoryInYear('Technology',2011,2014)


-- The Ranking of Customer and customers with the greatest and lowest Sales in all categories 
--FURNITURE
CREATE VIEW CustomerOfSalesByFurniture AS 
	SELECT DISTINCT
				[Customer Name],
				[Category], 
				SUM(Sales) OVER (PARTITION BY [Customer Name]) as Sales
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Category] = 'Furniture'
	
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY Sales DESC) AS Ranking, *
FROM CustomerOfSalesByFurniture


-- TECHNOLOGY
CREATE VIEW CustomerOfSalesByTechnology AS 
	SELECT DISTINCT
				[Customer Name],
				[Category], 
				SUM(Sales) OVER (PARTITION BY [Customer Name]) as Sales
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Category] = 'Technology'
	
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY Sales DESC) AS Ranking, *
FROM CustomerOfSalesByTechnology


-- OFFICE SUPPLIES
CREATE VIEW CustomerOfSalesByOfficeSupplies AS 
	SELECT DISTINCT
				[Customer Name],
				[Category], 
				SUM(Sales) OVER (PARTITION BY [Customer Name]) as Sales
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Category] = 'Office Supplies'
	
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY Sales DESC) AS Ranking, *
FROM CustomerOfSalesByOfficeSupplies

-- Customers with the greatest & lowest Sales by all categories

		SELECT DISTINCT [Category], FIRST_VALUE([Customer Name]) OVER(PARTITION BY [Category] ORDER BY Sales DESC) AS [Customer with the greatest Sales by Category],
		MAX(Sales) OVER (PARTITION BY [Category]) as [Sales by Category],
		LAST_VALUE([Customer Name]) OVER(PARTITION BY [Category] ORDER BY Sales DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) AS [Customer with the lowest Sales by Category],
		MIN(Sales) OVER (PARTITION BY [Category]) as [Sales by Category]
		FROM CustomerOfSalesByFurniture
UNION
		SELECT DISTINCT [Category], FIRST_VALUE([Customer Name]) OVER(PARTITION BY [Category] ORDER BY Sales DESC) AS [Customer with the greatest Sales by Category],
		MAX(Sales) OVER (PARTITION BY [Category]) as [Sales by Category],
		LAST_VALUE([Customer Name]) OVER(PARTITION BY [Category] ORDER BY Sales DESC 
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) AS [Customer with the lowest Sales by Category],
		MIN(Sales) OVER (PARTITION BY [Category]) as [Sales by Category]
		FROM CustomerOfSalesByOfficeSupplies
UNION
		SELECT DISTINCT [Category], FIRST_VALUE([Customer Name]) OVER(PARTITION BY [Category] ORDER BY Sales DESC) AS [Customer with the greatest Sales by Category],
		MAX(Sales) OVER (PARTITION BY [Category]) as [Sales by Category],
		LAST_VALUE([Customer Name]) OVER(PARTITION BY [Category] ORDER BY Sales DESC	
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) AS [Customer with the lowest Sales by Category],
		MIN(Sales) OVER (PARTITION BY [Category]) as [Sales By Category]
FROM CustomerOfSalesByTechnology


-- The Group of Customer by Categories

--FURNITURE
WITH GroupOfCustomerByFurniture AS (
	SELECT *, NTILE(3) OVER (ORDER BY Sales DESC) as [Group of Customer]
	FROM CustomerOfSalesByFurniture
)
SELECT [Customer Name],
CASE 
	WHEN [Group of Customer] = 1 Then 'High Sales in Furniture'
	WHEN [Group of Customer] = 2 Then 'Mid Sales in Furniture'
	WHEN [Group of Customer] = 3 Then 'Low Sales in Furniture'
		END AS [Level of Sales in Furniture]
FROM GroupOfCustomerByFurniture

-- OFFICE SUPPLIES
WITH GroupOfCustomerByOfficeSupplies AS (
	SELECT *, NTILE(3) OVER (ORDER BY Sales DESC) as [Group of Customer]
	FROM CustomerOfSalesByOfficeSupplies
)
SELECT [Customer Name],
CASE 
	WHEN [Group of Customer] = 1 Then 'High Sales in Office Supplies'
	WHEN [Group of Customer] = 2 Then 'Mid Sales in Office Supplies'
	WHEN [Group of Customer] = 3 Then 'Low Sales in Office Supplies'
		END AS [Level of Sales in Office Supplies]
FROM GroupOfCustomerByOfficeSupplies;

--Technology
WITH GroupofCustomerByTechnology AS (
	SELECT *, NTILE(3) OVER (ORDER BY Sales DESC) as [Group of Customer]
	FROM CustomerOfSalesByTechnology
)
SELECT [Customer Name],
CASE 
	WHEN [Group of Customer] = 1 Then 'High Sales in Technology'
	WHEN [Group of Customer] = 2 Then 'Mid Sales in Technology'
	WHEN [Group of Customer] = 3 Then 'Low Sales in Technology'
		END AS [Level of Sales in Technology]
FROM GroupofCustomerByTechnology

--4. Quantity of Orders by Ship Mode 
SELECT DISTINCT [Ship Mode], count(*) OVER (PARTITION BY [Ship Mode]) as [The Quantity of Orders]
FROM   [Project4].[dbo].[SuperStore]
ORDER BY [The Quantity of Orders] DESC
--4. Create Function 
CREATE FUNCTION [Quantity of Orders by Ship Mode]
(
	@YearOfOrderDate int
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT [Ship Mode], count(*) OVER (PARTITION BY [Ship Mode]) as [The Quantity of Orders]
	FROM   [Project4].[dbo].[SuperStore]
	WHERE YearOfOrderDate = @YearOfOrderDate;



--4. The Quantity of Orders by Ship Mode by Year
--2011
SELECT *
FROM [Quantity of Orders by Ship Mode](2011)
ORDER BY [The Quantity of Orders] DESC
--2012
SELECT *
FROM [Quantity of Orders by Ship Mode](2012)
ORDER BY [The Quantity of Orders] DESC
--2013
SELECT *
FROM [Quantity of Orders by Ship Mode](2013)
ORDER BY [The Quantity of Orders] DESC
--2014
SELECT *
FROM [Quantity of Orders by Ship Mode](2014)
ORDER BY [The Quantity of Orders] DESC

--4. The Percentage Quantity of Orders by Ship Mode in all years
CREATE VIEW PercentageQuantityOfOrdersByShipMode AS 
	SELECT DISTINCT [Ship Mode], count(*) OVER (PARTITION BY [Ship Mode]) as [The Quantity of Orders]
	FROM   [Project4].[dbo].[SuperStore]

DECLARE @SumOfQuanaityOfOrders FLOAT
SET  @SumOfQuanaityOfOrders = (SELECT SUM([The Quantity of Orders]) FROM  PercentageQuantityOfOrdersByShipMode )
PRINT @SumOfQuanaityOfOrders

SELECT [Ship Mode], FORMAT(([The Quantity Of Orders] / @SumOfQuanaityOfOrders) , 'P2') as [The percentage of the quantity of Orderds by Ship Mode]
FROM PercentageQuantityOfOrdersByShipMode
ORDER BY [The Quantity Of Orders] DESC


--4. The Percentage Quantity of Orders by Ship Mode Year by Year
DECLARE @SumOfQuantityOrders2011 FLOAT
SET @SumOfQuantityOrders2011 = (SELECT SUM([The Quantity of Orders]) FROM [Quantity of Orders by Ship Mode](2011))
PRINT @SumOfQuantityOrders2011

DECLARE @SumOfQuantityOrders2012 FLOAT
SET @SumOfQuantityOrders2012 = (SELECT SUM([The Quantity of Orders]) FROM [Quantity of Orders by Ship Mode](2012))
PRINT @SumOfQuantityOrders2012

DECLARE @SumOfQuantityOrders2013 FLOAT
SET @SumOfQuantityOrders2013 = (SELECT SUM([The Quantity of Orders]) FROM [Quantity of Orders by Ship Mode](2013))
PRINT @SumOfQuantityOrders2013

DECLARE @SumOfQuantityOrders2014 FLOAT
SET @SumOfQuantityOrders2014 = (SELECT SUM([The Quantity of Orders]) FROM [Quantity of Orders by Ship Mode](2014))
PRINT @SumOfQuantityOrders2014;

WITH PercentageQuantityOfOrderByShipMode2011  AS
(
	SELECT [Ship Mode], [The Quantity of Orders], FORMAT(([The Quantity of Orders] / @SumOfQuantityOrders2011) , 'P2') as [The Percentage Quantity of Orders by Ship Mode]
	FROM [Quantity of Orders by Ship Mode](2011)
), PercentageQuantityOfOrderByShipMode2012 AS 
(
	SELECT [Ship Mode],[The Quantity of Orders], FORMAT(([The Quantity of Orders] / @SumOfQuantityOrders2012) , 'P2') as [The Percentage Quantity of Orders by Ship Mode]
	FROM [Quantity of Orders by Ship Mode](2012)
), PercentageQuantityOfOrderByShipMode2013 AS 
(
	SELECT [Ship Mode],[The Quantity of Orders], FORMAT(([The Quantity of Orders] / @SumOfQuantityOrders2013) , 'P2') as [The Percentage Quantity of Orders by Ship Mode]
	FROM [Quantity of Orders by Ship Mode](2013)
), PercentageQuantityOfOrderByShipMode2014 AS 
(
SELECT [Ship Mode],[The Quantity of Orders], FORMAT(([The Quantity of Orders] / @SumOfQuantityOrders2014) , 'P2') as [The Percentage Quantity of Orders by Ship Mode]
	FROM [Quantity of Orders by Ship Mode](2014)
)
SELECT S2011.[Ship Mode], S2011.[The Percentage Quantity of Orders by Ship Mode] as [The Percentage Quantity of Orders by Ship Mode 2011],
	 S2012.[The Percentage Quantity of Orders by Ship Mode] as [The Percentage Quantity of Orders by Ship Mode 2012],
	 S2013.[The Percentage Quantity of Orders by Ship Mode]  as [The Percentage Quantity of Orders by Ship Mode 2013],
	S2014.[The Percentage Quantity of Orders by Ship Mode] as [The Percentage Quantity of Orders by Ship Mode 2014]
FROM PercentageQuantityOfOrderByShipMode2011 S2011
	LEFT JOIN PercentageQuantityOfOrderByShipMode2012 S2012
		ON S2011.[Ship Mode] = S2012.[Ship Mode]
	LEFT JOIN PercentageQuantityOfOrderByShipMode2013 S2013
		ON S2011.[Ship Mode] = S2013.[Ship Mode]
	LEFT JOIN PercentageQuantityOfOrderByShipMode2014 S2014
		ON S2011.[Ship Mode] = S2014.[Ship Mode]
ORDER BY S2011.[The Quantity of Orders] DESC



-- The quantity of Shipe Mode by Customer in all years
DROP PROCEDURE TheQuantityOfShipModeByCustomer
CREATE PROCEDURE TheQuantityOfShipModeByCustomer @ShipMode nvarchar(MAX), @StartYear int, @EndYear int
AS 
	SELECT DISTINCT [Customer Name], [Ship Mode], COUNT([Ship Mode]) OVER (PARTITION BY [Customer Name]) as [Quantity of Ship Mode]
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Ship Mode] = @ShipMode AND YearOfOrderDate BETWEEN @StartYear AND @EndYear
	ORDER BY [Quantity of Ship Mode] DESC
GO:

EXEC TheQuantityOfShipModeByCustomer @ShipMode = 'Standard Class', @StartYear = 2011, @EndYear = 2014
EXEC TheQuantityOfShipModeByCustomer @ShipMode = 'Second Class', @StartYear = 2011, @EndYear = 2014
EXEC TheQuantityOfShipModeByCustomer @ShipMode = 'First Class', @StartYear = 2011, @EndYear = 2014
EXEC TheQuantityOfShipModeByCustomer @ShipMode = 'Same Day', @StartYear = 2011, @EndYear = 2014

--The Sales of Ship Mode, The Quantity of Orders of Ship Mode by Customer
--The Sales of Ship Mode by Customer 
CREATE PROCEDURE SalesOfShipModeByCustomer @ShipMode nvarchar(30), @StartYear int, @EndYear int
AS
	SELECT [Customer Name], SUM([Sales]) OVER (PARTITION BY [Sales]) as [Sales]
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Ship Mode] = @ShipMode AND  YearOfOrderDate BETWEEN @StartYear AND @EndYear
	ORDER BY [Sales] DESC
GO

EXEC SalesOfShipModeByCustomer @ShipMode = 'Standard Class', @StartYear = 2011, @EndYear = 2014
EXEC SalesOfShipModeByCustomer @ShipMode = 'Second Class', @StartYear = 2011, @EndYear = 2014
EXEC SalesOfShipModeByCustomer @ShipMode = 'First Class', @StartYear = 2011, @EndYear = 2014
EXEC SalesOfShipModeByCustomer @ShipMode = 'Same Day', @StartYear = 2011, @EndYear = 2014

-- Quantity of Orders by Customer in Ship Mode
DROP FUNCTION QuantityOfShipModeByCustomer
CREATE FUNCTION QuantityOfShipModeByCustomer 
(
	@ShipMode nvarchar(MAX),
	@StartYear int,
	@EndYear int

)
RETURNS TABLE
AS
RETURN
		SELECT DISTINCT [Customer Name],[Ship Mode], [YearOfOrderDate], COUNT([Ship Mode]) OVER (PARTITION BY [Customer Name]) as [Quantity of Ship Mode]
		FROM [Project4].[dbo].[SuperStore]
		WHERE [Ship Mode] = @ShipMode 
			AND  [YearOfOrderDate]  BETWEEN @StartYear AND @EndYear 

-- Quantity of Orders by Customer in Ship Mode
SELECT DISTINCT [Customer Name],[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Standard Class', 2011, 2014)
ORDER BY [Quantity of Ship Mode] DESC


SELECT DISTINCT [Customer Name],[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Second Class', 2011, 2014)
ORDER BY [Quantity of Ship Mode] DESC

SELECT DISTINCT [Customer Name],[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('First Class', 2011, 2014)
ORDER BY [Quantity of Ship Mode] DESC

SELECT DISTINCT [Customer Name],[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Same Day', 2011, 2014)
ORDER BY [Quantity of Ship Mode] DESC

-- The whole Quantity of Orders by Customer in Ship Mode
SELECT DISTINCT [Customer Name],[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Standard Class', 2011, 2014)
UNION
SELECT DISTINCT [Customer Name],[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Second Class', 2011, 2014)
UNION
SELECT DISTINCT [Customer Name],[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('First Class', 2011, 2014)
UNION
SELECT DISTINCT [Customer Name],[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Same Day', 2011, 2014)
ORDER BY [Ship Mode] DESC, [Quantity of Ship Mode] DESC


-- Quantity of Orders by Customer in Standard Classs in a year
SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Standard Class', 2011, 2011)
ORDER BY [Quantity of Ship Mode] DESC

SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Standard Class', 2012, 2012)
ORDER BY [Quantity of Ship Mode] DESC

SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Standard Class', 2013, 2013)
ORDER BY [Quantity of Ship Mode] DESC

SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Standard Class', 2014, 2014)
ORDER BY [Quantity of Ship Mode] DESC


-- Quantity of Orders by Customer in Second Class in a year
SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Second Class', 2011, 2011)
ORDER BY [Quantity of Ship Mode] DESC

SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Second Class', 2012, 2012)
ORDER BY [Quantity of Ship Mode] DESC

SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Second Class', 2013, 2013)
ORDER BY [Quantity of Ship Mode] DESC

SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Second Class', 2014, 2014)
ORDER BY [Quantity of Ship Mode] DESC

-- Quantity of Orders by Customer in First Class in a year
SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('First Class', 2011, 2011)
ORDER BY [Quantity of Ship Mode] DESC

SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('First Class', 2012, 2012)
ORDER BY [Quantity of Ship Mode] DESC

SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('First Class', 2013, 2013)
ORDER BY [Quantity of Ship Mode] DESC

SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('First Class', 2014, 2014)
ORDER BY [Quantity of Ship Mode] DESC

-- Quantity of Orders by Customer in First Class in a year
SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Same Day', 2011, 2011)
ORDER BY [Quantity of Ship Mode] DESC

SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Same Day', 2012, 2012)
ORDER BY [Quantity of Ship Mode] DESC

SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Same Day', 2013, 2013)
ORDER BY [Quantity of Ship Mode] DESC

SELECT DISTINCT [Customer Name],[YearOfOrderDate] as Year,[Ship Mode],[Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Same Day', 2014, 2014)
ORDER BY [Quantity of Ship Mode] DESC

--
--Greatest and Lowest Quantity of Orders of Ship Mode by Customers

SELECT DISTINCT [Ship Mode],
			FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Quantity of Ship Mode] DESC) as [Customer with greatest quantity of Order by Ship Mode], 
			MAX([Quantity of Ship Mode]) OVER (PARTITION BY [Ship Mode]) as [Quantity of Ship Mode],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Quantity of Ship Mode] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest quantity of Order by Ship Mode],
			MIN([Quantity of Ship Mode]) OVER (PARTITION BY [Ship Mode]) as [Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Standard Class', 2011, 2014)
UNION
SELECT DISTINCT [Ship Mode],
			FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Quantity of Ship Mode] DESC) as [Customer with greatest quantity of Order by Ship Mode], 
			MAX([Quantity of Ship Mode]) OVER (PARTITION BY [Ship Mode]) as [Quantity of Ship Mode],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Quantity of Ship Mode] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest quantity of Order by Ship Mode],
			MIN([Quantity of Ship Mode]) OVER (PARTITION BY [Ship Mode]) as [Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Second Class', 2011, 2014)
UNION
SELECT DISTINCT [Ship Mode],
				FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Quantity of Ship Mode] DESC) as [Customer with greatest quantity of Order by Ship Mode], 
			MAX([Quantity of Ship Mode]) OVER (PARTITION BY [Ship Mode]) as [Quantity of Ship Mode],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Quantity of Ship Mode] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest quantity of Order by Ship Mode],
			MIN([Quantity of Ship Mode]) OVER (PARTITION BY [Ship Mode]) as [Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('First Class', 2011, 2014)
UNION
SELECT DISTINCT [Ship Mode],
			FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Quantity of Ship Mode] DESC) as [Customer with greatest quantity of Order by Ship Mode], 
			MAX([Quantity of Ship Mode]) OVER (PARTITION BY [Ship Mode]) as [Quantity of Ship Mode],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Quantity of Ship Mode] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest quantity of Order by Ship Mode],
			MIN([Quantity of Ship Mode]) OVER (PARTITION BY [Ship Mode]) as [Quantity of Ship Mode]
FROM QuantityOfShipModeByCustomer('Same Day', 2011, 2014)



-- --Greatest and Lowest Sales of Ship Mode by Customers
--CREATE VIEW TO STORE THE QUERY


CREATE VIEW SalesOfCustomerByStandardClass AS 
	SELECT DISTINCT [Customer Name],[Ship Mode], SUM([Sales]) OVER (PARTITION BY [Customer Name]) as [Sales]
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Ship Mode] = 'Standard Class' 
	

CREATE VIEW SalesOfCustomerBySecondClass AS 
	SELECT DISTINCT [Customer Name],[Ship Mode], SUM([Sales]) OVER (PARTITION BY [Customer Name]) as [Sales]
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Ship Mode] = 'Second Class'

CREATE VIEW SalesOfCustomerByFirstClass AS 
	SELECT DISTINCT [Customer Name],[Ship Mode], SUM([Sales]) OVER (PARTITION BY [Customer Name]) as [Sales]
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Ship Mode] = 'First Class'

CREATE VIEW SalesOfCustomerBySameDay AS 
	SELECT DISTINCT [Customer Name],[Ship Mode], SUM([Sales]) OVER (PARTITION BY [Customer Name]) as [Sales]
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Ship Mode] = 'Same Day'


-- CREATE CTE TO STORE ALL QUERIES
WITH MaxSalesOfCustomerByShipMode AS (
SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC) as [Customer with the greatest Sales by Ship Mode],
				MAX([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerByStandardClass
UNION
SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC) as [Customer with the greatest Sales by Ship Mode],
				MAX([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerBySecondClass
UNION
SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC) as [Customer with the greatest Sales by Ship Mode],
				MAX([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerByFirstClass
UNION
SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC) as [Customer with the greatest Sales by Ship Mode],
				MAX([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerBySameDay
), MinSalesOfCustomerByShipMode AS (
SELECT DISTINCT [Ship Mode],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Sales by Ship Mode],
			MIN([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerByStandardClass
UNION
SELECT DISTINCT [Ship Mode],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Sales by Ship Mode],
			MIN([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerBySecondClass
UNION
SELECT DISTINCT [Ship Mode],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Sales by Ship Mode],
			MIN([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerByFirstClass
UNION
SELECT DISTINCT [Ship Mode],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Sales] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Sales by Ship Mode],
			MIN([Sales]) OVER (PARTITION BY [Ship Mode]) as [Sales]
FROM SalesOfCustomerBySameDay
)
SELECT *
FROM MaxSalesOfCustomerByShipMode
	JOIN MinSalesOfCustomerByShipMode
		ON MaxSalesOfCustomerByShipMode.[Ship Mode] = MinSalesOfCustomerByShipMode.[Ship Mode]

/*
PROFIT

*/
--4. Customer of Profit 
DROP VIEW CustomerOfProfit
CREATE VIEW CustomerOfProfit AS 
	SELECT DISTINCT  [Customer Name], 
			SUM([Profit]) OVER (PARTITION BY [Customer Name]) as Profit
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Profit] >= 1
	--
-- The Ranking of Customer of Profit
SELECT rank() OVER (ORDER BY [Profit] DESC) as  Ranking, *
FROM CustomerOfProfit
ORDER BY Profit DESC
-- Customer of Profit greater than average profit

SELECT DISTINCT [Customer Name], SUM([Profit]) OVER (PARTITION BY [Customer Name]) as [Profit]
FROM [Project4].[dbo].[SuperStore]
WHERE [Profit] > (SELECT AVG([Profit]) FROM [Project4].[dbo].[SuperStore])
ORDER BY [Profit] DESC

-- Customer with greatest and lowest Profit

WITH CustomerWithGreatestandLowestProfit ([Customer Name],[Profit],[Customer with the greatest Profit],[Customer with the lowest Profit])  AS 
(
	SELECT  DISTINCT [Customer Name], [Profit], FIRST_VALUE([Customer Name]) OVER (ORDER BY [Profit] DESC) as [Customer with the greatest Profit],
					LAST_VALUE([Customer Name]) OVER (ORDER BY [Profit] DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS [Customer with the lowest Profit]
	FROM CustomerOfProfit
)
SELECT DISTINCT [Customer with the greatest Profit], [Customer with the lowest Profit]
FROM CustomerWithGreatestandLowestProfit
-- 4. TOP 10 Customer of Profit:
SELECT DISTINCT TOP 10 with TIES [Customer Name], 
		SUM([Profit]) OVER (PARTITION BY [Customer Name]) as Profit
FROM [Project4].[dbo].[SuperStore]
ORDER BY Profit DESC

-- 4. Grouping of Customer by buckets (high Mid and low Profit )
DROP TABLE IF EXISTS #GroupOfCustomer
CREATE TABLE #GroupOfCustomer (
[Customer Name] nvarchar(MAX),
[Profit] int
)

INSERT INTO #GroupOfCustomer
	SELECT DISTINCT  [Customer Name], 
			SUM([Profit]) OVER (PARTITION BY [Customer Name]) as Profit
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Profit] >= 1
	ORDER BY Profit DESC
-- Group of Customer by three levels
WITH GroupOfCustomer AS (
	SELECT *, NTILE(3) OVER (ORDER BY [Profit] DESC) as Buckets
	FROM #GroupOfCustomer
)
SELECT [Customer Name], 
	CASE
		WHEN [Buckets] = 1 THEN 'High Profit'
		WHEN [Buckets] = 2 THEN 'Mid Profit'
		WHEN [Buckets] = 3 THEN 'Low Profit'
	END AS [Level of Profit]
FROM GroupOfCustomer

-- Group of Customer by Segment by three levels
CREATE FUNCTION GroupOfCustomerOfProfitBySegment
(
 @Segment nvarchar(MAX)
)
RETURNS TABLE
AS RETURN
		SELECT DISTINCT 
			[Customer Name], 
			SUM([Profit]) OVER (PARTITION BY [Customer Name]) as Profit
			FROM [Project4].[dbo].[SuperStore]
			WHERE [Profit] >= 1 AND [Segment] = @Segment

-- Group of Customer of Profit by Corporate
WITH GroupOfCustomerOfProfitByCorporate AS (
	SELECT *, NTILE(3) OVER (ORDER BY [Profit] DESC) as Buckets		
	FROM GroupOfCustomerOfProfitBySegment('Corporate')

)
SELECT [Customer Name],
		CASE	
			WHEN Buckets = 1 THEN 'High Profit'
			WHEN Buckets = 2 THEN 'Mid Profit'
			WHEN Buckets = 3 THEN 'Low Profit'
			END AS 'Level of Profit'
FROM GroupOfCustomerOfProfitByCorporate



-- Group of Customer of Profit by Consumer
WITH GroupOfCustomerOfProfitByConsumer AS (
	SELECT *, NTILE(3) OVER (ORDER BY [Profit] DESC) as Buckets		
	FROM GroupOfCustomerOfProfitBySegment('Consumer')

)
SELECT [Customer Name],
		CASE	
			WHEN Buckets = 1 THEN 'High Profit'
			WHEN Buckets = 2 THEN 'Mid Profit'
			WHEN Buckets = 3 THEN 'Low Profit'
			END AS 'Level of Profit'
FROM GroupOfCustomerOfProfitByConsumer

-- Group of Customer of Profit by Home Office
WITH GroupOfCustomerOfProfitByHomeOffice AS (
	SELECT *, NTILE(3) OVER (ORDER BY [Profit] DESC) as Buckets		
	FROM GroupOfCustomerOfProfitBySegment('Home Office')

)
SELECT [Customer Name],
		CASE	
			WHEN Buckets = 1 THEN 'High Profit'
			WHEN Buckets = 2 THEN 'Mid Profit'
			WHEN Buckets = 3 THEN 'Low Profit'
			END AS 'Level of Profit'
FROM GroupOfCustomerOfProfitByHomeOffice


--4. TOP 10 Customer by Segment

CREATE PROCEDURE TOP10CustomerBySegment @Segment nvarchar(MAX)
AS
	SELECT DISTINCT TOP 10 with TIES [Customer Name], 
			SUM([Profit]) OVER (PARTITION BY [Customer Name]) as Profit
	FROM [Project4].[dbo].[SuperStore]
	WHERE Segment = @Segment
	ORDER BY Profit DESC


EXEC TOP10CustomerBySegment @Segment = 'Corporate'
EXEC TOP10CustomerBySegment @Segment = 'Consumer'
EXEC TOP10CustomerBySegment @Segment = 'Home Office'


--4.Profit of Segment by Customer
SELECT *
FROM [Project4].[dbo].[SuperStore]


--CREATE FUNCTION to store information of all customers by all segments
CREATE FUNCTION ProfitOfCustomerBySegment
(
	@Segment varchar(max),
	@StartYear int,
	@EndYear int
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT  [Customer Name],
					[Segment], 
					SUM([Profit]) OVER (PARTITION BY [Customer Name]) AS Profit
	FROM   [Project4].[dbo].[SuperStore]
	WHERE Segment = @Segment AND YearOfOrderDate BETWEEN @StartYear AND @EndYear
	
-- Customer of Profit by Segment greater  than average profit

SELECT *
FROM ProfitOfCustomerBySegment('Corporate',2011,2014)
WHERE Profit > (SELECT AVG([Profit])  FROM [Project4].[dbo].[SuperStore])
ORDER BY Profit DESC

SELECT *
FROM ProfitOfCustomerBySegment('Consumer',2011,2014)
WHERE Profit > (SELECT AVG([Profit])  FROM [Project4].[dbo].[SuperStore])
ORDER BY Profit DESC

SELECT *
FROM ProfitOfCustomerBySegment('Home Office',2011,2014)
WHERE Profit > (SELECT AVG([Profit])  FROM [Project4].[dbo].[SuperStore])
ORDER BY Profit DESC
-

--Cumulative distrubtion of Customer of Profit
CREATE VIEW ProfitOfCustomerByCorporate AS 
	SELECT *
	FROM ProfitOfCustomerBySegment('Corporate',2011,2014)
-- The Ranking of Customer of Profit by Corporate
SELECT rank() OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC) AS Ranking, *
FROM ProfitOfCustomerByCorporate


SELECT [Customer Name], 
		[Profit], 
		FORMAT(CUME_DIST() OVER (ORDER BY [Profit] DESC), 'P2') as [Cumulative distribution]
FROM ProfitOfCustomerByCorporate
-- Customer with Profit by Corporate
With CustomerGeneratesProfit AS 
(
SELECT [Customer Name], 
		[Profit], 
		FORMAT(CUME_DIST() OVER (ORDER BY [Profit] DESC), 'P2') as [Cumulative distribution]
FROM ProfitOfCustomerByCorporate
)
SELECT *
FROM CustomerGeneratesProfit
WHERE [Profit] >= 1

-- Customer without Profit by Corporate
With CustomerWithoutProfit AS 
(
SELECT [Customer Name], 
		[Profit], 
		FORMAT(CUME_DIST() OVER (ORDER BY [Profit] DESC), 'P2') as [Cumulative distribution]
FROM ProfitOfCustomerByCorporate
)
SELECT *
FROM CustomerWithoutProfit
WHERE [Profit] <= 0


-- Profit of Customer  by Corporate year by year
--2011
SELECT *
FROM ProfitOfCustomerBySegment('Corporate',2011,2011)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2012
SELECT *
FROM ProfitOfCustomerBySegment('Corporate',2012,2012)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2013
SELECT *
FROM ProfitOfCustomerBySegment('Corporate',2013,2013)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2014
SELECT *
FROM ProfitOfCustomerBySegment('Corporate',2014,2014)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC





--Consumer
CREATE VIEW ProfitOfCustomerByConsumer AS 
	SELECT *
	FROM ProfitOfCustomerBySegment('Consumer',2011,2014)


-- The Ranking of Customer of Profit by Consumer
SELECT rank() OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC) as Ranking,*
FROM ProfitOfCustomerByConsumer
WHERE [Profit] >= 1
ORDER BY [Profit] DESC


-- Cumulative distrubtion of Customer by Consumer
SELECT [Customer Name], 
		[Profit], 
		FORMAT(CUME_DIST() OVER (ORDER BY [Profit] DESC), 'P2') as [Cumulative distribution]
FROM ProfitOfCustomerByConsumer


--  Customer with Profit by Consumer
With CustomerGeneratesProfit AS 
(
SELECT [Customer Name], 
		[Profit], 
		FORMAT(CUME_DIST() OVER (ORDER BY [Profit] DESC), 'P2') as [Cumulative distribution]
FROM ProfitOfCustomerByConsumer
)
SELECT *
FROM CustomerGeneratesProfit
WHERE [Profit] >= 1

--  Customer without Profit by Consumer

With CustomerWithoutProfit AS 
(
SELECT [Customer Name], 
		[Profit], 
		FORMAT(CUME_DIST() OVER (ORDER BY [Profit] DESC), 'P2') as [Cumulative distribution]
FROM ProfitOfCustomerByConsumer
)
SELECT *
FROM CustomerWithoutProfit
WHERE [Profit] <= 0

-- Profit of Customer  by Consumer year by year
--2011
SELECT *
FROM ProfitOfCustomerBySegment('Consumer',2011,2011)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2012
SELECT *
FROM ProfitOfCustomerBySegment('Consumer',2012,2012)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2013
SELECT *
FROM ProfitOfCustomerBySegment('Consumer',2013,2013)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2014
SELECT *
FROM ProfitOfCustomerBySegment('Consumer',2014,2014)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC

--Home Office
CREATE VIEW ProfitOfCustomerByHomeOffice AS 
	SELECT *
	FROM ProfitOfCustomerBySegment('Home Office',2011,2014)

-- The Ranking of Customer of Profit by Home Office
SELECT RANK() OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC) as Ranking,*
FROM ProfitOfCustomerByHomeOffice
WHERE [Profit] >= 1
ORDER BY [Profit] DESC


SELECT [Customer Name], 
		[Profit], 
		FORMAT(CUME_DIST() OVER (ORDER BY [Profit] DESC), 'P2') as [Cumulative distribution]
FROM ProfitOfCustomerByHomeOffice 

-- Customer with Profit by Home Office
With CustomerGeneratesProfit AS 
(
SELECT [Customer Name], 
		[Profit], 
		FORMAT(CUME_DIST() OVER (ORDER BY [Profit] DESC), 'P2') as [Cumulative distribution]
FROM ProfitOfCustomerByHomeOffice 
)
SELECT *
FROM CustomerGeneratesProfit
WHERE [Profit] >= 1

-- Customer without Profit by Home Office

With CustomerWithoutProfit AS 
(
SELECT [Customer Name], 
		[Profit], 
		FORMAT(CUME_DIST() OVER (ORDER BY [Profit] DESC), 'P2') as [Cumulative distribution]
FROM ProfitOfCustomerByHomeOffice 
)
SELECT *
FROM CustomerWithoutProfit
WHERE [Profit] <= 0

-- Profit of Customer  by Home Office year by year
--2011
SELECT *
FROM ProfitOfCustomerBySegment('Home Office',2011,2011)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2012
SELECT *
FROM ProfitOfCustomerBySegment('Home Office',2012,2012)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2013
SELECT *
FROM ProfitOfCustomerBySegment('Home Office',2013,2013)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2014
SELECT *
FROM ProfitOfCustomerBySegment('Home Office',2014,2014)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC


-- Customer with the greatest Profit and Lowest Profit by Corporate, Consumer and Home Office Segmentsin all years
-- it takes a lot of time MODIFY IT!!

WITH GreatestAndLowestProfitByCorporate ([Customer Name],[Segment],[Profit],[Customer with the greatest Profit by Corporate],[Customer with the lowest Profit by Corporate])  AS 
(
SELECT *, FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC) as [Customer with the greatest Profit by Corporate],
			LAST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) as [Customer with the lowest Profit by Corporate]
FROM ProfitOfCustomerByCorporate
WHERE [Profit] >= 1
), GreatestAndLowestProfitByConsumer ([Customer Name],[Segment],[Profit],[Customer with the greatest Profit by Consumer],[Customer with the lowest Profit by Consumer]) AS
(
SELECT *,
		FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC) as [Customer with the greatest Profit by Consumer],
		LAST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Profit by Consumer]
FROM ProfitOfCustomerByConsumer
WHERE [Profit] >= 1
), GreatestAndLowestProfitByHomeOffice ([Customer Name],[Segment],[Profit],[Customer with the greatest Profit by Home Office],[Customer with the lowest Profit by Home Office]) AS
(
SELECT *, FIRST_VALUE([Customer Name]) OVER ( PARTITION BY [Segment] ORDER BY [Profit] DESC) as [Customer with the greatest Profit by Home Office],
		LAST_VALUE([Customer Name]) OVER (PARTITION BY [Segment] ORDER BY [Profit] DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Customer with the lowest Profit by Home Office]
FROM ProfitOfCustomerByHomeOffice
WHERE [Profit] >= 1
)
SELECT DISTINCT GreatestAndLowestProfitByCorporate.[Customer with the greatest Profit by Corporate],
				MAX(GreatestAndLowestProfitByCorporate.[Profit]) OVER (PARTITION BY GreatestAndLowestProfitByCorporate.[Segment]) as [Profit],
				GreatestAndLowestProfitByCorporate.[Customer with the lowest Profit by Corporate],
				MIN(GreatestAndLowestProfitByCorporate.[Profit]) OVER (PARTITION BY GreatestAndLowestProfitByCorporate.[Segment]) as [Profit],
				GreatestAndLowestProfitByConsumer.[Customer with the greatest Profit by Consumer], 
				MAX(GreatestAndLowestProfitByConsumer.[Profit]) OVER (PARTITION BY GreatestAndLowestProfitByConsumer.[Segment]) as [Profit],
				GreatestAndLowestProfitByConsumer.[Customer with the lowest Profit by Consumer],
				MIN(GreatestAndLowestProfitByConsumer.[Profit]) OVER (PARTITION BY GreatestAndLowestProfitByConsumer.[Segment]) as [Profit],
				GreatestAndLowestProfitByHomeOffice.[Customer with the greatest Profit by Home Office],
				MAX(GreatestAndLowestProfitByHomeOffice.[Profit]) OVER (PARTITION BY GreatestAndLowestProfitByHomeOffice.[Segment]) as [Profit],
				GreatestAndLowestProfitByHomeOffice.[Customer with the lowest Profit by Home Office],
				MIN(GreatestAndLowestProfitByHomeOffice.[Profit]) OVER (PARTITION BY GreatestAndLowestProfitByHomeOffice.[Segment]) as [Profit]
FROM GreatestAndLowestProfitByCorporate,GreatestAndLowestProfitByConsumer,GreatestAndLowestProfitByHomeOffice

-- Profit of Category and Profit of Customer by Category
SELECT *
FROM [Project4].[dbo].[SuperStore]


CREATE PROCEDURE ProfitOfCategoryByYear  @StartYear int, @EndYear int
AS
	SELECT DISTINCT [Category],		
				SUM([Profit]) OVER (PARTITION BY [Category]) as [Profit]
	FROM [Project4].[dbo].[SuperStore]
	WHERE YearOfOrderDate BETWEEN @StartYear AND @EndYear
	ORDER BY [Profit] DESC
GO

-- Profit of Category in all years
EXEC ProfitOfCategoryByYear @StartYear = 2011, @EndYear = 2014
-- Profit of Category year over year
EXEC ProfitOfCategoryByYear @StartYear = 2011, @EndYear = 2011
EXEC ProfitOfCategoryByYear @StartYear = 2012, @EndYear = 2012
EXEC ProfitOfCategoryByYear @StartYear = 2013, @EndYear = 2013
EXEC ProfitOfCategoryByYear @StartYear = 2014, @EndYear = 2014
--Profit of Customer by Category 
--CREATE FUNCTION TO STORE DATA
CREATE FUNCTION ProfitOfCategoryByCustomer 
(
@Category nvarchar(max),
@StartYear int,
@EndYear int
)
RETURNS TABLE
AS
RETURN	
	SELECT DISTINCT [Customer Name], [Category], SUM([Profit]) OVER (PARTITION BY [Customer Name]) as Profit
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Category] = @Category and YearOfOrderDate BETWEEN @StartYear AND @EndYear

--Customer of Profit by Technology
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking, *
FROM ProfitOfCategoryByCustomer('Technology',2011,2014)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
-- Customer of Profit by Technolog year over year
--2011
SELECT *
FROM ProfitOfCategoryByCustomer('Technology',2011,2011)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2012
SELECT *
FROM ProfitOfCategoryByCustomer('Technology',2012,2012)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2013
SELECT *
FROM ProfitOfCategoryByCustomer('Technology',2013,2013)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2014
SELECT *
FROM ProfitOfCategoryByCustomer('Technology',2014,2014)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC


--Customer of Profit by Technology greater than average profit
SELECT *
FROM ProfitOfCategoryByCustomer('Technology',2011,2014)
WHERE [Profit] > (SELECT AVG([Profit]) FROM [Project4].[dbo].[SuperStore] WHERE [Category] = 'Technology')
ORDER BY [Profit] DESC
--TOP 10 Customers of Profit by Technology
SELECT TOP 10 with TIES *
FROM ProfitOfCategoryByCustomer('Technology',2011,2014)
ORDER BY [Profit] DESC

--Group of Sales of  Customers by Technology
WITH GroupOfProfitByTechnology AS (
SELECT *, NTILE(3) OVER (ORDER BY [Profit] DESC) as Buckets
FROM ProfitOfCategoryByCustomer('Technology',2011,2014)
WHERE [Profit] >= 1
)
SELECT [Customer Name], 
		CASE 
			WHEN Buckets = 1 THEN 'High Profit'
			WHEN Buckets = 2 THEN 'Mid Profit'
			WHEN Buckets = 3 THEN 'Low Profit'
		END AS [Level of Profit]
FROM GroupOfProfitByTechnology
ORDER BY [Profit] DESC

--Cumulative distrubution of Profit by Customer for Technology
SELECT *, CAST(ROUND((cume_dist()  OVER (PARTITION BY [Category] ORDER BY [Profit] DESC))*100,2) AS FLOAT) as [Cumulative Distribution (%)]
FROM ProfitOfCategoryByCustomer('Technology',2011,2014)

--Cumulative distrubution of Profit by Customer for Technology with Profit
WITH CustomerwithProfitByCategory AS (	
SELECT *, CAST(ROUND((cume_dist()  OVER (PARTITION BY [Category] ORDER BY [Profit] DESC))*100,2) AS FLOAT) as [Cumulative Distribution (%)]
FROM ProfitOfCategoryByCustomer('Technology',2011,2014)
)
SELECT [Customer Name], [Category], [Profit],  [Cumulative Distribution (%)]
FROM CustomerwithProfitByCategory
WHERE  [Cumulative Distribution (%)] <= 77

--Cumulative distrubution of Profit by Customer for Technology without Profit
WITH CustomerwithoutProfitByCategory AS (	
SELECT *, CAST(ROUND((cume_dist()  OVER (PARTITION BY [Category] ORDER BY [Profit] DESC))*100,2) AS FLOAT)  as [Cumulative Distribution (%)]
FROM ProfitOfCategoryByCustomer('Technology',2011,2014)
)
SELECT [Customer Name], [Category], [Profit], [Cumulative Distribution (%)]
FROM CustomerwithoutProfitByCategory
WHERE [Cumulative Distribution (%)] >= 77

--Customer of Profit by Office Supplies
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking,*
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2014)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
-- Customer of Profit by Office Supplies year over year
--2011
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking,*
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2011)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2012
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking,*
FROM ProfitOfCategoryByCustomer('Office Supplies',2012,2012)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2013
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking,*
FROM ProfitOfCategoryByCustomer('Office Supplies',2013,2013)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2014
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking,*
FROM ProfitOfCategoryByCustomer('Office Supplies',2014,2014)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
-- Customer of Profit by Office Supplies greater than average profit
SELECT *
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2014)
WHERE [Profit] > (SELECT AVG([Profit]) FROM [Project4].[dbo].[SuperStore] WHERE [Category] = 'Office Supplies')
ORDER BY [Profit] DESC 

-- TOP 10 Customers of Profit by Office Supplies
SELECT TOP 10 with TIES *
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2014)
ORDER BY [Profit] DESC
-- Group of Sales of Customer by Office Supplies
WITH GroupOfProfitByOfficeSupplies AS (
SELECT *, NTILE(3) OVER (ORDER BY [Profit] DESC) as Buckets
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2014)
WHERE [Profit] >= 1
)
SELECT [Customer Name],
	CASE
		WHEN Buckets = 1 THEN 'High Profit'
		WHEN Buckets = 2 THEN 'Mid Profit'
		WHEN Buckets = 3 THEN 'Low Profit'
	END AS [Level of Profit]
FROM GroupOfProfitByOfficeSupplies
ORDER BY [Profit] DESC 

--Cumulative Distribution of Profit by Customer for Office Suplies
SELECT *, CAST(ROUND((cume_dist() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC))*100,2) AS FLOAT) as [Cumulative Distribution (%)]
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2014)
--Cumulative distrubution of Profit by Customer for Office Supplies with Profit
WITH CustomerwithProfitByOfficeSupplies AS (
SELECT *, CAST(ROUND((cume_dist() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC))*100,2) AS FLOAT) as [Cumulative Distribution (%)]
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2014)
)
SELECT *
FROM CustomerwithProfitByOfficeSupplies
WHERE [Cumulative Distribution (%)] <= 75.55

--Cumulative distrubution of Profit by Customer for Office Supplies without Profit
WITH CustomerwithProfitByOfficeSupplies AS (
SELECT *, CAST(ROUND((cume_dist() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC))*100,2) AS FLOAT) as [Cumulative Distribution (%)]
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2014)
)
SELECT *
FROM CustomerwithProfitByOfficeSupplies
WHERE [Cumulative Distribution (%)] >= 75.55


--Customer of Profit by Furniture
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking, *
FROM ProfitOfCategoryByCustomer('Furniture',2011,2014)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC

-- Customer of Profit by Furniture year by year
--2011
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking, *
FROM ProfitOfCategoryByCustomer('Furniture',2011,2011)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2012
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking, *
FROM ProfitOfCategoryByCustomer('Furniture',2012,2012)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2013
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking, *
FROM ProfitOfCategoryByCustomer('Furniture',2013,2013)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--2014
SELECT RANK() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as Ranking, *
FROM ProfitOfCategoryByCustomer('Furniture',2014,2014)
WHERE [Profit] >= 1
ORDER BY [Profit] DESC
--Customer of Profit by Furniture greater than average 
SELECT *
FROM ProfitOfCategoryByCustomer('Furniture',2011,2014)
WHERE [Profit] > (SELECT AVG([Profit]) FROM [Project4].[dbo].[SuperStore] WHERE [Category] = 'Furniture')
ORDER BY [Profit] DESC

-- TOP 10 Customer of Profit by Furniture
SELECT TOP 10 with TIES *
FROM ProfitOfCategoryByCustomer('Furniture',2011,2014)
ORDER BY [Profit] DESC


--Group of Customer of Profit by Furniture
WITH GroupOfThreeLevels AS (
SELECT *, NTILE(3) OVER (ORDER BY [Profit] DESC) as Buckets
FROM ProfitOfCategoryByCustomer('Furniture',2011,2014)
WHERE [Profit] >= 1 

)
SELECT [Customer Name],
	CASE	
		WHEN Buckets = 1 THEN 'High Profit'
		WHEN Buckets = 2 THEN 'Mid Profit'
		WHEN Buckets = 3 THEN 'Low Profit'
	END AS [Level of Profit]
FROM GroupOfThreeLevels
ORDER BY [Profit] DESC
--Cumulative Distrubtion of Profit of Customer by Furniture

SELECT *, CAST(ROUND(CUME_DIST() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC)*100,2) AS FLOAT) as [Cumulative Distrubution (%)]
FROM ProfitOfCategoryByCustomer('Furniture',2011,2014)
-- Cumulative Distrubtion of Customer by Furniture with Profit
WITH CustomerWithProfitByFurniture AS (
SELECT *, CAST(ROUND(CUME_DIST() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC)*100,2) AS FLOAT) as [Cumulative Distrubution (%)]
FROM ProfitOfCategoryByCustomer('Furniture',2011,2014)
)
SELECT *
FROM CustomerWithProfitByFurniture
WHERE [Cumulative Distrubution (%)] <= 50.20
-- Cumulative Distrubtion of Customer by Furniture without Profit
WITH CustomerWithProfitByFurniture AS (
SELECT *, CAST(ROUND(CUME_DIST() OVER (PARTITION BY [Category] ORDER BY [Profit] DESC)*100,2) AS FLOAT) as [Cumulative Distrubution (%)]
FROM ProfitOfCategoryByCustomer('Furniture',2011,2014)
)
SELECT *
FROM CustomerWithProfitByFurniture
WHERE [Cumulative Distrubution (%)] >= 50.20


WITH CustomerOfMaxProfitByCategory AS (
SELECT DISTINCT 
		[Category],
		FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as [Customer with the greatest Profit],
		MAX([Profit]) OVER (PARTITION BY [Category]) as [Profit]
FROM ProfitOfCategoryByCustomer('Technology',2011,2014)
WHERE [Profit] >= 1
UNION
SELECT DISTINCT
	[Category],
	FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as [Customer with the greatest Profit],
	MAX([Profit]) OVER (PARTITION BY [Category]) as [Profit]
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2014)
WHERE [Profit] >= 1
UNION
SELECT DISTINCT
	[Category],
	FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Profit] DESC) as [Customer with the greatest Profit],
	MAX([Profit]) OVER (PARTITION BY [Category]) as [Profit]
FROM ProfitOfCategoryByCustomer('Furniture',2011,2014)
WHERE [Profit] >= 1
), CustomerOfMinProfitByCategory AS
(
SELECT DISTINCT 
		[Category],
		LAST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Profit] DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) as [Customer with the greatest Profit],
		MIN([Profit]) OVER (PARTITION BY [Category]) as [Profit]
FROM ProfitOfCategoryByCustomer('Technology',2011,2014)
WHERE [Profit] >= 1
UNION
SELECT DISTINCT
	[Category],
	LAST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Profit] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	) as [Customer with the greatest Profit],
	MIN([Profit]) OVER (PARTITION BY [Category]) as [Profit]
FROM ProfitOfCategoryByCustomer('Office Supplies',2011,2014)
WHERE [Profit] >= 1
UNION
SELECT DISTINCT
	[Category],
	LAST_VALUE([Customer Name]) OVER (PARTITION BY [Category] ORDER BY [Profit] DESC
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	) as [Customer with the greatest Profit],
	MIN([Profit]) OVER (PARTITION BY [Category]) as [Profit]
FROM ProfitOfCategoryByCustomer('Furniture',2011,2014)
WHERE [Profit] >= 1
)
SELECT *
FROM CustomerOfMaxProfitByCategory maxcat
	JOIN CustomerOfMinProfitByCategory mincat
		on maxcat.[Category] = mincat.[Category]
ORDER BY maxcat.[Profit] DESC


-- Profit of Ship Mode Year by Year
CREATE PROCEDURE ProfitOfShipModeByYear  @StartYear int, @EndYear int
AS
SELECT DISTINCT [Ship Mode], SUM([Profit]) OVER (PARTITION BY [Ship Mode]) as Profit
FROM [Project4].[dbo].[SuperStore]
WHERE  [YearOfOrderDate] BETWEEN @StartYear AND @EndYear
ORDER BY [Profit] DESC
GO

EXEC ProfitOfShipModeByYear @StartYear = 2011, @EndYear = 2014
EXEC ProfitOfShipModeByYear  @StartYear = 2011, @EndYear = 2011
EXEC ProfitOfShipModeByYear  @StartYear = 2012, @EndYear = 2012
EXEC ProfitOfShipModeByYear  @StartYear = 2013, @EndYear = 2013
EXEC ProfitOfShipModeByYear  @StartYear = 2014, @EndYear = 2014


SELECT DISTINCT [Ship Mode]
FROM [Project4].[dbo].[SuperStore]
-- CREATE FUNCTION TO SHOW PROFIT OF SHIP MODE BY CUSTOMER 
CREATE FUNCTION ProfitOfShipModeByCustomers
(
	@ShipMode nvarchar(MAX),
	@StartYear int,
	@EndYear int
)
RETURNS TABLE
AS 
RETURN
	SELECT DISTINCT [Customer Name], [Ship Mode], SUM([Profit]) OVER (PARTITION BY [Customer Name]) as Profit
	FROM [Project4].[dbo].[SuperStore]
	WHERE [Ship Mode] = @ShipMode AND [YearOfOrderDate] BETWEEN @StartYear AND @EndYear


-- Profit of Customer by  First Class
SELECT *
FROM ProfitOfShipModeByCustomers('First Class', 2011, 2014) 
ORDER BY [Profit] DESC
-- Profit of Customer by First Class year over year
--2011
SELECT *
FROM ProfitOfShipModeByCustomers('First Class', 2011, 2014) 
ORDER BY [Profit] DESC
--2012
SELECT *
FROM ProfitOfShipModeByCustomers('First Class', 2012, 2012) 
ORDER BY [Profit] DESC
--2013
SELECT *
FROM ProfitOfShipModeByCustomers('First Class', 2013, 2013) 
ORDER BY [Profit] DESC
--2014
SELECT *
FROM ProfitOfShipModeByCustomers('First Class', 2014, 2014) 
ORDER BY [Profit] DESC


-- Profit of Customer by  Same Day
SELECT *
FROM ProfitOfShipModeByCustomers('Same Day', 2011, 2014) 
ORDER BY [Profit] DESC
-- Profit of Customer by First Class year over year
--2011
SELECT *
FROM ProfitOfShipModeByCustomers('Same Day', 2011, 2014) 
ORDER BY [Profit] DESC
--2012
SELECT *
FROM ProfitOfShipModeByCustomers('Same Day', 2012, 2012) 
ORDER BY [Profit] DESC
--2013
SELECT *
FROM ProfitOfShipModeByCustomers('Same Day', 2013, 2013) 
ORDER BY [Profit] DESC
--2014
SELECT *
FROM ProfitOfShipModeByCustomers('Same Day', 2014, 2014) 
ORDER BY [Profit] DESC



-- Profit of Customer by  Standard Class
SELECT *
FROM ProfitOfShipModeByCustomers('Standard Class', 2011, 2014) 
ORDER BY [Profit] DESC
-- Profit of Customer by First Class year over year
--2011
SELECT *
FROM ProfitOfShipModeByCustomers('Standard Class', 2011, 2014) 
ORDER BY [Profit] DESC
--2012
SELECT *
FROM ProfitOfShipModeByCustomers('Standard Class', 2012, 2012) 
ORDER BY [Profit] DESC
--2013
SELECT *
FROM ProfitOfShipModeByCustomers('Standard Class', 2013, 2013) 
ORDER BY [Profit] DESC
--2014
SELECT *
FROM ProfitOfShipModeByCustomers('Standard Class', 2014, 2014) 
ORDER BY [Profit] DESC


-- Profit of Customer by  Second Class
SELECT *
FROM ProfitOfShipModeByCustomers('Second Class', 2011, 2014) 
ORDER BY [Profit] DESC
-- Profit of Customer by First Class year over year
--2011
SELECT *
FROM ProfitOfShipModeByCustomers('Second Class', 2011, 2014) 
ORDER BY [Profit] DESC
--2012
SELECT *
FROM ProfitOfShipModeByCustomers('Second Class', 2012, 2012) 
ORDER BY [Profit] DESC
--2013
SELECT *
FROM ProfitOfShipModeByCustomers('Second Class', 2013, 2013) 
ORDER BY [Profit] DESC
--2014
SELECT *
FROM ProfitOfShipModeByCustomers('Second Class', 2014, 2014) 
ORDER BY [Profit] DESC

-- The greatest and lowest Profit of Ship Mode by Customer
WITH TheGreatestProfitofCustomerByShipMode AS 
(
	SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC) as [The greatest profit of Customer by Ship Mode],
			MAX([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Greatest Profit]
	FROM ProfitOfShipModeByCustomers('Same Day', 2011, 2014) 
	WHERE [Profit] >= 1
	UNION
	SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC) as [The greatest profit of Customer by Ship Mode],
			MAX([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Greatest Profit]
	FROM ProfitOfShipModeByCustomers('First Class', 2011, 2014) 
	WHERE [Profit] >= 1
	UNION
	SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC) as [The greatest profit of Customer by Ship Mode],
			MAX([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Greatest Profit]
	FROM ProfitOfShipModeByCustomers('Standard Class', 2011, 2014) 
	WHERE [Profit] >= 1
	UNION
	SELECT DISTINCT [Ship Mode], FIRST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC) as [The greatest profit of Customer by Ship Mode],
			MAX([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Greatest Profit]
	FROM ProfitOfShipModeByCustomers('Second Class', 2011, 2014) 
	WHERE [Profit] >= 1
), TheLowestProfitofCustomerByShipMode AS
(
	SELECT DISTINCT [Ship Mode], LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest profit of Customer by Ship Mode],
			MIN([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Lowest Profit]
	FROM ProfitOfShipModeByCustomers('Same Day', 2011, 2014) 
	WHERE [Profit] >= 1
	UNION
	SELECT DISTINCT [Ship Mode], LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest profit of Customer by Ship Mode],
			MIN([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Lowest Profit]
	FROM ProfitOfShipModeByCustomers('First Class', 2011, 2014) 
	WHERE [Profit] >= 1
	UNION
	SELECT DISTINCT [Ship Mode], LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest profit of Customer by Ship Mode],
			MIN([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Lowest Profit]
	FROM ProfitOfShipModeByCustomers('Standard Class', 2011, 2014) 
	WHERE [Profit] >= 1
	UNION
	SELECT DISTINCT [Ship Mode], LAST_VALUE([Customer Name]) OVER (PARTITION BY [Ship Mode] ORDER BY [Profit] DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [The lowest profit of Customer by Ship Mode],
			MIN([Profit]) OVER (PARTITION BY [Ship Mode]) as [The Lowest Profit]
	FROM ProfitOfShipModeByCustomers('Second Class', 2011, 2014) 
	WHERE [Profit] >= 1
)
SELECT SMGP.[Ship Mode],	
	SMGP.[The greatest profit of Customer by Ship Mode], 
	SMGP.[The Greatest Profit],
	SMLP.[The lowest profit of Customer by Ship Mode],
	SMLP.[The Lowest Profit]
FROM TheGreatestProfitofCustomerByShipMode SMGP 
	JOIN TheLowestProfitofCustomerByShipMode SMLP
		ON SMGP.[Ship Mode] = SMLP.[Ship Mode]


--Create One Table by CTE and PUT MAX AND MIN Profit and Sales by all things which were made
-- Profit And Sales -> Ship Mode
-- Profit And Sales -> Category
-- Profit And Sales -> Segment
-- Try to USE HAVING




--4.c) Average of Sales, Profit and Shipping Cost by Customer
SELECT DISTINCT [Customer Name], 
		ROUND(AVG(Sales) OVER (PARTITION BY [Customer Name]),2) as [Average Sales],
		ROUND(AVG([Profit]) OVER (PARTITION BY [Customer Name]),2) as [Average Profit],
		ROUND(AVG([Shipping Cost]) OVER (PARTITION BY [Customer Name]),2) as [Average Shipping Cost]
FROM  [Project4].[dbo].[SuperStore]



SELECT *
FROM [Project4].[dbo].[SuperStore]



-- Runinng Total ETC !! by month datepart quarter etc using it !!!
--4.c) The Quantity of Orders by Segment-- give it percetnage??
SELECT DISTINCT [Segment], count(*) OVER (PARTITION BY [Segment]) as [The Quantity of Orders],
	SUM([Sales]) OVER (PARTITION BY [Segment]) as Sales
FROM   [Project4].[dbo].[SuperStore]
ORDER BY [The Quantity of Orders] DESC

--4.d) The Quantity of Orders by City-- give it percetnage??
SELECT DISTINCT [City], count(*) OVER (PARTITION BY [City]) as [The Quantity of Orders]
FROM   [Project4].[dbo].[SuperStore]
ORDER BY [The Quantity of Orders] DESC

--4.e) The Quantity of Orders by State-- give it percetnage??
SELECT DISTINCT [State], count(*) OVER (PARTITION BY [State]) as [The Quantity of Orders]
FROM   [Project4].[dbo].[SuperStore]
ORDER BY [The Quantity of Orders] DESC

--4.f) The Quantity of Orders by Country-- give it percetnage??
SELECT DISTINCT [Country], count(*) OVER (PARTITION BY [Country]) as [The Quantity of Orders]
FROM   [Project4].[dbo].[SuperStore]
ORDER BY [The Quantity of Orders] DESC

--4.g) The Quantity of Orders by Market-- give it percetnage??
SELECT DISTINCT [Market], count(*) OVER (PARTITION BY [Market]) as [The Quantity of Orders]
FROM   [Project4].[dbo].[SuperStore]
ORDER BY [The Quantity of Orders] DESC

--4.h) The Quantity of Orders by Region-- give it percetnage??
SELECT DISTINCT [Region], count(*) OVER (PARTITION BY [Region]) as [The Quantity of Orders]
FROM   [Project4].[dbo].[SuperStore]
ORDER BY [The Quantity of Orders] DESC

--4.i) The Quantity of Orders by Category-- give it percetnage??
SELECT DISTINCT [Category], count(*) OVER (PARTITION BY [Category]) as [The Quantity of Orders]
FROM   [Project4].[dbo].[SuperStore]
ORDER BY [The Quantity of Orders] DESC

--4.j) The Quantity of Orders by Sub-Category-- give it percetnage??
SELECT DISTINCT [Sub-Category], count(*) OVER (PARTITION BY [Sub-Category]) as [The Quantity of Orders]
FROM   [Project4].[dbo].[SuperStore]
ORDER BY [The Quantity of Orders] DESC

--4.k) The Quantity of Orders by Product Name-- give it percetnage??
SELECT DISTINCT [Product Name], count(*) OVER (PARTITION BY [Product Name]) as [The Quantity of Orders]
FROM   [Project4].[dbo].[SuperStore]
ORDER BY [The Quantity of Orders] DESC

--4.l) The Quantity of Orders by Order Priority-- give it percetnage??
SELECT DISTINCT [Order Priority], count(*) OVER (PARTITION BY [Order Priority]) as [The Quantity of Orders]
FROM   [Project4].[dbo].[SuperStore]
ORDER BY [The Quantity of Orders] DESC
-- Shipping cost!!
-- Running TOtal per motnh etc etc
SELECT DISTINCT SUM([Sales]) OVER (PARTITION BY YearOfOrderDate) as SalesPerYear, [YearOfOrderDate]
FROM   [Project4].[dbo].[SuperStore]
 


--1. Normal
SELECT [Customer ID],DATENAME(MONTH,[OrderDate]) as [Month], [Sales]
FROM [Project4].[dbo].[SuperStore]
WHERE [YearOfOrderDate] = 2011
--1. PIVOT

SELECT [Category], [January], [February], [March]
FROM
(
	SELECT [Category],DATENAME(MONTH,[OrderDate]) as [Month], [Sales]
	FROM [Project4].[dbo].[SuperStore]
	WHERE [YearOfOrderDate] = 2011
) as SrC
PIVOT
(
	SUM([Sales])
	FOR [Month] IN ([January], [February], [March])

) AS PvT

--3. The difference of days between Order and Ship

SELECT [OrderDate], [ShipDate], DATEDIFF(day,[OrderDate],[ShipDate]) as [Difference of days Between Ship and Order Date]
FROM [Project4].[dbo].[SuperStore]

SELECT [OrderDate], [ShipDate], DATEPART(QQ, [OrderDate]) as QOrder, VAR(Sales) OVER (PARTITION BY OrderDate) as A
FROM   [Project4].[dbo].[SuperStore]

SELECT VALUE FROM string_split('Lukasz Dlugozima', ' ')





