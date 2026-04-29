SELECT * FROM "00_raw".forecast WHERE idworker = '100';

CREATE OR REPLACE VIEW "00_raw".profiling_forecast AS
SELECT count(*) AS total_rows,
count(*) FILTER (WHERE startdate IS NULL OR TRIM(BOTH FROM startdate) = '') AS startdate_null,
count(*) FILTER (WHERE enddate IS NULL OR TRIM(BOTH FROM enddate) = '') AS enddate_missing,
count(*) FILTER (WHERE enddateactual IS NULL OR TRIM(BOTH FROM enddateactual) = '') AS enddateactual_missing,
count(*) FILTER (WHERE (enddate IS NULL OR TRIM(BOTH FROM enddate) = '') AND (enddateactual IS NULL OR TRIM(BOTH FROM enddateactual) = '')) AS staff_leasing_rows,
count(*) FILTER (WHERE weeklyhours::text ~ '^[0-9]+\.[0-9]+$') AS weeklyhours_decimal,
count(*) FILTER (WHERE hourlycost::text ~ '^[0-9]+\.[0-9]+$') AS hourlycost_decimal,
count(*) FILTER (WHERE hourlyprice::text ~ '^[0-9]+\.[0-9]+$') AS hourlyprice_decimal,
count(*) FILTER (WHERE snapshotdate !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$') AS invalid_snapshotdate,
count(*) FILTER (WHERE idworker IN (SELECT idworker FROM "00_raw".forecast GROUP BY idworker HAVING COUNT(DISTINCT LOWER(TRIM(workername))) > 1)) AS idworker_multiple_names,
COUNT(DISTINCT idcontract) AS distinct_contracts,
COUNT(DISTINCT idcontract || '-' || snapshotdate) AS distinct_contract_snapshot,
COUNT(DISTINCT idcontract) FILTER (WHERE customer IN ('BigClientA','BigClientB')) AS bigclient_contracts,
COUNT(DISTINCT branch) FILTER (WHERE customer IN ('BigClientA','BigClientB')) AS bigclient_branches
FROM "00_raw".forecast;


SELECT * FROM "00_raw".profiling_forecast;

