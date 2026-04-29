-- Creo la fact table unica combinando forecast e actuals
CREATE TABLE "30_fact".actual_forecast AS
WITH 

-- Step 1: Normalizzo forecast
forecast_cte AS (
    SELECT
        idcontract::text,
        branch::text,
        customer::text AS customer,
        workername::text,
        idworker::text,
        start_date::date,
        end_date::date,
        end_date_final_forecast::date AS end_date_final,
        weekly_hours::integer,
        internalsales::text,
        ROUND(monthly_cost::numeric,2) AS monthly_cost,
        ROUND(monthly_revenue::numeric,2) AS monthly_revenue,
        snapshot_date::date,
        month_year::date,
        year::integer,
        month::integer,
        is_staff_leasing::integer,
        'forecast'::text AS source_table
    FROM "10_stg".forecast
    WHERE is_last_snapshot = 1
),

-- Step 2: Normalizzo actuals
actuals_cte AS (
    SELECT
        idcontract::text,
        branch::text,
        client::text AS customer,
        workername::text,
        idworker::text,
        start_date::date,
        end_date::date,
        end_date_final::date,
        weekly_hours::integer,
        internalsales::text,
        ROUND(monthly_cost::numeric,2) AS monthly_cost,
        ROUND(monthly_revenue::numeric,2) AS monthly_revenue,
        invoice_date::date AS snapshot_date,
        TO_DATE(TO_CHAR(invoice_date,'YYYY-MM-01'),'YYYY-MM-DD') AS month_year,
        invoice_year::integer AS year,
        invoice_month::integer AS month,
        is_staff_leasing::integer,
        'actuals'::text AS source_table
    FROM "10_stg".actuals
),

-- Step 3: Unisco forecast e actuals
combined_cte AS (
    SELECT * FROM forecast_cte
    UNION ALL
    SELECT * FROM actuals_cte
)

-- Step 4: Join con le dimensioni
SELECT 
    comb.idcontract,
    b.branch_id,
    b.branch_name,
    c.client_id,
    c.client_name,
    w.worker_id,
    w.worker_name,
    w.source_worker_id,
    i.internal_sales_id,
    i.internal_sales,
    ROUND(comb.monthly_cost,2) AS monthly_cost,
    ROUND(comb.monthly_revenue,2) AS monthly_revenue,
    comb.start_date,
    comb.end_date,
    comb.end_date_final,
    comb.weekly_hours,
    comb.is_staff_leasing,
    comb.month_year,
    comb.year AS invoice_year,
    comb.month AS invoice_month,
    comb.source_table
FROM combined_cte comb
LEFT JOIN "20_dim".branch b
    ON comb.branch = b.branch_name
LEFT JOIN "20_dim".clients c
    ON comb.customer = c.client_name
LEFT JOIN "20_dim".workers w
    ON comb.workername = w.worker_name
    AND comb.idworker = w.source_worker_id
LEFT JOIN "20_dim".internal_sales i
    ON comb.internalsales = i.internal_sales
    AND comb.branch = i.branch_name;

SELECT * FROM "30_fact".actual_forecast WHERE source_table = 'forecast';