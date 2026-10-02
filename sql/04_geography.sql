-- ==============================================================================
-- AMAZON INDIA E-COMMERCE SALES ANALYTICS
-- FILE 4: GEOGRAPHIC DEMAND & REGIONAL CONCENTRATION
--
-- Objective: Evaluate geographic order patterns, urban clusters, and regional AOV.
-- Target Table: fact_order_line / cleaned_amazon_sales
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- QUERY 19: State-Level Revenue, Volume & AOV Ranking
-- Business Question: Which Indian states generate the most revenue and distinct orders?
-- Technique: Aggregation with Window percentage and RANK()
-- ------------------------------------------------------------------------------
SELECT 
    ship_state,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(qty) AS units_sold,
    ROUND(SUM(net_revenue), 2) AS net_revenue,
    ROUND(100.0 * SUM(net_revenue) / SUM(SUM(net_revenue)) OVER (), 2) AS state_rev_share_pct,
    ROUND(
        SUM(net_revenue) / 
        NULLIF(COUNT(DISTINCT CASE WHEN is_cancelled = FALSE AND is_returned = FALSE THEN order_id END), 0), 
        2
    ) AS state_aov,
    DENSE_RANK() OVER (ORDER BY SUM(net_revenue) DESC) AS revenue_rank
FROM cleaned_amazon_sales
GROUP BY ship_state
ORDER BY net_revenue DESC;
-- Business Finding: Maharashtra, Karnataka, Telangana, and Uttar Pradesh lead nationwide demand.


-- ------------------------------------------------------------------------------
-- QUERY 20: Geographic Market Concentration Index (Top 3 vs Top 5 vs All)
-- Business Question: What percentage of total business is concentrated in the top states?
-- Technique: Cumulative window SUM() with state ranking
-- ------------------------------------------------------------------------------
WITH state_summary AS (
    SELECT 
        ship_state,
        SUM(net_revenue) AS state_revenue
    FROM cleaned_amazon_sales
    GROUP BY ship_state
),
cumulative_states AS (
    SELECT 
        ship_state,
        state_revenue,
        ROW_NUMBER() OVER (ORDER BY state_revenue DESC) AS rank,
        SUM(state_revenue) OVER (ORDER BY state_revenue DESC) AS cumulative_revenue,
        SUM(state_revenue) OVER () AS national_revenue
    FROM state_summary
)
SELECT 
    rank,
    ship_state,
    ROUND(state_revenue, 2) AS state_revenue,
    ROUND(100.0 * state_revenue / national_revenue, 2) AS single_state_share_pct,
    ROUND(100.0 * cumulative_revenue / national_revenue, 2) AS cumulative_share_pct
FROM cumulative_states
WHERE rank <= 10
ORDER BY rank;
-- Business Finding: Top 3 states generate ~44% of revenue; top 5 generate ~58%.


-- ------------------------------------------------------------------------------
-- QUERY 21: Top 15 Metro & Tier-1 Cities by Order Volume
-- Business Question: Which urban centers generate the highest transactional density?
-- Technique: City aggregation with DENSE_RANK()
-- ------------------------------------------------------------------------------
WITH city_metrics AS (
    SELECT 
        ship_city,
        ship_state,
        COUNT(DISTINCT order_id) AS distinct_orders,
        SUM(qty) AS units_sold,
        ROUND(SUM(net_revenue), 2) AS net_revenue,
        DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT order_id) DESC) AS city_rank
    FROM cleaned_amazon_sales
    WHERE ship_city != 'Unknown'
    GROUP BY ship_city, ship_state
)
SELECT 
    city_rank,
    ship_city,
    ship_state,
    distinct_orders,
    units_sold,
    net_revenue
FROM city_metrics
WHERE city_rank <= 15
ORDER BY city_rank;
-- Business Finding: Bengaluru, Hyderabad, Mumbai, New Delhi, and Chennai form top 5 urban hubs.


-- ------------------------------------------------------------------------------
-- QUERY 22: State AOV Variance Against National Average
-- Business Question: Which states exhibit significantly higher or lower ticket sizes?
-- Technique: Comparison against window AVG(AOV)
-- ------------------------------------------------------------------------------
WITH state_aov_calc AS (
    SELECT 
        ship_state,
        COUNT(DISTINCT order_id) AS orders,
        ROUND(
            SUM(net_revenue) / 
            NULLIF(COUNT(DISTINCT CASE WHEN is_cancelled = FALSE AND is_returned = FALSE THEN order_id END), 0), 
            2
        ) AS state_aov
    FROM cleaned_amazon_sales
    GROUP BY ship_state
    HAVING COUNT(DISTINCT order_id) >= 100 -- Focus on statistically reliable samples
),
benchmark AS (
    SELECT 
        ROUND(
            SUM(net_revenue) / 
            NULLIF(COUNT(DISTINCT CASE WHEN is_cancelled = FALSE AND is_returned = FALSE THEN order_id END), 0), 
            2
        ) AS national_aov
    FROM cleaned_amazon_sales
)
SELECT 
    s.ship_state,
    s.orders,
    s.state_aov,
    b.national_aov,
    ROUND(s.state_aov - b.national_aov, 2) AS aov_delta_inr,
    ROUND(100.0 * (s.state_aov - b.national_aov) / b.national_aov, 2) AS aov_variance_pct
FROM state_aov_calc s
CROSS JOIN benchmark b
ORDER BY s.state_aov DESC;


-- ------------------------------------------------------------------------------
-- QUERY 23: Category Preference Mix Across Top 5 States
-- Business Question: Do product preferences vary across the top 5 states?
-- Technique: Multi-level aggregation with category share partitioned by state
-- ------------------------------------------------------------------------------
WITH top_5_states AS (
    SELECT ship_state
    FROM cleaned_amazon_sales
    GROUP BY ship_state
    ORDER BY SUM(net_revenue) DESC
    LIMIT 5
),
state_cat_sales AS (
    SELECT 
        c.ship_state,
        c.category,
        SUM(c.net_revenue) AS category_revenue,
        SUM(SUM(c.net_revenue)) OVER (PARTITION BY c.ship_state) AS total_state_revenue
    FROM cleaned_amazon_sales c
    INNER JOIN top_5_states t ON c.ship_state = t.ship_state
    GROUP BY c.ship_state, c.category
)
SELECT 
    ship_state,
    category,
    ROUND(category_revenue, 2) AS category_revenue,
    ROUND(100.0 * category_revenue / total_state_revenue, 2) AS category_pct_in_state
FROM state_cat_sales
WHERE category IN ('Set', 'Kurta', 'Western Dress', 'Top')
ORDER BY ship_state, category_revenue DESC;


-- ------------------------------------------------------------------------------
-- QUERY 24: High-Density Postal Codes (Fulfillment Hub Logistics)
-- Business Question: Which top 20 PIN codes receive the highest delivery volume?
-- Technique: Postal code aggregation with state linkage
-- ------------------------------------------------------------------------------
SELECT 
    ship_postal_code,
    ship_city,
    ship_state,
    COUNT(DISTINCT order_id) AS distinct_orders,
    SUM(qty) AS units_delivered,
    ROUND(SUM(net_revenue), 2) AS net_revenue
FROM cleaned_amazon_sales
WHERE ship_postal_code != 'Unknown'
GROUP BY ship_postal_code, ship_city, ship_state
ORDER BY distinct_orders DESC
LIMIT 20;
