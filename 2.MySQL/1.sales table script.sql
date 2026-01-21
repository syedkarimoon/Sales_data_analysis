create database sales;
use sale;
SELECT * FROM sales_table_mysql;
DESCRIBE sales_table_mysql;
ALTER TABLE sales_table_mysql
MODIFY Order_ID VARCHAR(20);

/*  Table Normalization  */

/* 1.Customers Table */

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100)
);
INSERT INTO customers (customer_name)
SELECT DISTINCT Customer_Name
FROM sales_table_mysql;

/* Product table*/

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50)
);
INSERT INTO products (product_name, category)
SELECT DISTINCT Product, Category
FROM sales_table_mysql;

/*Orders Table */

CREATE TABLE orders (
    order_id VARCHAR(20),
    customer_id INT,
    product_id INT,
    order_date DATE,
    quantity INT,
    Total_sales DECIMAL(10,2),

    PRIMARY KEY (order_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
INSERT INTO orders (order_id, customer_id, product_id, order_date, quantity, sales)
SELECT 
    s.Order_ID,
    c.customer_id,
    p.product_id,
    STR_TO_DATE(s.Order_Date, '%d-%m-%Y %H:%i'),
    s.Quantity,
    s.Total_Sales
FROM sales_table_mysql s
JOIN customers c 
    ON s.Customer_Name = c.customer_name
JOIN products p 
    ON s.Product = p.product_name;
    
    SELECT * FROM customers;
    SELECT * FROM products;
    SELECT * From orders;
    
    /* validate data*/
    SELECT COUNT(*) 
    FROM orders;
SELECT * 
FROM orders 
LIMIT 10;

/*1️.Total Sales, 2. Sales by Customer, 3.Top 5 Products by Sales*/

SELECT SUM(sales) AS total_sales
FROM orders;

SELECT c.customer_name, SUM(o.sales) AS total_sales
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY total_sales DESC;

SELECT p.product_name, SUM(o.sales) AS total_sales
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC
LIMIT 5;

     /*DAY-WISE SALES ANALYSIS*/
/*Day-wise Total Sales*/

SELECT 
    DATE(order_date) AS order_day,
    SUM(sales) AS daily_sales
FROM orders
GROUP BY order_day
ORDER BY order_day;

/*Highest Sales Day*/
SELECT 
    DATE(order_date) AS order_day,
    SUM(sales) AS total_sales
FROM orders
GROUP BY order_day
ORDER BY total_sales DESC
LIMIT 1;

/*Lowest Sales Day*/
SELECT 
    DATE(order_date) AS order_day,
    SUM(sales) AS total_sales
FROM orders
GROUP BY order_day
ORDER BY total_sales ASC
LIMIT 1;

/*Average Daily Sales*/

SELECT 
    AVG(daily_sales) AS avg_daily_sales
FROM (
    SELECT DATE(order_date) AS order_day, SUM(sales) AS daily_sales
    FROM orders
    GROUP BY order_day
) t;

              /*Advanced SQL for Your Sales Project*/
/*Advanced SQL (CTE) for Your Sales Project*/
WITH daily_sales AS (
    SELECT
        DATE(order_date) AS order_day,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY DATE(order_date)
)
SELECT *
FROM daily_sales
ORDER BY order_day;

/*Window Function: Rank Days by Sales*/

WITH daily_sales AS (
    SELECT
        DATE(order_date) AS order_day,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY DATE(order_date)
)
SELECT
    order_day,
    total_sales,
    RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM daily_sales;

/*Window Function: Running (Cumulative) Sales*/

WITH daily_sales AS (
    SELECT
        DATE(order_date) AS order_day,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY DATE(order_date)
)
SELECT
    order_day,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_day) AS cumulative_sales
FROM daily_sales;

/* Window Function: Average Daily Sales (Without GROUP BY)*/

WITH daily_sales AS (
    SELECT
        DATE(order_date) AS order_day,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY DATE(order_date)
)
SELECT
    order_day,
    total_sales,
    AVG(total_sales) OVER () AS avg_daily_sales
FROM daily_sales;

/* Window Function: Compare Each Day with Previous Day*/

WITH daily_sales AS (
    SELECT
        DATE(order_date) AS order_day,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY DATE(order_date)
)
SELECT
    order_day,
    total_sales,
    LAG(total_sales) OVER (ORDER BY order_day) AS prev_day_sales,
    total_sales - LAG(total_sales) OVER (ORDER BY order_day) AS daily_change
FROM daily_sales;

/* Window Function: Customer Ranking by Sales*/

SELECT
    c.customer_name,
    SUM(o.sales) AS total_sales,
    DENSE_RANK() OVER (ORDER BY SUM(o.sales) DESC) AS customer_rank
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_name;

/* Top 3 Products Using CTE + Window Function */

WITH product_sales AS (
    SELECT
        p.product_name,
        SUM(o.sales) AS total_sales
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY p.product_name
)
SELECT *
FROM (
    SELECT
        product_name,
        total_sales,
        RANK() OVER (ORDER BY total_sales DESC) AS product_rank
    FROM product_sales
) ranked_products
WHERE product_rank <= 3;














