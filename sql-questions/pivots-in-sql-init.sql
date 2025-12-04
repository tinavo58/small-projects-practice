CREATE DATABASE SqlPractice;
GO

USE SqlPractice;
GO


-- create table to practice
BEGIN
	CREATE TABLE SalesData (
		region VARCHAR(50),
		category VARCHAR(50),
		revenue_or_sales MONEY
	);

	INSERT INTO SalesData VALUES
		('North', 'Electronics', 100000),
		('South', 'Electronics', 200000),
		('North', 'Clothing', 50000),
		('South', 'Clothing', 25000)
	;
END