# 3-Page Executive Dashboard Design Specification

This specification outlines the architecture, layout, visuals, and interactive user experience for the **AtliQ Hardware Sales & Profitability Suite**. It upgrades the generic single-page dashboard into a story-driven executive reporting application.

---

## Design System & Theme Guidelines

| Property | Value | Rationale |
| :--- | :--- | :--- |
| **Canvas Dimensions** | 16:9 widescreen (1280 x 720 px) | Standard corporate presentation format. |
| **Background Color** | Light Gray (`#F8F9FA`) with White Cards (`#FFFFFF`) | High contrast, modern SaaS card-based UI. |
| **Primary Brand Color** | Deep Executive Navy (`#1B2A4A`) | Header bars, primary accents, KPI icons. |
| **Secondary Accent** | Tech Cobalt Blue (`#2980B9`) | Selected states, primary bar charts. |
| **Positive / Margin KPI**| Emerald Green (`#27AE60`) | Profit margins >= 14%, positive YoY growth. |
| **Warning KPI** | Amber Gold (`#F39C12`) | Profit margins 10% - 13.9%. |
| **Negative KPI** | Crimson Coral (`#E74C3C`) | Compressed margins < 10%, negative variance. |
| **Typography** | Segoe UI (9pt data labels, 11pt axis, 14pt titles, 24pt KPIs) | Native Power BI rendering clarity. |

---

## Page 1: Executive Overview & Macro Performance

**Objective:** Give the C-suite (CEO/VP of Sales) an instant snapshot of top-line revenue, bottom-line profitability, order volume, and time-based trajectory.

### Layout Wireframe (1280 x 720)
```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ [LOGO] AtliQ Hardware Executive Performance Suite                 [Slicers: Year | Quarter | Channel]       │
├─────────────────┬─────────────────┬─────────────────┬─────────────────┬──────────────────┬──────────────────┤
│ TOTAL REVENUE   │ GROSS PROFIT    │ GROSS MARGIN %  │ TOTAL UNITS     │ AVG ORDER VALUE  │ YOY GROWTH %     │
│ ₹98.49 Cr       │ ₹10.82 Cr       │ 10.99%          │ 24.3 Lakh       │ ₹6,637           │ +12.4%           │
├─────────────────┴─────────────────┴─────────────────┴─────────────────┴──────────────────┴──────────────────┤
│  CHART 1: Monthly Revenue & Profit Margin Trend (Combo Chart)        │  CHART 2: Revenue by Product Category │
│  - X-Axis: Year-Month (e.g. Oct 2017 to Jun 2020)                    │  - Bar Chart: Displays, Peripherals,  │
│  - Column: Monthly Revenue (INR)                                      │    Storage, Systems, Audio            │
│  - Line: Gross Profit Margin %                                       │  - Tooltip: Units Sold, Margin %      │
├──────────────────────────────────────────────────────────────────────┴──────────────────────────────────────┤
│  CHART 3: Revenue by Zone (Donut Chart: North, South, Central)       │  CHART 4: Top 5 Margin Contributing   │
│  - North: 48.2% | Central: 37.1% | South: 14.7%                      │    Product Lines (Clustered Bar)      │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Page 2: Regional & Market Performance

**Objective:** Enable Regional Sales Directors to evaluate market efficiency, identifying cities with high revenue but thin margins versus emerging high-margin hubs.

### Visual Components
1. **Revenue vs. Margin % Scatter / Matrix:**
   - **X-Axis:** Total Revenue (Volume).
   - **Y-Axis:** Gross Margin % (Profitability).
   - **Quadrant Analysis:**
     - *Star Markets (Top-Right):* High Revenue + High Margin (e.g., Bengaluru, Hyderabad).
     - *Volume Drivers (Bottom-Right):* High Revenue + Low Margin (e.g., Delhi NCR, Mumbai).
     - *Niche Performers (Top-Left):* Low Revenue + High Margin (e.g., Chennai, Kochi).
     - *Underperformers (Bottom-Left):* Low Revenue + Low Margin (e.g., Lucknow, Surat).
2. **City-by-City Performance Table:**
   - Columns: City Name, Zone, Orders, Revenue, YoY Growth %, Gross Margin %, Margin KPI Dot.
3. **Interactive Slicers:**
   - Zone selector pills (`All`, `North`, `Central`, `South`).
   - Margin threshold filter (`All`, `High Margin >= 14%`, `Low Margin < 10%`).

---

## Page 3: Customer & Omnichannel Analytics

**Objective:** Uncover key account dependencies, evaluate the E-Commerce vs. Retail channel shift, and assess pandemic resilience.

### Visual Components
1. **Omnichannel Revenue Breakdown (100% Stacked Bar / Line):**
   - Compares **Brick & Mortar** vs. **E-Commerce** from 2017 to 2020.
   - **COVID-19 Callout Annotation:** Demonstrates the sharp transition to E-Commerce in Q2 2020 when physical stores were shut down.
2. **Top 10 Accounts & Pareto 80/20 Curve:**
   - Horizontal bar chart of top customers (e.g. Electricalsara Stores, Surge Stores, Premium Stores).
   - Line overlay showing **Cumulative Revenue %** (proving that the top 6 customers generate ~75% of total business revenue).
3. **Customer Type Comparison Card:**
   - Metrics side-by-side:
     - Retail Basket Size vs. E-Commerce Basket Size (AOV).
     - Average Discount / Margin disparity between Wholesale and Digital accounts.

---

## Interaction & Navigation Guidelines

1. **Top Navigation Ribbon:**
   - Include 3 page buttons with bookmark navigation (`Executive Overview`, `Regional Performance`, `Customer & Channels`).
2. **Cross-Filtering:**
   - Clicking any Market in Page 2 filters all product category cards for that specific city.
   - Clicking a Customer in Page 3 cross-highlights their preferred product mix.
3. **Report-Level Filters (Hidden in Pane):**
   - Excludes non-positive sales (`sales_amount > 0`).
   - Excludes non-operating test markets (`Mark097`, `Mark999`).
