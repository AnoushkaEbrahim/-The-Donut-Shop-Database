CREATE DATABASE donut_shop;

USE donut_shop;

CREATE TABLE customers (
	customer_id INT auto_increment PRIMARY KEY, 
    name VARCHAR(100),
    city VARCHAR(100),
    email VARCHAR(100)
);

INSERT INTO customers (name, email, city) VALUES
('Anoushka', 'anoushka@example.com', 'Berlin'),
('Aliya', 'aliya@example.com', 'Hamburg'),
('Ravi', 'ravi@example.com', 'Munich'),
('Samir', 'samir@example.com', 'Berlin');

select * FROM customers;

CREATE TABLE donuts (
	donut_id INT auto_increment PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(5,3),
    is_vegan BOOLEAN
);

INSERT INTO donuts (name, price, is_vegan) VALUES
('Chocolate Dream', 2.50, FALSE),
('Berry Blast', 2.80, TRUE),
('Classic Glaze', 2.00, FALSE),
('Coconut Swirl', 3.20, TRUE),
('Maple Delight', 2.70, FALSE);

SELECT * FROM donuts;

CREATE TABLE orders (
	order_id INT auto_increment PRIMARY KEY,
    donut_id int,
    customer_id INT,
    quantity INT,
    date DATE,
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id),    
    FOREIGN KEY(donut_id) REFERENCES donuts(donut_id)
);

INSERT INTO orders(customer_id, donut_id, quantity, date) VALUES
(1, 2, 2, '2025-04-01'),
(2, 1, 1, '2025-04-02'),
(3, 4, 3, '2025-04-03'),
(1, 3, 1, '2025-04-04'),
(4, 2, 2, '2025-04-04'),
(3, 5, 1, '2025-04-05');

SELECT * FROM orders;
-- ---------------------------------- BASIC SELECT QUERIES --------------------------------------------------------------
-- Shows all customers and just names & prices of donuts.
SELECT name FROM customers;
select name,price FROM donuts;

-- show only vegan donuts
SELECT name FROM donuts WHERE is_vegan=TRUE;

-- Donuts under 3 euros that are vegan
SELECT name FROM donuts WHERE price<=3 AND is_vegan=TRUE;
-- Customers in Berlin OR Munich
SELECT * FROM customers WHERE city = 'Berlin' OR city = 'Munich';

-- Pattern Matching with LIKE
-- Customers whose name starts with A
SELECT * FROM customers WHERE name LIKE'A%';
-- Donuts with "choco" in the name (case-sensitive)
SELECT * FROM donuts WHERE name LIKE'%choco%';

-- ORDER BY
-- Most expensive donuts first
SELECT * FROM donuts ORDER BY price DESC;
-- Customers alphabetically
SELECT * FROM customers ORDER BY name ASC;
SELECT * FROM donuts LIMIT 2;

-- Find all orders placed on '2025-04-04'.
SELECT * FROM orders WHERE date='2025-04-04';
-- Show all donuts that are NOT vegan and cost more than 2.5.
SELECT * FROM donuts WHERE price>2.5 AND is_vegan = FALSE;
-- List customers whose name ends with “a”.
SELECT * FROM customers WHERE name LIKE'%a';

-- ---------------------------------- AGGREGATE --------------------------------------------------------------------

-- Count total customers
SELECT COUNT(name) as Total_count_customers FROM customers;
-- Total quantity of donuts sold
SELECT SUM(quantity) as Total_donuts_sold FROM orders;
-- Average donut price
SELECT AVG(price) as Avg_donut_price FROM donuts;
-- Most expensive donut
SELECT MAX(price) as Most_Expensive FROM donuts;

-- ------------------------------ GROUP BY & HAVING -----------------------------------------------------------------
-- Total donuts sold per customer
SELECT SUM(quantity) AS total_donuts , customer_id 
FROM orders 
group by customer_id;

-- Number of customers in each city
SELECT city, COUNT(name) AS customer_count
FROM customers
GROUP BY city;

-- JOIN with GROUP BY 
-- Total donuts bought by each customer (with their names)
SELECT customers.name, SUM(orders.quantity)
FROM customers JOIN orders 
ON customers.customer_id=orders.customer_id
GROUP BY customers.name;

-- -- Only show customers who bought more than 2 donuts
SELECT customers.name, SUM(orders.quantity) AS num_of_donuts
FROM customers JOIN orders 
ON customers.customer_id=orders.customer_id
GROUP BY customers.name
HAVING num_of_donuts>2;

-- Find the average price of vegan donuts only.
SELECT AVG(price) AS avg_price
FROM donuts WHERE is_vegan=TRUE;
-- Show each city with more than 1 customer.
SELECT city, COUNT(name) AS customer_count
FROM customers 
GROUP BY city
HAVING customer_count>1;
-- List all donuts and the total quantity sold for each.
SELECT donuts.name, SUM(orders.quantity) AS quantity
FROM donuts INNER JOIN orders 
ON donuts.donut_id = orders.donut_id
group by donuts.name;
-- Show customers who ordered more than 1 donut in total.
SELECT customers.name, SUM(orders.quantity) as Quantity
FROM customers INNER JOIN orders
ON customers.customer_id = orders.customer_id 
group by customers.name
HAVING Quantity>1;

-- ---------------------------------------------- JOINS ------------------------------------------------------------------
-- INNER JOIN
-- Show all orders with customer name and donut name
SELECT customers.name, donuts.name, orders.quantity
FROM orders 
JOIN customers ON orders.customer_id = customers.customer_id
JOIN donuts ON orders.donut_id = donuts.donut_id;

-- List all customers and their orders (even if they haven't ordered yet)
SELECT 
    c.name AS customer_name,
    o.order_id,
    o.quantity
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- List all donuts and see who ordered them (even if no one has)
SELECT 
    d.name AS donut_name,
    o.order_id,
    o.customer_id
FROM donuts d
RIGHT JOIN orders o ON d.donut_id = o.donut_id;


-- ---------------------------------------UNION & UNION ALL ---------------------------------------------------------------
SELECT name AS item_name FROM customers
UNION
SELECT name FROM donuts;

-- ----------------------------------SUB QUERIES --------------------------------------------------------
-- Customers who ordered the most expensive donut
SELECT name FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
    WHERE donut_id = (
        SELECT donut_id FROM donuts WHERE price = (SELECT MAX(price) FROM donuts)
    )
);

-- -----------------------------------------VIEWS ---------------------------------------------
-- Create a view for all full order details
CREATE VIEW full_order_view AS
SELECT 
    o.order_id,
    c.name AS customer_name,
    d.name AS donut_name,
    o.quantity,
    o.date
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN donuts d ON o.donut_id = d.donut_id;

SELECT * FROM full_order_view WHERE quantity > 1;
