-- ============================================================
-- Project: Retail Sales Data Analysis
-- Database: sql_project_retail
-- Author: [Your Name]
-- Description:
--   This project analyzes retail sales data to clean,
--   explore, and answer key business questions using SQL.
-- ============================================================


-- Step 1: Create Database and Table
---------------------------------------------------------------
CREATE DATABASE sql_project_retail;

DROP TABLE IF EXISTS retail_sales;

CREATE TABLE retail_sales (
    transaction_id   INT PRIMARY KEY,
    sale_date        DATE,
    sale_time        TIME,
    customer_id      INT,
    gender           VARCHAR(15),
    age              INT,
    category         VARCHAR(20),
    quantity         INT,
    price_per_unit   FLOAT,
    cogs             FLOAT,
    total_sale       FLOAT
);


-- Step 2: Data Cleaning
---------------------------------------------------------------
-- Checking if there are NULL values in important columns
SELECT *
FROM retail_sales
WHERE transaction_id IS NULL
   OR sale_date IS NULL
   OR sale_time IS NULL
   OR gender IS NULL
   OR category IS NULL
   OR quantity IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;

-- Remove any NULL rows to keep dataset clean
DELETE FROM retail_sales
WHERE transaction_id IS NULL
   OR sale_date IS NULL
   OR sale_time IS NULL
   OR gender IS NULL
   OR category IS NULL
   OR quantity IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;


-- Step 3: Data Exploration
---------------------------------------------------------------
-- 1. How many sales records do we have?
SELECT COUNT(*) AS total_transactions
FROM retail_sales;

-- 2. How many unique customers are in the dataset?
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales;

-- 3. What categories are available?
SELECT DISTINCT category
FROM retail_sales;


-- Step 4: Business Questions & Answers
---------------------------------------------------------------

-- Q1. All transactions that happened on 5th Nov 2022
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';


-- Q2. Clothing sales with quantity > 4 in Nov 2022
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
  AND EXTRACT(YEAR FROM sale_date) = 2022
  AND EXTRACT(MONTH FROM sale_date) = 11
  AND quantity > 4;


-- Q3. Total sales amount and total orders for each category
SELECT 
    category,
    SUM(total_sale) AS total_revenue,
    COUNT(transaction_id) AS total_orders
FROM retail_sales
GROUP BY category
ORDER BY total_revenue DESC;


-- Q4. Average age of customers who purchased Beauty items
SELECT ROUND(AVG(age), 1) AS avg_age_beauty
FROM retail_sales
WHERE category = 'Beauty';


-- Q5. High-value transactions (Sales > 1000)
SELECT *
FROM retail_sales
WHERE total_sale > 1000
ORDER BY total_sale DESC;


-- Q6. Number of transactions by Gender within each Category
SELECT 
    category,
    gender,
    COUNT(transaction_id) AS transactions_count
FROM retail_sales
GROUP BY category, gender
ORDER BY category, transactions_count DESC;


-- Q7. Best-selling month in each year (based on average sale value)
SELECT year, month, avg_sale
FROM (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_sale,
        RANK() OVER (PARTITION BY EXTRACT(YEAR FROM sale_date) 
                     ORDER BY AVG(total_sale) DESC) AS rnk
    FROM retail_sales
    GROUP BY 1, 2
) ranked
WHERE rnk = 1;


-- Q8. Top 5 customers by total spending
SELECT 
    customer_id,
    SUM(total_sale) AS total_spent
FROM retail_sales
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 5;


-- Q9. Unique customers per category
SELECT 
    category,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category;


-- Q10. Sales distribution by time shifts (Morning, Afternoon, Evening)
WITH sales_with_shift AS (
    SELECT *,
           CASE
             WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
             WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
             ELSE 'Evening'
           END AS shift
    FROM retail_sales
)
SELECT shift, COUNT(*) AS orders_count
FROM sales_with_shift
GROUP BY shift
ORDER BY orders_count DESC;

