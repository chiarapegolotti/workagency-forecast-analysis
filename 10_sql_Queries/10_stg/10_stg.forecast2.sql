ALTER TABLE "10_stg".forecast
ADD COLUMN idworker_staging INTEGER;

WITH worker_map AS (
    SELECT 
        TRIM(LOWER(workername)) AS workername_clean,
        DENSE_RANK() OVER (ORDER BY TRIM(LOWER(workername))) AS new_idworker
    FROM "10_stg".forecast
    GROUP BY TRIM(LOWER(workername))
)
UPDATE "10_stg".forecast f
SET idworker_staging = wm.new_idworker
FROM worker_map wm
WHERE TRIM(LOWER(f.workername)) = wm.workername_clean;

SELECT idworker_staging, COUNT(DISTINCT workername) AS names_count
FROM "10_stg".forecast
GROUP BY idworker_staging
HAVING COUNT(DISTINCT workername) > 1;

SELECT workername, COUNT(DISTINCT idworker_staging) AS id_count
FROM "10_stg".forecast
GROUP BY workername
HAVING COUNT(DISTINCT idworker_staging) > 1;

SELECT workername, idworker, idworker_staging
FROM "10_stg".forecast
ORDER BY workername
LIMIT 50;

UPDATE "10_stg".forecast
SET idworker = idworker_staging;