-- ==============================================================================
-- AMAZON INDIA E-COMMERCE SALES ANALYTICS
-- FILE 1: DATA QUALITY, GRAIN AUDIT & RECONCILIATION QUERIES
--
-- Objective: Validate data grain, verify control totals, and prevent double-counting.
-- Target Table: fact_order_line / cleaned_amazon_sales
-- Standard ANSI SQL (PostgreSQL, DuckDB, BigQuery, Snowflake, SQLite compatible)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- QUERY 1: Data Grain Verification (Row Count vs Distinct Orders)
-- Business Question: What is the exact data grain of this dataset, and how many
-- line items exist per order on average?
-- Technique: COUNT(*) vs COUNT(DISTINCT) ratio
-- ------------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_line_items,
    COUNT(DISTINCT order_id) AS distinct_orders,
    COUNT(DISTINCT sku) AS distinct_skus,
    ROUND(COUNT(*)::NUMERIC / NULLIF(COUNT(DISTINCT order_id), 0), 3) AS avg_line_items_per_order
FROM cleaned_amazon_sales;
-- Expected Finding: 128,975 rows across 120,378 orders (1.071 lines/order).
-- Interview Takeaway: 1 row represents an individual order line item, NOT an order.


-- ------------------------------------------------------------------------------
-- QUERY 2: Multi-Line Order Distribution
-- Business Question: What proportion of customer orders contain multiple items?
-- Technique: Subquery / CTE with GROUP BY and HAVING
-- ------------------------------------------------------------------------------
WITH order_item_counts AS (
    SELECT 
        order_id,
        COUNT(*) AS items_in_order
    FROM cleaned_amazon_sales
    GROUP BY order_id
)
SELECT 
    items_in_order,
    COUNT(*) AS order_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total_orders
FROM order_item_counts
GROUP BY items_in_order
ORDER BY items_in_order;


-- ------------------------------------------------------------------------------
-- QUERY 3: Missing Value & Amount Anomaly Check
-- Business Question: Are missing or zero amounts associated with specific order statuses?
-- Technique: CASE WHEN aggregation and status cross-tabulation
-- ------------------------------------------------------------------------------
SELECT 
    status_group,
    COUNT(*) AS total_records,
    COUNT(CASE WHEN amount IS NULL OR amount = 0 THEN 1 END) AS zero_or_null_amounts,
    ROUND(100.0 * COUNT(CASE WHEN amount IS NULL OR amount = 0 THEN 1 END) / COUNT(*), 2) AS zero_amount_pct
FROM cleaned_amazon_sales
GROUP BY status_group
ORDER BY total_records DESC;
-- Business Finding: The vast majority of zero amounts occur on Cancelled orders.


-- ------------------------------------------------------------------------------
-- QUERY 4: Executive Control Totals (Python / Power BI Reconciliation)
-- Business Question: What are the macro control totals for orders, units, GMV, and net revenue?
-- Technique: Conditional SUM and DISTINCTCOUNT
-- ------------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_lines,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(qty) AS total_units_booked,
    ROUND(SUM(amount), 2) AS gross_merchandise_value,
    ROUND(SUM(net_revenue), 2) AS net_realized_revenue,
    COUNT(DISTINCT CASE WHEN is_cancelled = FALSE AND is_returned = FALSE THEN order_id END) AS fulfilled_orders,
    ROUND(
        SUM(net_revenue) / 
        NULLIF(COUNT(DISTINCT CASE WHEN is_cancelled = FALSE AND is_returned = FALSE THEN order_id END), 0), 
        2
    ) AS verified_aov
FROM cleaned_amazon_sales;


-- ------------------------------------------------------------------------------
-- QUERY 5: Date Boundary & Continuity Audit
-- Business Question: What is the exact transactional date coverage, and are there missing days?
-- Technique: MIN, MAX, and calendar day count
-- ------------------------------------------------------------------------------
SELECT 
    MIN(date) AS start_date,
    MAX(date) AS end_date,
    COUNT(DISTINCT date) AS active_trading_days,
    (MAX(date) - MIN(date)) + 1 AS calendar_day_span
FROM cleaned_amazon_sales;


-- ------------------------------------------------------------------------------
-- QUERY 6: Duplicate Record Detection
-- Business Question: Are there exact duplicate rows across all business keys?
-- Technique: GROUP BY with HAVING COUNT(*) > 1
-- ------------------------------------------------------------------------------
SELECT 
    order_id,
    sku,
    date,
    qty,
    amount,
    COUNT(*) AS duplicate_instances
FROM cleaned_amazon_sales
GROUP BY order_id, sku, date, qty, amount
HAVING COUNT(*) > 1;
-- Expected: 0 duplicate instances confirming clean staging.
