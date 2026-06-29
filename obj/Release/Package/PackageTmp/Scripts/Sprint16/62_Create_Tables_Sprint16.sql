USE GeoSitePro;
GO

IF OBJECT_ID('dbo.SystemSecurityEvents','U') IS NULL
BEGIN
    CREATE TABLE dbo.SystemSecurityEvents
    (
        EventId BIGINT IDENTITY(1,1) PRIMARY KEY,
        EventType NVARCHAR(80) NOT NULL,
        Severity NVARCHAR(30) NOT NULL DEFAULT('Info'),
        UserId BIGINT NULL,
        Username NVARCHAR(150) NULL,
        IpAddress NVARCHAR(80) NULL,
        UserAgent NVARCHAR(500) NULL,
        EntityName NVARCHAR(120) NULL,
        EntityId BIGINT NULL,
        Message NVARCHAR(500) NOT NULL,
        Details NVARCHAR(MAX) NULL,
        CreatedAt DATETIME NOT NULL DEFAULT(GETDATE())
    );
END
GO

IF OBJECT_ID('dbo.PasswordPolicies','U') IS NULL
BEGIN
    CREATE TABLE dbo.PasswordPolicies
    (
        PolicyId BIGINT IDENTITY(1,1) PRIMARY KEY,
        MinLength INT NOT NULL DEFAULT(10),
        RequireUppercase BIT NOT NULL DEFAULT(1),
        RequireLowercase BIT NOT NULL DEFAULT(1),
        RequireNumber BIT NOT NULL DEFAULT(1),
        RequireSpecial BIT NOT NULL DEFAULT(1),
        ExpiryDays INT NOT NULL DEFAULT(90),
        MaxFailedAttempts INT NOT NULL DEFAULT(5),
        LockoutMinutes INT NOT NULL DEFAULT(15),
        SessionTimeoutMinutes INT NOT NULL DEFAULT(30),
        AllowRememberMe BIT NOT NULL DEFAULT(0),
        ForceChangeDefaultPassword BIT NOT NULL DEFAULT(1),
        IsActive BIT NOT NULL DEFAULT(1),
        CreatedAt DATETIME NOT NULL DEFAULT(GETDATE()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME NULL,
        UpdatedBy BIGINT NULL
    );
END
GO

IF OBJECT_ID('dbo.DeploymentChecklistItems','U') IS NULL
BEGIN
    CREATE TABLE dbo.DeploymentChecklistItems
    (
        ItemId BIGINT IDENTITY(1,1) PRIMARY KEY,
        Area NVARCHAR(80) NOT NULL,
        ItemCode NVARCHAR(80) NOT NULL,
        ItemTitle NVARCHAR(250) NOT NULL,
        Description NVARCHAR(MAX) NULL,
        RequiredForProduction BIT NOT NULL DEFAULT(1),
        Status NVARCHAR(40) NOT NULL DEFAULT('Not Started'),
        EvidenceNotes NVARCHAR(MAX) NULL,
        ResponsiblePerson NVARCHAR(150) NULL,
        CheckedAt DATETIME NULL,
        CheckedBy BIGINT NULL,
        SortOrder INT NOT NULL DEFAULT(0),
        IsActive BIT NOT NULL DEFAULT(1),
        CreatedAt DATETIME NOT NULL DEFAULT(GETDATE()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL DEFAULT(0)
    );
    CREATE UNIQUE INDEX UX_DeploymentChecklistItems_ItemCode ON dbo.DeploymentChecklistItems(ItemCode) WHERE IsDeleted = 0;
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.PasswordPolicies WHERE IsActive = 1)
BEGIN
    INSERT INTO dbo.PasswordPolicies
    (MinLength, RequireUppercase, RequireLowercase, RequireNumber, RequireSpecial, ExpiryDays, MaxFailedAttempts, LockoutMinutes, SessionTimeoutMinutes, AllowRememberMe, ForceChangeDefaultPassword, IsActive)
    VALUES (10,1,1,1,1,90,5,15,30,0,1,1);
END
GO

PRINT 'Sprint 16 security tables created successfully.';
GO
