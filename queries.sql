-- подсчет количества покупателей
select
	count(customer_id) as customers_count
from customers;

-- выбираем десятку лучших продавцов по суммарной выручке
select
	concat(e.first_name, ' ', e.last_name) as seller,
	count(s.sales_id) as operations,
	floor(sum(s.quantity * p.price)) as income
from employees as e
inner join sales as s
	on e.employee_id = s.sales_person_id
inner join products as p
	on p.product_id = s.product_id
group by e.first_name, e.last_name
order by income desc
limit 10;

-- выбираем продавцов, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам
select
    concat(e.first_name, ' ', e.last_name) as seller,
    avg(s.quantity * p.price) as average_income
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id
inner join products as p on p.product_id = s.product_id
group by e.first_name, e.last_name
having avg(s.quantity * p.price) < (
    -- подзапрос, который считает среднее по всем продажам в базе
    select avg(s2.quantity * p2.price) 
    from sales as s2 
    join products p2 on s2.product_id = p2.product_id
)
order by average_income asc;

-- отчет о выручке по дням недели
select
	concat(e.first_name, ' ', e.last_name) as seller,
	to_char(s.sale_date, 'FMDay') as day_of_week,
	floor(sum(s.quantity * p.price)) as income
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id
inner join products as p on p.product_id = s.product_id
group by extract(isodow from s.sale_date), day_of_week, e.first_name, e.last_name
order by extract(isodow from s.sale_date), seller;