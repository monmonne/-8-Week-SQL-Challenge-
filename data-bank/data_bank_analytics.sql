----- A. Customer Nodes Exploration -----
-- 1. How many unique nodes are there on the Data Bank system?
select *
from data_bank.customer_nodes
where customer_id = 1;
select *
from data_bank.customer_transactions;
select * from data_bank.regions;

select count(distinct node_id) nodes_cnt
from customer_nodes;

-- 2. What is the number of nodes per region?
select region_name, count(*) as num_of_nodes
from customer_nodes nod 
join regions reg 
on nod.region_id = reg.region_id
group by region_name
order by region_name;

-- 3. How many customers are allocated to each region?
select region_name,count(*) ttl
from
(
select region_id, customer_id
from customer_nodes
group by region_id, customer_id
order by region_id, customer_id
) t1
join regions r 
on t1.region_id = r.region_id
group by region_name;

-- 4. How many days on average are customers reallocated to a different node?
