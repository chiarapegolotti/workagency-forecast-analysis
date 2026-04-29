TRUNCATE TABLE "10_stg".forecast;

-- Inserimento dati nella staging
INSERT INTO "10_stg".forecast
WITH casted AS (
    SELECT
        idContract,
        branch,
        customer,
        workerName,
        idWorker,

        TO_DATE(startDate, 'YYYY-MM-DD') AS start_date,
        CASE WHEN endDate IS NOT NULL AND TRIM(endDate) <> '' THEN TO_DATE(endDate, 'YYYY-MM-DD') END AS end_date,
        CASE WHEN endDateActual IS NOT NULL AND TRIM(endDateActual) <> '' THEN TO_DATE(endDateActual, 'YYYY-MM-DD') END AS end_date_actual,

        weeklyHours::INT AS weekly_hours,
        internalSales,
        hourlyCost::INT AS hourly_cost,
        hourlyPrice::INT AS hourly_price,

        TO_DATE(snapshotDate, 'YYYY-MM-DD') AS snapshot_date

    FROM "00_raw".forecast
),

business_rules AS (
    SELECT
        *,
        COALESCE(end_date_actual, end_date, DATE '2050-12-31') AS end_date_final_forecast,
        CASE WHEN end_date IS NULL AND end_date_actual IS NULL THEN 1 ELSE 0 END AS is_staff_leasing
    FROM casted
),

-- FILTRO snapshot globale: solo l'ultima data disponibile nel dataset
latest_snapshot AS (
    SELECT *
    FROM business_rules
    WHERE snapshot_date = (SELECT MAX(snapshot_date) FROM business_rules)
),

-- Generazione serie mensili per ogni contratto
expanded AS (
    SELECT
        l.*,
        generate_series(
            date_trunc('month', start_date),
            date_trunc('month', end_date_final_forecast),
            interval '1 month'
        )::DATE AS month_year
    FROM latest_snapshot l
),

final AS (
    SELECT
        e.*,
        EXTRACT(YEAR FROM month_year)::INT AS year,
        EXTRACT(MONTH FROM month_year)::INT AS month,

        -- flag per ultima snapshot globale
        1 AS is_last_snapshot,

        -- calcolo giorni attivi nel mese
        (LEAST(end_date_final_forecast, month_year + INTERVAL '1 month' - INTERVAL '1 day')::DATE
         - GREATEST(start_date, month_year) + 1)::NUMERIC AS active_days_in_month,

        ((month_year + INTERVAL '1 month' - INTERVAL '1 day')::DATE - month_year + 1)::NUMERIC AS days_in_month,

        -- calcolo ore mensili pro-rata
        ((LEAST(end_date_final_forecast, month_year + INTERVAL '1 month' - INTERVAL '1 day')::DATE
          - GREATEST(start_date, month_year) + 1)::NUMERIC
         / ((month_year + INTERVAL '1 month' - INTERVAL '1 day')::DATE - month_year + 1)::NUMERIC
        * weekly_hours * 4.333333333) AS monthly_hours,

        -- calcolo costi e ricavi mensili pro-rata
        ((LEAST(end_date_final_forecast, month_year + INTERVAL '1 month' - INTERVAL '1 day')::DATE
          - GREATEST(start_date, month_year) + 1)::NUMERIC
         / ((month_year + INTERVAL '1 month' - INTERVAL '1 day')::DATE - month_year + 1)::NUMERIC
        * weekly_hours * 4.333333333 * hourly_cost) AS monthly_cost,

        ((LEAST(end_date_final_forecast, month_year + INTERVAL '1 month' - INTERVAL '1 day')::DATE
          - GREATEST(start_date, month_year) + 1)::NUMERIC
         / ((month_year + INTERVAL '1 month' - INTERVAL '1 day')::DATE - month_year + 1)::NUMERIC
        * weekly_hours * 4.333333333 * hourly_price) AS monthly_revenue

    FROM expanded e
)

SELECT
    idContract,
    branch,
    customer,
    workerName,
    idWorker,
    start_date,
    end_date,
    end_date_actual,
    end_date_final_forecast,
    weekly_hours,
    internalSales,
    hourly_cost,
    hourly_price,
    snapshot_date,
    month_year,
    year,
    month,
    is_staff_leasing,
    is_last_snapshot,
    monthly_hours,
    monthly_cost,
    monthly_revenue
FROM final;

SELECT COUNT(*) AS total FROM "10_stg".forecast 
WHERE month_year < '2026-01-01';