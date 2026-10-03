# DAX Measure Dictionary & Business Logic

This document provides technical documentation, business rationale, and syntax for all DAX measures implemented in the **AtliQ Hardware Sales & Profitability Analytics Suite**.

---

## 1. Core Sales & Volume Metrics

| Measure Name | DAX Expression | Business Rationale | Format |
| :--- | :--- | :--- | :--- |
| **`[Total Revenue]`** | `SUM(fact_sales[sales_amount_inr])` | Sum of normalized sales transactions in INR across all filtered dimensions. | `₹#,##0` |
| **`[Total Units Sold]`** | `SUM(fact_sales[sales_qty])` | Aggregates volume of hardware units moved across distribution networks. | `#,##0` |
| **`[Total Orders]`** | `DISTINCTCOUNT(fact_sales[transaction_id])` | Total unique invoice/transaction records generated. | `#,##0` |
| **`[Active Customers]`** | `DISTINCTCOUNT(fact_sales[customer_code])` | Counts unique purchasing customer accounts within selected timeframe. | `#,##0` |
| **`[Active Products Sold]`**| `DISTINCTCOUNT(fact_sales[product_code])` | Counts distinct catalog items with active transactions. | `#,##0` |

---

## 2. Profitability & Unit Economics

| Measure Name | DAX Expression | Business Rationale | Format |
| :--- | :--- | :--- | :--- |
| **`[Total Cost (COGS)]`** | `SUM(fact_sales[cost_amount_inr])` | Direct manufacturing/procurement cost associated with fulfilled orders. | `₹#,##0` |
| **`[Gross Profit]`** | `[Total Revenue] - [Total Cost (COGS)]` | Net earnings before operating expenses, taxes, and overhead. | `₹#,##0` |
| **`[Gross Margin %]`** | `DIVIDE([Gross Profit], [Total Revenue], 0)` | Return per Rupee of revenue. Critical KPI to prevent unprofitable discounting. | `0.0%` |
| **`[Average Order Value]`**| `DIVIDE([Total Revenue], [Total Orders], 0)` | Average basket size per sales order transaction. | `₹#,##0` |
| **`[Average Selling Price]`**| `DIVIDE([Total Revenue], [Total Units Sold], 0)`| Blended realization price per unit across all product categories. | `₹#,##0.00` |

---

## 3. Time Intelligence & Variance Analysis

| Measure Name | DAX Expression | Business Rationale | Format |
| :--- | :--- | :--- | :--- |
| **`[Revenue LY]`** | `CALCULATE([Total Revenue], SAMEPERIODLASTYEAR(dim_date[order_date]))` | Benchmark sales from identical period in preceding year. | `₹#,##0` |
| **`[YoY Revenue Growth]`** | `[Total Revenue] - [Revenue LY]` | Absolute Rupee variance compared to previous year. | `+₹#,##0;-₹#,##0` |
| **`[YoY Revenue Growth %]`**| `DIVIDE([YoY Revenue Growth], [Revenue LY], 0)` | Percentage velocity of top-line growth. | `+0.0%;-0.0%` |
| **`[Revenue YTD]`** | `TOTALYTD([Total Revenue], dim_date[order_date])` | Cumulative year-to-date sales for pacing against annual targets. | `₹#,##0` |
| **`[YoY Profit Growth %]`** | `DIVIDE([Gross Profit] - [Gross Profit LY], [Gross Profit LY], 0)` | Ensures profit growth keeps pace with top-line revenue expansion. | `+0.0%;-0.0%` |

---

## 4. Omnichannel & Channel Dynamics

| Measure Name | DAX Expression | Business Rationale | Format |
| :--- | :--- | :--- | :--- |
| **`[Brick & Mortar Revenue]`**| `CALCULATE([Total Revenue], dim_customers[customer_channel] = "Brick & Mortar")` | Physical wholesale/retail store network revenue. | `₹#,##0` |
| **`[E-Commerce Revenue]`** | `CALCULATE([Total Revenue], dim_customers[customer_channel] = "E-Commerce")` | Direct-to-consumer and marketplace sales. | `₹#,##0` |
| **`[E-Commerce Share %]`** | `DIVIDE([E-Commerce Revenue], [Total Revenue], 0)` | Tracks digital channel adoption and resilience (e.g. during COVID-19). | `0.0%` |

---

## 5. Advanced Segmentation & Pareto Logic

| Measure Name | Description | Use Case |
| :--- | :--- | :--- |
| **`[Cumulative Customer Revenue]`** | Dynamically aggregates revenue from highest to lowest customer accounts using `ALLSELECTED` and `SUMX`. | Forms the running total for Pareto 80/20 analysis. |
| **`[Pareto Cumulative %]`** | Divides cumulative customer revenue by total selected sales. | Identifies the vital 20% of accounts generating 80% of cash flow. |
| **`[Margin Status KPI Color]`** | Evaluates margin thresholds (Green >= 14%, Amber 10-14%, Red < 10%). | Drives conditional formatting in cards and matrix visuals. |
