
USE master;
GO

-- 1. Database Recreation
IF DB_ID('EgyptianRealEstate') IS NOT NULL
BEGIN
    ALTER DATABASE EgyptianRealEstate SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE EgyptianRealEstate;
END
GO

CREATE DATABASE EgyptianRealEstate;
GO

USE EgyptianRealEstate;
GO

-- 2. Table Creation
IF OBJECT_ID('EgyptianRealEstateListings', 'U') IS NOT NULL
    DROP TABLE EgyptianRealEstateListings;
GO

CREATE TABLE EgyptianRealEstateListings (
    url             NVARCHAR(MAX),
    price           NVARCHAR(50),
    description     NVARCHAR(MAX),
    location        NVARCHAR(MAX),
    type            NVARCHAR(50),
    size            NVARCHAR(100),
    bedrooms        NVARCHAR(50),
    bathrooms       NVARCHAR(50),
    available_from  NVARCHAR(50),
    payment_method  NVARCHAR(50),
    down_payment    NVARCHAR(MAX)
);
GO

-- 3. Loading Procedure
CREATE OR ALTER PROCEDURE sp_LoadRealEstateData 
AS

-- Truncates and reloads real estate data from local CSV.

BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Start_time DATETIME = GETDATE();
    DECLARE @End_time   DATETIME;

    BEGIN TRY
        PRINT 'Loading...'
        
        TRUNCATE TABLE EgyptianRealEstateListings;

        BULK INSERT EgyptianRealEstateListings
        FROM 'F:\archive (5)\egypt_real_estate_listings.csv'
        WITH (
            FIRSTROW        = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR   = '\r\n', 
            FIELDQUOTE      = '"',
            TABLOCK,
            CODEPAGE        = '65001', 
            KEEPNULLS  
        );

        SET @End_time = GETDATE();
        PRINT 'Loaded Successfully';
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @Start_time, @End_time) AS NVARCHAR) + ' seconds.';
    END TRY

    BEGIN CATCH
        PRINT 'ERROR OCCURRED DURING LOADING'
        PRINT 'Error Message: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
