CREATE DATABASE pizza_sales;
USE pizza_sales;

# one way to import table is by right-clicking on the tables in the schemas tab,
# Tables --> right-click --> Table data import wizard --> browse the table data
# OR Use the below query

CREATE TABLE orders (
	order_id INT PRIMARY KEY,
    data TEXT,
    time TEXT
);
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.1/Uploads/orders.csv"
INTO TABLE orders
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

CREATE TABLE order_details (
	order_details INT PRIMARY KEY,
    order_id INT,
    pizza_id TEXT,
    quantity INT
);
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.1/Uploads/order_details.csv"
INTO TABLE order_details
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
#_________________________________________________________________________________________________#
SELECT *
FROM orders;

SELECT *
FROM order_details;

SELECT *
FROM pizzas;

SELECT *
FROM pizza_types;

# ON both pizzas and pizza_types table the pizza_type_id are same So, we are gonna create a temp table and combine both the tables into one.

CREATE VIEW pizza_details AS
SELECT p.pizza_id,p.pizza_type_id,pt.name,pt.category,p.size,p.price,pt.ingredients
FROM pizzas p
JOIN pizza_types pt
ON pt.pizza_type_id = p.pizza_type_id;

SELECT *
FROM pizza_details;

# Changing the datatype of date and time column of order table (PREPROCESSING OF DATA)
ALTER TABLE orders
RENAME COLUMN data TO date;

ALTER TABLE orders
MODIFY date DATE;

ALTER TABLE ORDERS
MODIFY time TIME;

# DATA ANALYSIS 
# The questions are in the readme file check it out.
# 1) Total Revenue
SELECT ROUND(SUM(p.price * od.quantity),2) AS total_revenue
FROM pizzas p
JOIN order_details od
ON p.pizza_id = od.pizza_id;

# 2) Total number of pizzas sold
SELECT SUM(quantity) AS total_pizzas_sold
FROM order_details;

# 3) Total orders
SELECT COUNT(order_id) AS total_orders
FROM orders;

# 4) Avg order value
SELECT ROUND(SUM(od.quantity*p.price)/COUNT(DISTINCT(od.order_id)),2) AS avg_order_value
FROM order_details od
JOIN pizza_details p
ON p.pizza_id = od.pizza_id;

# Avg number of pizzas per order
SELECT ROUND(SUM(od.quantity)/COUNT(DISTINCT(od.order_id)),0) AS avg_no_of_pizzas_per_order
FROM order_details od;

 # SECTOR WISE CATEGORY:
 # 1) What is the total revenue of pizza across different categories?
 SELECT p.category, SUM(p.price * od.quantity) AS total_revenue , COUNT(DISTINCT(od.order_id)) AS total_orders 
 FROM pizza_details p
 JOIN order_details od
 ON p.pizza_id = od.pizza_id
 GROUP BY p.category; 
 
 # 2)  What is the revenue of pizza across different sizes?
  SELECT p.size, SUM(p.price * od.quantity) AS total_revenue , COUNT(DISTINCT(od.order_id)) AS total_orders 
 FROM pizza_details p
 JOIN order_details od
 ON p.pizza_id = od.pizza_id
 GROUP BY p.size;

##______________________________________________________________________________________________________________##
# SEASONAL ANALYSIS:
# Hourly,daily, and monthly trend in orders and revenue of pizza
# 40:27
SELECT 
	CASE
		WHEN HOUR(o.time) BETWEEN 9 AND 12 THEN 'Late Morning'
        WHEN HOUR(o.time) BETWEEN 12 AND 15 THEN 'Lunch'
        WHEN HOUR(o.time) BETWEEN 15 AND 18 THEN 'Mid Afternoon'
        WHEN HOUR(o.time) BETWEEN 18 AND 21 THEN 'Dinner'
        WHEN HOUR(o.time) BETWEEN 21 AND 23 THEN 'Late Night'
        ELSE 'Others'
	END AS meal_time, COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
JOIN orders o ON o.order_id = o.order_id
GROUP BY meal_time;	

# weekdays (Which days of the week have the highest number of orders?)
SELECT DAYNAME(o.date) AS day_name, COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
JOIN orders o
ON o.order_id = od.order_id
GROUP BY day_name
ORDER BY total_orders DESC;

# monthwise trend (Which month has the highest revenue?)
SELECT MONTHNAME(o.date) AS month_name, COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
JOIN orders o
ON o.order_id = od.order_id
GROUP BY month_name
ORDER BY total_orders DESC;

##________________________________________________________________________________________________________##
# CUSTOMER BEHAVIOR ANALYSIS:
# Most ordered pizza by both name and size(Which pizza is the favorite of customers(most ordered pizza)?)
SELECT p.name, p.size, COUNT(od.order_id) AS pizza_count
FROM order_details od
JOIN pizza_details p
ON od.pizza_id = p.pizza_id
GROUP BY p.name,p.size
ORDER BY pizza_count DESC;

# TOP 5 pizzas by revenue (Top 5 pizzas by revenue?)
SELECT p.name,SUM(p.price * od.quantity) AS total_revenue
FROM order_details od
JOIN pizza_details p
ON od.pizza_id = p.pizza_id
GROUP BY p.name
ORDER BY total_revenue DESC
LIMIT 5;

# Top pizzas by sale (Which pizzas have had the most orders over the past year of business at the pizza restaurant?)
SELECT p.name,SUM(od.quantity) AS pizzas_sold
FROM order_details od
JOIN pizza_details p
ON od.pizza_id = p.pizza_id
GROUP BY p.name
ORDER BY pizzas_sold DESC
LIMIT 5;
##_____________________________________________________________________________________________________________##
# PIZZA ANALYSIS: 
# The pizza with the least and highest price?
#a) LEAST
SELECT p.name,p.price
FROM pizza_details p 
ORDER BY price;
# b) HIGHEST
SELECT p.name,p.price
FROM pizza_details p 
ORDER BY price DESC;

# Number of pizzas per category?
SELECT pt.category, COUNT(p.pizza_id) AS total_pizzas
FROM pizza_details pt
JOIN pizzas p
ON p.pizza_id = pt.pizza_id
GROUP BY pt.category;

# Number of pizzas per size
SELECT pt.size, COUNT(p.pizza_id) AS total_pizzas
FROM pizza_details pt
JOIN pizzas p
ON p.pizza_id = pt.pizza_id
GROUP BY pt.size;

# FINAL 
# Which ingredients does the restaurant need to make sure they have in hand to make the ordered pizzas?

SELECT *
FROM pizza_details;

SELECT *
FROM order_details;

CREATE TEMPORARY TABLE numbers AS(
	SELECT 1 AS n UNION ALL
    SELECT 2  UNION ALL SELECT 3  UNION ALL SELECT 4  UNION ALL
    SELECT 5  UNION ALL SELECT 6  UNION ALL SELECT 7  UNION ALL
    SELECT 8  UNION ALL SELECT 9  UNION ALL SELECT 10
);

SELECT ingredients, COUNT(ingredients) AS ingredients_count
FROM (
	SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(ingredients,',',n),',',-1) AS ingredients
    FROM order_details o
    JOIN pizza_details p ON p.pizza_id = o.pizza_id
    JOIN numbers ON CHAR_LENGTH(ingredients) - CHAR_LENGTH(REPLACE(ingredients,',','')) >= n-1
	) AS subquery
GROUP BY ingredients
ORDER BY ingredients_count DESC;



 

















