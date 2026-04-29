CREATE TABLE "40_audit".data_quality_log (
    run_timestamp TIMESTAMP,
    table_name TEXT,
    check_name TEXT,
    reference_date TEXT,
    metric_value INT
);

INSERT INTO "40_audit".data_quality_log
SELECT 
    NOW(),
    'forecast',
    'grain_violations',
    SnapshotDate,
    COUNT(*)
FROM (
    SELECT idContract, SnapshotDate
    FROM "00_raw".forecast
    GROUP BY idContract, SnapshotDate
    HAVING COUNT(*) > 1
) t
GROUP BY SnapshotDate;

INSERT INTO "40_audit".data_quality_log
SELECT 
    NOW(),
    'forecast',
    'volume',
    SnapshotDate,
    COUNT(*)
FROM "00_raw".forecast
GROUP BY SnapshotDate;

INSERT INTO "40_audit".data_quality_log
SELECT 
    NOW(),
    'actuals',
    'grain_violations',
    InvoiceMonth,
    COUNT(*)
FROM (
    SELECT idContract, InvoiceMonth
    FROM "00_raw".actuals
    GROUP BY idContract, InvoiceMonth
    HAVING COUNT(*) > 1
) t
GROUP BY InvoiceMonth;

INSERT INTO "40_audit".data_quality_log
SELECT 
    NOW(),
    'actuals',
    'staff_leasing_rows',
    InvoiceMonth,
    COUNT(*)
FROM "00_raw".actuals
WHERE (endDate IS NULL OR trim(endDate) = '') 
  AND (endDateActual IS NULL OR trim(endDateActual) = '')
GROUP BY InvoiceMonth;

INSERT INTO "40_audit".data_quality_log
SELECT 
    NOW(),
    'actuals',
    'cost_anomalies',
    InvoiceMonth,
    COUNT(*)
FROM "00_raw".actuals
WHERE monthlyCost <= 0
GROUP BY InvoiceMonth;

INSERT INTO "40_audit".data_quality_log
SELECT 
    NOW(),
    'actuals',
    'revenue_anomalies',
    InvoiceMonth,
    COUNT(*)
FROM "00_raw".actuals
WHERE monthlyRevenue <= 0
GROUP BY InvoiceMonth;