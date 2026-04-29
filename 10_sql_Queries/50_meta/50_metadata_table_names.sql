CREATE TABLE "50_metadata".table_columns (
    table_schema text,
    table_name text,
    column_name text,
    data_type text,
    is_nullable text,
    column_default text,
    ordinal_position int
);

-- forecast
INSERT INTO "50_metadata".table_columns
SELECT table_schema, table_name, column_name, data_type, is_nullable, column_default, ordinal_position
FROM information_schema.columns
WHERE table_schema = '10_stg' AND table_name = 'forecast';

-- actuals
INSERT INTO "50_metadata".table_columns
SELECT table_schema, table_name, column_name, data_type, is_nullable, column_default, ordinal_position
FROM information_schema.columns
WHERE table_schema = '10_stg' AND table_name = 'actuals';

-- branch dimension
INSERT INTO "50_metadata".table_columns
SELECT table_schema, table_name, column_name, data_type, is_nullable, column_default, ordinal_position
FROM information_schema.columns
WHERE table_schema = '20_dim' AND table_name = 'branch';

SELECT * FROM "50_metadata".table_columns;