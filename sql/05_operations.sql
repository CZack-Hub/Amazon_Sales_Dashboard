-- ==============================================================================
-- AMAZON INDIA E-COMMERCE SALES ANALYTICS
-- FILE 5: OPERATIONS, FULFILLMENT, CANCELLATIONS & B2B ANALYSIS
--
-- Objective: Dissect operational bottlenecks, channel reliability, and wholesale dynamics.
-- Target Table: fact_order_line / cleaned_amazon_sales
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- QUERY 25: Fulfillment Channel Performance: Amazon FBA vs Merchant Easy Ship
-- Business Question: How does Amazon FBA compare to Merchant in volume, cancellations, and RTS?
-- Technique: Aggregation with channel-specific conversion and leak rates
-- ------------------------------------------------------------------------------
SELECT 
    fulfilment,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(100.0 * COUNT(DISTINCT order_id) / SUM(COUNT(DISTINCT order_id)) OVER (), 2) AS volume_share_pct,
    COUNT(DISTINCT CASE WHEN is_cancelled = TRUE THEN order_id END) AS cancelled_orders,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN is_cancelled = TRUE THEN order_id END) / 
        COUNT(DISTINCT order_id), 
        2
    ) AS cancellation_rate_pct,
    COUNT(DISTINCT CASE WHEN is_returned = TRUE THEN order_id END) AS returned_orders,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN is_returned = TRUE THEN order_id END) / 
        COUNT(DISTINCT order_id), 
        2
    ) AS return_rate_pct,
    ROUND(SUM(net_revenue), 2) AS net_revenue
FROM cleaned_amazon_sales
GROUP BY fulfilment
ORDER BY total_orders DESC;
-- Business Finding: Amazon FBA commands ~70% of volume with lower operational leakage.


-- ------------------------------------------------------------------------------
-- QUERY 26: Cancellation Rate by Shipping Service Level
-- Business Question: Does expedited shipping reduce cancellation rates compared to standard?
-- Technique: Cross-tabulation of service level vs status flags
-- ------------------------------------------------------------------------------
SELECT 
    ship_service_level,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN is_cancelled = TRUE THEN order_id END) AS cancelled_orders,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN is_cancelled = TRUE THEN order_id END) / 
        COUNT(DISTINCT order_id), 
        2
    ) AS cancellation_rate_pct,
    ROUND(SUM(net_revenue), 2) AS net_revenue
FROM cleaned_amazon_sales
GROUP BY ship_service_level
ORDER BY total_orders DESC;


-- ------------------------------------------------------------------------------
-- QUERY 27: Operational Status Funnel & Revenue Leakage
-- Business Question: What is the distribution across all operational status buckets,
-- and how much revenue is trapped in each bucket?
-- Technique: Categorical grouping with revenue leakage calculation
-- ------------------------------------------------------------------------------
SELECT 
    status_group,
    COUNT(DISTINCT order_id) AS distinct_orders,
    ROUND(100.0 * COUNT(DISTINCT order_id) / SUM(COUNT(DISTINCT order_id)) OVER (), 2) AS order_share_pct,
    SUM(qty) AS units,
    ROUND(SUM(amount), 2) AS total_booked_amount,
    ROUND(SUM(net_revenue), 2) AS realized_amount,
    ROUND(SUM(amount) - SUM(net_revenue), 2) AS unrealized_leakage_amount
FROM cleaned_amazon_sales
GROUP BY status_group
ORDER BY distinct_orders DESC;


-- ------------------------------------------------------------------------------
-- QUERY 28: Return-to-Seller (RTS) Rates by Category
-- Business Question: Which categories suffer the highest rate of customer returns?
-- Technique: Category return rate calculation with volume threshold
-- ------------------------------------------------------------------------------
SELECT 
    category,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN is_returned = TRUE THEN order_id END) AS returned_orders,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN is_returned = TRUE THEN order_id END) / 
        NULLIF(COUNT(DISTINCT order_id), 0), 
        2
    ) AS return_rate_pct,
    ROUND(SUM(amount) FILTER (WHERE is_returned = TRUE), 2) AS revenue_lost_to_returns
FROM cleaned_amazon_sales
GROUP BY category
HAVING COUNT(DISTINCT order_id) >= 100
ORDER BY return_rate_pct DESC;


-- ------------------------------------------------------------------------------
-- QUERY 29: B2B Wholesale vs Retail B2C Purchasing Dynamics
-- Business Question: How do B2B institutional buyers differ in basket size and ticket value?
-- Technique: Comparative segment benchmarking with ratio metrics
-- ------------------------------------------------------------------------------
SELECT 
    CASE WHEN b2b = TRUE THEN 'B2B Enterprise Wholesale' ELSE 'B2C Retail Consumer' END AS customer_segment,
    COUNT(DISTINCT order_id) AS distinct_orders,
    ROUND(100.0 * COUNT(DISTINCT order_id) / SUM(COUNT(DISTINCT order_id)) OVER (), 2) AS order_volume_share_pct,
    SUM(qty) AS units_sold,
    ROUND(SUM(qty)::NUMERIC / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS units_per_order,
    ROUND(SUM(net_revenue), 2) AS net_revenue,
    ROUND(100.0 * SUM(net_revenue) / SUM(SUM(net_revenue)) OVER (), 2) AS revenue_share_pct,
    ROUND(
        SUM(net_revenue) / 
        NULLIF(COUNT(DISTINCT CASE WHEN is_cancelled = FALSE AND is_returned = FALSE THEN order_id END), 0), 
        2
    ) AS aov,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN is_cancelled = TRUE THEN order_id END) / 
        COUNT(DISTINCT order_id), 
        2
    ) AS cancellation_rate_pct
FROM cleaned_amazon_sales
GROUP BY b2b
ORDER BY b2b DESC;


-- ------------------------------------------------------------------------------
-- QUERY 30: High-Cancellation "At-Risk" Products (Operational Flagging)
-- Business Question: Which specific SKUs have unusually high cancellation rates (>25%)
-- and require merchandising / quality intervention?
-- Technique: HAVING clause filtering with statistical minimum order threshold
-- ------------------------------------------------------------------------------
SELECT 
    sku,
    category,
    style,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN is_cancelled = TRUE THEN order_id END) AS cancellations,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN is_cancelled = TRUE THEN order_id END) / 
        COUNT(DISTINCT order_id), 
        2
    ) AS cancellation_rate_pct,
    ROUND(SUM(amount), 2) AS gross_gmv_lost
FROM cleaned_amazon_sales
GROUP BY sku, category, style
HAVING COUNT(DISTINCT order_id) >= 20 
   AND (100.0 * COUNT(DISTINCT CASE WHEN is_cancelled = TRUE THEN order_id END) / COUNT(DISTINCT order_id)) >= 25.0
ORDER BY cancellation_rate_pct DESC, total_orders DESC
LIMIT 20;
-- Business Action: These SKUs require listing accuracy review (fit, color, fabric description).
