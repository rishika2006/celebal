CREATE DATABASE superstore_db;
USE superstore_db;

-- =====================================================
-- SECTION 1: DATA EXPLORATION
-- =====================================================

/* Q1. Display first 10 rows of dataset */
SELECT * 
FROM superstore 
LIMIT 10;

/* Q2. Find total number of records in table */
SELECT COUNT(*) AS Total_Rows 
FROM superstore;

/* Q3. Display structure of the table */
DESC superstore;

/* Q4. Get all unique product categories */
SELECT DISTINCT Category 
FROM superstore;


-- =====================================================
-- SECTION 2: FILTERING DATA
-- =====================================================

/* Q5. Fetch all orders from West region */
SELECT * 
FROM superstore 
WHERE Region = 'West';

/* Q6. Retrieve all Technology category products */
SELECT * 
FROM superstore 
WHERE Category = 'Technology';

/* Q7. Show orders where sales are greater than 1000 */
SELECT * 
FROM superstore 
WHERE Sales > 1000;

/* Q8. Get Furniture orders from East region only */
SELECT * 
FROM superstore 
WHERE Category = 'Furniture' 
AND Region = 'East';


-- =====================================================
-- SECTION 3: AGGREGATE FUNCTIONS
-- =====================================================

/* Q9. Calculate total sales */
SELECT SUM(Sales) AS Total_Sales 
FROM superstore;

/* Q10. Calculate average sales value */
SELECT AVG(Sales) AS Average_Sales 
FROM superstore;

/* Q11. Calculate total quantity sold */
SELECT SUM(Quantity) AS Total_Quantity 
FROM superstore;

/* Q12. Calculate total profit */
SELECT SUM(Profit) AS Total_Profit 
FROM superstore;


-- =====================================================
-- SECTION 4: CATEGORY ANALYSIS
-- =====================================================

/* Q13. Total sales grouped by category */
SELECT Category, SUM(Sales) AS Total_Sales 
FROM superstore 
GROUP BY Category 
ORDER BY Total_Sales DESC;

/* Q14. Total profit grouped by category */
SELECT Category, SUM(Profit) AS Total_Profit 
FROM superstore 
GROUP BY Category 
ORDER BY Total_Profit DESC;


-- =====================================================
-- SECTION 5: PRODUCT ANALYSIS
-- =====================================================

/* Q15. Top 10 best-selling products */
SELECT `Product Name`, SUM(Sales) AS Total_Sales 
FROM superstore 
GROUP BY `Product Name` 
ORDER BY Total_Sales DESC 
LIMIT 10;


-- =====================================================
-- SECTION 6: CUSTOMER ANALYSIS
-- =====================================================

/* Q16. Top 10 customers based on total sales */
SELECT `Customer Name`, SUM(Sales) AS Total_Sales 
FROM superstore 
GROUP BY `Customer Name` 
ORDER BY Total_Sales DESC 
LIMIT 10;


-- =====================================================
-- SECTION 7: REGION ANALYSIS
-- =====================================================

/* Q17. Total sales by region */
SELECT Region, SUM(Sales) AS Total_Sales 
FROM superstore 
GROUP BY Region 
ORDER BY Total_Sales DESC;


-- =====================================================
-- SECTION 8: BUSINESS INSIGHTS
-- =====================================================

/* Q18. Monthly sales trend analysis */
SELECT
MONTH(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS Month_Number,
SUM(Sales) AS Monthly_Sales
FROM superstore
GROUP BY Month_Number
ORDER BY Month_Number;

/* Q19. Monthly profit trend analysis */
SELECT
MONTH(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS Month_Number,
SUM(Profit) AS Monthly_Profit
FROM superstore
GROUP BY Month_Number
ORDER BY Month_Number;

/* Q20. Identify duplicate order IDs */
SELECT
`Order ID`,
COUNT(*) AS Duplicate_Count
FROM superstore
GROUP BY `Order ID`
HAVING COUNT(*) > 1;

/* Q21. Check records with missing sales values */
SELECT *
FROM superstore
WHERE Sales IS NULL;