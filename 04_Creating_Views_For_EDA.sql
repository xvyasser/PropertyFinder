USE EgyptianRealEstate;
GO

-- Creating Analytical Views For EDA
-- 1- Overall Summary By Property Type:
CREATE OR ALTER VIEW PropertyTypeSummary_VW AS
SELECT	
		pt.Type AS Type,
		COUNT(*) AS TotalListings,
		Avg(f.FullPrice) AS AvgPrice,
		MAX(f.FullPrice) AS MaxPrice,
		MIN(f.FullPrice) AS MinPrice,
		AVG(f.SizeSqm) AS AvgSizeSqm
FROM Fact_RealEstateListings f
INNER JOIN Dim_PropertyType pt ON f.TypeID = pt.TypeID
GROUP BY pt.Type;
GO
--2- Top 10 Properties By Price
CREATE OR ALTER VIEW Top10ByPrice_VW AS
SELECT TOP 10
	 pt.Type AS Type,
	 l.District AS District,
	 l.Area AS Area,
	 l.City AS City,
	 l.Governorate AS Governorate,
	 f.SizeSqm AS SizeSqm,
	 f.Bedrooms AS Bedrooms,
	 f.Bathrooms AS Bathrooms,
	 f.FullPrice AS FullPrice,
	 pm.PaymentMethod AS PaymentMethod
FROM Fact_RealEstateListings f
INNER JOIN Dim_PropertyType pt ON f.TypeID = pt.TypeID
INNER JOIN Dim_Location l ON f.LocationID = l.LocationID
INNER JOIN Dim_PaymentMethod pm ON f.PaymentMethodID = pm.PaymentMethodID
WHERE l.District IS NOT NULL
	  AND l.City IS NOT NULL
      AND l.Area IS NOT NULL
	  AND l.Governorate IS NOT NULL
ORDER BY f.FullPrice DESC;
GO

-- 3- Price Quartiles By Property Type

CREATE OR ALTER VIEW PriceQuartilesByType_VW AS
SELECT DISTINCT
     pt.Type AS Type,
     COUNT(*) OVER(PARTITION BY pt.Type) AS TotalCount,
     PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY f.FullPrice) OVER(PARTITION BY pt.Type) AS Q1,
     PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY f.FullPrice) OVER(PARTITION BY pt.Type) AS MedianPrice,
     PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY f.FullPrice) OVER(PARTITION BY pt.Type) AS Q3,
     PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY f.FullPrice) OVER(PARTITION BY pt.Type) -
     PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY f.FullPrice) OVER(PARTITION BY pt.Type) AS IQR,
     AVG(f.FullPrice) OVER(PARTITION BY pt.Type) AS AvgPrice,
     STDEV(f.FullPrice) OVER(PARTITION BY pt.Type) AS StdDev
FROM Fact_RealEstateListings f
INNER JOIN Dim_PropertyType pt ON f.TypeID = pt.TypeID;
GO

