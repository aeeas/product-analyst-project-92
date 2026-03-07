-- подсчет количества покупателей
SELECT
	count(customer_id) AS customers_count
FROM
	customers;

-- выбираем десятку лучших продавцов по суммарной выручке
SELECT
	concat(e.first_name, ' ', e.last_name) AS seller,
	count(s.sales_id) AS operations,
	floor(sum(s.quantity * p.price)) AS income
FROM
	employees AS e
INNER JOIN sales AS s
	ON
	e.employee_id = s.sales_person_id
INNER JOIN products AS p
	ON
	p.product_id = s.product_id
GROUP BY
	e.first_name,
	e.last_name
ORDER BY
	income DESC
LIMIT 10;

-- выбираем продавцов, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам
SELECT
	concat(e.first_name, ' ', e.last_name) AS seller,
	avg(s.quantity * p.price) AS average_income
FROM
	employees AS e
INNER JOIN sales AS s ON
	e.employee_id = s.sales_person_id
INNER JOIN products AS p ON
	p.product_id = s.product_id
GROUP BY
	e.first_name,
	e.last_name
HAVING
	avg(s.quantity * p.price) < (
	-- подзапрос, который считает среднее по всем продажам в базе
	SELECT
		avg(s2.quantity * p2.price)
	FROM
		sales AS s2
	JOIN products p2 ON
		s2.product_id = p2.product_id
)
ORDER BY
	average_income ASC;

-- отчет о выручке по дням недели
SELECT
	concat(e.first_name, ' ', e.last_name) AS seller,
	to_char(s.sale_date, 'FMDay') AS day_of_week,
	floor(sum(s.quantity * p.price)) AS income
FROM
	employees AS e
INNER JOIN sales AS s ON
	e.employee_id = s.sales_person_id
INNER JOIN products AS p ON
	p.product_id = s.product_id
GROUP BY
	EXTRACT(isodow FROM s.sale_date),
	day_of_week,
	e.first_name,
	e.last_name
ORDER BY
	EXTRACT(isodow FROM s.sale_date),
	seller;

-- количество покупателей в разных возрастных группах
SELECT
	CASE
		WHEN c.age BETWEEN 16 AND 25 THEN '16-25'
		WHEN c.age BETWEEN 26 AND 40 THEN '26-40'
		WHEN c.age > 40 THEN '40+'
	END AS age_category,
	COUNT(*) AS age_count
FROM customers AS c
GROUP BY age_category
ORDER BY age_category;

-- количество уникальных покупателей и выручка, которую они принесли
SELECT 
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    ROUND(SUM(p.price * s.quantity)) AS income
FROM sales AS s
INNER JOIN products AS p ON
	p.product_id = s.product_id
GROUP BY selling_month
ORDER BY selling_month ASC;

-- покупатели, первая покупка которых была в ходе проведения акции
WITH first_sales AS (
    -- находим первую покупку для каждого покупателя
    SELECT 
        customer_id,
        MIN(sales_id) AS first_sale_date
    FROM sales
    GROUP BY customer_id
)
SELECT 
    c.first_name || ' ' || c.last_name AS customer,
    s.sale_date,
    e.first_name || ' ' || e.last_name AS seller
FROM sales s
JOIN first_sales AS fs ON s.sales_id = fs.first_sale_date
JOIN customers AS c ON s.customer_id = c.customer_id
JOIN employees AS e ON s.sales_person_id = e.employee_id
JOIN products AS p ON s.product_id = p.product_id
WHERE p.price = 0 
ORDER BY c.customer_id;