USE GeoSitePro;
GO

/* Sprint 2: Boreholes, Borehole Layers, Samples, SPT Tests, Groundwater Observations */


IF OBJECT_ID(N'dbo.Reports', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Reports
    (
        ReportId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Reports PRIMARY KEY,
        ProjectId BIGINT NOT NULL,
        ReportTitle NVARCHAR(300) NULL,
        ReportStatus NVARCHAR(100) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Reports_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_Reports_IsDeleted DEFAULT(0),
        CONSTRAINT FK_Reports_Projects FOREIGN KEY(ProjectId) REFERENCES dbo.Projects(ProjectId)
    );
END
GO

IF OBJECT_ID(N'dbo.Boreholes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Boreholes
    (
        BoreholeId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Boreholes PRIMARY KEY,
        ProjectId BIGINT NOT NULL,
        BoreholeCode NVARCHAR(80) NOT NULL,
        PlannedDepthM DECIMAL(10,2) NULL,
        ActualDepthM DECIMAL(10,2) NOT NULL,
        Easting DECIMAL(18,3) NULL,
        Northing DECIMAL(18,3) NULL,
        ElevationM DECIMAL(10,3) NULL,
        DrillingMethodId BIGINT NULL,
        BoreholeStatusId BIGINT NULL,
        StartDate DATE NULL,
        EndDate DATE NULL,
        GroundwaterDepthM DECIMAL(10,2) NULL,
        LocationDescription NVARCHAR(500) NULL,
        FieldEngineer NVARCHAR(200) NULL,
        TerminationReason NVARCHAR(500) NULL,
        Notes NVARCHAR(MAX) NULL,
        IsActive BIT NOT NULL CONSTRAINT DF_Boreholes_IsActive DEFAULT(1),
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Boreholes_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_Boreholes_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL,
        CONSTRAINT FK_Boreholes_Projects FOREIGN KEY(ProjectId) REFERENCES dbo.Projects(ProjectId),
        CONSTRAINT FK_Boreholes_DrillingMethod FOREIGN KEY(DrillingMethodId) REFERENCES dbo.LookupItems(LookupItemId),
        CONSTRAINT FK_Boreholes_Status FOREIGN KEY(BoreholeStatusId) REFERENCES dbo.LookupItems(LookupItemId),
        CONSTRAINT CK_Boreholes_Depth CHECK(ActualDepthM > 0),
        CONSTRAINT CK_Boreholes_Dates CHECK(EndDate IS NULL OR StartDate IS NULL OR EndDate >= StartDate)
    );
END
GO

IF COL_LENGTH('dbo.Boreholes','BoreholeCode') IS NULL ALTER TABLE dbo.Boreholes ADD BoreholeCode NVARCHAR(80) NULL;
IF COL_LENGTH('dbo.Boreholes','PlannedDepthM') IS NULL ALTER TABLE dbo.Boreholes ADD PlannedDepthM DECIMAL(10,2) NULL;
IF COL_LENGTH('dbo.Boreholes','ActualDepthM') IS NULL ALTER TABLE dbo.Boreholes ADD ActualDepthM DECIMAL(10,2) NULL;
IF COL_LENGTH('dbo.Boreholes','Easting') IS NULL ALTER TABLE dbo.Boreholes ADD Easting DECIMAL(18,3) NULL;
IF COL_LENGTH('dbo.Boreholes','Northing') IS NULL ALTER TABLE dbo.Boreholes ADD Northing DECIMAL(18,3) NULL;
IF COL_LENGTH('dbo.Boreholes','ElevationM') IS NULL ALTER TABLE dbo.Boreholes ADD ElevationM DECIMAL(10,3) NULL;
IF COL_LENGTH('dbo.Boreholes','DrillingMethodId') IS NULL ALTER TABLE dbo.Boreholes ADD DrillingMethodId BIGINT NULL;
IF COL_LENGTH('dbo.Boreholes','BoreholeStatusId') IS NULL ALTER TABLE dbo.Boreholes ADD BoreholeStatusId BIGINT NULL;
IF COL_LENGTH('dbo.Boreholes','StartDate') IS NULL ALTER TABLE dbo.Boreholes ADD StartDate DATE NULL;
IF COL_LENGTH('dbo.Boreholes','EndDate') IS NULL ALTER TABLE dbo.Boreholes ADD EndDate DATE NULL;
IF COL_LENGTH('dbo.Boreholes','GroundwaterDepthM') IS NULL ALTER TABLE dbo.Boreholes ADD GroundwaterDepthM DECIMAL(10,2) NULL;
IF COL_LENGTH('dbo.Boreholes','LocationDescription') IS NULL ALTER TABLE dbo.Boreholes ADD LocationDescription NVARCHAR(500) NULL;
IF COL_LENGTH('dbo.Boreholes','FieldEngineer') IS NULL ALTER TABLE dbo.Boreholes ADD FieldEngineer NVARCHAR(200) NULL;
IF COL_LENGTH('dbo.Boreholes','TerminationReason') IS NULL ALTER TABLE dbo.Boreholes ADD TerminationReason NVARCHAR(500) NULL;
IF COL_LENGTH('dbo.Boreholes','Notes') IS NULL ALTER TABLE dbo.Boreholes ADD Notes NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.Boreholes','IsActive') IS NULL ALTER TABLE dbo.Boreholes ADD IsActive BIT NOT NULL CONSTRAINT DF_Boreholes_IsActive2 DEFAULT(1);
IF COL_LENGTH('dbo.Boreholes','CreatedAt') IS NULL ALTER TABLE dbo.Boreholes ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Boreholes_CreatedAt2 DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.Boreholes','CreatedBy') IS NULL ALTER TABLE dbo.Boreholes ADD CreatedBy BIGINT NULL;
IF COL_LENGTH('dbo.Boreholes','UpdatedAt') IS NULL ALTER TABLE dbo.Boreholes ADD UpdatedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.Boreholes','UpdatedBy') IS NULL ALTER TABLE dbo.Boreholes ADD UpdatedBy BIGINT NULL;
IF COL_LENGTH('dbo.Boreholes','DeletedAt') IS NULL ALTER TABLE dbo.Boreholes ADD DeletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.Boreholes','DeletedBy') IS NULL ALTER TABLE dbo.Boreholes ADD DeletedBy BIGINT NULL;
GO

UPDATE dbo.Boreholes SET BoreholeCode = N'BH-' + RIGHT(N'000' + CONVERT(NVARCHAR(20), BoreholeId), 3) WHERE BoreholeCode IS NULL;
UPDATE dbo.Boreholes SET ActualDepthM = ISNULL(ActualDepthM, 1) WHERE ActualDepthM IS NULL;
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name = N'UX_Boreholes_Project_Code' AND object_id = OBJECT_ID(N'dbo.Boreholes'))
CREATE UNIQUE INDEX UX_Boreholes_Project_Code ON dbo.Boreholes(ProjectId, BoreholeCode) WHERE IsDeleted = 0;
GO

IF OBJECT_ID(N'dbo.BoreholeLayers', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.BoreholeLayers
    (
        LayerId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_BoreholeLayers PRIMARY KEY,
        BoreholeId BIGINT NOT NULL,
        FromDepthM DECIMAL(10,2) NOT NULL,
        ToDepthM DECIMAL(10,2) NOT NULL,
        SoilRockTypeId BIGINT NULL,
        USCS NVARCHAR(50) NULL,
        Description NVARCHAR(MAX) NULL,
        Color NVARCHAR(100) NULL,
        ConsistencyDensity NVARCHAR(150) NULL,
        MoistureCondition NVARCHAR(150) NULL,
        RecoveryPercent DECIMAL(5,2) NULL,
        RQDPercent DECIMAL(5,2) NULL,
        Notes NVARCHAR(MAX) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_BoreholeLayers_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_BoreholeLayers_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL,
        CONSTRAINT FK_BoreholeLayers_Boreholes FOREIGN KEY(BoreholeId) REFERENCES dbo.Boreholes(BoreholeId),
        CONSTRAINT FK_BoreholeLayers_SoilRockType FOREIGN KEY(SoilRockTypeId) REFERENCES dbo.LookupItems(LookupItemId),
        CONSTRAINT CK_BoreholeLayers_Depths CHECK(FromDepthM >= 0 AND ToDepthM > FromDepthM),
        CONSTRAINT CK_BoreholeLayers_Percentages CHECK((RecoveryPercent IS NULL OR RecoveryPercent BETWEEN 0 AND 100) AND (RQDPercent IS NULL OR RQDPercent BETWEEN 0 AND 100))
    );
END
GO

IF OBJECT_ID(N'dbo.Samples', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Samples
    (
        SampleId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Samples PRIMARY KEY,
        ProjectId BIGINT NOT NULL,
        BoreholeId BIGINT NOT NULL,
        SampleCode NVARCHAR(100) NOT NULL,
        FromDepthM DECIMAL(10,2) NOT NULL,
        ToDepthM DECIMAL(10,2) NOT NULL,
        SampleTypeId BIGINT NULL,
        SampleQualityId BIGINT NULL,
        RecoveryLengthM DECIMAL(10,2) NULL,
        Description NVARCHAR(MAX) NULL,
        TakenDate DATE NULL,
        RequiredTests NVARCHAR(500) NULL,
        StorageLocation NVARCHAR(250) NULL,
        Notes NVARCHAR(MAX) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Samples_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_Samples_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL,
        CONSTRAINT FK_Samples_Projects FOREIGN KEY(ProjectId) REFERENCES dbo.Projects(ProjectId),
        CONSTRAINT FK_Samples_Boreholes FOREIGN KEY(BoreholeId) REFERENCES dbo.Boreholes(BoreholeId),
        CONSTRAINT FK_Samples_SampleType FOREIGN KEY(SampleTypeId) REFERENCES dbo.LookupItems(LookupItemId),
        CONSTRAINT FK_Samples_SampleQuality FOREIGN KEY(SampleQualityId) REFERENCES dbo.LookupItems(LookupItemId),
        CONSTRAINT CK_Samples_Depths CHECK(FromDepthM >= 0 AND ToDepthM > FromDepthM)
    );
END
GO

IF COL_LENGTH('dbo.Samples','BoreholeId') IS NULL ALTER TABLE dbo.Samples ADD BoreholeId BIGINT NULL;
IF COL_LENGTH('dbo.Samples','SampleCode') IS NULL ALTER TABLE dbo.Samples ADD SampleCode NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.Samples','FromDepthM') IS NULL ALTER TABLE dbo.Samples ADD FromDepthM DECIMAL(10,2) NULL;
IF COL_LENGTH('dbo.Samples','ToDepthM') IS NULL ALTER TABLE dbo.Samples ADD ToDepthM DECIMAL(10,2) NULL;
IF COL_LENGTH('dbo.Samples','SampleTypeId') IS NULL ALTER TABLE dbo.Samples ADD SampleTypeId BIGINT NULL;
IF COL_LENGTH('dbo.Samples','SampleQualityId') IS NULL ALTER TABLE dbo.Samples ADD SampleQualityId BIGINT NULL;
IF COL_LENGTH('dbo.Samples','RecoveryLengthM') IS NULL ALTER TABLE dbo.Samples ADD RecoveryLengthM DECIMAL(10,2) NULL;
IF COL_LENGTH('dbo.Samples','Description') IS NULL ALTER TABLE dbo.Samples ADD Description NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.Samples','TakenDate') IS NULL ALTER TABLE dbo.Samples ADD TakenDate DATE NULL;
IF COL_LENGTH('dbo.Samples','RequiredTests') IS NULL ALTER TABLE dbo.Samples ADD RequiredTests NVARCHAR(500) NULL;
IF COL_LENGTH('dbo.Samples','StorageLocation') IS NULL ALTER TABLE dbo.Samples ADD StorageLocation NVARCHAR(250) NULL;
IF COL_LENGTH('dbo.Samples','Notes') IS NULL ALTER TABLE dbo.Samples ADD Notes NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.Samples','CreatedAt') IS NULL ALTER TABLE dbo.Samples ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Samples_CreatedAt2 DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.Samples','CreatedBy') IS NULL ALTER TABLE dbo.Samples ADD CreatedBy BIGINT NULL;
IF COL_LENGTH('dbo.Samples','UpdatedAt') IS NULL ALTER TABLE dbo.Samples ADD UpdatedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.Samples','UpdatedBy') IS NULL ALTER TABLE dbo.Samples ADD UpdatedBy BIGINT NULL;
IF COL_LENGTH('dbo.Samples','DeletedAt') IS NULL ALTER TABLE dbo.Samples ADD DeletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.Samples','DeletedBy') IS NULL ALTER TABLE dbo.Samples ADD DeletedBy BIGINT NULL;
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name = N'IX_Samples_Borehole_Depth' AND object_id = OBJECT_ID(N'dbo.Samples'))
CREATE INDEX IX_Samples_Borehole_Depth ON dbo.Samples(BoreholeId, FromDepthM, ToDepthM) WHERE IsDeleted = 0;
GO

IF OBJECT_ID(N'dbo.SPTTests', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SPTTests
    (
        SPTTestId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_SPTTests PRIMARY KEY,
        ProjectId BIGINT NOT NULL,
        BoreholeId BIGINT NOT NULL,
        TestDepthM DECIMAL(10,2) NOT NULL,
        BlowCount1 INT NULL,
        BlowCount2 INT NULL,
        BlowCount3 INT NULL,
        NValue INT NULL,
        HammerEnergyRatio DECIMAL(6,2) NULL,
        CorrectedN DECIMAL(10,2) NULL,
        RecoveryLengthM DECIMAL(10,2) NULL,
        TestDate DATE NULL,
        Notes NVARCHAR(MAX) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_SPTTests_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_SPTTests_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL,
        CONSTRAINT FK_SPTTests_Projects FOREIGN KEY(ProjectId) REFERENCES dbo.Projects(ProjectId),
        CONSTRAINT FK_SPTTests_Boreholes FOREIGN KEY(BoreholeId) REFERENCES dbo.Boreholes(BoreholeId),
        CONSTRAINT CK_SPTTests_Depth CHECK(TestDepthM >= 0)
    );
END
GO

IF OBJECT_ID(N'dbo.GroundwaterObservations', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.GroundwaterObservations
    (
        GroundwaterObservationId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_GroundwaterObservations PRIMARY KEY,
        ProjectId BIGINT NOT NULL,
        BoreholeId BIGINT NOT NULL,
        ObservationDate DATE NULL,
        DepthToWaterM DECIMAL(10,2) NOT NULL,
        ObservationTypeId BIGINT NULL,
        CasingDepthM DECIMAL(10,2) NULL,
        StabilizedAfterHours DECIMAL(10,2) NULL,
        Notes NVARCHAR(MAX) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_GroundwaterObservations_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_GroundwaterObservations_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL,
        CONSTRAINT FK_GroundwaterObservations_Projects FOREIGN KEY(ProjectId) REFERENCES dbo.Projects(ProjectId),
        CONSTRAINT FK_GroundwaterObservations_Boreholes FOREIGN KEY(BoreholeId) REFERENCES dbo.Boreholes(BoreholeId),
        CONSTRAINT FK_GroundwaterObservations_Type FOREIGN KEY(ObservationTypeId) REFERENCES dbo.LookupItems(LookupItemId),
        CONSTRAINT CK_GroundwaterObservations_Depth CHECK(DepthToWaterM >= 0)
    );
END
GO

PRINT N'Sprint 2 tables created or updated successfully.';
GO
