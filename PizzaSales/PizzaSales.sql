drop database if exists sqlpowerbiproject;
SET GLOBAL local_infile = 1;
create database sqlpowerbiproject;
use sqlpowerbiproject;
drop table if exists pizza_sales;
CREATE TABLE pizza_sales (
    pizza_id INT,
    order_id INT,
    pizza_name_id VARCHAR(50),
    quantity INT,
    order_date varchar(50),  -- keep as text
    order_time TIME,
    unit_price DECIMAL(6,2),
    total_price DECIMAL(6,2),
    pizza_size CHAR(5),
    pizza_category VARCHAR(50),
    pizza_ingredients TEXT,
    pizza_name VARCHAR(200)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/pizza_sales.csv'
INTO TABLE pizza_sales
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(pizza_id, order_id, pizza_name_id, quantity, 
 @order_date, order_time,
 unit_price, total_price, pizza_size, pizza_category, pizza_ingredients, pizza_name)
SET order_date = STR_TO_DATE(@order_date, '%d-%m-%Y');

select * from pizza_sales;

SELECT SUM(total_price) AS Total_Revenue FROM pizza_sales;

SELECT (SUM(total_price) / COUNT(DISTINCT order_id)) AS Avg_order_Value FROM pizza_sales;

SELECT SUM(quantity) AS Total_pizza_sold FROM pizza_sales;

SELECT COUNT(DISTINCT order_id) AS Total_Orders FROM pizza_sales;

select (sum(quantity)/count(distinct order_id)) as averagepizzasperoder from pizza_sales;

SELECT 
    DAYNAME(order_date) AS order_day, 
    COUNT(DISTINCT order_id) AS total_orders
FROM 
    pizza_sales
GROUP BY 
    DAYNAME(order_date);

SELECT 
    MONTHNAME(order_date) AS Month_Name, 
    COUNT(DISTINCT order_id) AS Total_Orders
FROM 
    pizza_sales
GROUP BY 
    MONTH(order_date), MONTHNAME(order_date)
ORDER BY 
    MONTH(order_date);

SELECT pizza_category, SUM(total_price) as total_revenue,
SUM(total_price) * 100 / (SELECT SUM(total_price) from pizza_sales) AS PCT
FROM pizza_sales
GROUP BY pizza_category;

SELECT pizza_size, SUM(total_price) as total_revenue,
SUM(total_price) * 100 / (SELECT SUM(total_price) from pizza_sales) AS PCT
FROM pizza_sales
GROUP BY pizza_size
ORDER BY pizza_size;

SELECT pizza_category, SUM(quantity) as Total_Quantity_Sold
FROM pizza_sales
GROUP BY pizza_category
ORDER BY Total_Quantity_Sold DESC;

SELECT pizza_name, SUM(total_price) AS Total_Revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Revenue DESC
limit 5;

SELECT pizza_name, SUM(total_price) AS Total_Revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Revenue 
limit 5;

SELECT  pizza_name, SUM(quantity) AS Total_Pizza_Sold
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Pizza_Sold DESC
limit 5;

SELECT  pizza_name, SUM(quantity) AS Total_Pizza_Sold
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Pizza_Sold 
limit 5;

SELECT pizza_name, COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Orders DESC
Limit 5;

SELECT pizza_name, COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Orders 
Limit 5;
