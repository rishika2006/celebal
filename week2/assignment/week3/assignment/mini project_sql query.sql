USE superstore_db;

-- Find the top 5 customers based on total sales

SELECT
    c.`Customer Name`,
    SUM(o.Sales) AS Total_Sales
FROM orders o
JOIN customers c
ON o.`Customer ID` = c.`Customer ID`
GROUP BY c.`Customer Name`
ORDER BY Total_Sales DESC
LIMIT 5;


-- Find the bottom 5 customers based on total sales

SELECT
    c.`Customer Name`,
    SUM(o.Sales) AS Total_Sales
FROM orders o
JOIN customers c
ON o.`Customer ID` = c.`Customer ID`
GROUP BY c.`Customer Name`
ORDER BY Total_Sales ASC
LIMIT 5;


-- Find customers who have placed only one order

SELECT
    c.`Customer Name`,
    COUNT(DISTINCT o.`Order ID`) AS Order_Count
FROM orders o
JOIN customers c
ON o.`Customer ID` = c.`Customer ID`
GROUP BY c.`Customer Name`
HAVING COUNT(DISTINCT o.`Order ID`) = 1;


-- Find customers whose total sales are above the average customer sales

WITH customer_sales AS
(
    SELECT c.`Customer Name`, SUM(o.Sales) AS Total_Sales
    FROM orders o
    JOIN customers c
    ON o.`Customer ID` = c.`Customer ID`
    GROUP BY c.`Customer Name`
)
SELECT *
FROM customer_sales
WHERE Total_Sales >
(
    SELECT AVG(Total_Sales)
    FROM customer_sales
);


-- Find the highest order value recorded for each customer

SELECT
    c.`Customer Name`,
    MAX(o.Sales) AS Highest_Order_Value
FROM orders o
JOIN customers c
ON o.`Customer ID` = c.`Customer ID`
GROUP BY c.`Customer Name`
ORDER BY Highest_Order_Value DESC;