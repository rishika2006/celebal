-- =====================================================
-- CELEBAL SUMMER INTERNSHIP 2026
-- WEEK 2 TASK : E-COMMERCE SALES DATABASE
-- Assignment_2.sql
-- =====================================================

-- =====================================================
-- SECTION A : SQL BASICS
-- =====================================================

-- Q1. Display all columns and rows from customers table

SELECT * FROM customers;

-- Output:
-- 8 customer records displayed.

-- Q2. Retrieve first_name, last_name and city of all customers

SELECT first_name, last_name, city
FROM customers;

-- Output:
-- Customer names along with their cities.

-- Q3. List all unique categories available in products table

SELECT DISTINCT category
FROM products;

-- Output:
-- Electronics
-- Clothing
-- Home

/*
Q4. Primary Keys

customers   -> customer_id
products    -> product_id
orders      -> order_id
order_items -> item_id

Why Primary Key must be UNIQUE and NOT NULL?

1. Uniquely identifies each record.
2. Prevents duplicate entries.
3. Maintains data integrity.
4. Required for table relationships.
   */

/*
Q5. Constraints on email column

email VARCHAR(100) UNIQUE NOT NULL

Constraints:

1. UNIQUE
2. NOT NULL

Attempting to insert a duplicate email
will result in a duplicate key error.
*/

/*
Q6. Insert a product with negative price
*/

-- Example

INSERT INTO products
VALUES
(209,'Test Product','Electronics','TestBrand',-50,100);

-- Result:
-- ERROR

/*
Reason:
CHECK(unit_price > 0)

The CHECK constraint prevents
negative values.
*/

-- =====================================================
-- SECTION B : FILTERING & OPTIMIZATION
-- =====================================================

-- Q7. Retrieve all Delivered orders

SELECT *
FROM orders
WHERE status='Delivered';

-- Q8. Electronics products priced above ₹2000

SELECT *
FROM products
WHERE category='Electronics'
AND unit_price > 2000;

-- Q9. Customers from Maharashtra who joined in 2024

SELECT *
FROM customers
WHERE state='Maharashtra'
AND join_date BETWEEN '2024-01-01'
AND '2024-12-31';

-- Q10. Orders between 10-Aug-2024 and 25-Aug-2024 excluding cancelled

SELECT *
FROM orders
WHERE order_date BETWEEN '2024-08-10'
AND '2024-08-25'
AND status <> 'Cancelled';

/*
Q11.

idx_orders_date is an index created
on the order_date column.

Benefits:

1. Faster searching
2. Faster filtering
3. Faster sorting
4. Reduced table scans

Example Query:
*/

SELECT *
FROM orders
WHERE order_date='2024-08-15';

/*
Q12.

Non-SARGable Query
*/

SELECT *
FROM customers
WHERE YEAR(join_date)=2024;

/*
Index Friendly (SARGable) Query
*/

SELECT *
FROM customers
WHERE join_date >= '2024-01-01'
AND join_date < '2025-01-01';

-- =====================================================
-- SECTION C : AGGREGATION
-- =====================================================

-- Q13. Count total orders

SELECT COUNT(*) AS Total_Orders
FROM orders;

-- Output: 10

-- Q14. Revenue from Delivered orders

SELECT SUM(total_amount) AS Delivered_Revenue
FROM orders
WHERE status='Delivered';

-- Output: 17191.00

-- Q15. Average product price by category

SELECT
category,
AVG(unit_price) AS Average_Price
FROM products
GROUP BY category;

-- Q16. Order count and revenue by status

SELECT
status,
COUNT(*) AS Total_Orders,
SUM(total_amount) AS Total_Revenue
FROM orders
GROUP BY status
ORDER BY Total_Revenue DESC;

-- Q17. Most expensive and cheapest product in each category

SELECT
category,
MAX(unit_price) AS Highest_Price,
MIN(unit_price) AS Lowest_Price
FROM products
GROUP BY category;

-- Q18. Categories with average price above ₹2000

SELECT
category,
AVG(unit_price) AS Average_Price
FROM products
GROUP BY category
HAVING AVG(unit_price) > 2000;

-- =====================================================
-- SECTION D : JOINS & RELATIONSHIPS
-- =====================================================

-- Q19. Order details with customer names

SELECT
o.order_id,
o.order_date,
c.first_name,
c.last_name,
o.total_amount
FROM orders o
INNER JOIN customers c
ON o.customer_id=c.customer_id;

-- Q20. All customers and their orders

SELECT
c.customer_id,
c.first_name,
c.last_name,
o.order_id,
o.order_date,
o.status
FROM customers c
LEFT JOIN orders o
ON c.customer_id=o.customer_id;

-- Q21. Order item details

SELECT
o.order_id,
p.product_name,
oi.quantity,
oi.unit_price,
oi.discount_pct
FROM orders o
JOIN order_items oi
ON o.order_id=oi.order_id
JOIN products p
ON oi.product_id=p.product_id;

/*
Q22.

LEFT JOIN:
Returns all records from left table
and matching records from right table.

RIGHT JOIN:
Returns all records from right table
and matching records from left table.

FULL OUTER JOIN:
Returns all matching and non-matching
records from both tables.
*/

/*
Q23.

Foreign Key Relationships

orders.customer_id
REFERENCES customers.customer_id

order_items.order_id
REFERENCES orders.order_id

order_items.product_id
REFERENCES products.product_id

Attempting to insert:

customer_id = 999

will fail because the customer
does not exist in customers table.

A Foreign Key Constraint Error
will be generated.
*/

-- =====================================================
-- SECTION E : ADVANCED SQL
-- =====================================================

-- Q24. Product Price Classification

SELECT
product_name,
unit_price,
CASE
WHEN unit_price < 1000
THEN 'Budget'

WHEN unit_price BETWEEN 1000 AND 3000
THEN 'Mid-Range'

ELSE 'Premium'
END AS Price_Tier
FROM products;

-- Q25. Delivered vs Not Delivered Orders

SELECT

SUM(
CASE
WHEN status='Delivered'
THEN 1
ELSE 0
END
) AS Delivered_Orders,

SUM(
CASE
WHEN status<>'Delivered'
THEN 1
ELSE 0
END
) AS Not_Delivered_Orders

FROM orders;

/*
Q26. ACID Properties

A - Atomicity
Transaction executes completely or not at all.

C - Consistency
Database remains valid before and after transaction.

I - Isolation
Transactions do not interfere with one another.

D - Durability
Committed data remains permanently saved.

Example:
Bank Transfer System.
*/

-- Q27. Transaction Example

START TRANSACTION;

INSERT INTO orders
VALUES
(1011,102,CURDATE(),'Pending',1598.00);

INSERT INTO order_items
VALUES
(5016,1011,206,1,1299.00,0);

INSERT INTO order_items
VALUES
(5017,1011,208,1,599.00,0);

UPDATE products
SET stock_qty = stock_qty - 1
WHERE product_id=206;

UPDATE products
SET stock_qty = stock_qty - 1
WHERE product_id=208;

COMMIT;

-- If any statement fails:
-- ROLLBACK;

-- =====================================================
-- BUSINESS INSIGHTS
-- =====================================================

/*

1. Total Customers = 8

2. Total Products = 8

3. Total Orders = 10

4. Delivered Revenue = ₹17,191

5. Electronics category has the highest
   number of products.

6. Delivered orders contribute the
   largest share of revenue.

7. Foreign Keys ensure referential
   integrity between tables.

8. Indexes improve filtering and
   query performance.
   */
