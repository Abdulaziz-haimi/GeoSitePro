USE GeoSitePro;
GO

/* Sprint 3: Laboratory test results linked to Samples, Boreholes, and Projects. */

IF OBJECT_ID(N'dbo.LabTestResults', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.LabTestResults
    (
        LabTestResultId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_LabTestResults PRIMARY KEY,
        ProjectId BIGINT NOT NULL,
        BoreholeId BIGINT NOT NULL,
        SampleId BIGINT NOT NULL,
        LabTestTypeId BIGINT NOT NULL,
        TestCode NVARCHAR(100) NULL,
        TestStandard NVARCHAR(150) NULL,
        TestDate DATE NULL,
        ResultStatusId BIGINT NULL,
        NumericValue DECIMAL(18,4) NULL,
        Unit NVARCHAR(50) NULL,
        ResultValue NVARCHAR(250) NULL,
        ResultText NVARCHAR(MAX) NULL,
        Technician NVARCHAR(200) NULL,
        ReviewedBy NVARCHAR(200) NULL,
        IsApproved BIT NOT NULL CONSTRAINT DF_LabTestResults_IsApproved DEFAULT(0),
        ApprovedAt DATETIME2 NULL,
        ApprovedBy BIGINT NULL,
        Remarks NVARCHAR(MAX) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_LabTestResults_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_LabTestResults_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL,
        CONSTRAINT FK_LabTestResults_Projects FOREIGN KEY(ProjectId) REFERENCES dbo.Projects(ProjectId),
        CONSTRAINT FK_LabTestResults_Boreholes FOREIGN KEY(BoreholeId) REFERENCES dbo.Boreholes(BoreholeId),
        CONSTRAINT FK_LabTestResults_Samples FOREIGN KEY(SampleId) REFERENCES dbo.Samples(SampleId),
        CONSTRAINT FK_LabTestResults_TestType FOREIGN KEY(LabTestTypeId) REFERENCES dbo.LookupItems(LookupItemId),
        CONSTRAINT FK_LabTestResults_Status FOREIGN KEY(ResultStatusId) REFERENCES dbo.LookupItems(LookupItemId)
    );
END
GO

IF COL_LENGTH('dbo.LabTestResults','ProjectId') IS NULL ALTER TABLE dbo.LabTestResults ADD ProjectId BIGINT NULL;
IF COL_LENGTH('dbo.LabTestResults','BoreholeId') IS NULL ALTER TABLE dbo.LabTestResults ADD BoreholeId BIGINT NULL;
IF COL_LENGTH('dbo.LabTestResults','SampleId') IS NULL ALTER TABLE dbo.LabTestResults ADD SampleId BIGINT NULL;
IF COL_LENGTH('dbo.LabTestResults','LabTestTypeId') IS NULL ALTER TABLE dbo.LabTestResults ADD LabTestTypeId BIGINT NULL;
IF COL_LENGTH('dbo.LabTestResults','TestCode') IS NULL ALTER TABLE dbo.LabTestResults ADD TestCode NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.LabTestResults','TestStandard') IS NULL ALTER TABLE dbo.LabTestResults ADD TestStandard NVARCHAR(150) NULL;
IF COL_LENGTH('dbo.LabTestResults','TestDate') IS NULL ALTER TABLE dbo.LabTestResults ADD TestDate DATE NULL;
IF COL_LENGTH('dbo.LabTestResults','ResultStatusId') IS NULL ALTER TABLE dbo.LabTestResults ADD ResultStatusId BIGINT NULL;
IF COL_LENGTH('dbo.LabTestResults','NumericValue') IS NULL ALTER TABLE dbo.LabTestResults ADD NumericValue DECIMAL(18,4) NULL;
IF COL_LENGTH('dbo.LabTestResults','Unit') IS NULL ALTER TABLE dbo.LabTestResults ADD Unit NVARCHAR(50) NULL;
IF COL_LENGTH('dbo.LabTestResults','ResultValue') IS NULL ALTER TABLE dbo.LabTestResults ADD ResultValue NVARCHAR(250) NULL;
IF COL_LENGTH('dbo.LabTestResults','ResultText') IS NULL ALTER TABLE dbo.LabTestResults ADD ResultText NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.LabTestResults','Technician') IS NULL ALTER TABLE dbo.LabTestResults ADD Technician NVARCHAR(200) NULL;
IF COL_LENGTH('dbo.LabTestResults','ReviewedBy') IS NULL ALTER TABLE dbo.LabTestResults ADD ReviewedBy NVARCHAR(200) NULL;
IF COL_LENGTH('dbo.LabTestResults','IsApproved') IS NULL ALTER TABLE dbo.LabTestResults ADD IsApproved BIT NOT NULL CONSTRAINT DF_LabTestResults_IsApproved_Compat DEFAULT(0);
IF COL_LENGTH('dbo.LabTestResults','ApprovedAt') IS NULL ALTER TABLE dbo.LabTestResults ADD ApprovedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.LabTestResults','ApprovedBy') IS NULL ALTER TABLE dbo.LabTestResults ADD ApprovedBy BIGINT NULL;
IF COL_LENGTH('dbo.LabTestResults','Remarks') IS NULL ALTER TABLE dbo.LabTestResults ADD Remarks NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.LabTestResults','CreatedAt') IS NULL ALTER TABLE dbo.LabTestResults ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_LabTestResults_CreatedAt_Compat DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.LabTestResults','CreatedBy') IS NULL ALTER TABLE dbo.LabTestResults ADD CreatedBy BIGINT NULL;
IF COL_LENGTH('dbo.LabTestResults','UpdatedAt') IS NULL ALTER TABLE dbo.LabTestResults ADD UpdatedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.LabTestResults','UpdatedBy') IS NULL ALTER TABLE dbo.LabTestResults ADD UpdatedBy BIGINT NULL;
IF COL_LENGTH('dbo.LabTestResults','IsDeleted') IS NULL ALTER TABLE dbo.LabTestResults ADD IsDeleted BIT NOT NULL CONSTRAINT DF_LabTestResults_IsDeleted_Compat DEFAULT(0);
IF COL_LENGTH('dbo.LabTestResults','DeletedAt') IS NULL ALTER TABLE dbo.LabTestResults ADD DeletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.LabTestResults','DeletedBy') IS NULL ALTER TABLE dbo.LabTestResults ADD DeletedBy BIGINT NULL;
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name = N'IX_LabTestResults_Sample' AND object_id = OBJECT_ID(N'dbo.LabTestResults'))
CREATE INDEX IX_LabTestResults_Sample ON dbo.LabTestResults(SampleId, LabTestTypeId) WHERE IsDeleted = 0;
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name = N'IX_LabTestResults_Project' AND object_id = OBJECT_ID(N'dbo.LabTestResults'))
CREATE INDEX IX_LabTestResults_Project ON dbo.LabTestResults(ProjectId, BoreholeId, SampleId) WHERE IsDeleted = 0;
GO

PRINT N'Sprint 3 lab results table created successfully.';
GO
