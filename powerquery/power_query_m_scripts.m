/* ==============================================================================
   power_query_m_scripts.m
   Project: AtliQ Hardware Sales & Profitability Analytics Suite
   Description: Ready-to-use Power Query M code for Power BI Desktop.
   Usage: In Power BI Desktop > Home > Transform Data > New Source > Blank Query 
          > Advanced Editor > Paste the respective query block.
   ============================================================================== */


// ==============================================================================
// OPTION A: LOAD FROM LOCAL CSV FILES IN "data/" DIRECTORY
// (Recommended for instant standalone report generation without MySQL server)
// Replace "C:\YourFolderPath\data" with your local path.
// ==============================================================================

// ------------------------------------------------------------------------------
// QUERY 1: dim_customers
// ------------------------------------------------------------------------------
let
    Source = Csv.Document(File.Contents("data\dim_customers.csv"),[Delimiter=",", Columns=3, Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{
        {"customer_code", type text}, 
        {"customer_name", type text}, 
        {"customer_channel", type text}
    })
in
    #"Changed Type"


// ------------------------------------------------------------------------------
// QUERY 2: dim_markets
// ------------------------------------------------------------------------------
let
    Source = Csv.Document(File.Contents("data\dim_markets.csv"),[Delimiter=",", Columns=3, Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{
        {"market_code", type text}, 
        {"market_name", type text}, 
        {"zone", type text}
    })
in
    #"Changed Type"


// ------------------------------------------------------------------------------
// QUERY 3: dim_products
// ------------------------------------------------------------------------------
let
    Source = Csv.Document(File.Contents("data\dim_products.csv"),[Delimiter=",", Columns=5, Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{
        {"product_code", type text}, 
        {"product_name", type text}, 
        {"category", type text}, 
        {"product_type", type text}, 
        {"margin_rate", type number}
    })
in
    #"Changed Type"


// ------------------------------------------------------------------------------
// QUERY 4: dim_date
// ------------------------------------------------------------------------------
let
    Source = Csv.Document(File.Contents("data\dim_date.csv"),[Delimiter=",", Columns=8, Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{
        {"order_date", type date}, 
        {"month_start_date", type date}, 
        {"year", Int64.Type}, 
        {"quarter_name", type text}, 
        {"month_name", type text}, 
        {"month_num", Int64.Type}, 
        {"year_month", type text}, 
        {"day_of_week", type text}
    })
in
    #"Changed Type"


// ------------------------------------------------------------------------------
// QUERY 5: fact_sales
// ------------------------------------------------------------------------------
let
    Source = Csv.Document(File.Contents("data\fact_sales.csv"),[Delimiter=",", Columns=10, Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{
        {"transaction_id", Int64.Type}, 
        {"order_date", type date}, 
        {"customer_code", type text}, 
        {"product_code", type text}, 
        {"market_code", type text}, 
        {"sales_qty", Int64.Type}, 
        {"sales_amount_inr", type number}, 
        {"cost_amount_inr", type number}, 
        {"gross_profit_inr", type number}, 
        {"profit_margin_pct", type number}
    })
in
    #"Changed Type"


// ==============================================================================
// OPTION B: POWER QUERY ETL DIRECTLY FROM MYSQL
// (Use if connecting live to a MySQL server running sales database)
// ==============================================================================

/*
let
    Source = MySQL.Database("localhost", "sales"),
    sales_transactions = Source{[Schema="sales",Item="transactions"]}[Data],
    
    // 1. Remove carriage returns from currency
    #"Cleaned Currency" = Table.TransformColumns(sales_transactions, {{"currency", each Text.Trim(Text.Replace(_, "#(cr)", "")), type text}}),
    
    // 2. Filter out non-positive sales
    #"Filtered Valid Amounts" = Table.SelectRows(#"Cleaned Currency", each [sales_amount] > 0),
    
    // 3. Remove inactive international markets
    #"Filtered Operating Markets" = Table.SelectRows(#"Filtered Valid Amounts", each [market_code] <> "Mark097" and [market_code] <> "Mark999"),
    
    // 4. Normalize Bhopal duplicate market code (Mark013 -> Mark007)
    #"Normalized Market Code" = Table.ReplaceValue(#"Filtered Operating Markets", "Mark013", "Mark007", Replacer.ReplaceText, {"market_code"}),
    
    // 5. Currency Normalization (Convert USD to INR with 1 USD = 75 INR)
    #"Added Normalized Amount" = Table.AddColumn(#"Normalized Market Code", "sales_amount_inr", 
        each if Text.StartsWith([currency], "USD") then [sales_amount] * 75.0 else [sales_amount], type number),
        
    // 6. Deduplicate exact duplicate rows
    #"Removed Duplicates" = Table.Distinct(#"Added Normalized Amount", {"product_code", "customer_code", "market_code", "order_date", "sales_qty", "sales_amount_inr"})
in
    #"Removed Duplicates"
*/
