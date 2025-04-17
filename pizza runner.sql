create database pizza_runner;
drop table if exists pizza_runner.runners;
create table pizza_runner.runners
(runner_id int,
registration_date DATE
);
insert into pizza_runner.runners
(runner_id, registration_date) 
values
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

DROP TABLE IF EXISTS pizza_runner.customer_orders;

CREATE TABLE pizza_runner.customer_orders (
  order_id int,
  customer_id INT,
  pizza_id INT,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time datetime 
);

INSERT INTO pizza_runner.customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  (1, 101, 1, NULL, NULL, '2020-01-01 18:05:02'),
  (2, 101, 1, NULL, NULL, '2020-01-01 19:00:52'),
  (3, 102, 1, NULL, NULL, '2020-01-02 23:51:23'),
  (3, 102, 2, NULL, NULL, '2020-01-02 23:51:23'),
  (4, 103, 1, '4', NULL, '2020-01-04 13:23:46'),
  (4, 103, 1, '4', NULL, '2020-01-04 13:23:46'),
  (4, 103, 2, '4', NULL, '2020-01-04 13:23:46'),
  (5, 104, 1, NULL, '1', '2020-01-08 21:00:29'),
  (6, 101, 2, NULL, NULL, '2020-01-08 21:03:13'),
  (7, 105, 2, NULL, '1', '2020-01-08 21:20:29'),
  (8, 102, 1, NULL, NULL, '2020-01-09 23:54:33'),
  (9, 103, 1, '4', '1, 5', '2020-01-10 11:22:59'),
  (10, 104, 1, NULL, NULL, '2020-01-11 18:34:49'),
  (10, 104, 1, '2, 6', '1, 4', '2020-01-11 18:34:49');
  
  DROP TABLE IF EXISTS pizza_runner.runner_orders;
CREATE TABLE pizza_runner.runner_orders (
  order_id INT,
  runner_id INT,
  pickup_time DATETIME,
  distance DECIMAL(5,2),
  duration VARCHAR(20),
  cancellation VARCHAR(50)
);

INSERT INTO pizza_runner.runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  (1, 1, '2020-01-01 18:15:34', 20.00, '32 minutes', NULL),
  (2, 1, '2020-01-01 19:10:54', 20.00, '27 minutes', NULL),
  (3, 1, '2020-01-03 00:12:37', 13.40, '20 mins', NULL),
  (4, 2, '2020-01-04 13:53:03', 23.40, '40', NULL),
  (5, 3, '2020-01-08 21:10:57', 10.00, '15', NULL),
  (6, 3, NULL, NULL, NULL, 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', 25.00, '25mins', NULL),
  (8, 2, '2020-01-10 00:15:02', 23.40, '15 minute', NULL),
  (9, 2, NULL, NULL, NULL, 'Customer Cancellation'),
  (10, 1, '2020-01-11 18:50:20', 10.00, '10minutes', NULL);
  
  DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INT,
  pizza_name VARCHAR(20)
);

INSERT INTO pizza_names (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INT,
  toppings VARCHAR(100)
);

INSERT INTO pizza_recipes (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INT,
  topping_name VARCHAR(50)
);

INSERT INTO pizza_toppings (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato');
  
 SELECT 
    *
FROM
    pizza_toppings;
SELECT 
    *
FROM
    customer_orders;
  
  ----- DATA CLEANING----
  -- 
  
  -- 1. how many pizzas were ordered? 14
  select count(*) ttl_orders
  from customer_orders;
  -- 2. How many unique customer orders were made? 10
SELECT 
    COUNT(DISTINCT order_id) unique_customer_order
FROM
    customer_orders
;

-- 3. How many successful orders were delivered by each runner?
SELECT 
    *
FROM
    runner_orders;

SELECT 
    runner_id, COUNT(order_id) ttl_order
FROM
    runner_orders
WHERE
    cancellation IS NULL
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?

SELECT 
    na.pizza_name, COUNT(*) AS ttl_pizza_delivered
FROM
    pizza_names na
        JOIN
    customer_orders ord ON na.pizza_id = ord.pizza_id
        JOIN
    runner_orders run ON run.order_id = ord.order_id
WHERE
    run.cancellation IS NULL
GROUP BY na.pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
    na.pizza_name, ord.customer_id, COUNT(*) AS ttl_ordered
FROM
    pizza_names na
        JOIN
    customer_orders ord ON na.pizza_id = ord.pizza_id
GROUP BY na.pizza_name , ord.customer_id
ORDER BY na.pizza_name , ord.customer_id;


-- 6. What was the maximum number of pizzas delivered in a single order?


SELECT 
    order_id, COUNT(*) AS ttl_pizza
FROM
    customer_orders
GROUP BY order_id
ORDER BY 2 DESC
LIMIT 1;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changesrunner_orders
SELECT 
    *
FROM
    customer_orders;

SELECT 
    ord.customer_id,
    COUNT(CASE
        WHEN
            ord.exclusions IS NULL
                AND extras IS NULL
        THEN
            1
    END) no_change_cnt,
    COUNT(CASE
        WHEN
            ord.exclusions IS NOT NULL
                OR extras IS NOT NULL
        THEN
            1
    END) change_cnt
FROM
    customer_orders ord
        JOIN
    runner_orders run ON ord.order_id = run.order_id
WHERE
    run.cancellation IS NULL
GROUP BY ord.customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?


SELECT 
    COUNT(CASE
        WHEN
            ord.exclusions IS NOT NULL
                AND ord.extras IS NOT NULL
        THEN
            1
    END) ttl_pizza_changed
FROM
    customer_orders ord
        JOIN
    runner_orders run ON ord.order_id = run.order_id
WHERE
    run.cancellation IS NULL;SELECT 
    HOUR(order_time), COUNT(*) ttl_pizza
FROM
    customer_orders
GROUP BY HOUR(order_time)
ORDER BY 1 ASC;

-- 10. What was the volume of orders for each day of the week?
SELECT 
    DAYOFWEEK(order_time), COUNT(*) ttl_pizza
FROM
    customer_orders
GROUP BY DAYOFWEEK(order_time)
ORDER BY 1 ASC;

----- RUNNER AND CUSTOMER EXPERIENCE-----
-- 1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT *
from runners;

SELECT 
    WEEK(registration_date) + 1, COUNT(*) ttl_runner
FROM
    runners
GROUP BY WEEK(registration_date) + 1; # + 1 due to the result will count from 0 , instead of 1.


-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
-- clean the data to find the duration of each order order time to pickup  
with time_to_pickup as
(
select runo.order_id, runo.runner_id, cuso.order_time, runo.pickup_time,
		minute(timediff(runo.pickup_time,cuso.order_time)) time_pickuptime
from runner_orders runo
join customer_orders cuso 
on runo.order_id= cuso.order_id
where runo.pickup_time is not null
)
select runner_id, round(avg(time_pickuptime),2) avg_time
from time_to_pickup 
group by runner_id;



 -- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
 -- direction: find the num of pizza each order and how long dis it take to prepare
 
with cnt_pizza_per_order as
(
 select ord.order_id, count(pizza_id) ttl_pizza
 from customer_orders ord
 join runner_orders run 
 on ord.order_id = run.order_id
 where cancellation is null
 group by ord.order_id
) 
,time_per_order as
(
 select distinct ord.order_id, minute(timediff(order_time, pickup_time)) time_prep
 from customer_orders ord
 join runner_orders run 
 on ord.order_id = run.order_id
 where cancellation is null
 )
 select ttl_pizza, round(avg(time_prep)) time_prep_avg
 from time_per_order ti
 join cnt_pizza_per_order cnt
 on ti.order_id = cnt.order_id
 group by ttl_pizza;
 
 
 -- 4. What was the average distance travelled for each customer?
SELECT 
    customer_id, ROUND(AVG(distance), 2)
FROM
    (SELECT 
        run.order_id, cus.customer_id, distance
    FROM
        runner_orders run
    JOIN customer_orders cus ON run.order_id = cus.order_id
    WHERE
        cancellation IS NULL) t1
GROUP BY customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT 
    CONCAT(MAX(duration) - MIN(duration), ' mins') duration_gap
FROM
    runner_orders;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT 
    runner_id,
    AVG(distance),
    AVG(duration),
    ROUND(AVG(distance / duration), 2) speed
FROM
    runner_orders
GROUP BY runner_id;

SELECT 
    order_id, runner_id, AVG(distance / duration * 60) speed
FROM
    runner_orders
WHERE
    cancellation IS NULL
GROUP BY order_id , runner_id;

-- 7. What is the successful delivery percentage for each runner?
-- find the rate: tota order with no cancel/total order by each runenr 
SELECT 
    runner_id,
    total_order_taken,
    successful_taken,
    CONCAT(ROUND(successful_taken / total_order_taken * 100),
            '%') success_rate
FROM
    (SELECT 
        runner_id,
            COUNT(*) total_order_taken,
            COUNT(CASE
                WHEN cancellation IS NULL THEN 1
            END) successful_taken
    FROM
        runner_orders
    GROUP BY runner_id) t1;
