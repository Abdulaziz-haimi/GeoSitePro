USE GeoSitePro;
GO

IF OBJECT_ID(N'dbo.SeqBackupJobCode', N'SO') IS NULL
    EXEC('CREATE SEQUENCE dbo.SeqBackupJobCode AS BIGINT START WITH 1 INCREMENT BY 1');
GO

IF OBJECT_ID(N'dbo.SystemSettings', N'U') IS NULL
BEGIN
CREATE TABLE dbo.SystemSettings
(
    SettingId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_SystemSettings PRIMARY KEY,
    Category NVARCHAR(80) NOT NULL CONSTRAINT DF_SystemSettings_Category DEFAULT(N'General'),
    SettingKey NVARCHAR(150) NOT NULL,
    SettingValue NVARCHAR(MAX) NULL,
    DataType NVARCHAR(30) NOT NULL CONSTRAINT DF_SystemSettings_DataType DEFAULT(N'Text'),
    Description NVARCHAR(500) NULL,
    IsEncrypted BIT NOT NULL CONSTRAINT DF_SystemSettings_IsEncrypted DEFAULT(0),
    IsActive BIT NOT NULL CONSTRAINT DF_SystemSettings_IsActive DEFAULT(1),
    IsDeleted BIT NOT NULL CONSTRAINT DF_SystemSettings_IsDeleted DEFAULT(0),
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_SystemSettings_CreatedAt DEFAULT(SYSDATETIME()),
    CreatedBy BIGINT NULL,
    UpdatedAt DATETIME2 NULL,
    UpdatedBy BIGINT NULL,
    DeletedAt DATETIME2 NULL,
    DeletedBy BIGINT NULL
);
CREATE UNIQUE INDEX UX_SystemSettings_Key ON dbo.SystemSettings(SettingKey) WHERE IsDeleted = 0;
CREATE INDEX IX_SystemSettings_Category ON dbo.SystemSettings(Category, IsActive, IsDeleted);
END
GO

IF OBJECT_ID(N'dbo.SystemBackupJobs', N'U') IS NULL
BEGIN
CREATE TABLE dbo.SystemBackupJobs
(
    BackupJobId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_SystemBackupJobs PRIMARY KEY,
    BackupCode NVARCHAR(80) NOT NULL,
    BackupType NVARCHAR(40) NOT NULL CONSTRAINT DF_SystemBackupJobs_Type DEFAULT(N'FULL'),
    BackupPath NVARCHAR(500) NOT NULL,
    BackupCommand NVARCHAR(MAX) NULL,
    Description NVARCHAR(1000) NULL,
    Status NVARCHAR(30) NOT NULL CONSTRAINT DF_SystemBackupJobs_Status DEFAULT(N'Requested'),
    RequestedBy BIGINT NULL,
    RequestedAt DATETIME2 NOT NULL CONSTRAINT DF_SystemBackupJobs_RequestedAt DEFAULT(SYSDATETIME()),
    StartedAt DATETIME2 NULL,
    CompletedAt DATETIME2 NULL,
    ResultMessage NVARCHAR(MAX) NULL,
    IsDeleted BIT NOT NULL CONSTRAINT DF_SystemBackupJobs_IsDeleted DEFAULT(0),
    DeletedAt DATETIME2 NULL,
    DeletedBy BIGINT NULL
);
CREATE UNIQUE INDEX UX_SystemBackupJobs_Code ON dbo.SystemBackupJobs(BackupCode) WHERE IsDeleted = 0;
CREATE INDEX IX_SystemBackupJobs_Status ON dbo.SystemBackupJobs(Status, RequestedAt DESC) WHERE IsDeleted = 0;
END
GO

IF OBJECT_ID(N'dbo.SystemOperationLogs', N'U') IS NULL
BEGIN
CREATE TABLE dbo.SystemOperationLogs
(
    SystemLogId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_SystemOperationLogs PRIMARY KEY,
    LogLevel NVARCHAR(30) NOT NULL CONSTRAINT DF_SystemOperationLogs_Level DEFAULT(N'Info'),
    ModuleName NVARCHAR(100) NOT NULL,
    ActionName NVARCHAR(150) NOT NULL,
    EntityName NVARCHAR(100) NULL,
    EntityId BIGINT NULL,
    Message NVARCHAR(500) NOT NULL,
    Details NVARCHAR(MAX) NULL,
    UserId BIGINT NULL,
    ClientIp NVARCHAR(80) NULL,
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_SystemOperationLogs_CreatedAt DEFAULT(SYSDATETIME())
);
CREATE INDEX IX_SystemOperationLogs_Date ON dbo.SystemOperationLogs(CreatedAt DESC);
CREATE INDEX IX_SystemOperationLogs_Module ON dbo.SystemOperationLogs(ModuleName, LogLevel, CreatedAt DESC);
END
GO

DECLARE @DefaultSettings TABLE(Category NVARCHAR(80), SettingKey NVARCHAR(150), SettingValue NVARCHAR(MAX), DataType NVARCHAR(30), Description NVARCHAR(500));
INSERT INTO @DefaultSettings VALUES
(N'Backup', N'Backup.DefaultPath', N'C:\GeoSiteProBackups', N'Text', N'Default SQL Server backup folder.'),
(N'Backup', N'Backup.RetentionDays', N'30', N'Number', N'Number of days to keep backup records.'),
(N'Reporting', N'Reports.DefaultCompanyName', N'GeoSite Pro', N'Text', N'Default company name for printed outputs.'),
(N'Quality', N'Quality.MinimumScoreForApproval', N'70', N'Number', N'Minimum KPI score suggested before final approval.'),
(N'Security', N'Security.SessionTimeoutMinutes', N'60', N'Number', N'Logical session timeout policy.'),
(N'GISCAD', N'GIS.DefaultCoordinateSystem', N'WGS 84 / UTM', N'Text', N'Default coordinate system label.'),
(N'Workflow', N'Workflow.AllowApprovalWithoutKpi', N'false', N'Boolean', N'Controls whether approval can proceed without latest KPI snapshot.');

INSERT INTO dbo.SystemSettings(Category, SettingKey, SettingValue, DataType, Description, IsActive, IsDeleted, CreatedBy)
SELECT D.Category, D.SettingKey, D.SettingValue, D.DataType, D.Description, 1, 0, 1
FROM @DefaultSettings D
WHERE NOT EXISTS(SELECT 1 FROM dbo.SystemSettings S WHERE S.SettingKey = D.SettingKey AND S.IsDeleted = 0);
GO

PRINT N'Sprint 15 tables created successfully.';
GO
