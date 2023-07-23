
-- Customers who never ordered
select name from users
where user_id not in (select user_id from orders);

-- Average Price/dish
select f.f_name,avg(price) avg_price
from menu m 
inner join food f
on m.f_id=f.f_id
group by f.f_name
order by avg_price desc;

-- average restaurant rating
select r_name,round(avg(restaurant_rating),2) avg_rating
from orders o
inner join
restaurants r
on o.r_id=r.r_id
group by r_name;

-- top 3 restaurant having highest average rating
select top 3 r_name,round(avg(restaurant_rating),2) avg_rating
from orders o
inner join
restaurants r
on o.r_id=r.r_id
group by r_name
order by avg_rating desc;

-- Most popular dish based on number of orders
select top 1 f.f_name,count(o.f_id) number_of_orders
from order_details o
inner join 
food f
on o.f_id=f.f_id
group by f.f_name
order by count(o.f_id) desc;

-- top restaurant in terms of number of orders for july
select top 1 r_name,count(order_id) total_orders 
from (select*,month(date) month from orders where month(date)=7) o
inner join 
restaurants r
on o.r_id=r.r_id
group by r_name
order by total_orders desc;

-- top customers in terms of total number of orders
select u.name,count(o.user_id) total_orders
from users u
inner join 
orders o
on u.user_id=o.user_id
group by u.name
order by total_orders,u.name;

-- monthwise number of orders
select month(date) as month ,count(*) as total_orders
from orders
group by month(date)
order by month;

-- Restaurants with total sales greater than two thousand
select r_name,sum(amount) revenue
from orders o 
inner join 
restaurants r
on o.r_id=r.r_id
group by r_name
having sum(amount)>2000;

-- for all orders with order details for a particular customer in a particular date range
select o.order_id,r.r_name,od.f_id,f.f_name
from orders o
inner join
restaurants r
on o.r_id=r.r_id
inner join 
order_details od
on o.order_id=od.order_id
inner join 
food f
on od.f_id=f.f_id
where user_id=(select user_id from users where name='Nitish')
and (date between '2022-05-10' and '2022-06-10');

-- for restaurants with maximum repeated customers
select top 1 r_name,count(*) as loyal_customers 
from 
(select r_id,user_id,count(*) as 'Visits' 
from orders 
group by r_id,user_id
having count(*)>1)
t
inner join 
restaurants r
on t.r_id=r.r_id
group by r_name
order by loyal_customers desc;

-- Month over month revenue growth of online food delivery platform
with sales as
(select month(date) month,sum(amount) revenue,lag(sum(amount),1) over(order by month(date)) as prev
from orders
group by month(date))
select month,((revenue - prev)/prev)*100 monthly_revenue_growth 
from sales;

-- Month over month revenue growth of a particular restaurant

with sales as
(select month(date) month,sum(amount) as revenue,lag(sum(amount),1) over(order by month(Date))  prev_month
from orders o
inner join 
restaurants r
on o.r_id=r.r_id
group by r_name,month(date)
having r_name='dominos')
select month,revenue,prev_month,round(((revenue-prev_month)/prev_month),3) as revenue_growth
from sales;

--Customer and their favourite food
with temp as 
(select o.user_id,od.f_id,count(*) as frequency
from 
orders o 
inner join
order_details od 
on o.order_id=od.order_id
group by o.user_id,od.f_id)
select u.name,f.f_name from temp t1 
inner join
users u 
on u.user_id=t1.user_id
inner join food f
on f.f_id=t1.f_id
where t1.frequency=(select max(frequency) from temp t2 where t1.user_id=t2.user_id)
order by t1.user_id;
 
 -- Restaurant which got maximum number of orders
 select r_name,count(order_id) as number_of_orders
 from orders o
 inner join
 restaurants r
 on o.r_id=r.r_id
 group by r_name
 order by number_of_orders desc;

 
 --Most paired products
with newtable as
(select o.user_id,od.order_id,f_name
from 
orders o 
inner join 
order_details od
on o.order_id=od.order_id
inner join 
food f
on f.f_id=od.f_id) 
select one.f_name,two.f_name,count(*) as purchase_frequency from 
newtable one
inner join
newtable two
on one.user_id=two.user_id
and one.order_id=two.order_id
and one.f_name<two.f_name
group by one.f_name,two.f_name;







