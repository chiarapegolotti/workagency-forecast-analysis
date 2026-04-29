-- Table: 50_metadata.raw_metadata

-- DROP TABLE IF EXISTS "50_metadata".raw_metadata;

CREATE TABLE IF NOT EXISTS "50_metadata".raw_metadata
(
    table_name text COLLATE pg_catalog."default",
    grain text COLLATE pg_catalog."default",
    description text COLLATE pg_catalog."default"
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS "50_metadata".raw_metadata
    OWNER to postgres;