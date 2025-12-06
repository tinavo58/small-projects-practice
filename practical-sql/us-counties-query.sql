DROP TABLE IF EXISTS us_counties_2010;

CREATE TABLE us_counties_2010 (
    geo_name varchar(90),                    -- Name of the geography
    state_us_abbreviation varchar(2),        -- State/U.S. abbreviation
    summary_level varchar(3),                -- Summary Level
    region smallint,                         -- Region
    division smallint,                       -- Division
    state_fips varchar(2),                   -- State FIPS code
    county_fips varchar(3),                  -- County code
    area_land bigint,                        -- Area (Land) in square meters
    area_water bigint,                        -- Area (Water) in square meters
    population_count_100_percent integer,    -- Population count (100%)
    housing_unit_count_100_percent integer  -- Housing Unit count (100%)
    -- internal_point_lat numeric(10,7),        -- Internal point (latitude)
    -- internal_point_lon numeric(10,7)         -- Internal point (longitude)
);

COPY us_counties_2010
FROM '/private/tmp/us_counties_2010.csv'
WITH (FORMAT csv, HEADER);


/*
	query from this point
*/
SELECT
	*
FROM us_counties_2010
ORDER BY housing_unit_count_100_percent desc
LIMIT 10;

-- rank county-level geographies (top 3)
SELECT
	geo_name
	,state_us_abbreviation
	,area_land
FROM us_counties_2010
ORDER BY area_land DESC
LIMIT 3;

-- sort by longitude top 5
SELECT
	geo_name
	,state_us_abbreviation
	,internal_point_lon -- this col does not exist in the csv file
FROM us_counties_2010
ORDER BY
	internal_point_lon DESC
LIMIT 5;

-- export
COPY us_counties_2010 (geo_name, state_us_abbreviation)
TO '/private/tmp/export-sample.csv'
WITH (format csv, header, delimiter ',');

-- export from query directly within COPY
COPY (
	SELECT geo_name, state_us_abbreviation
	FROM us_counties_2010
	WHERE geo_name ILIKE '%mill%'
)
TO '/private/tmp/export-from-postgres.csv'
WITH (format csv, header, delimiter ',');

-- random
SELECT count(*)
FROM (
	SELECT geo_name, state_us_abbreviation
	FROM us_counties_2010
	WHERE geo_name ILIKE '%mill%') tbl;

-- top 20 most housing units
SELECT
	geo_name
	,state_us_abbreviation
	,housing_unit_count_100_percent
FROM us_counties_2010
ORDER BY
	3 desc
LIMIT 20;
	

