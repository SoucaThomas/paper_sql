USE paper_sql;
GO

-- Smoke test for the permission model: game_api can't SELECT data.Players,
-- but can EXEC this proc, which reads it via ownership chaining.
CREATE OR ALTER PROCEDURE api.Ping
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SYSUTCDATETIME()  AS ServerTime,
        ORIGINAL_LOGIN()  AS LoginName,
        (SELECT COUNT(*) FROM data.Players) AS PlayerCount
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END;
GO
