-- Table: 00_raw.actuals

-- DROP TABLE IF EXISTS "00_raw".actuals;

CREATE TABLE IF NOT EXISTS "00_raw".actuals
(
    idcontract text COLLATE pg_catalog."default",
    branch text COLLATE pg_catalog."default",
    client text COLLATE pg_catalog."default",
    workername text COLLATE pg_catalog."default",
    idworker text COLLATE pg_catalog."default",
    startdate text COLLATE pg_catalog."default",
    enddate text COLLATE pg_catalog."default",
    enddateactual text COLLATE pg_catalog."default",
    weeklyhours numeric,
    internalsales text COLLATE pg_catalog."default",
    monthlycost numeric,
    monthlyrevenue numeric,
    invoicemonth text COLLATE pg_catalog."default"
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS "00_raw".actuals
    OWNER to postgres;