CREATE DATABASE sales_analysis;
USE sales_analysis;



-- CLEANING THE DATA
ALTER TABLE orders ADD COLUMN Order_Date_Formatted DATE;

UPDATE orders 
SET Order_Date_Formatted = STR_TO_DATE(`Order Date`, '%m/%d/%Y');

SELECT `Order Date`, Order_Date_Formatted FROM orders LIMIT 10;

ALTER TABLE orders DROP COLUMN `Order Date`;
ALTER TABLE orders CHANGE Order_Date_Formatted Order_Date DATE;



-- ALTERING COLUMN NAMES
ALTER TABLE orders 
CHANGE `Order ID` Order_ID VARCHAR(20),
CHANGE `Customer ID` Customer_ID VARCHAR(20),
CHANGE `Customer Name` Customer_Name VARCHAR(100),
CHANGE `Segment` Segment VARCHAR(50),
CHANGE `City` City VARCHAR(50),
CHANGE `State` State VARCHAR(50),
CHANGE `Country` Country VARCHAR(50),
CHANGE `Region` Region VARCHAR(50),
CHANGE `Category` Category VARCHAR(50),
CHANGE `Sub-Category` Sub_Category VARCHAR(50),
CHANGE `Product ID` Product_ID VARCHAR(20),
CHANGE `Product Name` Product_Name VARCHAR(200),
CHANGE `Sales` Sales DECIMAL(10,2),
CHANGE `Quantity` Quantity INT,
CHANGE `Discount` Discount DECIMAL(5,2),
CHANGE `Profit` Profit DECIMAL(10,2);

ALTER TABLE returned 
CHANGE `Order ID` Order_ID VARCHAR(20);

ALTER TABLE orders 
CHANGE `Ship Date` Ship_Date VARCHAR(20);

ALTER TABLE orders 
CHANGE `Ship Mode` Ship_Mode VARCHAR(20);




-- 1) Total revenue and profit generated from all sales

SELECT SUM(Sales) AS total_revenue, SUM(Profit) AS total_profit
FROM orders;

-- 2) Sales by month

SELECT DATE_FORMAT(Order_Date, '%Y-%m') AS month, SUM(Sales) AS total_sales
FROM orders
GROUP BY month
ORDER BY month;

-- 3) Top 5 best selling products based on total sales

SELECT Product_Name, SUM(Sales) AS total_sales, SUM(Quantity) AS total_quantity
FROM orders
GROUP BY Product_Name
ORDER BY total_sales DESC
LIMIT 5;

-- 4) Top 10 products that generate the least profit

SELECT Product_Name, SUM(Profit) AS total_profit
FROM orders
GROUP BY Product_Name
ORDER BY total_profit ASC
LIMIT 10;

-- 5) Most profitable customer segments

SELECT Segment, SUM(Sales) AS total_sales, SUM(Profit) AS total_profit
FROM orders
GROUP BY Segment
ORDER BY total_profit DESC;

-- 6) Sales and profit contribution by region

SELECT Region, SUM(Sales) AS total_sales, SUM(Profit) AS total_profit
FROM orders
GROUP BY Region
ORDER BY total_sales DESC;

-- 7) Top 30 products with the highest return rate

SELECT o.Product_Name, COUNT(r.Order_ID) AS total_returns, 
       COUNT(r.Order_ID) * 100.0 / COUNT(o.Order_ID) AS return_rate
FROM orders o
LEFT JOIN returned r ON o.Order_ID = r.Order_ID
GROUP BY o.Product_Name
ORDER BY return_rate DESC
LIMIT 30;

-- 8) Customers who made the most orders and spent the most money

SELECT o.Customer_Name AS customer_name, 
       COUNT(o.Order_ID) AS total_orders, 
       SUM(o.Sales) AS total_spent
FROM orders o
JOIN people p ON o.Customer_Name = p.Person
GROUP BY o.Customer_Name
ORDER BY total_orders DESC
LIMIT 5;

-- 9) Return rate by customer segment

SELECT o.Segment,
       COUNT(DISTINCT o.Order_ID) AS total_orders,
       COUNT(DISTINCT r.Order_ID) AS total_returns,
       ROUND(COUNT(DISTINCT r.Order_ID) * 100.0 / COUNT(DISTINCT o.Order_ID), 2) AS return_rate
FROM orders o
LEFT JOIN returned r ON o.Order_ID = r.Order_ID
GROUP BY o.Segment
ORDER BY return_rate DESC;

-- 10) Customer loyalty analysis based on quantity of orders and sales

WITH CustomerOrders AS (
    SELECT Customer_Name, COUNT(Order_ID) AS total_orders, SUM(Sales) AS total_spent
    FROM orders
    GROUP BY Customer_Name
)
SELECT Customer_Name,
       total_orders,
       total_spent,
       CASE 
           WHEN total_orders = 1 THEN 'New Customer'
           WHEN total_orders BETWEEN 2 AND 5 THEN 'Emerging Customer'
           WHEN total_orders BETWEEN 6 AND 15 THEN 'Established Customer'
           ELSE 'High-Value Customer'
       END AS customer_category
FROM CustomerOrders
ORDER BY total_orders DESC, total_spent DESC
LIMIT 650;


