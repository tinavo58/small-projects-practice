CREATE DATABASE analysis;

CREATE TABLE teachers (
	id bigserial,
	first_name varchar(50),
	last_name varchar(50),
	school varchar(50),
	hire_date date,
	salary numeric
);

INSERT INTO teachers (first_name, last_name, school, hire_date, salary)
VALUES
	('Janet', 'Smith', 'F.D. Roosevelt HS', '2011-10-30', 36200),
	('Lee', 'Reynolds', 'F.D. Roosevelt HS', '1993-05-22', 65000),
	('Samuel', 'Cole', 'Myers Middle School', '2005-08-01', 43500),
	('Samantha', 'Bush', 'Myers Middle School', '2011-10-30', 36200),
	('Betty', 'Diaz', 'Myers Middle School', '2005-08-30', 43500),
	('Kathleen', 'Roush', 'F.D. Roosevelt HS', '2010-10-22', 38500);

-- query TABLE
SELECT
	school
	,count(*) number_of_staff
	,sum(salary) as total_wage
	,round(avg(salary),2) average_wage
FROM teachers
GROUP BY school;

-- 
SELECT
	last_name
	,first_name
	,CONCAT(first_name, ' ', last_name) employee
	,salary
FROM teachers
ORDER BY salary desc

-- using WHERE (filter)
SELECT
	CONCAT(first_name, ' ', last_name) staff
	,salary
FROM teachers
WHERE salary > 40000;

-- BETWEEN (inclusive)
SELECT
	concat(first_name, ' ', last_name)
	,salary
FROM teachers
WHERE
	salary BETWEEN 35000 AND 40000;

--
SELECT
	first_name
	,last_name
	,school
FROM teachers
WHERE
	school = 'Myers Middle School'
	AND salary < 40000;

-- ILIKE case-insensitive (only in postgres)
SELECT
	*
FROM teachers
WHERE
	last_name ILIKE 'r%';