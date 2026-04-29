-- Branch
TRUNCATE TABLE "20_dim".branch;

INSERT INTO "20_dim".branch(branch_id, branch_name)
SELECT
    DENSE_RANK() OVER (ORDER BY branch_name) AS branch_id,
    branch_name
FROM (
    SELECT DISTINCT branch AS branch_name
    FROM "00_raw".forecast
    UNION
    SELECT DISTINCT branch AS branch_name
    FROM "00_raw".actuals
) t;


-- Clients
TRUNCATE TABLE "20_dim".clients;

INSERT INTO "20_dim".clients(client_id, client_name)
SELECT
    DENSE_RANK() OVER (ORDER BY client_name) AS client_id,
    client_name
FROM (
    SELECT DISTINCT customer AS client_name
    FROM "00_raw".forecast
    UNION
    SELECT DISTINCT client AS client_name
    FROM "00_raw".actuals
) t;

-- Workers
TRUNCATE TABLE "20_dim".workers;

INSERT INTO "20_dim".workers(worker_id, worker_name, source_worker_id)
SELECT
    DENSE_RANK() OVER (ORDER BY worker_name) AS worker_id,
    worker_name,
    source_worker_id
FROM (
    -- Prendiamo i dati da staging per avere l'idworker corretto
    SELECT DISTINCT workerName AS worker_name, idworker_staging AS source_worker_id
    FROM "10_stg".forecast
    UNION
    SELECT DISTINCT workerName AS worker_name, idworker_staging AS source_worker_id
    FROM "10_stg".actuals
) t;

TRUNCATE TABLE "20_dim".internal_sales;

INSERT INTO "20_dim".internal_sales(internal_sales_id, internal_sales, branch_name)
SELECT
    DENSE_RANK() OVER (ORDER BY internal_sales, branch_name) AS internal_sales_id,
    internal_sales,
    branch_name
FROM (
    SELECT DISTINCT internalsales AS internal_sales, branch AS branch_name
    FROM "00_raw".forecast
    UNION
    SELECT DISTINCT internalsales AS internal_sales, branch AS branch_name
    FROM "00_raw".actuals
) t;

SELECT * FROM "20_dim".branch;
SELECT * FROM "20_dim".clients;
SELECT * FROM "20_dim".workers;
SELECT * FROM "20_dim".internal_sales;