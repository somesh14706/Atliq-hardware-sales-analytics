-- ==============================================================================
-- 03_star_schema_ddl.sql
-- Project: AtliQ Hardware Sales Analytics Suite
-- Description: Production Star Schema DDL with Primary Keys, Foreign Keys,
--              Indexes, and Referential Integrity Constraints.
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS `atliq_sales_dw` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `atliq_sales_dw`;

-- ------------------------------------------------------------------------------
-- 1. DIMENSION TABLE: dim_customers
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS `fact_sales`;
DROP TABLE IF EXISTS `dim_customers`;

CREATE TABLE `dim_customers` (
    `customer_code` VARCHAR(20) NOT NULL,
    `customer_name` VARCHAR(100) NOT NULL,
    `customer_channel` VARCHAR(50) NOT NULL COMMENT 'Brick & Mortar or E-Commerce',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`customer_code`),
    INDEX `idx_customer_channel` (`customer_channel`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ------------------------------------------------------------------------------
-- 2. DIMENSION TABLE: dim_markets
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS `dim_markets`;

CREATE TABLE `dim_markets` (
    `market_code` VARCHAR(20) NOT NULL,
    `market_name` VARCHAR(50) NOT NULL,
    `zone` VARCHAR(20) NOT NULL COMMENT 'North, South, Central',
    PRIMARY KEY (`market_code`),
    INDEX `idx_zone` (`zone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ------------------------------------------------------------------------------
-- 3. DIMENSION TABLE: dim_products
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS `dim_products`;

CREATE TABLE `dim_products` (
    `product_code` VARCHAR(20) NOT NULL,
    `product_name` VARCHAR(150) NOT NULL,
    `category` VARCHAR(50) NOT NULL COMMENT 'Displays, Peripherals, Systems, Storage, Accessories',
    `product_type` VARCHAR(50) NOT NULL COMMENT 'Own Brand or Distribution',
    `unit_cost_inr` DECIMAL(10, 2) DEFAULT 0.00,
    PRIMARY KEY (`product_code`),
    INDEX `idx_category` (`category`),
    INDEX `idx_product_type` (`product_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ------------------------------------------------------------------------------
-- 4. DIMENSION TABLE: dim_date
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS `dim_date`;

CREATE TABLE `dim_date` (
    `order_date` DATE NOT NULL,
    `month_start_date` DATE NOT NULL,
    `year` INT NOT NULL,
    `quarter_name` VARCHAR(10) NOT NULL,
    `month_name` VARCHAR(20) NOT NULL,
    `month_num` TINYINT NOT NULL,
    `formatted_yy_mmm` VARCHAR(20) NOT NULL,
    `year_month` VARCHAR(10) NOT NULL,
    `day_of_week` VARCHAR(20) NOT NULL,
    PRIMARY KEY (`order_date`),
    INDEX `idx_year_month` (`year`, `month_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ------------------------------------------------------------------------------
-- 5. FACT TABLE: fact_sales
-- ------------------------------------------------------------------------------
CREATE TABLE `fact_sales` (
    `transaction_id` INT AUTO_INCREMENT NOT NULL,
    `order_date` DATE NOT NULL,
    `customer_code` VARCHAR(20) NOT NULL,
    `product_code` VARCHAR(20) NOT NULL,
    `market_code` VARCHAR(20) NOT NULL,
    `sales_qty` INT NOT NULL CHECK (`sales_qty` > 0),
    `sales_amount_inr` DECIMAL(12, 2) NOT NULL CHECK (`sales_amount_inr` > 0),
    `cost_amount_inr` DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    `gross_profit_inr` DECIMAL(12, 2) GENERATED ALWAYS AS (`sales_amount_inr` - `cost_amount_inr`) STORED,
    `profit_margin_pct` DECIMAL(5, 2) GENERATED ALWAYS AS (
        CASE WHEN `sales_amount_inr` > 0 
             THEN ROUND(((`sales_amount_inr` - `cost_amount_inr`) / `sales_amount_inr`) * 100, 2)
             ELSE 0.00 
        END
    ) STORED,
    `currency` VARCHAR(10) NOT NULL DEFAULT 'INR',
    PRIMARY KEY (`transaction_id`),
    INDEX `idx_order_date` (`order_date`),
    INDEX `idx_customer` (`customer_code`),
    INDEX `idx_product` (`product_code`),
    INDEX `idx_market` (`market_code`),
    CONSTRAINT `fk_sales_customer` FOREIGN KEY (`customer_code`) REFERENCES `dim_customers` (`customer_code`) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT `fk_sales_market` FOREIGN KEY (`market_code`) REFERENCES `dim_markets` (`market_code`) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT `fk_sales_product` FOREIGN KEY (`product_code`) REFERENCES `dim_products` (`product_code`) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT `fk_sales_date` FOREIGN KEY (`order_date`) REFERENCES `dim_date` (`order_date`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
