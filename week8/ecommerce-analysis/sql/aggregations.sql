-- ============================================================
-- Query 1: Total Revenue Per Category
-- ============================================================

SELECT
    p.category,
    ROUND(
        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount_percent / 100.0)
        ),
        2
    ) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;


-- ============================================================
-- Query 2: Top 10 Customers by Total Order Value
-- ============================================================

SELECT
    c.customer_id,
    c.customer_name,
    ROUND(
        SUM(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount_percent / 100.0)
        ),
        2
    ) AS total_order_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_order_value DESC
LIMIT 10;


-- ============================================================
-- Query 3: Month-wise Order Count (Last 12 Months)
-- ============================================================

SELECT
    strftime('%Y-%m', order_date) AS order_month,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_month
ORDER BY order_month DESC
LIMIT 12;


-- ============================================================
-- Query 4: Customers Who Placed Orders But Never Had
--          Any Order Delivered
-- ============================================================

SELECT
    c.customer_id,
    c.customer_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
)
AND NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.status = 'DELIVERED'
)
ORDER BY c.customer_name;


-- ============================================================
-- Query 5: Products Having More Returned Quantity Than
--          Delivered Quantity
-- ============================================================

SELECT
    p.product_id,
    p.product_name,

    SUM(
        CASE
            WHEN o.status = 'RETURNED'
            THEN oi.quantity
            ELSE 0
        END
    ) AS returned_quantity,

    SUM(
        CASE
            WHEN o.status = 'DELIVERED'
            THEN oi.quantity
            ELSE 0
        END
    ) AS delivered_quantity

FROM products p

JOIN order_items oi
    ON p.product_id = oi.product_id

JOIN orders o
    ON oi.order_id = o.order_id

GROUP BY
    p.product_id,
    p.product_name

HAVING returned_quantity > delivered_quantity

ORDER BY returned_quantity DESC;


-- ============================================================
-- Query 6: Return Rate Per Category
-- ============================================================

SELECT
    p.category,

    SUM(
        CASE
            WHEN o.status = 'RETURNED'
            THEN oi.quantity
            ELSE 0
        END
    ) AS returned_items,

    SUM(oi.quantity) AS total_items,

    ROUND(
        (
            SUM(
                CASE
                    WHEN o.status = 'RETURNED'
                    THEN oi.quantity
                    ELSE 0
                END
            ) * 100.0
        ) / SUM(oi.quantity),
        2
    ) AS return_rate_percent

FROM products p

JOIN order_items oi
    ON p.product_id = oi.product_id

JOIN orders o
    ON oi.order_id = o.order_id

GROUP BY p.category

ORDER BY return_rate_percent DESC;