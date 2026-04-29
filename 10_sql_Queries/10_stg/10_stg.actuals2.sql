ALTER TABLE "10_stg".actuals
ADD COLUMN idworker_staging integer; -- to fix idworker duplicates

WITH ranked AS (
    SELECT *,
           DENSE_RANK() OVER (ORDER BY TRIM(LOWER(workername))) AS new_idworker
    FROM "10_stg".actuals
) -- to create a unique number for each workername
UPDATE "10_stg".actuals a
SET idworker_staging = r.new_idworker
FROM ranked r
WHERE a.idcontract = r.idcontract
  AND a.invoice_date = r.invoice_date;

SELECT idworker_staging, COUNT(DISTINCT workername) AS names_count
FROM "10_stg".actuals
GROUP BY idworker_staging
HAVING COUNT(DISTINCT workername) > 1;

UPDATE "10_stg".actuals
SET idworker = idworker_staging;


SELECT * FROM "10_stg".actuals WHERE idworker = '100';