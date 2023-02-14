/* --------------------
   Case Study Questions
   --------------------*/

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
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- Example Query:
-- SELECT
--   	product_id,
--     product_name,
--     price
-- FROM dannys_diner.menu
-- ORDER BY price DESC
-- LIMIT 5;
