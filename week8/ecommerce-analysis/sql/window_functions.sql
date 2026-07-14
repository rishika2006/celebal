-- ============================================================
-- WINDOW FUNCTIONS & ADVANCED SQL
-- ============================================================



-- ============================================================
-- Query 7: Running Total of Revenue Per Region
-- ============================================================

WITH daily_revenue AS
(
    SELECT

        o.region_code,

        DATE(o.order_date) AS order_date,

        ROUND(
            SUM(
                oi.quantity *
                oi.unit_price *
                (1 - oi.discount_percent / 100.0)
            ),
            2
        ) AS daily_revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY

        o.region_code,
        DATE(o.order_date)
)

SELECT

    region_code,
    order_date,
    daily_revenue,

    ROUND(

        SUM(daily_revenue)
        OVER
        (
            PARTITION BY region_code
            ORDER BY order_date
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW

        ),

        2

    ) AS running_total

FROM daily_revenue

ORDER BY

    region_code,
    order_date;



-- ============================================================
-- Query 8: Rank Products by Revenue within Each Category
-- ============================================================

WITH product_revenue AS
(
    SELECT

        p.category,

        p.product_id,

        p.product_name,

        ROUND(

            SUM(

                oi.quantity *
                oi.unit_price *
                (1 - oi.discount_percent / 100.0)

            ),

            2

        ) AS total_revenue

    FROM products p

    JOIN order_items oi
        ON p.product_id = oi.product_id

    GROUP BY

        p.category,
        p.product_id,
        p.product_name
)

SELECT

    category,

    product_name,

    total_revenue,

    DENSE_RANK()
    OVER
    (

        PARTITION BY category

        ORDER BY total_revenue DESC

    ) AS rank_in_category

FROM product_revenue

ORDER BY

    category,
    rank_in_category,
    product_name;



-- ============================================================
-- Query 9: LAG Analysis
-- Calculate Days Between Consecutive Orders
-- Flag Customers with Average Gap > 30 Days
-- ============================================================

WITH customer_orders AS
(

    SELECT

        customer_id,

        DATE(order_date) AS order_date,

        LAG(DATE(order_date))
        OVER
        (

            PARTITION BY customer_id

            ORDER BY DATE(order_date)

        ) AS previous_order_date

    FROM orders

),

order_gap AS
(

    SELECT

        customer_id,

        order_date,

        previous_order_date,

        CAST(

            julianday(order_date)
            -
            julianday(previous_order_date)

            AS INTEGER

        ) AS days_gap

    FROM customer_orders

),

customer_average AS
(

    SELECT

        customer_id,

        ROUND(

            AVG(days_gap),

            2

        ) AS average_gap

    FROM order_gap

    WHERE days_gap IS NOT NULL

    GROUP BY customer_id

)

SELECT

    og.customer_id,

    og.order_date,

    og.previous_order_date,

    og.days_gap,

    ca.average_gap,

    CASE

        WHEN ca.average_gap > 30

        THEN 'At Risk'

        ELSE 'Active'

    END AS customer_status

FROM order_gap og

JOIN customer_average ca

ON og.customer_id = ca.customer_id

ORDER BY

    og.customer_id,

    og.order_date;

-- ============================================================
-- Query 10: Multi-Level CTE
-- Monthly Customer Revenue Segmentation
-- ============================================================

WITH monthly_customer_revenue AS
(

    SELECT

        o.customer_id,

        strftime('%Y-%m', o.order_date) AS revenue_month,

        ROUND(

            SUM(

                oi.quantity *
                oi.unit_price *
                (1 - oi.discount_percent / 100.0)

            ),

            2

        ) AS monthly_revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY

        o.customer_id,
        strftime('%Y-%m', o.order_date)

),

customer_segments AS
(

    SELECT

        customer_id,

        revenue_month,

        monthly_revenue,

        CASE

            WHEN monthly_revenue > 10000
                THEN 'High'

            WHEN monthly_revenue BETWEEN 5000 AND 10000
                THEN 'Medium'

            ELSE 'Low'

        END AS revenue_category

    FROM monthly_customer_revenue

),

monthly_summary AS
(

    SELECT

        revenue_month,

        revenue_category,

        COUNT(customer_id) AS customer_count

    FROM customer_segments

    GROUP BY

        revenue_month,
        revenue_category

)

SELECT

    revenue_month,

    revenue_category,

    customer_count

FROM monthly_summary

ORDER BY

    revenue_month,
    revenue_category;



-- ============================================================
-- Query 11: Customer Segmentation using NTILE(4)
-- Divide Customers into Quartiles Based on Lifetime Value
-- ============================================================

WITH customer_lifetime_value AS
(

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

        ) AS total_value

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY

        c.customer_id,
        c.customer_name

),

customer_quartiles AS
(

    SELECT

        customer_id,

        customer_name,

        total_value,

        NTILE(4)
        OVER
        (
            ORDER BY total_value DESC
        ) AS quartile

    FROM customer_lifetime_value

)

SELECT

    customer_id,

    customer_name,

    total_value,

    quartile,

    CASE quartile

        WHEN 1 THEN 'Platinum'

        WHEN 2 THEN 'Gold'

        WHEN 3 THEN 'Silver'

        ELSE 'Bronze'

    END AS quartile_label

FROM customer_quartiles

ORDER BY

    total_value DESC;
-- ============================================================
-- Query 12: Year-over-Year Revenue Comparison
-- ============================================================

WITH monthly_revenue AS
(
    SELECT

        CAST(strftime('%Y', o.order_date) AS INTEGER) AS year,

        CAST(strftime('%m', o.order_date) AS INTEGER) AS month,

        ROUND(
            SUM(
                oi.quantity *
                oi.unit_price *
                (1 - oi.discount_percent / 100.0)
            ),
            2
        ) AS revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        CAST(strftime('%Y', o.order_date) AS INTEGER),
        CAST(strftime('%m', o.order_date) AS INTEGER)
)

SELECT

    cur.year,

    cur.month,

    cur.revenue,

    prev.revenue AS prev_year_revenue,

    CASE

        WHEN prev.revenue IS NULL
             OR prev.revenue = 0

        THEN NULL

        ELSE ROUND(

            ((cur.revenue - prev.revenue) * 100.0)
            / prev.revenue,

            2

        )

    END AS yoy_growth_percent

FROM monthly_revenue cur

LEFT JOIN monthly_revenue prev

ON prev.year = cur.year - 1

AND prev.month = cur.month

ORDER BY

    cur.year,

    cur.month;
-- ============================================================
-- Query 13: First Purchased Category vs Latest Purchased Category
-- ============================================================

WITH customer_categories AS
(

    SELECT

        o.customer_id,

        o.order_date,

        p.category,

        p.product_id,

        ROW_NUMBER()

        OVER
        (

            PARTITION BY o.customer_id

            ORDER BY

                o.order_date,

                p.product_id

        ) AS first_rank,

        ROW_NUMBER()

        OVER
        (

            PARTITION BY o.customer_id

            ORDER BY

                o.order_date DESC,

                p.product_id DESC

        ) AS last_rank

    FROM orders o

    JOIN order_items oi

        ON o.order_id = oi.order_id

    JOIN products p

        ON oi.product_id = p.product_id

),

first_category AS
(

    SELECT

        customer_id,

        category AS first_category

    FROM customer_categories

    WHERE first_rank = 1

),

last_category AS
(

    SELECT

        customer_id,

        category AS last_category

    FROM customer_categories

    WHERE last_rank = 1

)

SELECT

    f.customer_id,

    f.first_category,

    l.last_category,

    CASE

        WHEN f.first_category = l.last_category

        THEN 'No'

        ELSE 'Yes'

    END AS category_shift

FROM first_category f

JOIN last_category l

ON f.customer_id = l.customer_id

ORDER BY

    f.customer_id;
-- ============================================================
-- Query 14A: Top 10% Customers
-- ============================================================

WITH customer_revenue AS
(
    SELECT

        c.customer_id,

        ROUND(
            SUM(
                oi.quantity *
                oi.unit_price *
                (1 - oi.discount_percent / 100.0)
            ),
            2
        ) AS revenue

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        c.customer_id
),

revenue_distribution AS
(
    SELECT

        customer_id,

        revenue,

        SUM(revenue)
        OVER
        (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS cumulative_revenue,

        ROUND(
            SUM(revenue)
            OVER
            (
                ORDER BY revenue DESC
                ROWS BETWEEN UNBOUNDED PRECEDING
                AND CURRENT ROW
            )
            * 100.0
            /
            SUM(revenue) OVER (),
            2
        ) AS cumulative_percent,

        ROW_NUMBER()
        OVER
        (
            ORDER BY revenue DESC
        ) AS customer_rank,

        COUNT(*)
        OVER () AS total_customers

    FROM customer_revenue
)

SELECT

    customer_id,

    revenue,

    cumulative_revenue,

    cumulative_percent

FROM revenue_distribution

WHERE customer_rank <=
      CAST((total_customers * 0.10) + 0.999999 AS INTEGER)

ORDER BY revenue DESC;

-- ============================================================
-- Query 14B: Top 20% Customers
-- ============================================================

WITH customer_revenue AS
(
    SELECT

        c.customer_id,

        ROUND(
            SUM(
                oi.quantity *
                oi.unit_price *
                (1 - oi.discount_percent / 100.0)
            ),
            2
        ) AS revenue

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        c.customer_id
),

revenue_distribution AS
(
    SELECT

        customer_id,

        revenue,

        SUM(revenue)
        OVER
        (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS cumulative_revenue,

        ROUND(
            SUM(revenue)
            OVER
            (
                ORDER BY revenue DESC
                ROWS BETWEEN UNBOUNDED PRECEDING
                AND CURRENT ROW
            )
            * 100.0
            /
            SUM(revenue) OVER (),
            2
        ) AS cumulative_percent,

        ROW_NUMBER()
        OVER
        (
            ORDER BY revenue DESC
        ) AS customer_rank,

        COUNT(*)
        OVER () AS total_customers

    FROM customer_revenue
)

SELECT

    customer_id,

    revenue,

    cumulative_revenue,

    cumulative_percent

FROM revenue_distribution

WHERE customer_rank <=
      CAST((total_customers * 0.20) + 0.999999 AS INTEGER)

ORDER BY revenue DESC;


-- ============================================================
-- Query 16: Products Frequently Bought Together
-- ============================================================

WITH product_pairs AS
(

    SELECT

        oi1.product_id AS product_a,

        oi2.product_id AS product_b,

        COUNT(*) AS times_bought_together

    FROM order_items oi1

    JOIN order_items oi2

        ON oi1.order_id = oi2.order_id

       AND oi1.product_id < oi2.product_id

    GROUP BY

        oi1.product_id,

        oi2.product_id

)

SELECT

    p1.product_name AS product_a,

    p2.product_name AS product_b,

    times_bought_together

FROM product_pairs pp

JOIN products p1

ON pp.product_a = p1.product_id

JOIN products p2

ON pp.product_b = p2.product_id

ORDER BY

    times_bought_together DESC,

    product_a,

    product_b;