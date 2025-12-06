-- CAST
select (7 + 8)::varchar(40); -- (1)
select CAST(7 + 8 AS VARCHAR(10)); -- (2) = (1)

-- import csv data
CREATE TABLE bad_sentiments (
	keyword VARCHAR(50),
	count INTEGER
);

COPY bad_sentiments
FROM '/private/tmp/bad_sentiments.csv'
WITH (format csv, header);

-- check table
select * from bad_sentiments;

-- numeric FORMAT (a, b)
-- a: the total length of the number
-- b: decimal places
select 11;
select CAST(17519.668 as NUMERIC(8, 1));

-- square root -- these are only available in postgres
-- using SQL in other tools, might need to check
select |/10;
select |/9;
select sqrt(9);
select ||/8; -- cube root
select 9 !; -- error need to check this

/*
	practice YoY
*/
CREATE TABLE IF NOT EXISTS pct_change (
	department varchar(20),
	spend_2014 numeric(10,2),
	spend_2017 numeric(10,2)
);

INSERT INTO pct_change
VALUES
	('Building', 250000, 289000),
	('Assessor', 178556, 179500),
	('Library', 87777, 900001), -- accidentally add 1 zero
	('Clerk', 451980, 650000),
	('Police', 250000, 223000),
	('Recreation', 199000, 195000);

UPDATE pct_change -- no TABLE wording in this
SET spend_2017 = 90001
WHERE department = 'Library';

SELECT
	department
	,spend_2014
	,spend_2017
	,round((spend_2017 - spend_2014) / spend_2014 * 100, 1) AS pct_change
FROM pct_change;


-- learn median
CREATE TABLE percentile_test (numbers integer);

INSERT INTO percentile_test
VALUES (1), (2), (3), (4), (5), (6);

SELECT
	percentile_cont(.5) WITHIN GROUP (ORDER BY numbers), -- calc percentiles as continuous values
	percentile_disc(.5) WITHIN GROUP (ORDER BY numbers) -- returns only discrete values
FROM percentile_test;
