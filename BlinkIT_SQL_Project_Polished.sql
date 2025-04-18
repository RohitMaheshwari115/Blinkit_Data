
-- =============================================
-- Project: BlinkIT Grocery Retail Sales Analysis
-- =============================================
-- Description: This SQL script is designed to analyze grocery sales data using various analytical queries.
-- It includes data cleaning, KPIs, category-wise breakdowns, and advanced insights to support business decisions.

-- =============================================
-- 1. Data Cleaning & Standardization
-- =============================================

-- Normalize Item Fat Content for consistency
UPDATE blinkit_data
SET Item_Fat_Content = 
  CASE 
    WHEN Item_Fat_Content IN ('LF', 'low fat') THEN 'Low Fat'
    WHEN Item_Fat_Content = 'reg' THEN 'Regular'
    ELSE Item_Fat_Content
  END;

-- =============================================
-- 2. Key Performance Indicators (KPIs)
-- =============================================

-- 2.1 Total Sales in Millions
SELECT CAST(SUM(Total_Sales) / 1000000.0 AS DECIMAL(10,2)) AS Total_Sales_Million FROM blinkit_data;

-- 2.2 Average Sales per Transaction
SELECT CAST(AVG(Total_Sales) AS INT) AS Avg_Sales FROM blinkit_data;

-- 2.3 Total Number of Orders
SELECT COUNT(*) AS No_of_Orders FROM blinkit_data;

-- 2.4 Average Customer Rating
SELECT CAST(AVG(Rating) AS DECIMAL(10,1)) AS Avg_Rating FROM blinkit_data;

-- =============================================
-- 3. Sales Breakdown by Categories
-- =============================================

-- 3.1 Sales by Item Fat Content
SELECT Item_Fat_Content, CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM blinkit_data
GROUP BY Item_Fat_Content;

-- 3.2 Sales by Item Type
SELECT Item_Type, CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM blinkit_data
GROUP BY Item_Type
ORDER BY Total_Sales DESC;

-- 3.3 Sales by Outlet Location Type (Pivoted by Fat Content)
SELECT Outlet_Location_Type, 
       ISNULL([Low Fat], 0) AS Low_Fat, 
       ISNULL([Regular], 0) AS Regular
FROM 
(
    SELECT Outlet_Location_Type, Item_Fat_Content, 
           CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
    FROM blinkit_data
    GROUP BY Outlet_Location_Type, Item_Fat_Content
) AS SourceTable
PIVOT (
    SUM(Total_Sales) 
    FOR Item_Fat_Content IN ([Low Fat], [Regular])
) AS PivotTable
ORDER BY Outlet_Location_Type;

-- =============================================
-- 4. Outlet Performance Analysis
-- =============================================

-- 4.1 Sales by Outlet Establishment Year
SELECT Outlet_Establishment_Year, CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM blinkit_data
GROUP BY Outlet_Establishment_Year
ORDER BY Outlet_Establishment_Year;

-- 4.2 Sales and Contribution by Outlet Size
SELECT 
    Outlet_Size, 
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage
FROM blinkit_data
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;

-- 4.3 Sales by Outlet Location Type
SELECT Outlet_Location_Type, CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM blinkit_data
GROUP BY Outlet_Location_Type
ORDER BY Total_Sales DESC;

-- 4.4 Outlet Type Summary with Multiple Metrics
SELECT Outlet_Type, 
       CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
       CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Avg_Sales,
       COUNT(*) AS No_Of_Items,
       CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating,
       CAST(AVG(Item_Visibility) AS DECIMAL(10,2)) AS Item_Visibility
FROM blinkit_data
GROUP BY Outlet_Type
ORDER BY Total_Sales DESC;

-- =============================================
-- 5. Advanced Insights & Analytics
-- =============================================

-- 5.1 Top Selling Items per Outlet
SELECT Outlet_Identifier, Item_Identifier, SUM(Total_Sales) AS Total_Sales
FROM blinkit_data
GROUP BY Outlet_Identifier, Item_Identifier
ORDER BY Outlet_Identifier, Total_Sales DESC;

-- 5.2 Lowest Rated Product Types
SELECT Item_Type, CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM blinkit_data
GROUP BY Item_Type
ORDER BY Avg_Rating ASC;

-- 5.3 Sales by Rating Category
SELECT 
  CASE 
    WHEN Rating >= 4 THEN 'High'
    WHEN Rating BETWEEN 2 AND 3.9 THEN 'Medium'
    ELSE 'Low'
  END AS Rating_Category,
  COUNT(*) AS Orders,
  SUM(Total_Sales) AS Total_Sales
FROM blinkit_data
GROUP BY 
  CASE 
    WHEN Rating >= 4 THEN 'High'
    WHEN Rating BETWEEN 2 AND 3.9 THEN 'Medium'
    ELSE 'Low'
  END
ORDER BY Total_Sales DESC;

-- 5.4 Item Visibility Ranking within Item Type
SELECT 
  Item_Type,
  Item_Identifier,
  RANK() OVER (PARTITION BY Item_Type ORDER BY Item_Visibility DESC) AS Visibility_Rank
FROM blinkit_data;
