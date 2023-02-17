--Ref: https://www.db-fiddle.com/f/bLv9b15qZV1xzWgsgPJ8eK/1

/* --------------------
   Case Study Questions
   --------------------*/
   
-- Example Query:
-- SELECT
--   	product_id,
--     product_name,
--     price
-- FROM dannys_diner.menu
-- ORDER BY price DESC
-- LIMIT 5;

-- 1. What is the total amount each customer spent at the restaurant?

SELECT customer_id
, SUM(price) AS total_cust_spend
FROM dannys_diner.sales
JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
GROUP BY 1
ORDER By 2 DESC;


-- 2. How many days has each customer visited the restaurant?

--get each customer's order dates
--get distinct date per customer
--count these as num_days/cust

SELECT customer_id
, COUNT(DISTINCT DATE(order_date)) AS days_visited
FROM dannys_diner.sales
GROUP BY 1
ORDER BY 2 DESC;

-- 3. What was the first item from the menu purchased by each customer?

--window fxn to rank order_date in ASC order by each customer
--filter on first order date
--output first order per customer

WITH orders AS (
SELECT customer_id
  , product_id
, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_rk
FROM dannys_diner.sales
)

SELECT customer_id, product_name
FROM orders
JOIN dannys_diner.menu
ON orders.product_id = menu.product_id
WHERE order_rk = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT customer_id
, COUNT(sales.product_id) AS popular_item_cnt

FROM dannys_diner.sales

JOIN

(
SELECT product_id
, COUNT(*) AS item_count
FROM dannys_diner.sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1
) AS most_popular_item

ON sales.product_id = most_popular_item.product_id
GROUP BY 1
;

-- 5. Which item was the most popular for each customer?

WITH cte AS (
SELECT customer_id
, product_id
, COUNT(product_id) AS item_count
FROM dannys_diner.sales
GROUP BY 1
, 2
)

, item_pop_rk AS (
SELECT customer_id
, product_id
, item_count
, DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY item_count DESC) AS item_rk
FROM cte
)

SELECT customer_id
, product_name
FROM item_pop_rk
JOIN dannys_diner.menu
ON item_pop_rk.product_id = menu.product_id
WHERE item_rk = 1;

-- 6. Which item was purchased first by the customer after they became a member?

--join customer orders with members based on cust_id AND orders made after sign up date
--order orders by earliest date per customer
--filter on first date (closest to join date)
--output item purchased

WITH cte AS (
SELECT sales.customer_id
, sales.product_id
, DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date) AS order_date_rk
FROM dannys_diner.sales
JOIN dannys_diner.members
ON sales.customer_id = members.customer_id
AND sales.order_date > members.join_date
)

SELECT customer_id
, product_name AS first_purchase_after_membership
FROM cte
JOIN dannys_diner.menu
ON cte.product_id = menu.product_id
WHERE order_date_rk = 1
ORDER BY 1;

-- 7. Which item was purchased just before the customer became a member?

--get all dates before join date
--get the one that is last ranked (closest to join date)

WITH latest_purch AS (
SELECT members.customer_id
, join_date
, sales.order_date
, menu.product_name
, DENSE_RANK() OVER (PARTITION BY members.customer_id ORDER BY order_date DESC) AS latest_purchase
FROM dannys_diner.members
JOIN dannys_diner.sales
ON members.customer_id = sales.customer_id
AND members.join_date > sales.order_date
JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
ORDER BY customer_id, order_date
)

SELECT customer_id
, product_name
FROM latest_purch
WHERE latest_purchase = 1;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT sales.customer_id
, COUNT(sales.product_id) AS total_items
, SUM(price) AS amount_spent
FROM dannys_diner.sales
JOIN dannys_diner.members
ON sales.customer_id = members.customer_id
AND sales.order_date < members.join_date
JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
GROUP BY 1
ORDER BY 1;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

--get $ spent per item
--use condiitional to output points with sushi 2(10*price) pts per $1 and rest 10 pts per $1

SELECT sales.customer_id
, SUM(CASE WHEN product_name = 'sushi' THEN 2*(price*10) ELSE price*10 END) AS points
FROM dannys_diner.sales
JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
GROUP BY 1
ORDER BY 2 DESC;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

--get sales that happen only in January
--allocate points based on purchased item since membership 
	--join date + 6 days: 2*(price * 10)
    --outside of this first week, regular points: non-sushi = price * 10; sushi = 2*(price * 10)

SELECT members.customer_id
, SUM(CASE WHEN order_date <= join_date + INTERVAL '6 day' THEN 2*(price*10) 
WHEN order_date > join_date + INTERVAL '6 day' AND sales.product_id = 1 THEN 2*(price*10) 
WHEN order_date > join_date + INTERVAL '6 day' AND sales.product_id != 1 THEN price*10
END) AS points
FROM (SELECT * FROM dannys_diner.sales WHERE order_date BETWEEN '2021-01-01' AND '2021-01-31') AS sales
JOIN dannys_diner.members
ON sales.customer_id = members.customer_id
JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
GROUP BY 1
ORDER BY 1;

--BONUS Q:

-- Join All The Things
-- The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

-- Recreate the following table output using the available data:

-- customer_id	order_date	product_name	price	member
-- A	2021-01-01	curry	15	N
-- A	2021-01-01	sushi	10	N
-- A	2021-01-07	curry	15	Y
-- A	2021-01-10	ramen	12	Y
-- A	2021-01-11	ramen	12	Y
-- A	2021-01-11	ramen	12	Y
-- B	2021-01-01	curry	15	N
-- B	2021-01-02	curry	15	N
-- B	2021-01-04	sushi	10	N
-- B	2021-01-11	sushi	10	Y
-- B	2021-01-16	ramen	12	Y
-- B	2021-02-01	ramen	12	Y
-- C	2021-01-01	ramen	12	N
-- C	2021-01-01	ramen	12	N
-- C	2021-01-07	ramen	12	N

SELECT sales.customer_id
, order_date
, product_name
, price
, CASE WHEN join_date IS NOT NULL AND order_date >= join_date THEN 'Y' ELSE 'N' END AS member
FROM dannys_diner.sales
LEFT JOIN dannys_diner.members
ON sales.customer_id = members.customer_id
LEFT JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
ORDER BY 1
, 2;

--Rank All The Things
-- Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

-- customer_id	order_date	product_name	price	member	ranking
-- A	2021-01-01	curry	15	N	null
-- A	2021-01-01	sushi	10	N	null
-- A	2021-01-07	curry	15	Y	1
-- A	2021-01-10	ramen	12	Y	2
-- A	2021-01-11	ramen	12	Y	3
-- A	2021-01-11	ramen	12	Y	3
-- B	2021-01-01	curry	15	N	null
-- B	2021-01-02	curry	15	N	null
-- B	2021-01-04	sushi	10	N	null
-- B	2021-01-11	sushi	10	Y	1
-- B	2021-01-16	ramen	12	Y	2
-- B	2021-02-01	ramen	12	Y	3
-- C	2021-01-01	ramen	12	N	null
-- C	2021-01-01	ramen	12	N	null
-- C	2021-01-07	ramen	12	N	null

WITH members AS (SELECT sales.customer_id
, order_date
, product_name
, price
, CASE WHEN join_date IS NOT NULL AND order_date >= join_date THEN 'Y' ELSE 'N' END AS member
FROM dannys_diner.sales
LEFT JOIN dannys_diner.members
ON sales.customer_id = members.customer_id
LEFT JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
ORDER BY 1
, 2)

SELECT *
, CASE WHEN member = 'Y' THEN RANK() OVER (PARTITION BY member, customer_id ORDER BY order_date) ELSE NULL END AS ranking
FROM members
ORDER BY 1
, 2;
