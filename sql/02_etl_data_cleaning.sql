-- ==============================================================================
-- 02_etl_data_cleaning.sql
-- Project: AtliQ Hardware Sales Analytics Suite
-- Description: Robust SQL ETL pipeline to clean, standardize, and transform
--              the sales data into an enterprise-ready analytics schema.
-- ==============================================================================

USE `sales`;

-- ------------------------------------------------------------------------------
-- 1. CLEAN DIMENSION: CUSTOMERS (v_dim_customers)
-- Fixes: Fixes typo 'custmer_name' -> 'customer_name', trims whitespace.
-- ------------------------------------------------------------------------------
DROP VIEW IF EXISTS `v_dim_customers`;
CREATE VIEW `v_dim_customers` AS
SELECT 
    TRIM(customer_code) AS customer_code,
    TRIM(custmer_name) AS customer_name,
    TRIM(customer_type) AS customer_channel
FROM `customers`;


-- ------------------------------------------------------------------------------
-- 2. CLEAN DIMENSION: MARKETS (v_dim_markets)
-- Fixes:
--   - Unifies duplicate Bhopal codes (Mark013 merged into Mark007)
--   - Excludes inactive international test markets (New York Mark097, Paris Mark999)
-- ------------------------------------------------------------------------------
DROP VIEW IF EXISTS `v_dim_markets`;
CREATE VIEW `v_dim_markets` AS
SELECT 
    TRIM(markets_code) AS market_code,
    TRIM(markets_name) AS market_name,
    TRIM(zone) AS zone
FROM `markets`
WHERE markets_code NOT IN ('Mark013', 'Mark097', 'Mark999');


-- ------------------------------------------------------------------------------
-- 3. CLEAN DIMENSION: DATE (v_dim_date)
-- Fixes: Strips '\r' carriage return from date_yy_mmm, enriches date attributes.
-- ------------------------------------------------------------------------------
DROP VIEW IF EXISTS `v_dim_date`;
CREATE VIEW `v_dim_date` AS
SELECT 
    `date` AS order_date,
    `cy_date` AS month_start_date,
    `year`,
    CONCAT('Q', QUARTER(`date`)) AS quarter_name,
    `month_name`,
    MONTH(`date`) AS month_num,
    REPLACE(TRIM(`date_yy_mmm`), '\r', '') AS formatted_yy_mmm,
    DATE_FORMAT(`date`, '%Y-%m') AS year_month,
    DAYNAME(`date`) AS day_of_week
FROM `date`;


-- ------------------------------------------------------------------------------
-- 4. CLEAN DIMENSION: PRODUCTS (v_dim_products)
-- Fixes:
--   - Resolves '\r' in product_type ('Own Brand\r' -> 'Own Brand')
--   - Incorporates missing products (Prod280 - Prod339) using a UNION to ensure
--     zero orphan keys remain in fact_sales.
-- ------------------------------------------------------------------------------
DROP VIEW IF EXISTS `v_dim_products`;
CREATE VIEW `v_dim_products` AS
SELECT 
    TRIM(product_code) AS product_code,
    REPLACE(TRIM(product_type), '\r', '') AS product_type
FROM `products`

UNION

-- Add missing products from transactions that were omitted from products table
SELECT DISTINCT
    TRIM(t.product_code) AS product_code,
    'Distribution' AS product_type -- Default category for missing catalog items
FROM `transactions` t
LEFT JOIN `products` p ON t.product_code = p.product_code
WHERE p.product_code IS NULL;


-- ------------------------------------------------------------------------------
-- 5. CLEAN FACT: TRANSACTIONS (v_fact_sales)
-- Fixes:
--   - Cleans dirty currency string (removes '\r')
--   - Converts USD to INR using standardized conversion rate (1 USD = 75 INR)
--   - Filters out non-positive transactions (sales_amount <= 0)
--   - Remaps duplicate market Mark013 to Mark007 (Bhopal)
--   - Excludes non-operating markets (New York, Paris)
--   - Deduplicates identical transactions
-- ------------------------------------------------------------------------------
DROP VIEW IF EXISTS `v_fact_sales`;
CREATE VIEW `v_fact_sales` AS
SELECT 
    t.product_code,
    t.customer_code,
    CASE 
        WHEN t.market_code = 'Mark013' THEN 'Mark007' 
        ELSE t.market_code 
    END AS market_code,
    t.order_date,
    t.sales_qty,
    -- Standardized Normalized Amount in INR
    CASE 
        WHEN t.currency LIKE 'USD%' THEN ROUND(t.sales_amount * 75.0, 2)
        ELSE ROUND(t.sales_amount, 2)
    END AS normalized_sales_amount,
    'INR' AS standardized_currency
FROM (
    -- Deduplication subquery
    SELECT DISTINCT
        TRIM(product_code) AS product_code,
        TRIM(customer_code) AS customer_code,
        TRIM(market_code) AS market_code,
        order_date,
        sales_qty,
        sales_amount,
        REPLACE(TRIM(currency), '\r', '') AS currency
    FROM `transactions`
    WHERE sales_amount > 0
      AND market_code NOT IN ('Mark097', 'Mark999')
) t;
