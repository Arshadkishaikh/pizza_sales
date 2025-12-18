create database pizzahut;

use pizzahut;

select * from pizzahut.pizzas;

create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id));

select * from orders;

create table orders_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id));

select * from order_details;


-- Q1- Retrieve the total number of orders placed.

select count(order_id) as Total_Orders
from orders;


-- Q2- Calculate the total revenue generated from pizza sales.

select round(sum(od.quantity * p.price), 2)
from order_details as od
inner join pizzas as p
on od.pizza_id = p.pizza_id;


-- Q3- Identify the highest-priced pizza.

select pt.name, p.price 
from pizza_types as pt
inner join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
order by price desc
limit 1;


-- Q4- Identify the most common pizza size ordered.

 select p.size , count(od.order_details_id) as order_count
 from pizzas as p
 join order_details as od 
 on p.pizza_id = od.pizza_id
 group by p.size
 order by count(od.order_details_id) desc ;
 
 
 -- Q5- List the top 5 most ordered pizza types along with their quantities.
 
 select pt.name, sum(od.quantity) as quantity
 from pizza_types as pt
 join pizzas as p
 on pt.pizza_type_id = p.pizza_type_id
 join order_details as od
 on p.pizza_id = od.pizza_id
 group by pt.name
 order by quantity desc
 limit 5;
 
 
-- Q6- Join the necessary tables to find the total quantity of each pizza category ordered.

select pt.category,
sum(od.quantity) as quantity
from pizza_types as pt 
join pizzas as p 
on pt.pizza_type_id = p.pizza_type_id
join order_details as od
on p.pizza_id = od.pizza_id
group by pt.category
order by quantity desc;


-- Q7- Determine the distribution of orders by hour of the day.

select hour(order_time) as hour, count(order_id) as order_count
from orders
group by hour(order_time);


-- Q8- Join relevant tables to find the category-wise distribution of pizzas.

select category, count(name) 
from pizza_types
group by category;


-- Q9- Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(quantity), 0) as avg_ordered_pizzas_per_day
from (select o.order_date, sum(od.quantity) as quantity
from orders as o
join order_details as od
on o.order_id = od.order_id
group by o.order_date) as order_quantity;


-- Q10- Determine the top 3 most ordered pizza types based on revenue.

select pt.name, sum(od.quantity * p.price) as revenue
 from pizza_types as pt 
 join pizzas as p 
 on p.pizza_type_id = pt.pizza_type_id
 join order_details as od
 on p.pizza_id = od.pizza_id
 group by pt.name
 order by revenue desc
 limit 3;


-- Q11- Calculate the percentage contribution of each pizza type to total revenue.

select pt.category, 
concat(round(sum(od.quantity * p.price) / 
		(select round(sum(od.quantity * p.price), 2)
		from order_details as od
		inner join pizzas as p
		on od.pizza_id = p.pizza_id)* 100, 2) , '%') as revenue
from pizza_types as pt 
join pizzas as p 
on pt.pizza_type_id = p.pizza_type_id
join order_details as od
on od.pizza_id = p.pizza_id
group by pt.category
order by revenue desc;


-- Q12- Analyze the cumulative revenue generated over time.

select order_date, sum(revenue) over(order by order_date) as cum_revenue
from (select o.order_date, sum(od.quantity * p.price) as revenue
		from order_details as od
		join pizzas as p
		on od.pizza_id = p.pizza_id
		join orders as o 
		on o.order_id = od.order_id
		group by o.order_date)as sales;
    
    
    
-- Q13- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, revenue, rn
from (select category, name , revenue,
		rank() over(partition by category 
					order by revenue desc) as rn
		from (select pt.category, pt.name, sum(od.quantity * p.price) as revenue
				from pizza_types as pt 
				join pizzas as p 
				on pt.pizza_type_id = p.pizza_type_id
				join order_details as od
				on od.pizza_id = p.pizza_id
				group by pt.category, pt.name) as a) b
where rn <= 3;