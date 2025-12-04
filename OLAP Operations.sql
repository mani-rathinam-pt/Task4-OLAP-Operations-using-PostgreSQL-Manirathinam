DROP TABLE IF EXISTS sales_sample;
-- Create sales_sample table
CREATE TABLE sales_sample (
    Product_Id INTEGER NOT NULL,
    Region VARCHAR(50) NOT NULL,
    Date DATE NOT NULL,
    Sales_Amount NUMERIC(10,2) NOT NULL
);

-- ========================================
-- TASK 2: DATA CREATION
-- ========================================

-- Insert 10 sample records into sales_sample table
INSERT INTO sales_sample (Product_Id, Region, Date, Sales_Amount) VALUES
(101, 'East', '2024-01-15', 5000.00),
(102, 'West', '2024-01-20', 7000.00),
(101, 'North', '2024-02-10', 4500.00),
(103, 'South', '2024-02-15', 6000.00),
(102, 'East', '2024-03-05', 8000.00),
(104, 'West', '2024-03-12', 3000.00),
(101, 'South', '2024-04-08', 5500.00),
(103, 'North', '2024-04-18', 7500.00),
(104, 'East', '2024-05-22', 4000.00),
(102, 'West', '2024-05-30', 9000.00);

SELECT * FROM sales_sample ORDER BY Date;

-- ========================================
-- TASK 3: PERFORM OLAP OPERATIONS
-- ========================================

-- a) DRILL DOWN

-- Step 1: View sales at Region level 
SELECT 
    Region,
    SUM(Sales_Amount) AS Total_Sales
FROM sales_sample
GROUP BY Region
ORDER BY Total_Sales DESC;

-- Step 2: Drill down to Product level within each Region (more detailed level)
SELECT 
    Region,
    Product_Id,
    SUM(Sales_Amount) AS Total_Sales
FROM sales_sample
GROUP BY Region, Product_Id
ORDER BY Region, Total_Sales DESC;

-- b) ROLLUP

-- Step 1: View sales at Product level
SELECT 
    Product_Id,
    SUM(Sales_Amount) AS Total_Sales
FROM sales_sample
GROUP BY Product_Id
ORDER BY Product_Id;

-- Step 2: Roll up to Region level (higher level summary)
SELECT 
    Region,
    SUM(Sales_Amount) AS Total_Sales
FROM sales_sample
GROUP BY Region
ORDER BY Region;

-- Using ROLLUP function for hierarchical summary (Product → Region → Grand Total)
SELECT 
    Region,
    Product_Id,
    SUM(Sales_Amount) AS Total_Sales
FROM sales_sample
GROUP BY ROLLUP(Region, Product_Id)
ORDER BY Region NULLS LAST, Product_Id NULLS LAST;

-- c) CUBE

-- Using CUBE function to analyze all possible combinations of dimensions
SELECT 
    Region,
    Product_Id,
    SUM(Sales_Amount) AS Total_Sales
FROM sales_sample
GROUP BY CUBE(Region, Product_Id)
ORDER BY Region NULLS LAST, Product_Id NULLS LAST;

-- CUBE with three dimensions (Region, Product, Date - using EXTRACT for month)
SELECT 
    Region,
    Product_Id,
    EXTRACT(MONTH FROM Date) AS Month,
    SUM(Sales_Amount) AS Total_Sales
FROM sales_sample
GROUP BY CUBE(Region, Product_Id, EXTRACT(MONTH FROM Date))
ORDER BY Region NULLS LAST, Product_Id NULLS LAST, Month NULLS LAST;

-- d) SLICE

-- Slice 1: View sales for a specific region (Example: East)
SELECT 
    Product_Id,
    Date,
    Sales_Amount
FROM sales_sample
WHERE Region = 'East'
ORDER BY Date;

-- Slice 2: View sales for a specific date range (Example: Q1 2024 - Jan to Mar)
SELECT 
    Product_Id,
    Region,
    Date,
    Sales_Amount
FROM sales_sample
WHERE Date BETWEEN '2024-01-01' AND '2024-03-31'
ORDER BY Date;

-- e) DICE

-- Dice 1: View sales for specific products in specific regions
SELECT 
    Product_Id,
    Region,
    Date,
    Sales_Amount
FROM sales_sample
WHERE Product_Id IN (101, 102) 
    AND Region IN ('East', 'West')
ORDER BY Date;

-- Dice 2: View sales for specific products in specific regions within a date range
SELECT 
    Product_Id,
    Region,
    Date,
    Sales_Amount
FROM sales_sample
WHERE Product_Id IN (102, 103) 
    AND Region IN ('North', 'South')
    AND Date BETWEEN '2024-02-01' AND '2024-04-30'
ORDER BY Date;

-- Dice 3: View sales with multiple criteria and calculate totals
SELECT 
    Product_Id,
    Region,
    COUNT(*) AS Number_of_Sales,
    SUM(Sales_Amount) AS Total_Sales
FROM sales_sample
WHERE Product_Id IN (101, 102, 104) 
    AND Region IN ('East', 'West')
    AND Sales_Amount > 4000
GROUP BY Product_Id, Region
ORDER BY Total_Sales DESC;