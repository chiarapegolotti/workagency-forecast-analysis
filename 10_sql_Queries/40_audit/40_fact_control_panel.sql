CREATE OR REPLACE VIEW "40_audit".fact_control_panel AS

WITH base AS (
    SELECT *
    FROM "30_fact".actual_forecast
),

-- Copertura temporale: primi e ultimi mesi di forecast e actuals
time_check AS (
    SELECT
        MIN(CASE WHEN source_table = 'forecast' THEN month_year END) AS forecast_start,
        MAX(CASE WHEN source_table = 'forecast' THEN month_year END) AS forecast_end,
        MIN(CASE WHEN source_table = 'actuals' THEN month_year END) AS actual_start,
        MAX(CASE WHEN source_table = 'actuals' THEN month_year END) AS actual_end
    FROM base
),

-- Volumi: righe, contratti, workers, clients, staff leasing
volume_check AS (
    SELECT
        COUNT(*) AS total_rows,
        COUNT(DISTINCT idcontract) AS total_contracts,
        COUNT(DISTINCT worker_id) AS total_workers,
        COUNT(DISTINCT client_id) AS total_clients,
        COUNT(DISTINCT CASE WHEN is_staff_leasing = 1 THEN idcontract END) AS total_staff_leasing
    FROM base
),

-- KPI economici
kpi_check AS (
    SELECT
        SUM(CASE WHEN source_table = 'forecast' THEN monthly_revenue END) AS forecast_revenue,
        SUM(CASE WHEN source_table = 'actuals' THEN monthly_revenue END) AS actual_revenue,
        SUM(CASE WHEN source_table = 'actuals' THEN monthly_revenue END)
        - SUM(CASE WHEN source_table = 'forecast' THEN monthly_revenue END) AS delta_revenue,
        AVG(CASE WHEN source_table = 'forecast' THEN monthly_revenue END) AS avg_forecast_revenue,
        AVG(CASE WHEN source_table = 'actuals' THEN monthly_revenue END) AS avg_actual_revenue
    FROM base
),

-- Media ore lavorate (settimanali)
hours_check AS (
    SELECT
        AVG(weekly_hours) AS avg_weekly_hours
    FROM base
)

-- Select finale con tutti i controlli
SELECT
    t.*,
    v.*,
    k.*,
    h.*,

    -- Flag per forecast futuri
    CASE 
        WHEN t.forecast_end > t.actual_end THEN 1 ELSE 0 
    END AS forecast_has_future,

    CASE 
        WHEN t.actual_end > CURRENT_DATE THEN 1 ELSE 0 
    END AS actual_has_future_flag

FROM time_check t
CROSS JOIN volume_check v
CROSS JOIN kpi_check k
CROSS JOIN hours_check h;

SELECT * FROM "40_audit".fact_control_panel;