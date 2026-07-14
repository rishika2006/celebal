-- ============================================================
-- COHORT ANALYSIS
-- ============================================================

-- ============================================================
-- Query 15: Customer Cohort Analysis
--
-- Cohort = Registration Month
-- Measure retention for Month 0, Month 1,
-- Month 2 and Month 3
-- ============================================================

WITH customer_cohort AS
(

    SELECT

        customer_id,

        DATE(registration_date) AS registration_date,

        strftime('%Y-%m', registration_date) AS cohort_month

    FROM customers

),

customer_orders AS
(

    SELECT

        cc.customer_id,

        cc.cohort_month,

        strftime('%Y-%m', o.order_date) AS order_month,

        (
            (
                CAST(strftime('%Y', o.order_date) AS INTEGER)
                -
                CAST(strftime('%Y', cc.registration_date) AS INTEGER)
            ) * 12
        )

        +

        (

            CAST(strftime('%m', o.order_date) AS INTEGER)
            -
            CAST(strftime('%m', cc.registration_date) AS INTEGER)

        ) AS month_number

    FROM customer_cohort cc

    JOIN orders o

        ON cc.customer_id = o.customer_id

),

cohort_size AS
(

    SELECT

        cohort_month,

        COUNT(DISTINCT customer_id) AS cohort_size

    FROM customer_cohort

    GROUP BY cohort_month

),

retention AS
(

    SELECT

        cohort_month,

        month_number,

        COUNT(DISTINCT customer_id) AS retained_customers

    FROM customer_orders

    WHERE month_number BETWEEN 0 AND 3

    GROUP BY

        cohort_month,

        month_number

)

SELECT

    r.cohort_month,

    r.month_number,

    cs.cohort_size,

    r.retained_customers,

    ROUND(

        r.retained_customers
        * 100.0

        /

        cs.cohort_size,

        2

    ) AS retention_rate_percent

FROM retention r

JOIN cohort_size cs

ON r.cohort_month = cs.cohort_month

ORDER BY

    r.cohort_month,

    r.month_number;