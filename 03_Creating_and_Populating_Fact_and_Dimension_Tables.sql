USE EgyptianRealEstate;
GO

-- Creating Dimension Tables

--Creating Property Type Dim Table :

CREATE TABLE Dim_PropertyType(
TypeID INT IDENTITY(1,1) PRIMARY KEY,
Type NVARCHAR(50) UNIQUE NOT NULL);
GO

--Creating Location Dim Table :


CREATE TABLE Dim_Location(
LocationID INT IDENTITY(1,1) PRIMARY KEY,
FullLocation NVARCHAR(500) UNIQUE NOT NULL,
District NVARCHAR(100),
Area NVARCHAR(100),
City NVARCHAR(100),
Governorate NVARCHAR(100));
GO

--Creating Payment Method Dim Table :



CREATE TABLE Dim_PaymentMethod(
PaymentMethodID INT IDENTITY(1,1) PRIMARY KEY,
PaymentMethod NVARCHAR(50) UNIQUE NOT NULL);
GO

--Creating FACT Table :



CREATE TABLE Fact_RealEstateListings(
ListingID INT,
TypeID INT,
LocationID INT,
PaymentMethodID INT,
FullPrice DECIMAL(18,2),
DownPayment DECIMAL(18,2),
SizeSqm INT,
Bedrooms INT,
Bathrooms INT,
availableFrom DATE,
Description NVARCHAR(MAX),

CONSTRAINT FK_Type FOREIGN KEY (TypeID) REFERENCES Dim_PropertyType(TypeID),
CONSTRAINT FK_Location FOREIGN KEY (LocationID) REFERENCES Dim_Location(LocationID),
CONSTRAINT FK_PaymentMethod FOREIGN KEY (PaymentMethodID) REFERENCES Dim_PaymentMethod(PaymentMethodID)
);
GO

-- Populating Dimension Tables :
--Populating Property Type Dimension Table :

INSERT INTO Dim_PropertyType(Type)
SELECT DISTINCT type AS Type
FROM EgyptianRealEstateListings
WHERE type IS NOT NULL;
GO

--Populating Location Dimension Table :

INSERT INTO Dim_Location(FullLocation,District,Area,City,Governorate)
SELECT DISTINCT location,
district,
area,
city,
governorate
FROM EgyptianRealEstateListings;
GO

--Populating Payment Method Dimension Table :

INSERT INTO Dim_PaymentMethod(PaymentMethod)
SELECT DISTINCT payment_method
FROM EgyptianRealEstateListings
WHERE payment_method IS NOT NULL;
GO

--- Populating Fact Table :

INSERT INTO Fact_RealEstateListings(ListingID,
TypeID,
LocationID,
PaymentMethodID,
FullPrice,
DownPayment,
SizeSqm,
Bedrooms,
Bathrooms,
availableFrom,
Description)
SELECT e.ListingID,
t.TypeID,
l.LocationID,
pm.PaymentMethodID,
e.FullPrice,
e.downPayment,
e.Size_Sqm,
e.bedrooms,
e.bathrooms,
e.availableFrom,
e.description

FROM EgyptianRealEstateListings e
LEFT JOIN Dim_PropertyType t ON e.type = t.Type
LEFT JOIN Dim_Location l ON e.location = l.FullLocation
LEFT JOIN Dim_PaymentMethod pm ON e.payment_method = pm.PaymentMethod

WHERE e.type IS NOT NULL
AND e.location IS NOT NULL;
GO
SELECT * FROM Fact_RealEstateListings
-- CREATING Indexes for Performance :

CREATE NONCLUSTERED INDEX IX_Fact_Type ON Fact_RealEstateListings(TypeID);
CREATE NONCLUSTERED INDEX IX_Fact_Location ON Fact_RealEstateListings(LocationID);
CREATE NONCLUSTERED INDEX IX_Fact_PaymentMethond ON Fact_RealEstateListings(PaymentMethodID);

