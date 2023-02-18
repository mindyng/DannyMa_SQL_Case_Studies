-- Schema SQL Query SQL ResultsEdit on DB Fiddle
-- Example Query:
-- SELECT
-- 	runners.runner_id,
--     runners.registration_date,
-- 	COUNT(DISTINCT runner_orders.order_id) AS orders
-- FROM pizza_runner.runners
-- INNER JOIN pizza_runner.runner_orders
-- 	ON runners.runner_id = runner_orders.runner_id
-- WHERE runner_orders.cancellation IS NOT NULL
-- GROUP BY
-- 	runners.runner_id,
--     runners.registration_date;
    
-- Before you start writing your SQL queries however - you might want to investigate the data, you may want to do something with some of those null values and data types in the customer_orders and runner_orders tables!

-- A. Pizza Metrics
-- How many pizzas were ordered?

SELECT COUNT(*) AS total_pizzas_ordered
FROM pizza_runner.customer_orders;

-- How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id) AS unique_customer_orders
FROM pizza_runner.customer_orders;

-- How many successful orders were delivered by each runner?

SELECT runner_id
, COUNT(*) AS total_successful_orders
FROM pizza_runner.runner_orders
WHERE duration != 'null'
GROUP BY 1;

-- How many of each type of pizza was delivered?

SELECT pizza_id
, COUNT(*) AS pizza_type_count
FROM pizza_runner.runner_orders
JOIN pizza_runner.customer_orders
ON runner_orders.order_id = customer_orders.order_id
WHERE duration != 'null'
GROUP BY 1
ORDER BY 1;

-- How many Vegetarian and Meatlovers were ordered by each customer?

SELECT customer_id
, pizza_name
, COUNT(*) AS num_pizzas
FROM pizza_runner.customer_orders
JOIN pizza_runner.pizza_names
ON customer_orders.pizza_id = pizza_names.pizza_id
GROUP BY 1
, 2;

-- What was the maximum number of pizzas delivered in a single order?

SELECT customer_orders.order_id
, COUNT(*) AS num_pizzas
FROM pizza_runner.customer_orders
JOIN pizza_runner.runner_orders
ON customer_orders.order_id = runner_orders.order_id
WHERE duration != 'null'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?



-- How many pizzas were delivered that had both exclusions and extras?
-- What was the total volume of pizzas ordered for each hour of the day?
-- What was the volume of orders for each day of the week?
