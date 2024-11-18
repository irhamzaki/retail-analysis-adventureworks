-- fungsi untuk membersihkan data keuangan
CREATE FUNCTION clean_money(text)
    RETURNS numeric AS
$BODY$
BEGIN
    RETURN CAST(REPLACE(REPLACE($1, '$', ''), ',', '') AS numeric);
END;
$BODY$
LANGUAGE plpgsql;


-- menampilkan data total sales, biaya produksi, dan biaya transaksi serta net profit

-- bulanan
SELECT 
    DATE_TRUNC('month', order_date) AS sales_month,
    SUM(clean_money(s.sales)) AS total_sales,
    SUM(clean_money(s.cost)) AS total_costs,
    (SUM(clean_money(s.sales)) - SUM(clean_money(s.cost))) AS net_profit
FROM sales s
JOIN product p ON s.product_key = p.product_key
GROUP BY sales_month
ORDER BY sales_month;

-- kuartal
SELECT 
    DATE_TRUNC('quarter', order_date) AS sales_quarter,
    SUM(clean_money(s.sales)) AS total_sales,
    SUM(clean_money(s.cost)) AS total_costs,
    (SUM(clean_money(s.sales)) - SUM(clean_money(s.cost))) AS net_profit
FROM sales s
JOIN product p ON s.product_key = p.product_key
GROUP BY sales_quarter
ORDER BY sales_quarter;

-- tahunan
SELECT 
    DATE_TRUNC('year', order_date) AS sales_year,
    SUM(clean_money(s.sales)) AS total_sales,
    SUM(clean_money(s.cost)) AS total_costs,
    (SUM(clean_money(s.sales)) - SUM(clean_money(s.cost))) AS net_profit
FROM sales s
JOIN product p ON s.product_key = p.product_key
GROUP BY sales_year
ORDER BY sales_year;


-- kontribusi tiap region terhadap total sales dari awal beroperasinya retail AdventureWorks
SELECT 
    r.name AS region_name,
    SUM(clean_money(s.sales)) AS total_sales,
    SUM(clean_money(s.cost)) AS total_costs,
    (SUM(clean_money(s.sales)) - SUM(clean_money(s.cost))) AS net_profit
FROM sales s
JOIN product p ON s.product_key = p.product_key
JOIN region r ON s.sales_teritory_key = r.sales_teritory_key
GROUP BY region_name
ORDER BY net_profit DESC;


-- mencari jumlah reseller dengan profit +/-/0/belum ada transaksi
WITH reseller_profits AS (
    SELECT 
        r.reseller_key,
        r.name AS reseller_name,
        (SUM(clean_money(s.sales)) - SUM(clean_money(s.cost))) AS net_profit
    FROM reseller r
    LEFT JOIN sales s ON r.reseller_key = s.reseller_key
    LEFT JOIN product p ON s.product_key = p.product_key
    GROUP BY r.reseller_key, r.name
)

SELECT
    COUNT(CASE WHEN net_profit > 0 THEN 1 END) AS positive_profit_count,
    COUNT(CASE WHEN net_profit < 0 THEN 1 END) AS negative_profit_count,
    COUNT(CASE WHEN net_profit = 0 THEN 1 END) AS zero_profit_count,
    COUNT(CASE WHEN net_profit IS NULL THEN 1 END) AS no_transaction_count
FROM reseller_profits;


-- mencari 5 reseller profit terbesar
SELECT 
    r.name AS reseller_name,
    r.bussiness_type AS business_type,
    rg.name AS region_name,
    SUM(clean_money(s.sales)) AS total_sales,
    SUM(clean_money(s.cost)) AS total_costs,
    (SUM(clean_money(s.sales)) - SUM(clean_money(s.cost))) AS net_profit,
    ((SUM(clean_money(s.sales)) - SUM(clean_money(s.cost))) / SUM(clean_money(s.sales)) * 100) AS profit_margin
FROM sales s
JOIN product p ON s.product_key = p.product_key
JOIN reseller r ON s.reseller_key = r.reseller_key
JOIN region rg ON s.sales_teritory_key = rg.sales_teritory_key
GROUP BY reseller_name, business_type, region_name
ORDER BY net_profit DESC
LIMIT 5;


-- mencari 5 reseller profit margin terbesar
SELECT 
    r.name AS reseller_name,
    r.bussiness_type AS business_type,
    rg.name AS region_name,
    SUM(clean_money(s.sales)) AS total_sales,
    SUM(clean_money(s.cost)) AS total_costs,
    (SUM(clean_money(s.sales)) - SUM(clean_money(s.cost))) AS net_profit,
    ((SUM(clean_money(s.sales)) - SUM(clean_money(s.cost))) / SUM(clean_money(s.sales)) * 100) AS profit_margin
FROM sales s
JOIN product p ON s.product_key = p.product_key
JOIN reseller r ON s.reseller_key = r.reseller_key
JOIN region rg ON s.sales_teritory_key = rg.sales_teritory_key
GROUP BY reseller_name, business_type, region_name
ORDER BY profit_margin DESC
LIMIT 5;


-- mencari 5 reseller profit terkecil
SELECT 
    r.name AS reseller_name,
    r.bussiness_type AS business_type,
    rg.name AS region_name,
    SUM(clean_money(s.sales)) AS total_sales,
    SUM(clean_money(s.cost)) AS total_costs,
    (SUM(clean_money(s.sales)) - SUM(clean_money(s.cost))) AS net_profit,
    ((SUM(clean_money(s.sales)) - SUM(clean_money(s.cost))) / SUM(clean_money(s.sales)) * 100) AS profit_margin
FROM sales s
JOIN product p ON s.product_key = p.product_key
JOIN reseller r ON s.reseller_key = r.reseller_key
JOIN region rg ON s.sales_teritory_key = rg.sales_teritory_key
GROUP BY reseller_name, business_type, region_name
ORDER BY net_profit ASC
LIMIT 5;


-- mencari 5 reseller profit margin terkecil
SELECT 
    r.name AS reseller_name,
    r.bussiness_type AS business_type,
    rg.name AS region_name,
    SUM(clean_money(s.sales)) AS total_sales,
    SUM(clean_money(s.cost)) AS total_costs,
    (SUM(clean_money(s.sales)) - SUM(clean_money(s.cost))) AS net_profit,
    ((SUM(clean_money(s.sales)) - SUM(clean_money(s.cost))) / SUM(clean_money(s.sales)) * 100) AS profit_margin
FROM sales s
JOIN product p ON s.product_key = p.product_key
JOIN reseller r ON s.reseller_key = r.reseller_key
JOIN region rg ON s.sales_teritory_key = rg.sales_teritory_key
GROUP BY reseller_name, business_type, region_name
ORDER BY profit_margin ASC
LIMIT 5;





