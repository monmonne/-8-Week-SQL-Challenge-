----- A.  Customer Journey-----

select customer_id, PL.plan_id, plan_name, start_date, price
from plans pl
join subscriptions su 
on pl.plan_id = su.plan_id
WHERE customer_id IN (1, 2, 11, 13, 15, 16, 18, 19);

/* DESCRIPTION
- customer 1 start trial on 2020-08-01 and after 7 day trial register basic monthly with 9.90
- customer 2 start trial on 2020-09-20 and after 7 day trial register pro annual with 199.00
- customer 11 start trial on 2020-11-19 and after 7 day trial then churn , stop sub
- customer 13 start trial on 2020-12-15 and after 7 day trial register basic monthly with 9.90 ,pro monthly with 19.90
- customer 15 start trial on 2020-03-17 and after 7 day trial register pro monthly with 19.90, then churn, stop sub
- customer 16 start trial on 2020-05-31 and after 7 day trial register basic monthly with 9.90, then pro annual with 199.00
- customer 18 start trial on 2020-07-06 and after 7 day trial register pro monthly with 19.90
- customer 19 start trial on 2020-06-22 and after 7 day trial register pro monthly with 19.90, then pro annual with 199.00 
*/

----- B. Data Analysis Questions -----
-- 1. How many customers has Foodie-Fi ever had? 1000
select count(distinct customer_id)
from subscriptions;

-- 2.What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
select year(start_date), month(start_date),  count(*)
from subscriptions s
join plans p 
on s.plan_id = p.plan_id
where p.plan_id = 0 
group by year(start_date),  month(start_date)
order by 1,2;
;

select *
from subscriptions
where start_date like '2021%'
and plan_id  = 0; # no trial regis in 2021

-- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

select plan_name, count(*) as ttl_event
from subscriptions s 
join plans p 
on s.plan_id = p.plan_id
where start_date > '2020-12-31'
group by plan_name
order by 2;
 -- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
 
 select count(customer_id) ttl_churn_customer, round(count(customer_id)/(select count(distinct customer_id) from subscriptions) *100,1) churn_rate
from subscriptions s 
join plans p 
on s.plan_id = p.plan_id
where plan_name = 'churn';
 
 -- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number? 92
select count(*)ttl_customer, round(count(*)/(select count(distinct customer_id) from subscriptions)*100) churn_rate_after_trial
from
(
select customer_id, plan_name, rank() over( partition by customer_id order by p.plan_id) rnk
from subscriptions s 
join plans p 
on s.plan_id = p.plan_id
)t1
 where rnk = 2 and plan_name  = "churn";
 
 -- 6. What is the number and percentage of customer plans after their initial free trial?
 select plan_name, count(customer_id) ttl_customer, concat(round(count(customer_id)/(select count(distinct customer_id) from subscriptions)*100), '%') rate
 from
 (
 select customer_id, plan_name, rank() over( partition by customer_id order by p.plan_id) rnk

from subscriptions s 
join plans p 
on s.plan_id = p.plan_id
) t1
where plan_name != 'trial' and rnk = 2
group by plan_name;

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

select plan_name, count(customer_id) ttl_customer, round(count(customer_id)/(select count(distinct customer_id) from subscriptions)*100,1) conversion_rate
from
(
select customer_id, p.plan_name, start_date, rank() over( partition by customer_id order by start_date desc) rnk
from subscriptions s 
join plans p 
on s.plan_id = p.plan_id
where start_date < '2021-01-01'
) t1
where rnk = 1
group by plan_name;

-- 8. How many customers have upgraded to an annual plan in 2020?
select count(*) tt_annual_customer
from subscriptions s 
join plans p 
on s.plan_id = p.plan_id
where plan_name like '%annual%'
and year(start_date) = 2020;

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
-- find the trial_date and annualdate in st
with  trial_list as
(
select customer_id, start_date, p.plan_id, plan_name
from subscriptions s 
join plans p 
on s.plan_id = p.plan_id
where plan_name like 'trial'
) 
select concat(round(avg(datediff(t1.start_date,tl.start_date))), ' days') average_time_to_annualplan
from trial_list tl
join 
(select customer_id, start_date, p.plan_id, plan_name
from subscriptions s 
join plans p 
on s.plan_id = p.plan_id
where plan_name like '%annual'
) t1
on tl.customer_id = t1.customer_id;

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)?
with  trial_list as
(
select customer_id, start_date, p.plan_id, plan_name
from subscriptions s 
join plans p 
on s.plan_id = p.plan_id
where plan_name like 'trial'
) 
select 
	count( case when datediff(t1.start_date, tl.start_date) <= 30 then 1 end) as one_month,
    count( case when datediff(t1.start_date, tl.start_date) between 31 and 60 then 1 end) as two_month,
	count( case when datediff(t1.start_date, tl.start_date) between 61 and 90 then 1 end) as three_month,
	count( case when datediff(t1.start_date, tl.start_date) between 91 and 120 then 1 end) as four_month,
	count( case when datediff(t1.start_date, tl.start_date) between 121 and 150 then 1 end) as five_month,
	count( case when datediff(t1.start_date, tl.start_date) between 151 and 180 then 1 end) as six_month,
	count( case when datediff(t1.start_date, tl.start_date) between 181 and 210 then 1 end) as seven_month,
	count( case when datediff(t1.start_date, tl.start_date) between 211 and 240 then 1 end) as eight_month,
	count( case when datediff(t1.start_date, tl.start_date) between 241 and 270 then 1 end) as nine_month,
	count( case when datediff(t1.start_date, tl.start_date) between 270 and 300 then 1 end) as ten_month,
	count( case when datediff(t1.start_date, tl.start_date) between 301 and 330 then 1 end) as eleven_month,
	count( case when datediff(t1.start_date, tl.start_date) between 331 and 365 then 1 end) as one_year
from trial_list tl
join 
(select customer_id, start_date, p.plan_id, plan_name
from subscriptions s 
join plans p 
on s.plan_id = p.plan_id
where plan_name like '%annual'
) t1
on tl.customer_id = t1.customer_id;

-- 1. How many customers downgraded from a pro monthly to a basic monthly plan in 2020? 0
with pro_monthly as
(select customer_id, start_date, p.plan_id, plan_name
from subscriptions s 
join plans p 
on s.plan_id = p.plan_id
where plan_name like '%pro monthly'
and year(start_date) = 2020
),
basic_monthly as
(select customer_id, start_date, p.plan_id, plan_name
from subscriptions s 
join plans p 
on s.plan_id = p.plan_id
where plan_name like '%basic monthly'
and year(start_date) = 2020
)
select count(*) pro_to_basic
from pro_monthly pro
join basic_monthly bs
on pro.customer_id = bs.customer_id
where pro.start_date < bs.start_date;

----- C. Challenge Payment Question -----
/*
The Foodie-Fi team wants to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- once a customer churns they will no longer make payments
*/



