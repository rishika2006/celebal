CREATE DATABASE superstore_db;
USE superstore_db;

SELECT *
FROM superstore_raw
LIMIT 10;

-- Creating separate tables from raw data

CREATE TABLE customers AS
SELECT DISTINCT
    `Customer ID`,
    `Customer Name`,
    Segment
FROM superstore_raw;

CREATE TABLE products AS
SELECT DISTINCT
    `Product ID`,
    `Product Name`,
    Category,
    `Sub-Category`
FROM superstore_raw;

CREATE TABLE orders AS
SELECT DISTINCT
    `Order ID`,
    `Order Date`,
    `Ship Date`,
    `Ship Mode`,
    `Customer ID`,
    `Product ID`,
    Sales,
    Quantity,
    Discount,
    Profit
FROM superstore_raw;

-- Orders with sales above average

SELECT *
FROM orders
WHERE Sales >
(
    SELECT AVG(Sales)
    FROM orders
);

-- Highest sales order of each customer

SELECT *
FROM orders o
WHERE Sales =
(
    SELECT MAX(o2.Sales)
    FROM orders o2
    WHERE o2.`Customer ID` = o.`Customer ID`
);

-- Total sales by customer

WITH customer_sales AS
(
    SELECT
        `Customer ID`,
        SUM(Sales) AS Total_Sales
    FROM orders
    GROUP BY `Customer ID`
)
SELECT *
FROM customer_sales;

-- Customers whose sales are above average

WITH customer_sales AS
(
    SELECT
        `Customer ID`,
        SUM(Sales) AS Total_Sales
    FROM orders
    GROUP BY `Customer ID`
)
SELECT *
FROM customer_sales
WHERE Total_Sales >
(
    SELECT AVG(Total_Sales)
    FROM customer_sales
);

-- Ranking customers based on total sales

WITH customer_sales AS
(
    SELECT
        `Customer ID`,
        SUM(Sales) AS Total_Sales
    FROM orders
    GROUP BY `Customer ID`
)
SELECT
    `Customer ID`,
    Total_Sales,
    RANK() OVER (ORDER BY Total_Sales DESC) AS Sales_Rank
FROM customer_sales;

-- Row number for each order within a customer

SELECT
    `Order ID`,
    `Customer ID`,
    Sales,
    ROW_NUMBER() OVER
    (
        PARTITION BY `Customer ID`
        ORDER BY Sales DESC
    ) AS Row_Num
FROM orders;

-- Top 3 customers

WITH customer_sales AS
(
    SELECT
        `Customer ID`,
        SUM(Sales) AS Total_Sales
    FROM orders
    GROUP BY `Customer ID`
),
ranked_customers AS
(
    SELECT
        `Customer ID`,
        Total_Sales,
        RANK() OVER (ORDER BY Total_Sales DESC) AS Sales_Rank
    FROM customer_sales
)
SELECT *
FROM ranked_customers
WHERE Sales_Rank <= 3;

-- step 3
-- First calculates total sales for every customer using a CTE.
-- Then joins the result with the customers table to get customer names.
-- Finally ranks customers based on total sales using the RANK() window function.

WITH customer_sales AS
(
    SELECT
        `Customer ID`,
        SUM(Sales) AS Total_Sales
    FROM orders
    GROUP BY `Customer ID`
)

SELECT
    c.`Customer Name`,
    cs.Total_Sales,
    RANK() OVER (ORDER BY cs.Total_Sales DESC) AS Sales_Rank
FROM customer_sales cs
JOIN customers c
ON cs.`Customer ID` = c.`Customer ID`;