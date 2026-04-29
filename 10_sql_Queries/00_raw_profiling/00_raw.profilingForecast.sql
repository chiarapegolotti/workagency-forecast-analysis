-- View: 00_raw.profiling_forecast

-- DROP VIEW "00_raw".profiling_forecast;

CREATE OR REPLACE VIEW "00_raw".profiling_forecast
 AS
 SELECT count(*) AS total_rows,
    count(*) FILTER (WHERE startdate IS NULL OR TRIM(BOTH FROM startdate) = ''::text) AS startdate_null,
    count(*) FILTER (WHERE enddate IS NULL OR TRIM(BOTH FROM enddate) = ''::text) AS enddate_missing,
    count(*) FILTER (WHERE enddateactual IS NULL OR TRIM(BOTH FROM enddateactual) = ''::text) AS enddateactual_missing,
    count(*) FILTER (WHERE (enddate IS NULL OR TRIM(BOTH FROM enddate) = ''::text) AND (enddateactual IS NULL OR TRIM(BOTH FROM enddateactual) = ''::text)) AS staff_leasing_rows,
    count(*) FILTER (WHERE weeklyhours::text ~ '^[0-9]+\.[0-9]+$'::text) AS weeklyhours_decimal,
    count(*) FILTER (WHERE hourlycost::text ~ '^[0-9]+\.[0-9]+$'::text) AS hourlycost_decimal,
    count(*) FILTER (WHERE hourlyprice::text ~ '^[0-9]+\.[0-9]+$'::text) AS hourlyprice_decimal,
    count(*) FILTER (WHERE snapshotdate !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'::text) AS invalid_snapshotdate
   FROM "00_raw".forecast;

ALTER TABLE "00_raw".profiling_forecast
    OWNER TO postgres;

