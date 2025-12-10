select * from gold_fact_sales limit 10;


-- long term trends by year
-- calc total sales, total customers, total quantity
select
	extract(year from order_date) as order_year
	,sum(sales_amount) as total_sales
	,count(distinct customer_key) as total_customers -- count unique customers
	,sum(quantity) as total_quantity
FROM
	gold_fact_sales
WHERE
	order_date is not null
group by
	-- year(order_date) -- this is not available in postgres
	1
order by
	order_year -- or can use 1;


-- monthly seasonality to uncover trends and pattern
-- agg sales measures by month, regardless of the year
-- this analysis helps identify seasonality like which month would be most busy
SELECT
	extract(month from order_date) as order_month
	,sum(sales_amount) as total_sales
	,count(distinct customer_key) as total_customers
	,sum(quantity) total_quantity
from gold_fact_sales
where order_date is not null
group by 1
order by 1;


-- analyse trends by year and month
-- how monthly sales are performing within a specific year
SELECT
	extract(year from order_date) order_year
	,extract(month from order_date) as order_month
	,sum(sales_amount) as total_sales
	,count(distinct customer_key) as total_customers
	,sum(quantity) total_quantity
from gold_fact_sales
where order_date is not null
group by 1, 2
order by 1, 2;


-- cumulative analysis
-- date_trunc: keep the whole date but 'round it down' to the 1st day of the month ie keep both month and 
WITH monthly_sales (order_date, total_sales) AS (
	-- col name can be set in the bracket as above
	SELECT
		date_trunc('month', order_date) -- as order_date -- set granularity to the first day of the month
		,sum(sales_amount) -- total_sales
	from gold_fact_sales
	where order_date is not null
	group by 1
	)
SELECT
	order_date
	,total_sales
	-- calc cumulative sum
	,SUM(total_sales) OVER (
		-- adding partition here
		PARTITION BY extract(year from order_date) -- resets sum at the start of each new year
		ORDER BY order_date
		) running_total_sales
FROM monthly_sales
ORDER BY 1;


/*
	performance analysis
	-> compare current value (measure) vs target value (measure)
	to measure success or compare categories
	- core formula: find difference between 2 measures
*/
-- analyse yearly performance of products
-- comparing their sales to the product's average sales and previous year's sales
WITH yearly_product_sales (order_year, product_name, current_sales) AS (
	SELECT
		extract(year from s.order_date),
		p.product_name,
		sum(s.sales_amount)
	FROM gold_fact_sales s
	LEFT JOIN gold_dim_products p
	USING (product_key)
	WHERE order_date is not null
	GROUP BY 1, 2
	)
SELECT
	order_year,
	product_name,
	current_sales,
	-- USE LAG to retrieve sales from previous yr
	LAG(current_sales) OVER (
		PARTITION BY product_name
		ORDER BY order_year
	) AS previous_year_sales,
	-- calc the diff (current - previous)
	current_sales - LAG (current_sales) OVER (
		PARTITION BY product_name
		ORDER BY order_year
	) AS diff_previous_year,
	-- create Flag -> increase, decrease
	CASE 
		WHEN (current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year)) > 0 THEN 'Increase'
		WHEN (current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year)) < 0 THEN 'Decrease'
		ELSE 'No change'
	END previous_year_change
FROM
	yearly_product_sales
ORDER BY
	product_name,
	order_year
;


-- try the abvoe with CTEs
WITH yearly_product_sales (order_year, product_name, current_sales) AS (
	SELECT
		extract(year from s.order_date),
		p.product_name,
		sum(s.sales_amount)
	FROM gold_fact_sales s
	LEFT JOIN gold_dim_products p
	USING (product_key)
	WHERE order_date is not null
	GROUP BY 1, 2
	),
	current_previous_product_sales AS (
		SELECT
			*,
			LAG(current_sales) OVER (
				PARTITION BY product_name
				ORDER BY order_year
			) previous_year_sales
		FROM
			yearly_product_sales -- taken from 1st CTE
	)
SELECT
	*,
	-- calc the diff (current - previous)
	current_sales - previous_year_sales AS diff_previous_year,
	-- create Flag -> increase, decrease
	CASE 
		WHEN (current_sales - previous_year_sales) > 0 THEN 'Increase'
		WHEN (current_sales - previous_year_sales) < 0 THEN 'Decrease'
		ELSE 'No change'
	END previous_year_change
FROM
	current_previous_product_sales
ORDER BY
	product_name,
	order_year
;


-- cumulative analysis: running total
-- -> show how business progresses overtime
WITH monthly_sales AS (
	SELECT
		-- convert all to month-year
		DATE_TRUNC('month', order_date) order_date,
		SUM(sales_amount) total_sales
	FROM gold_fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY 1 -- can use # to represent col order or whatever entered in the SELECT statement
	)
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) as running_total_sales
FROM monthly_sales
ORDER BY order_date;


-- lets see the growth for each year
-- adding PARTITION BY would produce the desired result
WITH monthly_sales AS (
	SELECT
		-- convert all to month-year
		DATE_TRUNC('month', order_date) order_date,
		SUM(sales_amount) total_sales
	FROM gold_fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY 1 -- can use # to represent col order or whatever entered in the SELECT statement, not the alias name
	)
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (PARTITION BY EXTRACT(YEAR from order_date) ORDER BY order_date) as running_total_sales
FROM monthly_sales
ORDER BY order_date;


-- moving average
-- results: price reduced signigicantly in 2012 # whats the reason behind this?
-- each product has not been factored in the calc [need re-work]
WITH average_price (order_date, avg_mth_price) as 
(
	select
		date_trunc('month', order_date),
		round(avg(price), 2)
	from gold_fact_sales
	where order_date is not null
	group by 1
)
select *,
	round(avg(avg_mth_price) over (order by order_date), 2) moving_avg
from average_price
order by order_date;


-- part to whole analysis
-- determine how much a specific catergory (product type) contribute to the entire business, which is most impactful
-- select a measure > divide by the total of that measure, x 100 to get pct
-- eg: 1 category's sales / total sales across all categories
with category_sales as (
	select
		category,
		-- subcategory,
		sum(sales_amount) total_sales
	from gold_dim_products
	join gold_fact_sales
		using (product_key)
	where
		order_date is not null
	group by
		category
		-- 1, 2
	)	
select
	*,
	round(
		(total_sales * 100) /
		sum(total_sales) over () -- calculate the total sales across all categories
		, 2
	) pct_total
from category_sales
order by 
	-- 1, 2, 
	total_sales;


-- data segmentation: grouping data
-- case-when used to define the rules for each range
-- eg: below 100, between 100 and 500, above 1000

	select
		*
	-- from gold_fact_sales
	from gold_dim_products
	limit 10

	