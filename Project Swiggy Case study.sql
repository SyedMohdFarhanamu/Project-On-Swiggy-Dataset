CREATE DATABASE project_swiggy;
USE project_swiggy;

-- FIND THE CUSTOMER WHO HAD NEVER ORDERED
SELECT name FROM users WHERE user_id NOT IN (SELECT user_id FROM orders);

-- AVERAGE PRICE/DISH
SELECT f.f_name, AVG(m.price) AS 'Avg price' 
FROM menu m INNER JOIN food f 
ON m.f_id=f.f_id 
GROUP BY m.f_id ;

-- FIND TOP RESTAURANT IN TERMS OF NUMBERS OF ORDERS FOR A GIVEN MONTH
SELECT r.r_name, COUNT(*) AS 'Month' 
FROM orders o INNER JOIN restaurants r 
ON r.r_id=o.r_id 
WHERE MONTHNAME(o.date) LIKE 'JULY' 
GROUP BY o.r_id
ORDER BY COUNT(*) DESC 
LIMIT 1; 

SELECT r.r_name, COUNT(*) AS 'Month' 
FROM orders o INNER JOIN restaurants r 
ON r.r_id=o.r_id 
WHERE MONTHNAME(o.date) LIKE 'MAY' 
GROUP BY o.r_id
ORDER BY COUNT(*) DESC 
LIMIT 1; 

SELECT r.r_name, COUNT(*) AS 'Month' 
FROM orders o INNER JOIN restaurants r 
ON r.r_id=o.r_id 
WHERE MONTHNAME(o.date) LIKE 'JUNE' 
GROUP BY o.r_id
ORDER BY COUNT(*) DESC 
LIMIT 1;

-- RESTAURANT WITH MONTHLY SALE > 500 FOR
SELECT r.r_name, SUM(o.amount) AS 'revenue'
FROM orders o INNER JOIN restaurants r 
ON o.r_id=r.r_id
WHERE MONTHNAME(o.date) LIKE 'may'
GROUP BY o.r_id
HAVING revenue>500;

-- SHOW ALL ORDERS WITH ORDER DETAILS FOR A PARTICULAR CUSTOMER IN A PARTICULAR DATE RANGE
SELECT o.order_id , r.r_name, f.f_name
FROM orders o 
INNER JOIN restaurants r 
ON r.r_id=o.r_id
INNER JOIN order_details od
ON o.order_id=od.order_id
INNER JOIN food f
ON f.f_id=od.f_id
WHERE user_id = (SELECT user_id FROM users WHERE name LIKE 'Ankit')
AND (date >'2022-06-10' AND date < '2022-07-10');                 #### So this is order history of Ankit user.

SELECT o.order_id , r.r_name, f.f_name
FROM orders o INNER JOIN restaurants r 
ON o.r_id=r.r_id
INNER JOIN order_details od
ON o.order_id=od.order_id
INNER JOIN food f
ON od.f_id=f.f_id
WHERE user_id = (SELECT user_id FROM users WHERE name='Nitish')
AND date BETWEEN '2022-06-10' AND '2022-07-10';                  #### So this is order history of Nitish user.


-- FIND THE RESTAURANTS WITH MAXIMUM REPEATED CUSTOMERS.
SELECT r.r_name, COUNT(*) AS 'loyal_customers' 
FROM 
	(SELECT user_id, r_id , COUNT(*) AS 'Visited' 
	FROM orders 
	GROUP BY user_id,r_id 
	HAVING Visited >1  ) t 
JOIN restaurants r 
ON r.r_id=t.r_id
GROUP BY t.r_id
ORDER BY loyal_customers DESC LIMIT 1;     #### Loyal Customer in particular restaurants


-- MONTH OVER MONTH REVENUE GROWTH OF SWIGGY
SELECT t.month, ((t.revenue-t.prev)/t.prev)*100 AS 'growth_in_%' FROM
(
WITH sales AS 
(
	SELECT MONTHNAME(date) AS 'month' , SUM(amount) AS 'revenue'
	FROM orders 
	GROUP BY month
    )
SELECT month, revenue, LAG(revenue,1) OVER(ORDER BY revenue) AS 'prev' FROM sales
) t


-- CUSTOMER FAVORITE FOOD
WITH temp AS 
(
	SELECT  o.user_id,od.f_id, COUNT(*) AS 'FREQUENCY'
	FROM orders o
	INNER JOIN order_details od
	ON od.order_id=o.order_id
	GROUP BY o.user_id,od.f_id
    )
SELECT u.name, f.f_name,t1.frequency 
FROM temp t1 
INNER JOIN users u
ON u.user_id= t1.user_id
INNER JOIN food f
ON f.f_id=t1.f_id
WHERE t1.frequency = (
					SELECT MAX(frequency) 
                    FROM temp t2 
                    WHERE t2.user_id=t1.user_id  )
                    
-- FIND THE MOST LOYAL CUSTOMER FOR ALL RESTAURANT.
#### FOR DOMINOS
SELECT u.name, COUNT(*) AS orders_times 
FROM (
	SELECT * 
	FROM orders 
	WHERE r_id=(SELECT r_id 
				FROM restaurants 
				WHERE r_name LIKE 'box8')) t
INNER JOIN users u
ON u.user_id=t.user_id
GROUP BY t.user_id
ORDER BY orders_times DESC LIMIT 1;

#### FOR Dosa Plaza
SELECT u.name, COUNT(*) AS orders_times 
FROM (
	SELECT * 
	FROM orders 
	WHERE r_id=(SELECT r_id 
				FROM restaurants 
				WHERE r_name LIKE 'Dosa Plaza')) t
INNER JOIN users u
ON u.user_id=t.user_id
GROUP BY t.user_id
ORDER BY orders_times DESC LIMIT 1;


-- MONTH OVER MONTH REVENUE GROWTH OF A RESTAURENT
#### FOR DOMINOS RESTAURANT
SELECT t.month, ((t.revenue-t.prev)/t.prev)*100 AS 'growth_in_%' FROM (
WITH sale_rest AS (
					SELECT MONTHNAME(date) AS 'month' , SUM(amount) AS 'revenue'
					FROM orders 
					WHERE r_id=(SELECT r_id 
								FROM restaurants 
								WHERE r_name LIKE 'dominos')
GROUP BY month

)
SELECT month, revenue, 
LAG(revenue,1) OVER(ORDER BY MONTH(month)) AS 'prev' 
FROM sale_rest ) t ;


#### FOR KFC RESTAURANT
SELECT t.month, ((t.revenue-t.prev)/t.prev)*100 AS 'growth_in_%' FROM (
WITH sale_rest AS (
					SELECT MONTHNAME(date) AS 'month' , SUM(amount) AS 'revenue'
					FROM orders 
					WHERE r_id=(SELECT r_id 
								FROM restaurants 
								WHERE r_name LIKE 'kfc')
GROUP BY month

)
SELECT month, revenue, 
LAG(revenue,1) OVER(ORDER BY MONTH(month)) AS 'prev' 
FROM sale_rest ) t ;


