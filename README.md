# PropertyFinder real estate market: End-to-End Analytics Project
*This project provides a production-ready business intelligence solution for analyzing the Egyptian real estate market on PropertyFinder website. It combines a sophisticated SQL Server data warehouse with a comprehensive Power BI dashboard to deliver actionable insights*

This project uses the **[Egyptian Real Estate Listings On PropertyFinder Dataset]([https://www.kaggle.com/datasets/crainbramp/steam-dataset-2025-multi-modal-gaming-analytics])**

## 🧠 Project Overview

This repository contains **all code, views, and documentation** for:

1. 🏗️ *Complete ETL Pipeline* - Automated data extraction, transformation, and loading
2. 📈 *Interactive Dashboards* - 4 comprehensive Power BI pages
3. 🗄️ *Star Schema Design* - Optimized data warehouse with fact and dimension tables
4. 🎯 *Pre-built Analytics* - Created Using DAX, views and aggregation tables
5. 🚀 *Performance Optimized* - Using indexed queries

## 🛠️ Project Workflow

### 1️⃣ **Database Setup & Loading (SQL Server)**
- Created a new SQL Server database (`EgyptianRealEstateListings`)
- Attempted loading the dataset using native SQL Server `BULK INSERT` command

### 2️⃣ **Data Cleaning**
Performed comprehensive cleaning and transformations in SQL Server:
- Fixed data types (`availableFrom` → `DATE`, `bathrooms` → `INT`)
- Dropped the entierly NULL rows
- Derived a size column in sqm only `732 sqft / 68 sqm` and changed data type → `INT`
-	Removed commas "8,000,000" from Price and fixed data type → `INT`
- Derived 4 New Columns → Compound, District, City, Region from the `location` column
- Challenge: Single text column contains 4-level hierarchy:
`Swan Lake Gouna, Al Gouna, Hurghada, Red Sea`
- Handled the NULLs in the `price` column with the average price of every property type
- Handled the NULLs in `down_payment` column (If the payment method is cash then replaced it with the full price and If it's installments then replace with 10% with the full price)
- Handled the NULLs in the `payment_methed` column
- Derived the numbers from the `bedrooms` column → "1+ Maid" to "1" and changed the date type to `INT`


### 3️⃣ **Data Modeling & Views**
Designed a star-schema–inspired model with:
- Fact tables: `Fact_RealEstateListings`
- Backup table: `EgyptianRealEstateListings_backup`
- Dimensions tables: `Dim_Location`,`Dim_PaymentMethod`,`Dim_PropertyType`
- Created Primary Key columns for every table (Fact & Dimensions)
- Created Foriegn Key Constraints for every table
- Created Indexes for performance optimization

- Created **optimized analytical views**:
- `PriceQuartilesByType_VW`
- `PropertyTypeSummary_VW`
- `Top10ByPrice_VW`

> 📂 See `/sql` folder for full scripts.


### 4️⃣ **Power BI Dashboard**
- Connected Power BI directly to SQL Server (**Import mode**)
- Built **4 interactive dashboard pages**:
  - Overview
  - Property Type Analytics
  - Location Analysis
  - Price Analysis
 Implemented DAX measures

> 📊 **Final Output**: `PropertyFinder Dashboard` (included)


### 🎯 **Business Value**
What Questions Does This Answer?

*Market Size & Trends:*

- How many properties are currently listed?
- What are the average and median prices?
- What's the distribution of listings according to budget?
- What is the installments to cash ratio?


*Geographic Insights:*

What's the distribution of listings across Egypt (with full location)?
Which cities command the highest prices?
Where are the best value opportunities?
How does pricing vary by region?


*Property Characteristics:*

What's the price to size ratio across property types?
Which property types are most common?
What is the price range across property types?




