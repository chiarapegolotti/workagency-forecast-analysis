CREATE TABLE "00_raw".forecast(
	idContract TEXT, -- unique value even for different snapshots
	branch TEXT, --6 branches, regular for italian work agencies
	customer TEXT,
	workerName TEXT,
	idWorker TEXT,
	startDate TEXT, -- is not null, checked to be sure
	endDate TEXT, -- checked for staff leasing existance NULL EXISTS
	endDateActual TEXT, -- NULL EXISTS
	weeklyHours NUMERIC, -- is an integer
	internalSales TEXT, -- each branch has at least 1 internal sales
	hourlyCost NUMERIC, -- is an integer
	hourlyPrice NUMERIC, -- is an integer
	SnapshotDate TEXT -- date format
);

SELECT * FROM "00_raw".forecast;
SELECT COUNT (*) FROM "00_raw".forecast;
SELECT COUNT(*) FROM "00_raw".forecast GROUP BY idcontract HAVING COUNT(*) >1;
SELECT DISTINCT branch FROM "00_raw".forecast;
SELECT * FROM "00_raw".forecast WHERE startdate IS NULL;
SELECT COUNT(*) FROM "00_raw".forecast WHERE (enddate IS NULL OR trim(enddate) = '') AND (enddateactual IS NULL OR trim(enddateactual) = '') GROUP BY snapshotdate;
SELECT COUNT(*) FROM "00_raw".forecast WHERE weeklyhours::text ~ '^[0-9]+\.[0-9]+$';
SELECT COUNT(*) FROM "00_raw".forecast GROUP BY branch HAVING COUNT (*)<1;
SELECT COUNT(*) FROM "00_raw".forecast WHERE hourlyprice::text ~ '^[0-9]+\.[0-9]+$';
SELECT COUNT(*) FROM "00_raw".forecast WHERE snapshotdate ~ '^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$';
SELECT COUNT(*) FROM "00_raw".forecast WHERE TO_DATE(snapshotdate, 'YYYY-MM-DD') IS NOT NULL;

CREATE OR REPLACE VIEW "00_raw".profiling_forecast AS
SELECT 
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE startDate IS NULL) AS startdate_null,
    COUNT(*) FILTER (WHERE endDate IS NULL OR trim(endDate) = '') AS enddate_missing,
    COUNT(*) FILTER (WHERE endDateActual IS NULL OR trim(endDateActual) = '') AS enddateactual_missing,
    COUNT(*) FILTER (WHERE weeklyHours::text ~ '^[0-9]+\.[0-9]+$') AS weeklyhours_decimal,
    COUNT(*) FILTER (WHERE hourlyCost::text ~ '^[0-9]+\.[0-9]+$') AS hourlycost_decimal,
    COUNT(*) FILTER (WHERE hourlyPrice::text ~ '^[0-9]+\.[0-9]+$') AS hourlyprice_decimal,
    COUNT(*) FILTER (WHERE snapshotDate !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$') AS invalid_snapshotdate
FROM "00_raw".forecast;