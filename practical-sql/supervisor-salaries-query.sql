CREATE TABLE supervisor_salaries (
	town varchar(30),
	county varchar(30),
	supervisor varchar(30),
	start_date date,
	salary money,
	benefits money
);

COPY supervisor_salaries (town, supervisor, salary) -- incl columns here
FROM '/private/tmp/supervisor_salaries.csv'
WITH (format csv, header);

-- query
select * from supervisor_salaries limit 5;

-- clear data from table
DELETE FROM supervisor_salaries; -- clear content only

/*
	create temp to use to insert data into the main one
*/
CREATE TEMPORARY TABLE supervisor_salaries_temp
	(LIKE supervisor_salaries);

COPY supervisor_salaries_temp (town, supervisor, salary)
FROM '/private/tmp/supervisor_salaries.csv'
WITH (format csv, header);

INSERT INTO supervisor_salaries (town, county, supervisor, salary)
SELECT town, 'some_county', supervisor, salary
FROM supervisor_salaries_temp; -- this would insert value into the main one

DROP TABLE supervisor_salaries_temp;

