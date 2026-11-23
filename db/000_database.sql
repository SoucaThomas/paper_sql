-- Database + schemas.
--   data = tables
--   api  = procs/views the app is allowed to EXECUTE
IF DB_ID('paper_sql') IS NULL
    CREATE DATABASE paper_sql;
GO

USE paper_sql;
GO

IF SCHEMA_ID('data') IS NULL
    EXEC('CREATE SCHEMA data AUTHORIZATION dbo');

IF SCHEMA_ID('api') IS NULL
    EXEC('CREATE SCHEMA api AUTHORIZATION dbo');
GO
