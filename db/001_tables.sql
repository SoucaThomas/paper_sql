USE paper_sql;
GO

-- Player accounts
IF OBJECT_ID('data.Players') IS NULL
CREATE TABLE data.Players (
    Id               INT IDENTITY(1, 1) NOT NULL CONSTRAINT PK_Players PRIMARY KEY,
    Username         NVARCHAR(32)  NOT NULL CONSTRAINT UQ_Players_Username UNIQUE,
    PasswordHash     VARBINARY(64) NOT NULL,              -- SHA2_512 = 64 bytes
    Salt             VARBINARY(16) NOT NULL,
    Iterations       INT           NOT NULL,
    CreatedAt        DATETIME2(3)  NOT NULL CONSTRAINT DF_Players_CreatedAt DEFAULT SYSUTCDATETIME(),
    IsBanned         BIT           NOT NULL CONSTRAINT DF_Players_IsBanned DEFAULT 0,
    GamesPlayed      INT           NOT NULL CONSTRAINT DF_Players_GamesPlayed DEFAULT 0,
    Wins             INT           NOT NULL CONSTRAINT DF_Players_Wins DEFAULT 0,
    Kills            INT           NOT NULL CONSTRAINT DF_Players_Kills DEFAULT 0,
    Deaths           INT           NOT NULL CONSTRAINT DF_Players_Deaths DEFAULT 0,
    BestTerritoryPct DECIMAL(5, 2) NOT NULL CONSTRAINT DF_Players_BestTerritoryPct DEFAULT 0,

    CONSTRAINT CK_Players_Username CHECK (
        LEN(Username) BETWEEN 3 AND 32
        AND Username NOT LIKE '%[^a-zA-Z0-9_]%'           -- only letters, digits, underscore
    ),
    CONSTRAINT CK_Players_Iterations CHECK (Iterations > 0)
);
GO

IF OBJECT_ID('data.Sessions') IS NULL
CREATE TABLE data.Sessions (
    TokenHash  VARBINARY(32) NOT NULL CONSTRAINT PK_Sessions PRIMARY KEY,
    PlayerId   INT           NOT NULL,
    CreatedAt  DATETIME2(3)  NOT NULL CONSTRAINT DF_Sessions_CreatedAt DEFAULT SYSUTCDATETIME(),
    LastSeenAt DATETIME2(3)  NOT NULL CONSTRAINT DF_Sessions_LastSeenAt DEFAULT SYSUTCDATETIME(),
    ExpiresAt  DATETIME2(3)  NOT NULL,
    Ip         VARCHAR(45)   NULL,                        -- 45 chars fits IPv6

    CONSTRAINT FK_Sessions_Players FOREIGN KEY (PlayerId)
        REFERENCES data.Players (Id) ON DELETE CASCADE,
    CONSTRAINT CK_Sessions_Expiry CHECK (ExpiresAt > CreatedAt)
);
GO

-- "All sessions of player X" (logout everywhere) and expired-session cleanup.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Sessions_PlayerId')
    CREATE INDEX IX_Sessions_PlayerId ON data.Sessions (PlayerId);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Sessions_ExpiresAt')
    CREATE INDEX IX_Sessions_ExpiresAt ON data.Sessions (ExpiresAt);
GO
