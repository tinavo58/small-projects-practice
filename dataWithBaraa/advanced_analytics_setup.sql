CREATE TABLE gold_dim_customers(
	customer_key integer,
	customer_id integer,
	customer_number varchar(50),
	first_name varchar(50),
	last_name varchar(50),
	country varchar(50),
	marital_status varchar(50),
	gender varchar(50),
	birthdate date,
	create_date date
);

CREATE TABLE gold_dim_products(
	product_key integer ,
	product_id integer ,
	product_number varchar(50) ,
	product_name varchar(50) ,
	category_id varchar(50) ,
	category varchar(50) ,
	subcategory varchar(50) ,
	maintenance varchar(50) ,
	cost integer,
	product_line varchar(50),
	start_date date 
);

CREATE TABLE gold_fact_sales(
	order_number varchar(50),
	product_key integer,
	customer_key integer,
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount integer,
	quantity smallint,
	price integer 
);

COPY gold_dim_customers
FROM '/private/tmp/gold.dim_customers.csv'
WITH (format csv, header);

COPY gold_dim_products
FROM '/private/tmp/gold.dim_products.csv'
WITH (format csv, header);

COPY gold_fact_sales
FROM '/private/tmp/gold.fact_sales.csv'
WITH (format csv, header);