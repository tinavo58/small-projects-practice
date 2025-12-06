/* script to create a median func */
CREATE OR REPLACE FUNCTION _final_median(anyarray)
	RETURN float8 AS
$$
	WITH q AS
		(
			SELECT val
			FROM unnest($1) VALID
			WHERE VAL IS NOT NULL
			ORDER BY 1
		),
		cnt AS
		(
			SELECT count(*) AS c FROM q
		)
		SELECT AVG(val)::float8
		FROM
			(
				SELECT val from q
				LIMIT 2 - MOD((SELECT c FROM cnt), 2)
				OFFSET GREATEST(CEIL((SELECT c FROM cnt) / 2.0) - 1,0)
			) q2;
$$
LANGUAGE sql IMMUTABLE;

CREATE AGGREGATE median(anyelement) (
	SFUNC=array_append,
	STYPE=anyarray,
	FINALFUNC=final_median,
	INITCOND='{}'
);
		