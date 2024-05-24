create database pizzahut;
use pizzahut;


-- Retrieve the total number of orders placed.
select * from orders;
select count(order_id) from orders;


-- Calculate the total revenue generated from pizza sales.
select
round(SUM(order_details.quantity * pizzas.price),2) as total_revenue
from order_details inner join pizzas
on order_details.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza

SELECT pizza_types.name , pizzas.price 
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY PIZZAS.PRICE DESC 
LIMIT 1;
-- Identify the most common pizza size ordered


SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.
 
SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS quantity_details
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity_details DESC
LIMIT 5;


-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS qunatity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category;
-- Determine the distribution of orders by hour of the day.

select hour(time) as hour ,count(order_id) as order_count from orders
group by  hour(time);


-- Join relevant tables to find the category-wise distribution of pizzas.

select pizza_types.category , count(name) 
from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        orders.date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date) AS order_qunatity;


-- Determine the top 3 most ordered pizza types based on revenue.


SELECT 
    pizza_types.name,
    SUM(pizzas.price * order_details.quantity) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.qunatity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.qunatity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,2) AS revenue
FROM
    pizza_types	
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;



-- Analyze the cumulative revenue generated over time.


select date,
sum(revenue) over(order by date) as cum_revenue
from 
(select orders.date ,
sum(order_details.quantity* pizzas.price) as revenue
from order_details
join pizzas
on order_details.pizza_id  = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
 
 
 select name , revenue from
 (select category,name ,revenue,
 rank() over(partition by category order by revenue desc) as rn
 from
(select pizza_types.category , pizza_type.name,
sum((order_details.quantity)*pizzas.price) as revenue
from pizza_types 
join pizzas
on pizza_types.pizza_type_id =pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_type.name) as a) as b
where rn<=3;








