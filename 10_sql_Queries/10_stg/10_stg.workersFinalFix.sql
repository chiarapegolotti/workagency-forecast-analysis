WITH worker_map AS (
    SELECT 
        TRIM(LOWER(workername)) AS workername_clean,
        DENSE_RANK() OVER (ORDER BY TRIM(LOWER(workername))) AS new_idworker
    FROM (
        SELECT workername FROM "10_stg".forecast
        UNION
        SELECT workername FROM "10_stg".actuals
    ) t
)


-- Aggiorna forecast
UPDATE "10_stg".forecast f
SET idworker_staging = wm.new_idworker
FROM worker_map wm
WHERE TRIM(LOWER(f.workername)) = wm.workername_clean;

-- Aggiorna actuals
UPDATE "10_stg".actuals a
SET idworker_staging = wm.new_idworker
FROM worker_map wm
WHERE TRIM(LOWER(a.workername)) = wm.workername_clean;

