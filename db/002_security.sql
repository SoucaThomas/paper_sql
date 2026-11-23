-- $(GAME_API_PASSWORD) is replaced by scripts/migrate.ts
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'game_api')
    CREATE LOGIN game_api WITH PASSWORD = '$(GAME_API_PASSWORD)', CHECK_POLICY = OFF;
ELSE
    -- keep the login in sync with .env when the password changes
    ALTER LOGIN game_api WITH PASSWORD = '$(GAME_API_PASSWORD)';
GO

USE paper_sql;
GO

IF USER_ID('game_api') IS NULL
    CREATE USER game_api FOR LOGIN game_api WITH DEFAULT_SCHEMA = api;

IF DATABASE_PRINCIPAL_ID('api_caller') IS NULL
    CREATE ROLE api_caller;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members rm
    WHERE rm.role_principal_id = DATABASE_PRINCIPAL_ID('api_caller')
      AND rm.member_principal_id = USER_ID('game_api')
)
    ALTER ROLE api_caller ADD MEMBER game_api;
GO

GRANT EXECUTE, SELECT ON SCHEMA::api TO api_caller;          -- SELECT so api views work too
DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::data TO api_caller;
GO
