USE SqlPractice;


/*
	practice
*/
SELECT *
FROM dbo.SalesData;


INSERT INTO SalesData VALUES
	('East', 'Misc', 75000);


SELECT
	region,
	[electronics],
	[clothing],
	[misc]
FROM dbo.SalesData
PIVOT (
	SUM(revenue_or_sales)
	FOR category in ([electronics], [clothing], [misc])
	) as pivotTable;