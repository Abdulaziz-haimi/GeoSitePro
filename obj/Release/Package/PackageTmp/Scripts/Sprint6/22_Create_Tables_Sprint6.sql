USE GeoSitePro;
GO

/* Sprint 6: Standards compliance, QA/QC, and engineering calculations. Safe compatibility script. */

/* Audit log compatibility columns used by Sprint 6/7 procedures. */
IF OBJECT_ID(N'dbo.AuditLogs', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.AuditLogs','OldValues') IS NULL ALTER TABLE dbo.AuditLogs ADD OldValues NVARCHAR(MAX) NULL;
    IF COL_LENGTH('dbo.AuditLogs','NewValues') IS NULL ALTER TABLE dbo.AuditLogs ADD NewValues NVARCHAR(MAX) NULL;
END
GO


IF OBJECT_ID(N'dbo.Standards', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Standards
    (
        StandardId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Standards PRIMARY KEY,
        StandardCode NVARCHAR(100) NOT NULL,
        StandardTitle NVARCHAR(500) NOT NULL,
        Organization NVARCHAR(100) NULL,
        CategoryId BIGINT NULL,
        VersionYear INT NULL,
        StandardType NVARCHAR(100) NULL,
        ScopeSummary NVARCHAR(MAX) NULL,
        Remarks NVARCHAR(MAX) NULL,
        IsActive BIT NOT NULL CONSTRAINT DF_Standards_IsActive DEFAULT(1),
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Standards_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_Standards_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO
IF COL_LENGTH('dbo.Standards','StandardCode') IS NULL ALTER TABLE dbo.Standards ADD StandardCode NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.Standards','StandardTitle') IS NULL ALTER TABLE dbo.Standards ADD StandardTitle NVARCHAR(500) NULL;
IF COL_LENGTH('dbo.Standards','Organization') IS NULL ALTER TABLE dbo.Standards ADD Organization NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.Standards','CategoryId') IS NULL ALTER TABLE dbo.Standards ADD CategoryId BIGINT NULL;
IF COL_LENGTH('dbo.Standards','VersionYear') IS NULL ALTER TABLE dbo.Standards ADD VersionYear INT NULL;
IF COL_LENGTH('dbo.Standards','StandardType') IS NULL ALTER TABLE dbo.Standards ADD StandardType NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.Standards','ScopeSummary') IS NULL ALTER TABLE dbo.Standards ADD ScopeSummary NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.Standards','Remarks') IS NULL ALTER TABLE dbo.Standards ADD Remarks NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.Standards','IsActive') IS NULL ALTER TABLE dbo.Standards ADD IsActive BIT NOT NULL CONSTRAINT DF_Standards_IsActive2 DEFAULT(1);
IF COL_LENGTH('dbo.Standards','CreatedAt') IS NULL ALTER TABLE dbo.Standards ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Standards_CreatedAt2 DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.Standards','CreatedBy') IS NULL ALTER TABLE dbo.Standards ADD CreatedBy BIGINT NULL;
IF COL_LENGTH('dbo.Standards','UpdatedAt') IS NULL ALTER TABLE dbo.Standards ADD UpdatedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.Standards','UpdatedBy') IS NULL ALTER TABLE dbo.Standards ADD UpdatedBy BIGINT NULL;
IF COL_LENGTH('dbo.Standards','IsDeleted') IS NULL ALTER TABLE dbo.Standards ADD IsDeleted BIT NOT NULL CONSTRAINT DF_Standards_IsDeleted2 DEFAULT(0);
IF COL_LENGTH('dbo.Standards','DeletedAt') IS NULL ALTER TABLE dbo.Standards ADD DeletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.Standards','DeletedBy') IS NULL ALTER TABLE dbo.Standards ADD DeletedBy BIGINT NULL;
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'UX_Standards_Code' AND object_id=OBJECT_ID(N'dbo.Standards'))
    CREATE UNIQUE INDEX UX_Standards_Code ON dbo.Standards(StandardCode) WHERE IsDeleted=0;
GO

IF OBJECT_ID(N'dbo.ProjectQualityChecks', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProjectQualityChecks
    (
        QualityCheckId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ProjectQualityChecks PRIMARY KEY,
        ProjectId BIGINT NOT NULL,
        CheckAreaId BIGINT NULL,
        ChecklistItem NVARCHAR(1000) NOT NULL,
        RequirementReference NVARCHAR(300) NULL,
        SeverityId BIGINT NULL,
        StatusId BIGINT NULL,
        ResponsiblePerson NVARCHAR(200) NULL,
        DueDate DATE NULL,
        ClosedDate DATE NULL,
        EvidenceText NVARCHAR(MAX) NULL,
        CorrectiveAction NVARCHAR(MAX) NULL,
        Remarks NVARCHAR(MAX) NULL,
        IsApproved BIT NOT NULL CONSTRAINT DF_ProjectQualityChecks_IsApproved DEFAULT(0),
        ApprovedAt DATETIME2 NULL,
        ApprovedBy BIGINT NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectQualityChecks_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_ProjectQualityChecks_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO
IF COL_LENGTH('dbo.ProjectQualityChecks','ProjectId') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD ProjectId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectQualityChecks','CheckAreaId') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD CheckAreaId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectQualityChecks','ChecklistItem') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD ChecklistItem NVARCHAR(1000) NULL;
IF COL_LENGTH('dbo.ProjectQualityChecks','RequirementReference') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD RequirementReference NVARCHAR(300) NULL;
IF COL_LENGTH('dbo.ProjectQualityChecks','SeverityId') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD SeverityId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectQualityChecks','StatusId') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD StatusId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectQualityChecks','ResponsiblePerson') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD ResponsiblePerson NVARCHAR(200) NULL;
IF COL_LENGTH('dbo.ProjectQualityChecks','DueDate') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD DueDate DATE NULL;
IF COL_LENGTH('dbo.ProjectQualityChecks','ClosedDate') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD ClosedDate DATE NULL;
IF COL_LENGTH('dbo.ProjectQualityChecks','EvidenceText') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD EvidenceText NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.ProjectQualityChecks','CorrectiveAction') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD CorrectiveAction NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.ProjectQualityChecks','Remarks') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD Remarks NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.ProjectQualityChecks','IsApproved') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD IsApproved BIT NOT NULL CONSTRAINT DF_ProjectQualityChecks_IsApproved2 DEFAULT(0);
IF COL_LENGTH('dbo.ProjectQualityChecks','ApprovedAt') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD ApprovedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ProjectQualityChecks','ApprovedBy') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD ApprovedBy BIGINT NULL;
IF COL_LENGTH('dbo.ProjectQualityChecks','CreatedAt') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectQualityChecks_CreatedAt2 DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.ProjectQualityChecks','CreatedBy') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD CreatedBy BIGINT NULL;
IF COL_LENGTH('dbo.ProjectQualityChecks','UpdatedAt') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD UpdatedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ProjectQualityChecks','UpdatedBy') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD UpdatedBy BIGINT NULL;
IF COL_LENGTH('dbo.ProjectQualityChecks','IsDeleted') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD IsDeleted BIT NOT NULL CONSTRAINT DF_ProjectQualityChecks_IsDeleted2 DEFAULT(0);
IF COL_LENGTH('dbo.ProjectQualityChecks','DeletedAt') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD DeletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ProjectQualityChecks','DeletedBy') IS NULL ALTER TABLE dbo.ProjectQualityChecks ADD DeletedBy BIGINT NULL;
GO

IF OBJECT_ID(N'dbo.EngineeringCalculations', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.EngineeringCalculations
    (
        CalculationId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_EngineeringCalculations PRIMARY KEY,
        ProjectId BIGINT NOT NULL,
        CalculationTypeId BIGINT NOT NULL,
        CalculationDate DATE NULL,
        CalculationTitle NVARCHAR(300) NULL,
        Input1 DECIMAL(18,6) NULL,
        Input2 DECIMAL(18,6) NULL,
        Input3 DECIMAL(18,6) NULL,
        Input4 DECIMAL(18,6) NULL,
        Input5 DECIMAL(18,6) NULL,
        Input6 DECIMAL(18,6) NULL,
        Result1 DECIMAL(18,6) NULL,
        Result2 DECIMAL(18,6) NULL,
        Result3 DECIMAL(18,6) NULL,
        Unit NVARCHAR(50) NULL,
        ResultSummary NVARCHAR(MAX) NULL,
        CalculatedBy NVARCHAR(200) NULL,
        CheckedBy NVARCHAR(200) NULL,
        IsApproved BIT NOT NULL CONSTRAINT DF_EngineeringCalculations_IsApproved DEFAULT(0),
        ApprovedAt DATETIME2 NULL,
        ApprovedBy BIGINT NULL,
        Notes NVARCHAR(MAX) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_EngineeringCalculations_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_EngineeringCalculations_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO
IF COL_LENGTH('dbo.EngineeringCalculations','ProjectId') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD ProjectId BIGINT NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','CalculationTypeId') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD CalculationTypeId BIGINT NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','CalculationDate') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD CalculationDate DATE NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','CalculationTitle') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD CalculationTitle NVARCHAR(300) NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','Input1') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD Input1 DECIMAL(18,6) NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','Input2') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD Input2 DECIMAL(18,6) NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','Input3') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD Input3 DECIMAL(18,6) NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','Input4') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD Input4 DECIMAL(18,6) NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','Input5') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD Input5 DECIMAL(18,6) NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','Input6') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD Input6 DECIMAL(18,6) NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','Result1') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD Result1 DECIMAL(18,6) NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','Result2') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD Result2 DECIMAL(18,6) NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','Result3') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD Result3 DECIMAL(18,6) NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','Unit') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD Unit NVARCHAR(50) NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','ResultSummary') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD ResultSummary NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','CalculatedBy') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD CalculatedBy NVARCHAR(200) NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','CheckedBy') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD CheckedBy NVARCHAR(200) NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','IsApproved') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD IsApproved BIT NOT NULL CONSTRAINT DF_EngineeringCalculations_IsApproved2 DEFAULT(0);
IF COL_LENGTH('dbo.EngineeringCalculations','ApprovedAt') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD ApprovedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','ApprovedBy') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD ApprovedBy BIGINT NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','Notes') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD Notes NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','CreatedAt') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_EngineeringCalculations_CreatedAt2 DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.EngineeringCalculations','CreatedBy') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD CreatedBy BIGINT NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','UpdatedAt') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD UpdatedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','UpdatedBy') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD UpdatedBy BIGINT NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','IsDeleted') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD IsDeleted BIT NOT NULL CONSTRAINT DF_EngineeringCalculations_IsDeleted2 DEFAULT(0);
IF COL_LENGTH('dbo.EngineeringCalculations','DeletedAt') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD DeletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.EngineeringCalculations','DeletedBy') IS NULL ALTER TABLE dbo.EngineeringCalculations ADD DeletedBy BIGINT NULL;
GO

/* Professional field extensions for already-created Sprint 2 tables. */
IF OBJECT_ID(N'dbo.Boreholes', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Boreholes','RigType') IS NULL ALTER TABLE dbo.Boreholes ADD RigType NVARCHAR(150) NULL;
    IF COL_LENGTH('dbo.Boreholes','BoreholeDiameterMm') IS NULL ALTER TABLE dbo.Boreholes ADD BoreholeDiameterMm DECIMAL(10,2) NULL;
    IF COL_LENGTH('dbo.Boreholes','CasingDepthM') IS NULL ALTER TABLE dbo.Boreholes ADD CasingDepthM DECIMAL(10,2) NULL;
    IF COL_LENGTH('dbo.Boreholes','CoordinateSystem') IS NULL ALTER TABLE dbo.Boreholes ADD CoordinateSystem NVARCHAR(100) NULL;
    IF COL_LENGTH('dbo.Boreholes','LogPreparedBy') IS NULL ALTER TABLE dbo.Boreholes ADD LogPreparedBy NVARCHAR(200) NULL;
    IF COL_LENGTH('dbo.Boreholes','LogCheckedBy') IS NULL ALTER TABLE dbo.Boreholes ADD LogCheckedBy NVARCHAR(200) NULL;
END
GO
IF OBJECT_ID(N'dbo.Samples', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Samples','SamplerType') IS NULL ALTER TABLE dbo.Samples ADD SamplerType NVARCHAR(150) NULL;
    IF COL_LENGTH('dbo.Samples','TubeDiameterMm') IS NULL ALTER TABLE dbo.Samples ADD TubeDiameterMm DECIMAL(10,2) NULL;
    IF COL_LENGTH('dbo.Samples','SealedBy') IS NULL ALTER TABLE dbo.Samples ADD SealedBy NVARCHAR(200) NULL;
    IF COL_LENGTH('dbo.Samples','TransportCondition') IS NULL ALTER TABLE dbo.Samples ADD TransportCondition NVARCHAR(300) NULL;
    IF COL_LENGTH('dbo.Samples','ReceivedByLab') IS NULL ALTER TABLE dbo.Samples ADD ReceivedByLab NVARCHAR(200) NULL;
    IF COL_LENGTH('dbo.Samples','ReceivedAtLab') IS NULL ALTER TABLE dbo.Samples ADD ReceivedAtLab DATETIME2 NULL;
    IF COL_LENGTH('dbo.Samples','ChainOfCustodyNo') IS NULL ALTER TABLE dbo.Samples ADD ChainOfCustodyNo NVARCHAR(100) NULL;
END
GO
IF OBJECT_ID(N'dbo.SPTTests', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.SPTTests','HammerType') IS NULL ALTER TABLE dbo.SPTTests ADD HammerType NVARCHAR(150) NULL;
    IF COL_LENGTH('dbo.SPTTests','RodLengthM') IS NULL ALTER TABLE dbo.SPTTests ADD RodLengthM DECIMAL(10,2) NULL;
    IF COL_LENGTH('dbo.SPTTests','BoreholeDiameterMm') IS NULL ALTER TABLE dbo.SPTTests ADD BoreholeDiameterMm DECIMAL(10,2) NULL;
    IF COL_LENGTH('dbo.SPTTests','SamplerCorrection') IS NULL ALTER TABLE dbo.SPTTests ADD SamplerCorrection DECIMAL(10,3) NULL;
    IF COL_LENGTH('dbo.SPTTests','RodCorrection') IS NULL ALTER TABLE dbo.SPTTests ADD RodCorrection DECIMAL(10,3) NULL;
    IF COL_LENGTH('dbo.SPTTests','BoreholeCorrection') IS NULL ALTER TABLE dbo.SPTTests ADD BoreholeCorrection DECIMAL(10,3) NULL;
    IF COL_LENGTH('dbo.SPTTests','N60') IS NULL ALTER TABLE dbo.SPTTests ADD N60 DECIMAL(10,2) NULL;
END
GO

PRINT N'Sprint 6 tables and compatibility columns created successfully.';
GO
