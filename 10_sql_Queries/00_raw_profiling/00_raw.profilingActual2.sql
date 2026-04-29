CREATE OR REPLACE VIEW "00_raw".profiling_actuals AS
SELECT 
    count(*) AS totrecord,
    count(*) FILTER (WHERE startdate IS NULL OR TRIM(BOTH FROM startdate) = '') AS startdatenull,
    count(DISTINCT branch) AS totbranch,
    count(*) FILTER (WHERE enddate IS NULL OR TRIM(BOTH FROM enddate) = '') AS enddate_missing,
    count(*) FILTER (WHERE enddateactual IS NULL OR TRIM(BOTH FROM enddateactual) = '') AS enddateactual_missing,
    count(*) FILTER (WHERE (enddate IS NULL OR TRIM(BOTH FROM enddate) = '') AND (enddateactual IS NULL OR TRIM(BOTH FROM enddateactual) = '')) AS staff_leasing_rows,
    count(*) FILTER (WHERE weeklyhours::text ~ '^[0-9]+\.[0-9]+$') AS weeklyhours_decimal,
    count(*) FILTER (WHERE monthlycost::text ~ '^[0-9]+\.[0-9]+$') AS costrounddecimals,
    count(*) FILTER (WHERE monthlyrevenue::text ~ '^[0-9]+\.[0-9]+$') AS revenuerounddecimals,
    count(*) FILTER (WHERE invoicemonth IS NULL OR TRIM(BOTH FROM invoicemonth) = '') AS invalidinvoice,
    count(*) FILTER (WHERE monthlycost <= 0) AS cost_anomalies,
    count(*) FILTER (WHERE monthlyrevenue <= 0) AS revenue_anomalies, 
	count(*) FILTER (WHERE idworker IN (SELECT idworker FROM "00_raw".actuals GROUP BY idworker HAVING COUNT(DISTINCT workername) > 1
    )) AS idworker_multiple_names,
    count(DISTINCT idcontract || invoicemonth) AS distinct_contract_months,
    count(DISTINCT idcontract) AS distinct_contracts

FROM "00_raw".actuals;

SELECT * FROM "00_raw".profiling_actuals;

SELECT COUNT(*) FROM "00_raw".actuals WHERE idworker IN(
SELECT idworker
FROM "00_raw".actuals
GROUP BY idworker
HAVING COUNT(DISTINCT TRIM(LOWER(workername))) > 1); -- the id worker is not a real id, it's just a random number