


-- Creazione tabella di staging
CREATE TABLE "10_stg".forecast (
    idContract TEXT,
    branch TEXT,
    customer TEXT,
    workerName TEXT,
    idWorker TEXT,

    start_date DATE,
    end_date DATE,
    end_date_actual DATE,
    end_date_final_forecast DATE,

    weekly_hours INT,
    internalSales TEXT,
    hourly_cost INT,
    hourly_price INT,

    snapshot_date DATE,
    month_year DATE, -- primo giorno del mese
    year INT,
    month INT,

    is_staff_leasing INT,
    is_last_snapshot INT,

    monthly_hours NUMERIC,
    monthly_cost NUMERIC,
    monthly_revenue NUMERIC,

    PRIMARY KEY (idContract, snapshot_date, year, month)
);
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
        -- end date finale per business
        COALESCE(end_date_actual, end_date, DATE '2050-12-31') AS end_date_final_forecast,
        -- staff leasing flag
        CASE WHEN end_date IS NULL AND end_date_actual IS NULL THEN 1 ELSE 0 END AS is_staff_leasing
    FROM casted
),

-- Generazione serie mensili per ogni contratto
expanded AS (
    SELECT
        b.*,
        generate_series(
            date_trunc('month', start_date),
            date_trunc('month', end_date_final_forecast),
            interval '1 month'
        )::DATE AS month_year
    FROM business_rules b
),

final AS (
    SELECT
        e.*,
        EXTRACT(YEAR FROM month_year)::INT AS year,
        EXTRACT(MONTH FROM month_year)::INT AS month,

        -- flag per ultima snapshot del contratto
        CASE WHEN snapshot_date = MAX(snapshot_date) OVER (PARTITION BY idContract) THEN 1 ELSE 0 END AS is_last_snapshot,

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