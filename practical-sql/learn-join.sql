/*
-- learn JOIN
	format required
	dept | location | first_name | last_name | salary
*/
-- 

CREATE TABLE departments (
	dept_id bigserial,
	dept varchar(100),
	city varchar(100),
	CONSTRAINT dept_key PRIMARY KEY (dept_id),
	CONSTRAINT dept_city_unique UNIQUE (dept, city)
);

CREATE TABLE employees (
	emp_id bigserial,
	first_name varchar(100),
	last_name varchar(100),
	salary integer,
	dept_id integer REFERENCES departments (dept_id),
	CONSTRAINT emp_key PRIMARY KEY (emp_id),
	CONSTRAINT emp_dept_uniqe UNIQUE (emp_id, dept_id)
);

INSERT INTO departments (dept, city)
VALUES
	('Tax', 'Atlanta'), ('IT', 'Boston');

INSERT INTO employees (first_name, last_name, salary, dept_id)
VALUES
	('Nancy', 'Jones', 62500, 1),
	('Lee', 'Smith', 59300, 1),
	('Soo', 'Nguyen', 83000, 2),
	('Janet', 'King', 95000, 2);

select * from departments;
select * from employees;

-- actual JOIN query
SELECT *
FROM employees e
JOIN departments d -- this is INNER join
	ON e.dept_id = d.dept_id; -- no USING in postgres

-- LEFT & RIGHT
-- create table schools_left
CREATE TABLE schools_left (
	-- id bigserial PRIMARY KEY,
	id integer CONSTRAINT left_id_key PRIMARY KEY,
	left_school varchar(100)
);

INSERT INTO schools_left (left_school)
VALUES
	('Oak Street School'),
	('Roosevelt High School'),
	('Washington Middle School'),
	('Jefferson High School');

select * from schools_left;

update schools_left
set id = 5
where left_school = 'Washington Middle School';

update schools_left
set id = 6
where left_school = 'Jefferson High School';

-- create table schools_right
CREATE TABLE schools_right (
	-- id bigserial PRIMARY KEY,
	id integer CONSTRAINT right_id_key PRIMARY KEY,
	right_school varchar(100)
);

INSERT INTO schools_right
VALUES
	(1, 'Oak Street School'),
	(2, 'Roosevelt High School'),
	(3, 'Morrison Elementary'),
	(4, 'Chase Magnet Academy'),
	(6, 'Jefferson High School');

-----
SELECT *
FROM schools_left l
JOIN schools_right r
ON l.id = r.id;

SELECT *
FROM schools_left l
LEFT JOIN schools_right r
ON l.id = r.id;

SELECT *
FROM schools_left l
RIGHT JOIN schools_right r
ON l.id = r.id;

SELECT *
FROM schools_left l
FULL OUTER JOIN schools_right r
ON l.id = r.id;

SELECT *
FROM schools_left l
CROSS JOIN schools_right r; -- no common key is required

-- NULL
SELECT *
FROM schools_left l
LEFT JOIN schools_right r
ON l.id = r.id
WHERE r.id IS NULL; -- find what missing on the right table

select
	l.id left_id,
	left_school,
	right_school
from
	schools_left l
left join
	schools_right r
on l.id = r.id;

-- create schools_enrollment & schools_grades
create table schools_enrollment (
	id integer constraint enrollment_id primary key,
	enrollment integer
);

insert into schools_enrollment
values (1, 360), (2, 1001), (5, 450), (6, 927);

create table schools_grades (
	id integer constraint grade_id primary key,
	grades varchar(5)
);

insert into schools_grades
values (1, 'K-3'), (2, '9-12'), (5, '6-8'), (6, '9-12');

select
	l.id left_id
	,left_school
	,enrollment
	,grades
from schools_left l
left join schools_enrollment e on l.id = e.id
left join schools_grades g on l.id = g.id;


-- primary key, composite primary key
CREATE TABLE natural_key_composite_example (
	student_id varchar(10),
	school_day date,
	present boolean,
	CONSTRAINT student_key PRIMARY KEY (student_id, school_day)
);

DELETE FROM natural_key_composite_example;

INSERT INTO natural_key_composite_example
VALUES
	(775, '2017-01-22', 'Y'),
	(775, '2017-01-23', 'Y'),
	(775, '2017-01-23', 'N'); -- this would now fail because id & school day already existed

select * from natural_key_composite_example;

-- surrogate key
drop table surrogate_key_example;

create table surrogate_key_example (
	order_number bigserial,
	product_name varchar(50),
	order_date date,
	constraint order_key PRIMARY KEY (order_number)
);

insert into surrogate_key_example (product_name, order_date)
values
	('Beachball Polish', '2015-03-17'),
	('Wrinkle De-Atomier', '2017-05-22'),
	('Flux Capacitor', '1985-10-26');

select * from surrogate_key_example;


/*
	foreign	key
*/
drop table registrations;
drop table licences;

create table licenses (
	license_id varchar(10),
	first_name varchar(50),
	last_name varchar(50),
	constraint licenses_key primary key (license_id)
);

-- include CASCADE
create table registrations (
	registration_id varchar(10),
	registration_date date,
	license_id varchar(10) references licenses (license_id) on delete cascade, -- added on delete cascade, this means when deleting a licence record, that means the related registration record would also be deleted
	constraint registration_key primary key (registration_id, license_id)
);

insert into licenses values ('T229901', 'Lynn', 'Malero');
insert into registrations values ('A203391', '2017-03-17', 'T229901');
insert into registrations values ('A75772', '2017-03-17', 'T000001'); -- this wont work as license_id is not found in the licences table


/*
	CHECK constraint
*/
create table check_constraint_example (
	user_id bigserial,
	user_role varchar(50),
	salary integer,
	constraint user_id_key primary key (user_id),
	constraint check_role_in_list check (user_role IN ('Admin', 'Staff')),
	constraint check_salary_not_zero check (salary > 0)
);

-- use () and AND to combine more than 1 test
-- CONSTRAINT grad_check CHECK (credits >= 120 AND tution = 'Paid')
-- test values across columns
-- CONSTRAINT sale_check CHECK (sale_price < retail_price)

-- UNIQUE allow NULL values
-- PRIMARY KEY no values can be NULL
create table unique_constraint_example (
	contact_id bigserial constraint contact_id_ley primary key,
	first_name varchar(50),
	last_name varchar(50),
	email varchar(200),
	constraint email_unique UNIQUE (email)
);

insert into unique_constraint_example (first_name, last_name, email)
values ('Samantha', 'Lee', 'slee@example.org');

insert into unique_constraint_example (first_name, last_name, email)
values ('Betty', 'Diaz', 'bdiaz@example.org');

insert into unique_constraint_example (first_name, last_name, email)
values ('Sasha', 'Lee', 'slee@example.org'); -- error shows email already exists


/*
	NOT NULL
*/
create table not_null_example (
	student_id bigserial constraint student_id_key primary key,
	first_name varchar(50) not null,
	last_name varchar(50) not null
);

select * from not_null_example;

-- removing constraints or adding them later
-- to remove a PRIMARY key, FOREIGN key, UNIQUE
-- ALTER TABLE table_name DROP CONSTRAINT constraint_name
-- to drop NOT NULL - operates on the column
-- ALTER TABLE table_name ALTER COLUMN column_name DROP NOT NULL

alter table not_null_example drop constraint student_id_key;
alter table not_null_example add constraint student_id_key primary key (student_id);
alter table not_null_example alter column first_name drop not null;
alter table not_null_example alter column first_name set not null;

















