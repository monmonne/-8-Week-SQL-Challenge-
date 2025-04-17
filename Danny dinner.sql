CREATE DATABASE dannys_diner;

CREATE TABLE dannys_diner.sales (
    customer_id VARCHAR(1),
    order_date DATE,
    product_id INT
);

INSERT INTO dannys_diner.sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);


CREATE TABLE dannys_diner.menu (
    product_id INT,
    product_name VARCHAR(5),
    price INT
);


INSERT INTO dannys_diner.menu
  (product_id, product_name, price)
VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);


CREATE TABLE dannys_diner.members (
    customer_id VARCHAR(1),
    join_date DATE
);

INSERT INTO dannys_diner.members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

SELECT 
    *
FROM
    members;
SELECT 
    *
FROM
    menu;
SELECT 
    *
FROM
    sales;
--  1. What is the total amount each customer spent at the restaurant?
SELECT 
    s.customer_id customer, SUM(m.price) total_spending
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY 2 DESC;

-- Q2. How many days has each customer visited the restaurant?
SELECT 
    customer_id, COUNT(DISTINCT order_date) total_visit
FROM
    sales
GROUP BY 1;

-- Q3. What was the first item from the menu purchased by each customer?
 -- 1 find the first product that each customer buy
 
WITH  first_purchase AS
(
 SELECT customer_id, order_date, product_id
 FROM
 (
 SELECT  * , dense_rank() over(partition by customer_id order by order_date) rnk
 FROM sales 
) t1
WHERE rnk = 1
GROUP BY 1, 2, 3 #select the first prod  each customer bought
)

SELECT f.customer_id, f.order_date, m.product_name
FROM first_purchase f 
JOIN menu m 
ON f.product_id = m.product_id;

-- Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?
 
SELECT 
    m.product_id, m.product_name, COUNT(*) AS total_sale_cnt
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
GROUP BY m.product_name , m.product_id
ORDER BY 3 DESC;
 
 --  Q5. Which item was the most popular for each customer?
 --  detect the cnt of each prodtc purchase each customer
 with most_fav_prod as
 (select customer_id,product_id, total_cnt
 from(
 select *, dense_rank() over (partition by customer_id order by total_cnt desc) rnk
 from(
 select customer_id, product_id, count(*) as total_cnt
 from sales
 group by customer_id, product_id
 )t1
 )t2
 where rnk = 1
 )
 select f.customer_id, f.product_id, m.product_name, f.total_cnt
 from most_fav_prod f 
 join menu m on f.product_id = m.product_id
order  by  1,2;

-- Q6. Which item was purchased first by the customer after they became a member?
 /* 1.find the customer with their first order after register_Date
 */
SELECT customer_id, order_date, join_date, product_name
FROM 
(
 SELECT s.customer_id, s.order_date, s.product_id, m.product_name, mem.join_date,
 DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date ASC) order_date_rnk
 FROM sales s 
 JOIN members mem 
 ON s.order_date>= mem.join_date
 AND s.customer_id = mem.customer_id
 JOIN menu m 
 ON s.product_id = m.product_id
 ) t1
 WHERE t1.order_date_rnk= 1;
 
 -- Q7. Which item was purchased just before the customer became a member?
 

 with order_before_member as
 (
 select s.customer_id, s.order_date, mem.join_date, s.product_id,m.product_name,
 rank() over(partition by s.customer_id order by s.order_date desc) rnk
 from sales s
 join members mem 
 on s.customer_id = mem.customer_id
 and s.order_date < mem.join_date
 join menu m on s.product_id = m.product_id
) 
select * 
from order_before_member
where rnk = 1;

-- Q8. What is the total items and amount spent for each member before they became a member?
SELECT 
    s.customer_id, COUNT(*) AS ttl_pro, SUM(m.price) ttl_amt
FROM
    sales s
        JOIN
    members mem ON s.customer_id = mem.customer_id
        AND s.order_date < mem.join_date
        JOIN
    menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- Note: Only customers who are members receive points when purchasing items

WITH table_of_point AS
(
SELECT s.customer_id,
	   m.product_name, 
       m.price,
	   CASE WHEN s.customer_id IN (SELECT customer_id FROM members) AND product_name != 'sushi' THEN 10
			WHEN s.customer_id IN (SELECT customer_id FROM members) AND product_name = 'sushi' THEN 20 
			ELSE 0
	   END AS point
FROM sales s 
JOIN menu m 
ON s.product_id = m.product_id
)
select customer_id, sum(price * point) ttl_point
from table_of_point 
group by customer_id;

-- Q10. In the first week after a customer joins the program (including their join date), they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH extra_first_week AS
(
SELECT s.customer_id, s.order_date, mem.join_date, s.product_id, m.product_name, m.price, 20 as point
FROM sales s
JOIN members mem
ON s.customer_id = mem.customer_id
AND s.order_date>= mem.join_date
AND datediff(s.order_date, mem.join_date) <=6
JOIN menu m
ON s.product_id = m.product_id
ORDER BY s.customer_id, s.order_date
)
SELECT customer_id, sum(price * point)  1stweek_pnt
FROM extra_first_week
GROUP BY 1; # firstweek point


-------

with point_after_member as
(
select s.customer_id, s.order_date, mem.join_date, s.product_id, m.product_name, m.price,
	   case when datediff(s.order_date, mem.join_date) <= 6 then 20 # 1week after registration
			when  m.product_name = 'sushi' then 20
            else 10
		end as point
from sales s
join members mem
on s.customer_id = mem.customer_id
and s.order_date>= mem.join_date
join menu m
on s.product_id = m.product_id
order by s.customer_id, s.order_date
)
select customer_id, sum(price * point) ttl_point_jan
from point_after_member 
where month(order_date) = 1 and year(order_date) = 2021
group by 1; # this is case when point is calculated for customers from the day they became members til the end of jan

-----
with purchase_in_jan as
(
select s.customer_id, s.order_date, s.product_id, m.product_name, m.price
from sales s
join menu m 
on s.product_id = m.product_id
where month(s.order_date) = 1 and year(s.order_date) = 2021
order by s.customer_id
)
select jan.customer_id, 
       sum( case when jan.order_date between mem.join_date and date_Add(mem.join_date, interval 6 day) then price * 20
			 when product_name = 'sushi' then price * 20
		else price * 10 end) ttp
from purchase_in_jan jan
left join members mem 
on jan.customer_id= mem.customer_id
group by jan.customer_id
order by jan.customer_id;



SELECT 
    jan.customer_id,
    SUM(CASE
        WHEN
            DATEDIFF(jan.order_date, mem.join_date) <= 6
                OR product_name = 'sushi'
        THEN
            price * 20
        ELSE price * 10
    END) AS point
FROM
    purchase_in_jan jan
        LEFT JOIN
    members mem ON jan.customer_id = mem.customer_id
GROUP BY 1
; # point for all customers that order in jan




