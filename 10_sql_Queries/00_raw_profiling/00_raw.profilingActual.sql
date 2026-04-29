-- View: 00_raw.profiling_actuals

-- DROP VIEW "00_raw".profiling_actuals;

CREATE OR REPLACE VIEW "00_raw".profiling_actuals
 AS
 SELECT count(*) AS totrecord,
    count(*) FILTER (WHERE startdate IS NULL OR TRIM(BOTH FROM startdate) = ''::text) AS startdatenull,
    count(DISTINCT branch) AS totbranch,
    count(*) FILTER (WHERE enddate IS NULL OR TRIM(BOTH FROM enddate) = ''::text) AS enddate_missing,
    count(*) FILTER (WHERE enddateactual IS NULL OR TRIM(BOTH FROM enddateactual) = ''::text) AS enddateactual_missing,
    count(*) FILTER (WHERE (enddate IS NULL OR TRIM(BOTH FROM enddate) = ''::text) AND (enddateactual IS NULL OR TRIM(BOTH FROM enddateactual) = ''::text)) AS staff_leasing_rows,
    count(*) FILTER (WHERE weeklyhours::text ~ '^[0-9]+\.[0-9]+$'::text) AS weeklyhours_decimal,
    count(*) FILTER (WHERE monthlycost::text ~ '^[0-9]+\.[0-9]+$'::text) AS costrounddecimals,
    count(*) FILTER (WHERE monthlyrevenue::text ~ '^[0-9]+\.[0-9]+$'::text) AS revenuerounddecimals,
    count(*) FILTER (WHERE invoicemonth IS NULL OR TRIM(BOTH FROM invoicemonth) = ''::text) AS invalidinvoice,
    count(*) FILTER (WHERE monthlycost <= 0::numeric) AS cost_anomalies,
    count(*) FILTER (WHERE monthlyrevenue <= 0::numeric) AS revenue_anomalies
   FROM "00_raw".actuals;

ALTER TABLE "00_raw".profiling_actuals
    OWNER TO postgres;

