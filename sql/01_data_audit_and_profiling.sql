-- ==============================================================================
-- 01_data_audit_and_profiling.sql
-- Project: AtliQ Hardware Sales Analytics Suite
-- Description: Diagnostic SQL script to detect data anomalies, referential
--              integrity violations, character pollution, and currency issues
--              present in the raw database dump.
-- ==============================================================================

USE `sales`;

-- ------------------------------------------------------------------------------
-- 1. RECORD COUNT SUMMARY & HIGH-LEVEL CHECKS
-- ------------------------------------------------------------------------------
SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM `customers`
UNION ALL
SELECT 'date' AS table_name, COUNT(*) AS total_rows FROM `date`
UNION ALL
SELECT 'markets' AS table_name, COUNT(*) AS total_rows FROM `markets`
UNION ALL
SELECT 'products' AS table_name, COUNT(*) AS total_rows FROM `products`
UNION ALL
SELECT 'transactions' AS table_name, COUNT(*) AS total_rows FROM `transactions`;


-- ------------------------------------------------------------------------------
-- 2. CRITICAL ISSUE: ORPHAN FACT KEYS (REFERENTIAL INTEGRITY GAP)
-- Diagnostic: Over 55,150+ transactions reference product codes (Prod280 - Prod339)
--             that DO NOT exist in the products dimension table!
-- ------------------------------------------------------------------------------
SELECT 
    COUNT(DISTINCT t.product_code) AS missing_product_count,
    COUNT(t.product_code) AS affected_transactions_count,
    ROUND(COUNT(t.product_code) * 100.0 / (SELECT COUNT(*) FROM transactions), 2) AS pct_transactions_affected,
    ROUND(SUM(CASE WHEN t.currency LIKE 'USD%' THEN t.sales_amount * 75 ELSE t.sales_amount END), 2) AS at_risk_revenue_inr
FROM `transactions` t
LEFT JOIN `products` p ON t.product_code = p.product_code
WHERE p.product_code IS NULL;

-- Sample missing product codes
SELECT DISTINCT t.product_code
FROM `transactions` t
LEFT JOIN `products` p ON t.product_code = p.product_code
WHERE p.product_code IS NULL
ORDER BY t.product_code
LIMIT 15;


-- ------------------------------------------------------------------------------
-- 3. CARRIAGE RETURN ('\r') POLLUTION IN STRINGS
-- Diagnostic: CSV ingestion on Windows left trailing '\r' characters in multiple tables.
-- ------------------------------------------------------------------------------
-- A. Currency field in transactions
SELECT 
    currency,
    HEX(currency) AS hex_representation,
    COUNT(*) AS transaction_count,
    ROUND(SUM(sales_amount), 2) AS raw_sales_sum
FROM `transactions`
GROUP BY currency, HEX(currency);

-- B. Product type in products table
SELECT 
    product_type,
    HEX(product_type) AS hex_representation,
    COUNT(*) AS count
FROM `products`
GROUP BY product_type, HEX(product_type);

-- C. Date format in date table
SELECT 
    date_yy_mmm,
    HEX(date_yy_mmm) AS hex_representation,
    COUNT(*) AS count
FROM `date`
GROUP BY date_yy_mmm, HEX(date_yy_mmm)
LIMIT 10;


-- ------------------------------------------------------------------------------
-- 4. CURRENCY & DUPLICATE USD TRANSACTIONS
-- Diagnostic: Only 4 USD transactions exist, but they are pairwise duplicates
--             where one row has 'USD' and the duplicate has 'USD\r'.
-- ------------------------------------------------------------------------------
SELECT *
FROM `transactions`
WHERE currency LIKE 'USD%';


-- ------------------------------------------------------------------------------
-- 5. ZERO AND NEGATIVE SALES AMOUNTS
-- Diagnostic: Identifies transactions with zero amount (1,609 rows) and negative
--             sales (-1 amount rows).
-- ------------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN sales_amount < 0 THEN 'Negative Sales (< 0)'
        WHEN sales_amount = 0 THEN 'Zero Sales (= 0)'
        ELSE 'Valid Sales (> 0)'
    END AS sales_amount_category,
    COUNT(*) AS transaction_count,
    ROUND(SUM(sales_amount), 2) AS total_amount,
    SUM(sales_qty) AS total_qty
FROM `transactions`
GROUP BY 
    CASE 
        WHEN sales_amount < 0 THEN 'Negative Sales (< 0)'
        WHEN sales_amount = 0 THEN 'Zero Sales (= 0)'
        ELSE 'Valid Sales (> 0)'
    END;


-- ------------------------------------------------------------------------------
-- 6. MARKET DIMENSION ANOMALIES
-- Diagnostic: Duplicate market codes for Bhopal (Mark007 vs Mark013) and
--             inactive international markets (New York & Paris with blank zones).
-- ------------------------------------------------------------------------------
SELECT 
    m.markets_code,
    m.markets_name,
    m.zone,
    COUNT(t.product_code) AS transaction_count,
    COALESCE(ROUND(SUM(CASE WHEN t.currency LIKE 'USD%' THEN t.sales_amount * 75 ELSE t.sales_amount END), 2), 0) AS total_revenue_inr
FROM `markets` m
LEFT JOIN `transactions` t ON m.markets_code = t.market_code
GROUP BY m.markets_code, m.markets_name, m.zone
ORDER BY m.markets_name, m.markets_code;


-- ------------------------------------------------------------------------------
-- 7. REVENUE RECONCILIATION SUMMARY (RAW VS CLEANED)
-- Diagnostic: Measures the financial impact of data cleaning rules.
-- ------------------------------------------------------------------------------
SELECT 
    '1. Raw Dataset (As-Is)' AS audit_stage,
    COUNT(*) AS total_tx_count,
    ROUND(SUM(CASE WHEN currency LIKE 'USD%' THEN sales_amount * 75.0 ELSE sales_amount END), 2) AS total_revenue_inr
FROM `transactions`

UNION ALL

SELECT 
    '2. After Filtering sales_amount <= 0' AS audit_stage,
    COUNT(*) AS total_tx_count,
    ROUND(SUM(CASE WHEN currency LIKE 'USD%' THEN sales_amount * 75.0 ELSE sales_amount END), 2) AS total_revenue_inr
FROM `transactions`
WHERE sales_amount > 0

UNION ALL

SELECT 
    '3. After Removing Inactive Markets (NY, Paris)' AS audit_stage,
    COUNT(*) AS total_tx_count,
    ROUND(SUM(CASE WHEN currency LIKE 'USD%' THEN sales_amount * 75.0 ELSE sales_amount END), 2) AS total_revenue_inr
FROM `transactions`
WHERE sales_amount > 0 
  AND market_code NOT IN ('Mark097', 'Mark999');
