-- ============================================================
-- UCI Online Retail — Final Business Analysis
-- ============================================================
-- Purpose:
-- Analyse the key business questions
-- using the dbt reporting layer as the analytical source of truth.
--
-- Reporting models used:
--   rpt_sales_performance
--   rpt_customer_analytics
--   rpt_geography_timeseries
--
-- Product, customer, geography and time dimensions are already
-- incorporated into the reporting models.
-- ============================================================


-- ============================================================
-- 1. SALES PERFORMANCE
-- ============================================================

-- 1.1 Completed orders, revenue, quantity and AOV

SELECT
    COUNT(DISTINCT invoice) AS completed_orders,
    ROUND(SUM(revenue), 2) AS total_revenue,
    SUM(quantity) AS total_quantity,
    ROUND(
        SAFE_DIVIDE(
            SUM(revenue),
            COUNT(DISTINCT invoice)
        ),
        2
    ) AS average_order_value
FROM {{ ref('rpt_sales_performance') }}
WHERE NOT is_cancelled;


-- 1.2 Average basket size

SELECT
    ROUND(
        SAFE_DIVIDE(
            SUM(quantity),
            COUNT(DISTINCT invoice)
        ),
        2
    ) AS average_basket_size
FROM {{ ref('rpt_sales_performance') }}
WHERE NOT is_cancelled;


-- 1.3 Highest-value transaction

SELECT
    invoice,
    invoice_date,
    customer_id,
    country,
    ROUND(revenue, 2) AS revenue
FROM {{ ref('rpt_sales_performance') }}
WHERE NOT is_cancelled
ORDER BY revenue DESC
LIMIT 1;


-- 1.4 Revenue by month

SELECT
    order_year,
    order_month,
    order_month_name,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM {{ ref('rpt_sales_performance') }}
WHERE NOT is_cancelled
GROUP BY
    order_year,
    order_month,
    order_month_name
ORDER BY
    order_year,
    order_month;


-- 1.5 Revenue by weekday

SELECT
    order_day_name,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM {{ ref('rpt_sales_performance') }}
WHERE NOT is_cancelled
GROUP BY order_day_name
ORDER BY total_revenue DESC;


-- 1.6 Revenue by hour

SELECT
    order_hour,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM {{ ref('rpt_sales_performance') }}
WHERE NOT is_cancelled
GROUP BY order_hour
ORDER BY order_hour;


-- ============================================================
-- 2. CUSTOMER ANALYTICS
-- ============================================================

-- 2.1 Top 20 customers by revenue

SELECT
    customer_id,
    customer_orders,
    ROUND(customer_revenue, 2) AS customer_revenue,
    ROUND(customer_aov, 2) AS customer_aov,
    repeat_customer
FROM {{ ref('rpt_customer_analytics') }}
ORDER BY customer_revenue DESC
LIMIT 20;


-- 2.2 Customers with the most orders

SELECT
    customer_id,
    customer_orders
FROM {{ ref('rpt_customer_analytics') }}
ORDER BY customer_orders DESC
LIMIT 10;


-- 2.3 Customers with the highest quantity purchased

SELECT
    customer_id,
    SUM(quantity) AS total_quantity
FROM {{ ref('rpt_sales_performance') }}
WHERE NOT is_cancelled
  AND customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY total_quantity DESC
LIMIT 10;


-- 2.4 Customer sales metrics

SELECT
    customer_id,
    ROUND(SUM(revenue), 2) AS total_revenue,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT invoice) AS completed_orders,
    ROUND(
        SAFE_DIVIDE(
            SUM(revenue),
            COUNT(DISTINCT invoice)
        ),
        2
    ) AS average_order_value,
    ROUND(
        SAFE_DIVIDE(
            SUM(quantity),
            COUNT(DISTINCT invoice)
        ),
        2
    ) AS average_basket_size
FROM {{ ref('rpt_sales_performance') }}
WHERE NOT is_cancelled
  AND customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY average_order_value DESC
LIMIT 10;


-- 2.5 Pareto analysis: Top 20% vs Bottom 80%

SELECT
    customer_group AS customer_segment,
    COUNT(*) AS customers,
    ROUND(SUM(customer_revenue), 2) AS revenue,
    ROUND(AVG(customer_revenue), 2) AS avg_customer_revenue,
    ROUND(
        100 * SAFE_DIVIDE(
            SUM(customer_revenue),
            SUM(SUM(customer_revenue)) OVER ()
        ),
        2
    ) AS percentage_of_total_revenue,
    ROUND(AVG(customer_orders), 2) AS avg_orders,
    COUNTIF(repeat_customer) AS repeat_customers,
    ROUND(
        100 * SAFE_DIVIDE(
            COUNTIF(repeat_customer),
            COUNT(*)
        ),
        2
    ) AS repeat_rate
FROM {{ ref('rpt_customer_analytics') }}
GROUP BY customer_group
ORDER BY customer_segment;


-- ============================================================
-- 3. PRODUCT PERFORMANCE
-- ============================================================

-- 3.1 Products / subcategories generating the most revenue

SELECT
    top_level_category,
    subcategory,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM {{ ref('rpt_sales_performance') }}
WHERE NOT is_cancelled
GROUP BY
    top_level_category,
    subcategory
ORDER BY total_revenue DESC
LIMIT 10;


-- 3.2 Products / subcategories with the highest quantity sold

SELECT
    top_level_category,
    subcategory,
    SUM(quantity) AS total_quantity
FROM {{ ref('rpt_sales_performance') }}
WHERE NOT is_cancelled
GROUP BY
    top_level_category,
    subcategory
ORDER BY total_quantity DESC
LIMIT 10;


-- 3.3 Products with the highest cancellation volume

SELECT
    top_level_category,
    subcategory,
    COUNT(*) AS cancelled_sales
FROM {{ ref('rpt_sales_performance') }}
WHERE is_cancelled
GROUP BY
    top_level_category,
    subcategory
ORDER BY cancelled_sales DESC
LIMIT 10;


-- 3.4 Product cancellation rate

SELECT
    top_level_category,
    subcategory,
    COUNT(*) AS total_sales,
    COUNTIF(is_cancelled) AS cancelled_sales,
    ROUND(
        100 * SAFE_DIVIDE(
            COUNTIF(is_cancelled),
            COUNT(*)
        ),
        2
    ) AS cancellation_rate
FROM {{ ref('rpt_sales_performance') }}
WHERE top_level_category IS NOT NULL
GROUP BY
    top_level_category,
    subcategory
ORDER BY cancellation_rate DESC;


-- ============================================================
-- 4. GEOGRAPHY
-- ============================================================

-- 4.1 Countries generating the most revenue

SELECT
    country,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM {{ ref('rpt_sales_performance') }}
WHERE NOT is_cancelled
GROUP BY country
ORDER BY total_revenue DESC
LIMIT 10;


-- 4.2 Countries with the highest number of customers

SELECT
    country,
    COUNT(DISTINCT customer_id) AS customer_count
FROM {{ ref('rpt_sales_performance') }}
WHERE NOT is_cancelled
  AND customer_id IS NOT NULL
GROUP BY country
ORDER BY customer_count DESC
LIMIT 10;


-- ============================================================
-- 5. TIME SERIES & SEASONALITY
-- ============================================================

-- 5.1 Monthly revenue over time

SELECT
    order_year,
    order_month,
    order_month_name,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM {{ ref('rpt_sales_performance') }}
WHERE NOT is_cancelled
GROUP BY
    order_year,
    order_month,
    order_month_name
ORDER BY
    order_year,
    order_month;


-- 5.2 Monthly quantity vs revenue

SELECT
    order_year,
    order_month,
    order_month_name,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(quantity), 2) AS average_line_quantity,
    ROUND(AVG(revenue), 2) AS average_line_revenue
FROM {{ ref('rpt_sales_performance') }}
WHERE NOT is_cancelled
GROUP BY
    order_year,
    order_month,
    order_month_name
ORDER BY total_revenue DESC;


-- ============================================================
-- 6. CANCELLATION ANALYSIS
-- ============================================================

-- 6.1 Cancellation behaviour by weekday

SELECT
    order_day_name,
    COUNT(*) AS total_sales,
    COUNTIF(is_cancelled) AS cancelled_sales,
    ROUND(
        100 * SAFE_DIVIDE(
            COUNTIF(is_cancelled),
            COUNT(*)
        ),
        2
    ) AS cancellation_rate
FROM {{ ref('rpt_sales_performance') }}
WHERE top_level_category IS NOT NULL
GROUP BY order_day_name
ORDER BY cancellation_rate DESC;


-- 6.2 Overall cancellation rate

SELECT
    COUNT(*) AS total_sales,
    COUNTIF(is_cancelled) AS cancelled_sales,
    ROUND(
        100 * SAFE_DIVIDE(
            COUNTIF(is_cancelled),
            COUNT(*)
        ),
        2
    ) AS cancellation_rate
FROM {{ ref('rpt_sales_performance') }};