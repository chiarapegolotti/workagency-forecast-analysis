CREATE VIEW "60_mart".monthly_revenue AS
SELECT
    month_year,
    source_table,
    SUM(monthly_revenue) AS total_revenue,
    SUM(monthly_cost) AS total_cost
FROM "30_fact".actual_forecast
GROUP BY month_year, source_table;

SELECT * FROM "60_mart".monthly_revenue;

CREATE VIEW "60_mart".forecast_vs_actual AS
SELECT
    month_year,

    SUM(CASE WHEN source_table = 'forecast' THEN monthly_revenue END) AS forecast_revenue,
    SUM(CASE WHEN source_table = 'actuals' THEN monthly_revenue END) AS actual_revenue,

    SUM(CASE WHEN source_table = 'actuals' THEN monthly_revenue END)
    - SUM(CASE WHEN source_table = 'forecast' THEN monthly_revenue END) AS delta

FROM "30_fact".actual_forecast
GROUP BY month_year;

SELECT * FROM "60_mart".forecast_vs_actual;

CREATE VIEW "60_mart".clients_revenue AS
SELECT
    client_name,
    month_year,
    SUM(monthly_revenue) AS revenue
FROM "30_fact".actual_forecast
GROUP BY client_name, month_year;

SELECT * FROM "60_mart".clients_revenue;

CREATE VIEW "60_mart".contracts_funnel AS
SELECT
    month_year,
    COUNT(DISTINCT idcontract) AS contratti,
    COUNT(DISTINCT worker_id) AS lavoratori,
    COUNT(DISTINCT client_id) AS clienti,
    SUM(monthly_revenue) AS revenue
FROM "30_fact".actual_forecast
GROUP BY month_year;

SELECT * FROM "60_mart".contracts_funnel;

CREATE VIEW "60_mart".workers_performance AS
SELECT
    worker_id,
    worker_name,

    month_year,

    client_name,
    branch_name,

    source_table,

    SUM(monthly_revenue) AS total_revenue,
    SUM(monthly_cost) AS total_cost,

    SUM(monthly_revenue - monthly_cost) AS margin,

    AVG(weekly_hours) AS avg_weekly_hours,

    COUNT(DISTINCT idcontract) AS total_contracts

FROM "30_fact".actual_forecast
GROUP BY
    worker_id,
    worker_name,
    month_year,
    client_name,
    branch_name,
    source_table;

SELECT * FROM "60_mart".workers_performance;