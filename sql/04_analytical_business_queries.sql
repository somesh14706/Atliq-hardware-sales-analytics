-- ==============================================================================
-- 04_analytical_business_queries.sql
-- Project: AtliQ Hardware Sales Analytics Suite
-- Description: Advanced analytical SQL queries answering core business questions,
--              profitability dynamics, omnichannel shift, and COVID-19 impact.
-- ==============================================================================

USE `atliq_sales_dw`;

-- ------------------------------------------------------------------------------
-- 1. EXECUTIVE KPI SUMMARY (ALL-TIME PERFORMANCE)
-- ------------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_transactions,
    SUM(sales_qty) AS total_units_sold,
    ROUND(SUM(sales_amount_inr) / 10000000, 2) AS total_revenue_crores_inr,
    ROUND(SUM(gross_profit_inr) / 10000000, 2) AS total_gross_profit_crores_inr,
    ROUND((SUM(gross_profit_inr) / SUM(sales_amount_inr)) * 100, 2) AS overall_profit_margin_pct,
    ROUND(SUM(sales_amount_inr) / COUNT(*), 2) AS average_order_value_inr,
    ROUND(SUM(sales_amount_inr) / SUM(sales_qty), 2) AS average_selling_price_inr
FROM `fact_sales`;


-- ------------------------------------------------------------------------------
-- 2. REGIONAL PERFORMANCE: REVENUE VS. PROFIT MARGIN MATRIX
-- Business Insight: Identifies high-revenue/low-margin vs high-margin markets.
-- ------------------------------------------------------------------------------
SELECT 
    m.zone,
    m.market_name,
    COUNT(f.transaction_id) AS total_orders,
    SUM(f.sales_qty) AS units_sold,
    ROUND(SUM(f.sales_amount_inr), 2) AS total_revenue_inr,
    ROUND(SUM(f.gross_profit_inr), 2) AS total_gross_profit_inr,
    ROUND((SUM(f.gross_profit_inr) / SUM(f.sales_amount_inr)) * 100, 2) AS profit_margin_pct,
    ROUND((SUM(f.sales_amount_inr) * 100.0) / (SELECT SUM(sales_amount_inr) FROM fact_sales), 2) AS revenue_contribution_pct
FROM `fact_sales` f
JOIN `dim_markets` m ON f.market_code = m.market_code
GROUP BY m.zone, m.market_name
ORDER BY total_revenue_inr DESC;


-- ------------------------------------------------------------------------------
-- 3. OMNICHANNEL CHANNEL ANALYSIS: BRICK & MORTAR VS. E-COMMERCE
-- Business Insight: Measures performance and margin disparity across sales channels.
-- ------------------------------------------------------------------------------
SELECT 
    d.year,
    c.customer_channel,
    COUNT(f.transaction_id) AS total_orders,
    SUM(f.sales_qty) AS units_sold,
    ROUND(SUM(f.sales_amount_inr), 2) AS total_revenue_inr,
    ROUND((SUM(f.gross_profit_inr) / SUM(f.sales_amount_inr)) * 100, 2) AS channel_margin_pct,
    ROUND(SUM(f.sales_amount_inr) / COUNT(f.transaction_id), 2) AS average_order_value_inr
FROM `fact_sales` f
JOIN `dim_customers` c ON f.customer_code = c.customer_code
JOIN `dim_date` d ON f.order_date = d.order_date
GROUP BY d.year, c.customer_channel
ORDER BY d.year ASC, total_revenue_inr DESC;


-- ------------------------------------------------------------------------------
-- 4. TOP 10 STRATEGIC CUSTOMERS & MARGIN CONTRIBUTION
-- Business Insight: Highlights key revenue drivers and their profitability profile.
-- ------------------------------------------------------------------------------
SELECT 
    c.customer_name,
    c.customer_channel,
    COUNT(f.transaction_id) AS total_orders,
    ROUND(SUM(f.sales_amount_inr), 2) AS total_revenue_inr,
    ROUND(SUM(f.gross_profit_inr), 2) AS total_gross_profit_inr,
    ROUND((SUM(f.gross_profit_inr) / SUM(f.sales_amount_inr)) * 100, 2) AS profit_margin_pct,
    ROUND((SUM(f.sales_amount_inr) * 100.0) / (SELECT SUM(sales_amount_inr) FROM fact_sales), 2) AS pct_of_company_revenue
FROM `fact_sales` f
JOIN `dim_customers` c ON f.customer_code = c.customer_code
GROUP BY c.customer_name, c.customer_channel
ORDER BY total_revenue_inr DESC
LIMIT 10;


-- ------------------------------------------------------------------------------
-- 5. PRODUCT CATEGORY & BRAND TYPE PERFORMANCE
-- Business Insight: Compares profitability between 'Own Brand' and 'Distribution'.
-- ------------------------------------------------------------------------------
SELECT 
    p.category,
    p.product_type,
    COUNT(DISTINCT p.product_code) AS unique_products,
    SUM(f.sales_qty) AS total_units_sold,
    ROUND(SUM(f.sales_amount_inr), 2) AS total_revenue_inr,
    ROUND(SUM(f.gross_profit_inr), 2) AS total_gross_profit_inr,
    ROUND((SUM(f.gross_profit_inr) / SUM(f.sales_amount_inr)) * 100, 2) AS profit_margin_pct
FROM `fact_sales` f
JOIN `dim_products` p ON f.product_code = p.product_code
GROUP BY p.category, p.product_type
ORDER BY total_revenue_inr DESC;


-- ------------------------------------------------------------------------------
-- 6. COVID-19 IMPACT ANALYSIS (MONTH-BY-MONTH IN 2020)
-- Business Insight: Quantifies the severe lockdown shock in March–May 2020.
-- ------------------------------------------------------------------------------
SELECT 
    d.year_month,
    d.month_name,
    COUNT(f.transaction_id) AS total_orders,
    SUM(f.sales_qty) AS units_sold,
    ROUND(SUM(f.sales_amount_inr), 2) AS monthly_revenue_inr,
    ROUND(SUM(f.gross_profit_inr), 2) AS monthly_gross_profit_inr,
    ROUND((SUM(f.gross_profit_inr) / SUM(f.sales_amount_inr)) * 100, 2) AS margin_pct
FROM `fact_sales` f
JOIN `dim_date` d ON f.order_date = d.order_date
WHERE d.year = 2020
GROUP BY d.year_month, d.month_name, d.month_num
ORDER BY d.month_num ASC;


-- ------------------------------------------------------------------------------
-- 7. PARETO 80/20 CUSTOMER REVENUE CONCENTRATION
-- Business Insight: Demonstrates cumulative revenue distribution across accounts.
-- ------------------------------------------------------------------------------
WITH CustomerRevenue AS (
    SELECT 
        c.customer_name,
        SUM(f.sales_amount_inr) AS revenue
    FROM `fact_sales` f
    JOIN `dim_customers` c ON f.customer_code = c.customer_code
    GROUP BY c.customer_name
),
RankedCustomers AS (
    SELECT 
        customer_name,
        revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue,
        SUM(revenue) OVER () AS total_company_revenue
    FROM CustomerRevenue
)
SELECT 
    customer_name,
    ROUND(revenue, 2) AS customer_revenue_inr,
    ROUND(cumulative_revenue, 2) AS cumulative_revenue_inr,
    ROUND((cumulative_revenue / total_company_revenue) * 100, 2) AS cumulative_pct,
    CASE 
        WHEN (cumulative_revenue / total_company_revenue) <= 0.80 THEN 'Top 80% (Tier 1)'
        ELSE 'Remaining 20% (Tier 2/3)'
    END AS pareto_tier
FROM RankedCustomers
ORDER BY revenue DESC;
