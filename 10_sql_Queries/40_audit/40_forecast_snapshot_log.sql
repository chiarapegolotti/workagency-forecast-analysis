-- Creazione della tabella log snapshot
CREATE TABLE IF NOT EXISTS "40_audit".forecast_snapshot_log (
    snapshot_date DATE PRIMARY KEY,
    total_contracts INT,
    temporary_contracts INT,
    staff_leasing_contracts INT,
    total_workers INT,
    avg_monthly_hours NUMERIC(18,2),
    total_monthly_cost NUMERIC(18,2),
    total_monthly_revenue NUMERIC(18,2),
    delta_total_contracts INT,
    delta_temporary_contracts INT,
    delta_staff_leasing_contracts INT,
    delta_total_monthly_hours NUMERIC(18,2),
    delta_total_monthly_cost NUMERIC(18,2),
    delta_total_monthly_revenue NUMERIC(18,2)
);

-- Inserimento aggregati dal raw
WITH base AS (
    SELECT
        TO_DATE(snapshotDate, 'YYYY-MM-DD') AS snapshot_date,
        COUNT(*) AS total_contracts,
        COUNT(*) FILTER (
            WHERE NOT ( (endDate IS NULL OR trim(endDate) = '') 
                     AND (endDateActual IS NULL OR trim(endDateActual) = '') )
        ) AS temporary_contracts,  -- contratti temporanei
        COUNT(*) FILTER (
            WHERE (endDate IS NULL OR trim(endDate) = '') 
              AND (endDateActual IS NULL OR trim(endDateActual) = '')
        ) AS staff_leasing_contracts,  -- contratti a tempo indeterminato
        COUNT(DISTINCT idWorker) AS total_workers,
        ROUND(AVG(weeklyHours)::NUMERIC,2) AS avg_monthly_hours,
        ROUND(SUM(weeklyHours * 4.333333 * hourlyCost)::NUMERIC,2) AS total_monthly_cost,
        ROUND(SUM(weeklyHours * 4.333333 * hourlyPrice)::NUMERIC,2) AS total_monthly_revenue
    FROM "00_raw".forecast
    GROUP BY snapshotDate
    ORDER BY snapshotDate
),
lagged AS (
    SELECT
        *,
        LAG(total_contracts) OVER (ORDER BY snapshot_date) AS prev_total_contracts,
        LAG(temporary_contracts) OVER (ORDER BY snapshot_date) AS prev_temporary_contracts,
        LAG(staff_leasing_contracts) OVER (ORDER BY snapshot_date) AS prev_staff_leasing_contracts,
        LAG(avg_monthly_hours) OVER (ORDER BY snapshot_date) AS prev_avg_monthly_hours,
        LAG(total_monthly_cost) OVER (ORDER BY snapshot_date) AS prev_total_monthly_cost,
        LAG(total_monthly_revenue) OVER (ORDER BY snapshot_date) AS prev_total_monthly_revenue
    FROM base
)
INSERT INTO "40_audit".forecast_snapshot_log
SELECT
    snapshot_date,
    total_contracts,
    temporary_contracts,
    staff_leasing_contracts,
    total_workers,
    avg_monthly_hours,
    total_monthly_cost,
    total_monthly_revenue,
    total_contracts - COALESCE(prev_total_contracts,0) AS delta_total_contracts,
    temporary_contracts - COALESCE(prev_temporary_contracts,0) AS delta_temporary_contracts,
    staff_leasing_contracts - COALESCE(prev_staff_leasing_contracts,0) AS delta_staff_leasing_contracts,
    ROUND(avg_monthly_hours - COALESCE(prev_avg_monthly_hours,0),2) AS delta_avg_monthly_hours,
    ROUND(total_monthly_cost - COALESCE(prev_total_monthly_cost,0),2) AS delta_total_monthly_cost,
    ROUND(total_monthly_revenue - COALESCE(prev_total_monthly_revenue,0),2) AS delta_total_monthly_revenue
FROM lagged
ORDER BY snapshot_date;

SELECT * FROM "40_audit".forecast_snapshot_log;