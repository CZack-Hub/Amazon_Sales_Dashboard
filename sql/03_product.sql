-- ==============================================================================
-- AMAZON INDIA E-COMMERCE SALES ANALYTICS
-- FILE 3: PRODUCT, MERCHANDISING & PARETO (80/20) ANALYSIS
--
-- Objective: Dissect category margins, identify hero SKUs, and evaluate catalog concentration.
-- Target Table: fact_order_line / cleaned_amazon_sales
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- QUERY 13: Category Revenue & Volume Contribution
-- Business Question: Which apparel categories generate the bulk of business volume?
-- Technique: Aggregation with Window SUM() for percentage of total
-- ------------------------------------------------------------------------------
SELECT 
    category,
    COUNT(DISTINCT order_id) AS distinct_orders,
    SUM(qty) AS total_units_sold,
    ROUND(SUM(amount), 2) AS gross_revenue,
    ROUND(SUM(net_revenue), 2) AS net_revenue,
    ROUND(100.0 * SUM(net_revenue) / SUM(SUM(net_revenue)) OVER (), 2) AS revenue_share_pct,
    ROUND(SUM(net_revenue) / NULLIF(SUM(qty), 0), 2) AS avg_realized_price_per_unit
FROM cleaned_amazon_sales
GROUP BY category
ORDER BY net_revenue DESC;
-- Business Finding: "Set" and "Kurta" generate ~69% of net revenue.


-- ------------------------------------------------------------------------------
-- QUERY 14: Pareto (80/20) Cumulative Revenue Analysis on Product SKUs
-- Business Question: What percentage of catalog SKUs account for 80% of net revenue?
-- Technique: Running total window function SUM() OVER () and cumulative percentage
-- ------------------------------------------------------------------------------
WITH sku_totals AS (
    SELECT 
        sku,
        category,
        SUM(net_revenue) AS sku_revenue,
        SUM(qty) AS sku_units
    FROM cleaned_amazon_sales
    GROUP BY sku, category
),
sku_cumulative AS (
    SELECT 
        sku,
        category,
        sku_revenue,
        sku_units,
        ROW_NUMBER() OVER (ORDER BY sku_revenue DESC) AS sku_rank,
        COUNT(*) OVER () AS total_catalog_skus,
        SUM(sku_revenue) OVER (ORDER BY sku_revenue DESC) AS cumulative_revenue,
        SUM(sku_revenue) OVER () AS total_catalog_revenue
    FROM sku_totals
)
SELECT 
    sku_rank,
    sku,
    category,
    ROUND(sku_revenue, 2) AS sku_revenue,
    sku_units,
    ROUND(100.0 * sku_rank / total_catalog_skus, 2) AS catalog_sku_pct,
    ROUND(100.0 * cumulative_revenue / total_catalog_revenue, 2) AS cumulative_revenue_pct,
    CASE 
        WHEN cumulative_revenue / total_catalog_revenue <= 0.80 THEN 'Class A (Top 80% Rev)'
        WHEN cumulative_revenue / total_catalog_revenue <= 0.95 THEN 'Class B (Next 15% Rev)'
        ELSE 'Class C (Long Tail 5% Rev)'
    END AS abc_pareto_classification
FROM sku_cumulative
ORDER BY sku_rank;
-- Business Finding: Top ~18.5% of SKUs generate 80% of sales.


-- ------------------------------------------------------------------------------
-- QUERY 15: Top 10 Best-Selling SKUs by Net Revenue
-- Business Question: Which individual product SKUs are the top 10 revenue drivers?
-- Technique: Window Function DENSE_RANK() with multi-column metrics
-- ------------------------------------------------------------------------------
WITH ranked_skus AS (
    SELECT 
        sku,
        style,
        category,
        size,
        SUM(qty) AS units_sold,
        ROUND(SUM(net_revenue), 2) AS net_revenue,
        ROUND(SUM(net_revenue) / NULLIF(SUM(qty), 0), 2) AS avg_unit_price,
        DENSE_RANK() OVER (ORDER BY SUM(net_revenue) DESC) AS revenue_rank
    FROM cleaned_amazon_sales
    GROUP BY sku, style, category, size
)
SELECT 
    revenue_rank,
    sku,
    style,
    category,
    size,
    units_sold,
    net_revenue,
    avg_unit_price
FROM ranked_skus
WHERE revenue_rank <= 10
ORDER BY revenue_rank;


-- ------------------------------------------------------------------------------
-- QUERY 16: Volume vs Price Trade-Off (High Units, Low Margin Potential)
-- Business Question: Which products sell high volume but have lower average realization?
-- Technique: Cross-comparison of unit rank vs revenue rank
-- ------------------------------------------------------------------------------
WITH sku_ranks AS (
    SELECT 
        sku,
        category,
        SUM(qty) AS units_sold,
        SUM(net_revenue) AS net_revenue,
        ROUND(SUM(net_revenue) / NULLIF(SUM(qty), 0), 2) AS price_per_unit,
        RANK() OVER (ORDER BY SUM(qty) DESC) AS unit_rank,
        RANK() OVER (ORDER BY SUM(net_revenue) DESC) AS revenue_rank
    FROM cleaned_amazon_sales
    GROUP BY sku, category
)
SELECT 
    sku,
    category,
    units_sold,
    unit_rank,
    ROUND(net_revenue, 2) AS net_revenue,
    revenue_rank,
    price_per_unit,
    (revenue_rank - unit_rank) AS rank_disparity
FROM sku_ranks
WHERE unit_rank <= 50 AND price_per_unit < 400
ORDER BY units_sold DESC;


-- ------------------------------------------------------------------------------
-- QUERY 17: Apparel Size Demand Matrix Across Top Categories
-- Business Question: What is the garment size distribution across the primary categories?
-- Technique: Conditional aggregation / Pivot simulation using CASE WHEN
-- ------------------------------------------------------------------------------
SELECT 
    category,
    SUM(CASE WHEN size = 'XS' THEN qty ELSE 0 END) AS size_xs_units,
    SUM(CASE WHEN size = 'S' THEN qty ELSE 0 END) AS size_s_units,
    SUM(CASE WHEN size = 'M' THEN qty ELSE 0 END) AS size_m_units,
    SUM(CASE WHEN size = 'L' THEN qty ELSE 0 END) AS size_l_units,
    SUM(CASE WHEN size = 'XL' THEN qty ELSE 0 END) AS size_xl_units,
    SUM(CASE WHEN size = 'XXL' THEN qty ELSE 0 END) AS size_xxl_units,
    SUM(CASE WHEN size = '3XL' THEN qty ELSE 0 END) AS size_3xl_units,
    SUM(qty) AS total_category_units
FROM cleaned_amazon_sales
WHERE category IN ('Set', 'Kurta', 'Western Dress', 'Top')
GROUP BY category
ORDER BY total_category_units DESC;
-- Business Finding: Sizes M, L, and XL dominate volume across all apparel categories.


-- ------------------------------------------------------------------------------
-- QUERY 18: Monthly Category Ranking Dynamics (Shift over Time)
-- Business Question: Did category revenue leadership change between April, May, and June?
-- Technique: DENSE_RANK() PARTITION BY month ORDER BY revenue DESC
-- ------------------------------------------------------------------------------
WITH monthly_category_sales AS (
    SELECT 
        year_month,
        category,
        ROUND(SUM(net_revenue), 2) AS monthly_revenue,
        DENSE_RANK() OVER (
            PARTITION BY year_month 
            ORDER BY SUM(net_revenue) DESC
        ) AS category_rank
    FROM cleaned_amazon_sales
    GROUP BY year_month, category
)
SELECT 
    year_month,
    category_rank,
    category,
    monthly_revenue
FROM monthly_category_sales
WHERE category_rank <= 5
ORDER BY year_month, category_rank;
