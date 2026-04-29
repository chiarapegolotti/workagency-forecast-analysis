TRUNCATE TABLE "20_dim".workers;

INSERT INTO "20_dim".workers(worker_id, worker_name, source_worker_id)
SELECT
    DENSE_RANK() OVER (ORDER BY worker_name) AS worker_id,
    worker_name,
    source_worker_id
FROM (
    SELECT DISTINCT workername AS worker_name, idworker_staging AS source_worker_id
    FROM "10_stg".forecast
    UNION
    SELECT DISTINCT workername AS worker_name, idworker_staging AS source_worker_id
    FROM "10_stg".actuals
) t;


SELECT f.workername, f.idworker_staging, w.worker_id
FROM "10_stg".forecast f
LEFT JOIN "20_dim".workers w
    ON f.idworker_staging = w.source_worker_id
WHERE f.is_last_snapshot = 1
  AND w.worker_id IS NULL
LIMIT 50;
