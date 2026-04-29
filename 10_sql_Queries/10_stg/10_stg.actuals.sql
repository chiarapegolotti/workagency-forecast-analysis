-- Table: 10_stg.actuals

-- DROP TABLE IF EXISTS "10_stg".actuals;

CREATE TABLE IF NOT EXISTS "10_stg".actuals
(
    idcontract text COLLATE pg_catalog."default" NOT NULL,
    branch text COLLATE pg_catalog."default",
    client text COLLATE pg_catalog."default",
    workername text COLLATE pg_catalog."default",
    idworker text COLLATE pg_catalog."default",
    start_date date,
    end_date date,
    end_date_actual date,
    end_date_final date,
    is_staff_leasing integer,
    weekly_hours integer,
    internalsales text COLLATE pg_catalog."default",
    monthly_cost numeric,
    monthly_revenue numeric,
    invoice_date date NOT NULL,
    invoice_year integer,
    invoice_month integer,
    flag_cost_anomaly integer,
    flag_revenue_anomaly integer,
    flag_start_in_month integer,
    flag_end_in_month integer,
    flag_active_in_month integer,
    CONSTRAINT actuals_pkey PRIMARY KEY (idcontract, invoice_date)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS "10_stg".actuals
    OWNER to postgres;