USE EgyptianRealEstate;
GO
SELECT * FROM dbo.EgyptianRealEstateListings;

--CREATING Backup Table
SELECT *
INTO dbo.EgyptianRealEstateListings_backup
FROM dbo.EgyptianRealEstateListings;
GO

--Adding an ID Column:

ALTER TABLE EgyptianRealEstateListings
ADD ListingID INT IDENTITY(1,1) PRIMARY KEY

 --Data Quality Check :

SELECT
	COUNT(*) AS TotalRows,
	DISTINCT ListingID AS UniqueListings
FROM EgyptianRealEstateListings;
GO


-- Checking for NULL prices and handling them :

 SELECT price,description,location,type FROM dbo.EgyptianRealEstateListings
 WHERE price IS NULL;
 GO


 -- Deleting Rows where price, description and location are NULLS :
 WITH NULLS AS(
 SELECT * FROM dbo.EgyptianRealEstateListings
 WHERE price IS NULL
 AND description IS NULL
 AND location IS NULL)

DELETE FROM NULLS;

-- Creating a new Column for Size in Sqm:

ALTER TABLE dbo.EgyptianRealEstateListings
ADD Size_Sqm INT;

UPDATE dbo.EgyptianRealEstateListings
SET Size_Sqm = 
			CAST(REPLACE(
					TRIM(
						SUBSTRING(size,CHARINDEX('/',size)+1,CHARINDEX('sqm',size)-CHARINDEX('/',size)-1))
						,',','') AS INT);
GO

ALTER TABLE dbo.EgyptianRealEstateListings
DROP COLUMN size;
GO

--Changing available_from column type from String to Date and Handling the NULLS :

ALTER TABLE dbo.EgyptianRealEstateListings
ADD availableFrom DATE;

UPDATE  dbo.EgyptianRealEstateListings
SET availableFROM = CONVERT(DATE,ISNULL(available_from,'2025-08-01'),106)
GO

ALTER TABLE dbo.EgyptianRealEstateListings
DROP COLUMN available_from;

--Splitting the Location column to Disrtict, Area, City and Governorate

ALTER TABLE dbo.EgyptianRealEstateListings
ADD district NVARCHAR(50),
	area NVARCHAR(50),
	city NVARCHAR(50),
	governorate NVARCHAR(50);

UPDATE dbo.EgyptianRealEstateListings
SET 
	district = TRIM(PARSENAME(REPLACE(location, ',', '.'), 4)),    
    area = TRIM(PARSENAME(REPLACE(location, ',', '.'), 3)),        
    city = TRIM(PARSENAME(REPLACE(location, ',', '.'), 2)),         
    governorate = TRIM(PARSENAME(REPLACE(location, ',', '.'), 1));   

GO

--Changing price from String to INT:

ALTER TABLE dbo.EgyptianRealEstateListings
ADD FullPrice INT

UPDATE dbo.EgyptianRealEstateListings
SET FullPrice = CAST(REPLACE(TRIM(price),',','') AS INT);
GO

ALTER TABLE dbo.EgyptianRealEstateListings
DROP COLUMN price;

-- Changing down_payment column type from String to INT and handling the NULLS:

ALTER TABLE dbo.EgyptianRealEstateListings
ADD downPayment INT;

UPDATE dbo.EgyptianRealEstateListings
SET downPayment = 
CASE WHEN down_payment IS NULL and payment_method = 'Cash' THEN FullPrice
     WHEN down_payment IS NULL and payment_method = 'Installments' THEN FullPrice*0.1
	 WHEN down_payment IS NOT NULL THEN CAST(REPLACE(TRIM(SUBSTRING(down_payment,1,CHARINDEX(' ',down_payment)-1)),',','') AS INT)
	 ELSE NULL
END;

-- Handling NULLS in the price column

WITH AvgPrice AS(
SELECT type, AVG(CAST(FullPrice AS BIGINT)) AS AvgPrice
FROM EgyptianRealEstateListings
WHERE FullPrice IS NOT NULL
GROUP BY type)

UPDATE a 
SET a.FullPrice = b.AvgPrice
FROM EgyptianRealEstateListings AS a
INNER JOIN AvgPrice AS b
ON a.type = b.type
WHERE a.FullPrice IS NULL

-- Dropping the URL and down_payment Columns

ALTER TABLE EgyptianRealEstateListings
DROP COLUMN url

ALTER TABLE EgyptianRealEstateListings
DROP COLUMN down_payment

--Changing Bedrooms and Bathrooms Column Type

UPDATE EgyptianRealEstateListings
SET bedrooms = TRY_CAST(
                   CASE 
                       WHEN bedrooms LIKE '%studio%' THEN '0'
                       ELSE SUBSTRING(bedrooms, PATINDEX('%[0-9]%', bedrooms), LEN(bedrooms))
                   END AS INT
               ),
    bathrooms = TRY_CAST(bathrooms AS INT);

-- Changing FullPrice Type

UPDATE EgyptianRealEstateListings
SET FullPrice = CAST(FullPrice AS DECIMAL(18,2))

--Checking and Handling Outliers in the downPayment Column :

SELECT FullPrice,downPayment,payment_method
FROM EgyptianRealEstateListings
WHERE  downPayment < 10000

UPDATE EgyptianRealEstateListings
SET downPayment =
CASE WHEN downPayment < 10000 AND payment_method ='Installments' THEN FullPrice *0.1
WHEN downPayment <> FullPrice AND payment_method = 'Cash' THEN FullPrice
ELSE downPayment
END

-- Dropping Null Values in Location Column:

WITH NullLocation AS(
SELECT * FROM EgyptianRealEstateListings
where location IS NULL)

DELETE FROM NullLocation


-- Handling Null Values In Payment Method and Down Payment Columns :

SELECT * FROM EgyptianRealEstateListings
WHERE payment_method IS NULL AND downPayment IS NULL

UPDATE EgyptianRealEstateListings
SET payment_method =
	CASE WHEN payment_method IS NULL Then 'Cash'
	ELSE payment_method
	END,

downPayment =
	CASE WHEN downPayment IS NULL Then FullPrice
	ELSE downPayment
	END;

