-- ==============================================================================
-- AMAZON INDIA E-COMMERCE SALES ANALYTICS
-- FILE 2: SALES, REVENUE & TIME INTELLIGENCE QUERIES
--
-- Objective: Evaluate time-series trends, moving averages, and period-over-period growth.
-- Target Table: fact_order_line / cleaned_amazon_sales
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- QUERY 7: Daily Sales Run-Rate & Fulfilled Order Volume
-- Business Question: What is the daily revenue and fulfilled transaction run-rate?
-- Technique: Date aggregation with conditional metrics
-- ------------------------------------------------------------------------------
SELECT 
    date,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN is_cancelled = FALSE AND is_returned = FALSE THEN order_id END) AS fulfilled_orders,
    SUM(qty) AS units_sold,
    ROUND(SUM(amount), 2) AS gross_revenue,
    ROUND(SUM(net_revenue), 2) AS net_revenue,
    ROUND(
        SUM(net_revenue) / 
        NULLIF(COUNT(DISTINCT CASE WHEN is_cancelled = FALSE AND is_returned = FALSE THEN order_id END), 0), 
        2
    ) AS daily_aov
FROM cleaned_amazon_sales
GROUP BY date
ORDER BY date;


-- ------------------------------------------------------------------------------
-- QUERY 8: 7-Day Rolling Moving Average of Net Revenue
-- Business Question: What is the smoothed revenue momentum after removing daily volatility?
-- Technique: Window Function with ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
-- ------------------------------------------------------------------------------
WITH daily_metrics AS (
    SELECT 
        date,
        SUM(net_revenue) AS daily_net_revenue,
        COUNT(DISTINCT order_id) AS daily_orders
    FROM cleaned_amazon_sales
    GROUP BY date
)
SELECT 
    date,
    ROUND(daily_net_revenue, 2) AS daily_net_revenue,
    ROUND(
        AVG(daily_net_revenue) OVER (
            ORDER BY date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 
        2
    ) AS net_revenue_7d_moving_avg,
    ROUND(
        AVG(daily_orders) OVER (
            ORDER BY date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 
        1
    ) AS orders_7d_moving_avg
FROM daily_metrics
ORDER BY date;


-- ------------------------------------------------------------------------------
-- QUERY 9: Monthly Revenue Summary & Realization Rate
-- Business Question: How much revenue was realized versus lost to cancellations per month?
-- Technique: DATE_TRUNC / STRFTIME / EXTRACT with grouped financial ratios
-- ------------------------------------------------------------------------------
SELECT 
    year_month,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN is_cancelled = FALSE AND is_returned = FALSE THEN order_id END) AS fulfilled_orders,
    ROUND(SUM(amount), 2) AS gross_gmv,
    ROUND(SUM(net_revenue), 2) AS net_revenue,
    ROUND(SUM(amount) - SUM(net_revenue), 2) AS lost_revenue,
    ROUND(100.0 * SUM(net_revenue) / NULLIF(SUM(amount), 0), 2) AS revenue_realization_rate_pct
FROM cleaned_amazon_sales
GROUP BY year_month
ORDER BY year_month;


-- ------------------------------------------------------------------------------
-- QUERY 10: Month-over-Month (MoM) Growth Analysis
-- Business Question: What is the MoM percentage growth in net revenue and order count?
-- Technique: Window Function LAG() with CTE
-- ------------------------------------------------------------------------------
WITH monthly_data AS (
    SELECT 
        year_month,
        SUM(net_revenue) AS net_revenue,
        COUNT(DISTINCT order_id) AS total_orders
    FROM cleaned_amazon_sales
    GROUP BY year_month
)
SELECT 
    year_month,
    ROUND(net_revenue, 2) AS net_revenue,
    ROUND(LAG(net_revenue) OVER (ORDER BY year_month), 2) AS prior_month_revenue,
    ROUND(
        100.0 * (net_revenue - LAG(net_revenue) OVER (ORDER BY year_month)) /
        NULLIF(LAG(net_revenue) OVER (ORDER BY year_month), 0),
        2
    ) AS mom_revenue_growth_pct,
    total_orders,
    LAG(total_orders) OVER (ORDER BY year_month) AS prior_month_orders,
    ROUND(
        100.0 * (total_orders - LAG(total_orders) OVER (ORDER BY year_month))::NUMERIC /
        NULLIF(LAG(total_orders) OVER (ORDER BY year_month), 0),
        2
    ) AS mom_order_growth_pct
FROM monthly_data
ORDER BY year_month;


-- ------------------------------------------------------------------------------
-- QUERY 11: Day-of-Week Sales Performance & Basket Sizing
-- Business Question: Which day of the week generates highest sales velocity and AOV?
-- Technique: GROUP BY day_of_week with percentage of week's sales
-- ------------------------------------------------------------------------------
SELECT 
    day_of_week,
    COUNT(DISTINCT order_id) AS orders,
    SUM(qty) AS units_sold,
    ROUND(SUM(net_revenue), 2) AS net_revenue,
    ROUND(100.0 * SUM(net_revenue) / SUM(SUM(net_revenue)) OVER (), 2) AS pct_of_weekly_revenue,
    ROUND(
        SUM(net_revenue) / 
        NULLIF(COUNT(DISTINCT CASE WHEN is_cancelled = FALSE AND is_returned = FALSE THEN order_id END), 0), 
        2
    ) AS aov
FROM cleaned_amazon_sales
GROUP BY day_of_week
ORDER BY net_revenue DESC;


-- ------------------------------------------------------------------------------
-- QUERY 12: Top 5 Peak Trading Days
-- Business Question: What were the single highest revenue days during Q2 2022?
-- Technique: DENSE_RANK() OVER (ORDER BY revenue DESC)
-- ------------------------------------------------------------------------------
WITH ranked_days AS (
    SELECT 
        date,
        day_of_week,
        COUNT(DISTINCT order_id) AS distinct_orders,
        SUM(qty) AS units,
        ROUND(SUM(net_revenue), 2) AS net_revenue,
        DENSE_RANK() OVER (ORDER BY SUM(net_revenue) DESC) AS revenue_rank
    FROM cleaned_amazon_sales
    GROUP BY date, day_of_week
)
SELECT 
    revenue_rank,
    date,
    day_of_week,
    distinct_orders,
    units,
    net_revenue
FROM ranked_days
WHERE revenue_rank <= 5
ORDER BY revenue_rank;
