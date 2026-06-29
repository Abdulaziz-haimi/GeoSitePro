USE GeoSitePro;
GO

/* Sprint 10: Real data exchange/export logging. */

IF OBJECT_ID(N'dbo.DataExportJobs', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DataExportJobs
    (
        ExportJobId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DataExportJobs PRIMARY KEY,
        ProjectId BIGINT NOT NULL,
        DatasetCode NVARCHAR(100) NOT NULL,
        ExportFormat NVARCHAR(30) NOT NULL CONSTRAINT DF_DataExportJobs_ExportFormat DEFAULT(N'CSV'),
        FileName NVARCHAR(300) NULL,
        RowCount INT NULL,
        Status NVARCHAR(50) NOT NULL CONSTRAINT DF_DataExportJobs_Status DEFAULT(N'Completed'),
        RequestedBy BIGINT NULL,
        RequestedAt DATETIME2 NOT NULL CONSTRAINT DF_DataExportJobs_RequestedAt DEFAULT(SYSDATETIME()),
        CompletedAt DATETIME2 NULL,
        Notes NVARCHAR(MAX) NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_DataExportJobs_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO

IF COL_LENGTH('dbo.DataExportJobs','ProjectId') IS NULL ALTER TABLE dbo.DataExportJobs ADD ProjectId BIGINT NULL;
IF COL_LENGTH('dbo.DataExportJobs','DatasetCode') IS NULL ALTER TABLE dbo.DataExportJobs ADD DatasetCode NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.DataExportJobs','ExportFormat') IS NULL ALTER TABLE dbo.DataExportJobs ADD ExportFormat NVARCHAR(30) NOT NULL CONSTRAINT DF_DataExportJobs_ExportFormat2 DEFAULT(N'CSV');
IF COL_LENGTH('dbo.DataExportJobs','FileName') IS NULL ALTER TABLE dbo.DataExportJobs ADD FileName NVARCHAR(300) NULL;
IF COL_LENGTH('dbo.DataExportJobs','RowCount') IS NULL ALTER TABLE dbo.DataExportJobs ADD RowCount INT NULL;
IF COL_LENGTH('dbo.DataExportJobs','Status') IS NULL ALTER TABLE dbo.DataExportJobs ADD Status NVARCHAR(50) NOT NULL CONSTRAINT DF_DataExportJobs_Status2 DEFAULT(N'Completed');
IF COL_LENGTH('dbo.DataExportJobs','RequestedBy') IS NULL ALTER TABLE dbo.DataExportJobs ADD RequestedBy BIGINT NULL;
IF COL_LENGTH('dbo.DataExportJobs','RequestedAt') IS NULL ALTER TABLE dbo.DataExportJobs ADD RequestedAt DATETIME2 NOT NULL CONSTRAINT DF_DataExportJobs_RequestedAt2 DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.DataExportJobs','CompletedAt') IS NULL ALTER TABLE dbo.DataExportJobs ADD CompletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.DataExportJobs','Notes') IS NULL ALTER TABLE dbo.DataExportJobs ADD Notes NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.DataExportJobs','IsDeleted') IS NULL ALTER TABLE dbo.DataExportJobs ADD IsDeleted BIT NOT NULL CONSTRAINT DF_DataExportJobs_IsDeleted2 DEFAULT(0);
IF COL_LENGTH('dbo.DataExportJobs','DeletedAt') IS NULL ALTER TABLE dbo.DataExportJobs ADD DeletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.DataExportJobs','DeletedBy') IS NULL ALTER TABLE dbo.DataExportJobs ADD DeletedBy BIGINT NULL;
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'IX_DataExportJobs_Project' AND object_id=OBJECT_ID(N'dbo.DataExportJobs'))
    CREATE INDEX IX_DataExportJobs_Project ON dbo.DataExportJobs(ProjectId, RequestedAt DESC) WHERE IsDeleted=0;
GO

PRINT N'Sprint 10 export tables created successfully.';
GO
