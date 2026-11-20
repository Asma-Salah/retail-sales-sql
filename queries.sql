show search_path;



--Section A — SQL fundamentals (Q1–Q10)
--Q1: Retrieve all customer records.
select * from customers;

--Q2:Display customer names, cities, and segments.
select customer_name,city,customer_segment
from customers;

--Q3: Find customers living in Nairobi.
select customer_name, city
from customers c
where city = 'Nairobi';

--Q4: Find customers registered after January 1, 2025.

select customer_name,registration_date
from customers
where registration_date >= DATE '2025-01-1';

--Q5: Display all unique customer cities.
select Distinct city
from customers;

--Q6: Retrieve the 10 most recent orders.

select *
from orders
order by order_date desc, order_id desc
limit 10;

--Q7: Find orders with unit prices above KSh 10,000.
select * from orders
where unit_price > 10000;

--Q8: Find customers whose names start with A.
select customer_name
from customers 
where customer_name LIKE 'A%';

--Q9: Retrieve orders with quantities between 2 and 5.
select * from orders
where quantity between 2 and 5;

--Q10: Find orders paid through M-Pesa.
select order_id, product_name,payment_method 
from orders
where payment_method = 'M-Pesa';


--Section B — Aggregation and grouping (Q11–Q20)

--Q11: Count all customers.
select count(*)
from customers;

--Q12: Count all orders.
select count(*)
from orders;

--Q13: Calculate completed-order revenue.

select sum(quantity * unit_price * (1 - discount/100))
from orders
where order_status = 'Completed';

--Q14: Calculate the average completed-order value.
--average
--status:completed

select round(avg(quantity * unit_price * (1 - discount/100)), 2)  as avg_order_value
from orders 
where order_status = 'Completed';

--Q15: Find the highest and lowest product prices.
select * from orders;
select max( unit_price) as highest_price, min( unit_price) as lowest_price
from orders;

--Q16: Calculate revenue by product category.
select * from orders;
select  product_category, round(sum(quantity * unit_price *(1 - discount/100)), 2)as revenue
from orders 
where order_status = 'Completed'
group by product_category
order by revenue desc;

--Q17: Count customers by city.
select * from customers;
select city, count(*) as customers
from customers 
group by city
order by customers desc;

--Q18: Calculate quantity sold by product.
-- units sold = Completed orders only (cancelled/pending were not sold)
select * from orders;
select product_name, sum(quantity) as unit_sold
from orders 
where order_status = 'Completed'
group by product_name 
order by unit_sold desc;

--Q19: Find categories generating more than KSh 100,000 in revenue.
select * from orders;
select product_category, round(sum(quantity * unit_price *(1 - discount/100)), 2)as revenue
from orders 
where order_status = 'Completed' 
group by product_category
having sum(quantity * unit_price * (1 - discount / 100)) > 100000
order by revenue desc;


--Q20: Calculate the percentage of cancelled orders.
select round( 100.0 * count(*) 
filter (where order_status = 'Cancelled') / count(*), 2 ) as cancelled_pct
from orders;

--Section C — Joins and customer analytics (Q21–Q28)
--Q21: Display orders with customer names and cities.
select order_id,customer_name, city
from orders o
left join customers c using(customer_id);

--Q22: Calculate total spending by customer.

select c.customer_id, c.customer_name, round(sum(o.quantity * o.unit_price *(1 - o.discount/100)), 2) as total_spending
from customers c
join orders o on o.customer_id = c.customer_id
where o.order_status = 'Completed'
group by c.customer_id, c.customer_name
order by total_spending desc;

--Q23: Identify customers who have never ordered.
select c.customer_id, c.customer_name, o.order_id
from customers c 
left join orders o on c.customer_id = o.customer_id
where order_id  is null;


--Q24: Find the 10 highest-spending customers.
select c.customer_id, c.customer_name, round(sum(o.quantity * o.unit_price *(1 - o.discount/100)), 2) as total_spending
from customers c
join orders o on o.customer_id = c.customer_id
where o.order_status = 'Completed'
group by c.customer_id 
order by total_spending desc, c.customer_id
limit  10;


--Q25: Calculate revenue by customer city.
select  c.city,  round(sum(o.quantity * o.unit_price *(1 - o.discount/100)), 2) as total_spending
from customers c
join orders o on o.customer_id = c.customer_id
where o.order_status = 'Completed'
group by c.city
order by total_spending desc;

--Q26: Identify customers with more than five orders.

select c.customer_id, c.customer_name, count(order_id) as order_count
from customers c
join orders o on c.customer_id = o.customer_id
group by  c.customer_id, c.customer_name
having count(order_id)> 5
order by order_count desc;

--Q27: Calculate average customer spending by segment.
-- average of each customer's total completed spending; customers with no completed orders are excluded.
With customer_totals as(
	select  c.customer_id, 
		c.customer_segment, 
		sum(o.quantity * o.unit_price *(1 - o.discount/100)) as total_spending
	from customers c
	join orders o on o.customer_id = c.customer_id
	where o.order_status = 'Completed'
	group by c.customer_id, c.customer_segment
)
select customer_segment,
		round(avg(total_spending), 2) as avg_customer_spending
from customer_totals
group by customer_segment 
order by avg_customer_spending desc;

--Q28: Identify the most popular category among VIP customers.
-- popular = most orders placed by VIP customers (all statuses); revenue and units not used.
select customer_segment, product_category, count(o.order_id) as order_count
from customers c
join orders o on o.customer_id = c.customer_id
where customer_segment = 'VIP'
group by o.product_category, c.customer_segment
order by order_count desc
limit 1;

--Section D — Subqueries and CTEs (Q29–Q34)
--Q29: Find customers spending above the average total spending per purchasing customer.
with customer_spending as(
	select 
		c.customer_id, c.customer_name, sum(o.quantity * o.unit_price *(1 - o.discount/100)) as total_spending
	from customers c
	join orders o on o.customer_id = c.customer_id
	where o.order_status = 'Completed'
	group by c.customer_id, c.customer_name
)
select 	customer_id, customer_name, total_spending as total_spending
from customer_spending
where total_spending > (select avg(total_spending) from customer_spending);

--Q30: Find products priced above the overall average unit price.
with product_price as(
select  product_name, unit_price
from orders
group by product_name, unit_price
)
select product_name, unit_price 
from product_price 
where unit_price >(select avg(unit_price) from product_price);

--Q31: Use a CTE to identify the three highest-revenue months.

with  monthly_revenue as(
select date_trunc('month', o.order_date) as month, sum(o.quantity * o.unit_price *(1 - o.discount/100)) as revenue
from orders o
where o.order_status = 'Completed'
group by month
)
select month, revenue
from monthly_revenue
order by revenue desc
limit 3;

--Q32: Find customers purchasing from at least three categories.
select * from orders;
select c.customer_id, c.customer_name, count(distinct o.product_category) as category_count
from customers c
join orders o on o.customer_id = c.customer_id
group by c.customer_id, c.customer_name
having count(distinct o.product_category) >= 3;

--Q33: Use a CTE to calculate category revenue, cost, profit, and profit margin.

with category_totals as(
select o.product_category, 
		sum(o.quantity * o.unit_price *(1 - o.discount/100)) as revenue, 
		sum(o.quantity * o.cost_price) as cost
from orders o
where order_status = 'Completed'
group by  o.product_category
)
select product_category, 
			ROUND(revenue, 2) as revenue, 
			ROUND(cost, 2) as cost, 
			ROUND(revenue - cost, 2) as profit,
			ROUND((revenue - cost) / nullif(revenue, 0) * 100, 2) as margin_percentage
from category_totals 
order by margin_percentage desc;

--Q34: Find customers whose latest completed order is more than 90 days before the latest order date in the dataset.

select c.customer_id,
       max(o.order_date) as last_completed_date
from customers c
join orders o on o.customer_id = c.customer_id
where o.order_status = 'Completed'
group by c.customer_id
having (select max(order_date) from orders) - max(o.order_date) > 90;

--Section E — Window functions (Q35–Q42)
--Q35: Rank customers by spending using RANK().
with customer_totals as(
			select c.customer_id, c.customer_name, sum(o.quantity * o.unit_price *(1 - o.discount/100)) as total_spending
from customers c
join orders o on o.customer_id = c.customer_id
where o.order_status = 'Completed'
group by c.customer_id, c.customer_name
)
select customer_id, customer_name,
			round(total_spending, 2) as total_spending,
			rank() over (order by total_spending desc) as spending_rank
from customer_totals
order by spending_rank;

--Q36: Number each customer's orders by recency using ROW_NUMBER().
with customer_orders as(
select o.customer_id, o.order_id, o.order_date
from orders o
)
select order_id,
		order_date,
		customer_id,
		row_number() over(
		partition by customer_id
		order by order_date desc, order_id desc
		) as order_recency
from customer_orders
order by customer_id, order_recency;

--Q37: Rank products within categories using DENSE_RANK().

with products_totals as(
select 
	product_category, 
	product_name,
	sum(quantity * unit_price * (1 - discount / 100)) as total_revenue
from orders 
where order_status ='Completed'
group by product_name, product_category
)
select product_category,
		product_name,
		round(total_revenue, 2) as total_revenue,
		dense_rank() over(
		partition by product_category
		order by total_revenue desc) as product_rank
from products_totals
order by product_category, product_rank;

--Q38: Calculate cumulative monthly revenue.
with monthly as(
select date_trunc('Month', order_date) as month, 
		sum(quantity * unit_price * (1 - discount / 100)) as total_revenue
from orders 
where order_status ='Completed'
group by month
)
select
		month,
		round(total_revenue, 2) as total_revenue,
		round(sum(total_revenue) over( 
		order by MONTH
		), 2) as comulative_revenue
from monthly;

--Q39: Compare monthly revenue using LAG().
with monthly as(
select date_trunc('Month', order_date) as month, 
		sum(quantity * unit_price * (1 - discount / 100)) as total_revenue
from orders 
where order_status ='Completed'
group by month
)
select 
		month,
		round(total_revenue) as total_revenue,
		round(total_revenue - lag(total_revenue) 
		over (order by month), 2)
		as change_from_previous
from monthly
order by month;	

--Q40: Calculate month-over-month revenue growth (%).
with monthly as(
select date_trunc('Month', order_date) as month, 
		sum(quantity * unit_price * (1 - discount / 100)) as total_revenue
from orders 
where order_status ='Completed'
group by month
),
with_previous as(
select 
		month,
		round(total_revenue, 2) as total_revenue,
		round(lag(total_revenue) over(
		order by month), 2)
		as previous_revenue
from monthly
)
select month,
       round(total_revenue, 2) as total_revenue,
       round(previous_revenue, 2) as previous_revenue,
       round((total_revenue - previous_revenue) / nullif(previous_revenue, 0) * 100.0, 2) as growth_pct
from with_previous  
order by month;	


--Q41: Divide customers into four spending groups using NTILE(4).
with customer_revenue as(
			select c.customer_id, c.customer_name, sum(o.quantity * o.unit_price * (1 - o.discount / 100)) as total_revenue
from orders o
join customers c on o.customer_id = c.customer_id 
where order_status = 'Completed'
group by c.customer_id
)
select 
		customer_id, 
		customer_name,
		round(total_revenue) as total_revenue,
		ntile(4) over(order by total_revenue desc) as spending_group
from customer_revenue
order by spending_group, total_revenue desc;

--Q42: Calculate each category's share of total revenue using window functions.
select o.product_category,
       round(sum(o.quantity * o.unit_price * (1 - o.discount / 100)), 2) as category_revenue,
       round(
           100.0 * sum(o.quantity * o.unit_price * (1 - o.discount / 100))
           / sum(sum(o.quantity * o.unit_price * (1 - o.discount / 100))) over (),
       2) as pct_of_total
from orders o
where o.order_status = 'Completed'
group by o.product_category
order by pct_of_total desc;

--Section F — Advanced business intelligence (Q43–Q46)

--Q43: Create a monthly_sales_summary view (month, orders, revenue, cost, profit). Then SELECT from it.

CREATE OR REPLACE VIEW monthly_sales_summary as
select 
	date_trunc('month', order_date) as month,
	count(*) as orders, 
	round(sum(quantity * unit_price * (1 - discount / 100))  filter(where order_status = 'Completed'), 2) as revenue,
	round(sum(quantity * cost_price) filter(where order_status = 'Completed'), 2) as cost,
	round(sum(quantity * unit_price * (1 - discount / 100) - quantity * cost_price) filter(where order_status = 'Completed'), 2) as profit
from orders
group by date_trunc('month', order_date);

select * from monthly_sales_summary
order by month;
	
select 
	sum(orders) as orders, 
	sum(revenue) as revenue, 
	sum(cost) as cost, 
	sum(profit) as profit from monthly_sales_summary;

--Q44: Create a PostgreSQL function that returns completed-order revenue for a supplied customer ID. 
--Show it working for one customer and for an ID that does not exist (it should return 0, not NULL).
create or replace function order_revenue_for(p_customer_id integer)
RETURNS numeric
LANGUAGE plpgsql
as $$
declare
	v_revenue numeric;
begin
	select
		coalesce(round(sum(o.quantity * o.unit_price * (1 - o.discount / 100)), 2), 0) into v_revenue
	from orders o
	where order_status = 'Completed' and p_customer_id = o.customer_id;

	return v_revenue;
end;
$$;

select order_revenue_for(1); 
select order_revenue_for(99999); 

--Q45: Segment customers into High, Medium and Low Value. Explain why you chose your thresholds
-- — for example percentiles, or round KSh amounts based on what the data looks like.

-- thresholds based on the spread of customer completed spending:
-- min 1,899, p33 55,583, p67 178,433, max 848,119.
-- High >= 180,000 (about the 67th percentile), Low < 50,000 (a round figure near the 33rd percentile),
-- Medium in between. Customers with no completed orders are excluded.
with customer_spending as(
select 
	c.customer_id, c.customer_name, round(sum(o.quantity * o.unit_price *(1 - o.discount/100)), 2) as total_spending
from customers c
join orders o on o.customer_id = c.customer_id
where o.order_status = 'Completed'
group by c.customer_id, c.customer_name
)
select 
	customer_id,
	customer_name,
	round(total_spending, 2) as total_spending,
case
	when total_spending >= 180000 then 'High'
	when total_spending < 50000 then 'Low'
	else 'Medium'
end as customer_value
from customer_spending
order by total_spending desc;

--Q46: Produce a management report:
-- the top five customers, top five products, the most profitable category, and the lowest-revenue month.

--Top 5 customers
select 
	c.customer_id, 
	c.customer_name, 
	round(sum(o.quantity * o.unit_price *(1 - o.discount/100)), 2) as total_spending
from customers c
join orders o on o.customer_id = c.customer_id
where o.order_status = 'Completed'
group by c.customer_id, c.customer_name
order by total_spending desc
limit 5;

--Top 5 Products
select  

	o.product_name, 
	round(sum(o.quantity * o.unit_price *(1 - o.discount/100)), 2) as product_revenue
from orders o
where o.order_status = 'Completed'
group by o.product_name
order by product_revenue desc
limit 5;

--The most profitable category
select 
	o.product_category, 
	sum(o.quantity * o.unit_price * (1 - o.discount / 100) - o.quantity * o.cost_price) as profit
from orders o 
where order_status = 'Completed'
group by o.product_category
order by profit desc
limit 1;

--The lowest month  revenue
select 
	date_trunc('month',o.order_date) as month,
	round(sum(o.quantity * o.unit_price *(1 - o.discount/100)), 2) as revenue
from orders o
where order_status = 'Completed'
group by month
order by revenue
limit 1;











