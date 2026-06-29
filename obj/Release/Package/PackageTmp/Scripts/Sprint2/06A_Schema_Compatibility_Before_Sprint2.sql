USE GeoSitePro;
GO

/*
GeoSitePro Sprint 2 compatibility patch
Run this once BEFORE 07_Create_Lookups_Permissions_Sprint2_FIXED.sql and 08_Create_StoredProcedures_Sprint2_FIXED.sql.
It upgrades older GeoSitePro databases without deleting existing data.
*/

/* ---------- Core security tables ---------- */
IF OBJECT_ID(N'dbo.Users', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Users','Email') IS NULL ALTER TABLE dbo.Users ADD Email NVARCHAR(200) NULL;
    IF COL_LENGTH('dbo.Users','Mobile') IS NULL ALTER TABLE dbo.Users ADD Mobile NVARCHAR(50) NULL;
    IF COL_LENGTH('dbo.Users','CreatedBy') IS NULL ALTER TABLE dbo.Users ADD CreatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.Users','UpdatedAt') IS NULL ALTER TABLE dbo.Users ADD UpdatedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.Users','UpdatedBy') IS NULL ALTER TABLE dbo.Users ADD UpdatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.Users','IsDeleted') IS NULL ALTER TABLE dbo.Users ADD IsDeleted BIT NOT NULL CONSTRAINT DF_Users_IsDeleted_Compat DEFAULT(0);
    IF COL_LENGTH('dbo.Users','DeletedAt') IS NULL ALTER TABLE dbo.Users ADD DeletedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.Users','DeletedBy') IS NULL ALTER TABLE dbo.Users ADD DeletedBy BIGINT NULL;
END
GO

IF OBJECT_ID(N'dbo.Roles', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Roles','Description') IS NULL ALTER TABLE dbo.Roles ADD Description NVARCHAR(500) NULL;
    IF COL_LENGTH('dbo.Roles','CreatedAt') IS NULL ALTER TABLE dbo.Roles ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Roles_CreatedAt_Compat DEFAULT(SYSDATETIME());
    IF COL_LENGTH('dbo.Roles','CreatedBy') IS NULL ALTER TABLE dbo.Roles ADD CreatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.Roles','UpdatedAt') IS NULL ALTER TABLE dbo.Roles ADD UpdatedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.Roles','UpdatedBy') IS NULL ALTER TABLE dbo.Roles ADD UpdatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.Roles','IsDeleted') IS NULL ALTER TABLE dbo.Roles ADD IsDeleted BIT NOT NULL CONSTRAINT DF_Roles_IsDeleted_Compat DEFAULT(0);
    IF COL_LENGTH('dbo.Roles','DeletedAt') IS NULL ALTER TABLE dbo.Roles ADD DeletedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.Roles','DeletedBy') IS NULL ALTER TABLE dbo.Roles ADD DeletedBy BIGINT NULL;
END
GO

IF OBJECT_ID(N'dbo.Permissions', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Permissions','ModuleName') IS NULL ALTER TABLE dbo.Permissions ADD ModuleName NVARCHAR(100) NULL;
    IF COL_LENGTH('dbo.Permissions','PermissionNameEn') IS NULL ALTER TABLE dbo.Permissions ADD PermissionNameEn NVARCHAR(200) NULL;
    IF COL_LENGTH('dbo.Permissions','Description') IS NULL ALTER TABLE dbo.Permissions ADD Description NVARCHAR(500) NULL;
    IF COL_LENGTH('dbo.Permissions','SortOrder') IS NULL ALTER TABLE dbo.Permissions ADD SortOrder INT NOT NULL CONSTRAINT DF_Permissions_SortOrder_Compat DEFAULT(100);
    IF COL_LENGTH('dbo.Permissions','IsActive') IS NULL ALTER TABLE dbo.Permissions ADD IsActive BIT NOT NULL CONSTRAINT DF_Permissions_IsActive_Compat DEFAULT(1);
    IF COL_LENGTH('dbo.Permissions','CreatedAt') IS NULL ALTER TABLE dbo.Permissions ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Permissions_CreatedAt_Compat DEFAULT(SYSDATETIME());
    IF COL_LENGTH('dbo.Permissions','IsDeleted') IS NULL ALTER TABLE dbo.Permissions ADD IsDeleted BIT NOT NULL CONSTRAINT DF_Permissions_IsDeleted_Compat DEFAULT(0);
END
GO

IF OBJECT_ID(N'dbo.UserRoles', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.UserRoles','AssignedAt') IS NULL ALTER TABLE dbo.UserRoles ADD AssignedAt DATETIME2 NOT NULL CONSTRAINT DF_UserRoles_AssignedAt_Compat DEFAULT(SYSDATETIME());
    IF COL_LENGTH('dbo.UserRoles','AssignedBy') IS NULL ALTER TABLE dbo.UserRoles ADD AssignedBy BIGINT NULL;
    IF COL_LENGTH('dbo.UserRoles','IsActive') IS NULL ALTER TABLE dbo.UserRoles ADD IsActive BIT NOT NULL CONSTRAINT DF_UserRoles_IsActive_Compat DEFAULT(1);
END
GO

IF OBJECT_ID(N'dbo.RolePermissions', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.RolePermissions','GrantedAt') IS NULL ALTER TABLE dbo.RolePermissions ADD GrantedAt DATETIME2 NOT NULL CONSTRAINT DF_RolePermissions_GrantedAt_Compat DEFAULT(SYSDATETIME());
    IF COL_LENGTH('dbo.RolePermissions','GrantedBy') IS NULL ALTER TABLE dbo.RolePermissions ADD GrantedBy BIGINT NULL;
END
GO

IF OBJECT_ID(N'dbo.AuditLogs', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.AuditLogs','OldValues') IS NULL ALTER TABLE dbo.AuditLogs ADD OldValues NVARCHAR(MAX) NULL;
    IF COL_LENGTH('dbo.AuditLogs','NewValues') IS NULL ALTER TABLE dbo.AuditLogs ADD NewValues NVARCHAR(MAX) NULL;
    IF COL_LENGTH('dbo.AuditLogs','ActionDate') IS NULL ALTER TABLE dbo.AuditLogs ADD ActionDate DATETIME2 NOT NULL CONSTRAINT DF_AuditLogs_ActionDate_Compat DEFAULT(SYSDATETIME());
    IF COL_LENGTH('dbo.AuditLogs','CreatedAt') IS NULL ALTER TABLE dbo.AuditLogs ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_AuditLogs_CreatedAt_Compat DEFAULT(SYSDATETIME());
END
GO

/* ---------- Lookup tables: support both old CategoryCode/Code and new LookupCategoryId/ItemCode shapes ---------- */
IF OBJECT_ID(N'dbo.LookupCategories', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.LookupCategories','LookupCategoryId') IS NULL ALTER TABLE dbo.LookupCategories ADD LookupCategoryId BIGINT IDENTITY(1,1) NOT NULL;
    IF COL_LENGTH('dbo.LookupCategories','CategoryNameEn') IS NULL ALTER TABLE dbo.LookupCategories ADD CategoryNameEn NVARCHAR(200) NULL;
    IF COL_LENGTH('dbo.LookupCategories','SortOrder') IS NULL ALTER TABLE dbo.LookupCategories ADD SortOrder INT NOT NULL CONSTRAINT DF_LookupCategories_SortOrder_Compat DEFAULT(100);
    IF COL_LENGTH('dbo.LookupCategories','IsActive') IS NULL ALTER TABLE dbo.LookupCategories ADD IsActive BIT NOT NULL CONSTRAINT DF_LookupCategories_IsActive_Compat DEFAULT(1);
    IF COL_LENGTH('dbo.LookupCategories','IsDeleted') IS NULL ALTER TABLE dbo.LookupCategories ADD IsDeleted BIT NOT NULL CONSTRAINT DF_LookupCategories_IsDeleted_Compat DEFAULT(0);
END
GO

IF OBJECT_ID(N'dbo.LookupCategories', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'UX_LookupCategories_LookupCategoryId_Compat' AND object_id=OBJECT_ID(N'dbo.LookupCategories'))
        CREATE UNIQUE INDEX UX_LookupCategories_LookupCategoryId_Compat ON dbo.LookupCategories(LookupCategoryId);
END
GO

IF OBJECT_ID(N'dbo.LookupItems', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.LookupItems','LookupCategoryId') IS NULL ALTER TABLE dbo.LookupItems ADD LookupCategoryId BIGINT NULL;
    IF COL_LENGTH('dbo.LookupItems','CategoryCode') IS NULL ALTER TABLE dbo.LookupItems ADD CategoryCode NVARCHAR(100) NULL;
    IF COL_LENGTH('dbo.LookupItems','ItemCode') IS NULL ALTER TABLE dbo.LookupItems ADD ItemCode NVARCHAR(100) NULL;
    IF COL_LENGTH('dbo.LookupItems','Code') IS NULL ALTER TABLE dbo.LookupItems ADD Code NVARCHAR(100) NULL;
    IF COL_LENGTH('dbo.LookupItems','Description') IS NULL ALTER TABLE dbo.LookupItems ADD Description NVARCHAR(500) NULL;
    IF COL_LENGTH('dbo.LookupItems','IsDefault') IS NULL ALTER TABLE dbo.LookupItems ADD IsDefault BIT NOT NULL CONSTRAINT DF_LookupItems_IsDefault_Compat DEFAULT(0);
    IF COL_LENGTH('dbo.LookupItems','IsDeleted') IS NULL ALTER TABLE dbo.LookupItems ADD IsDeleted BIT NOT NULL CONSTRAINT DF_LookupItems_IsDeleted_Compat DEFAULT(0);
END
GO

UPDATE LI
SET LI.ItemCode = ISNULL(LI.ItemCode, LI.Code),
    LI.Code = ISNULL(LI.Code, LI.ItemCode),
    LI.LookupCategoryId = ISNULL(LI.LookupCategoryId, LC.LookupCategoryId),
    LI.CategoryCode = ISNULL(LI.CategoryCode, LC.CategoryCode)
FROM dbo.LookupItems LI
LEFT JOIN dbo.LookupCategories LC ON LC.CategoryCode = LI.CategoryCode OR LC.LookupCategoryId = LI.LookupCategoryId;
GO

/* ---------- Clients and Projects ---------- */
IF OBJECT_ID(N'dbo.Clients', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Clients
    (
        ClientId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Clients PRIMARY KEY,
        ClientName NVARCHAR(250) NOT NULL,
        ContactPerson NVARCHAR(200) NULL,
        Email NVARCHAR(200) NULL,
        Mobile NVARCHAR(50) NULL,
        IsActive BIT NOT NULL CONSTRAINT DF_Clients_IsActive_Compat DEFAULT(1),
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Clients_CreatedAt_Compat DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_Clients_IsDeleted_Compat DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.Clients', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Clients','ContactPerson') IS NULL ALTER TABLE dbo.Clients ADD ContactPerson NVARCHAR(200) NULL;
    IF COL_LENGTH('dbo.Clients','Email') IS NULL ALTER TABLE dbo.Clients ADD Email NVARCHAR(200) NULL;
    IF COL_LENGTH('dbo.Clients','Mobile') IS NULL ALTER TABLE dbo.Clients ADD Mobile NVARCHAR(50) NULL;
    IF COL_LENGTH('dbo.Clients','IsActive') IS NULL ALTER TABLE dbo.Clients ADD IsActive BIT NOT NULL CONSTRAINT DF_Clients_IsActive_Compat2 DEFAULT(1);
    IF COL_LENGTH('dbo.Clients','CreatedAt') IS NULL ALTER TABLE dbo.Clients ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Clients_CreatedAt_Compat2 DEFAULT(SYSDATETIME());
    IF COL_LENGTH('dbo.Clients','CreatedBy') IS NULL ALTER TABLE dbo.Clients ADD CreatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.Clients','UpdatedAt') IS NULL ALTER TABLE dbo.Clients ADD UpdatedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.Clients','UpdatedBy') IS NULL ALTER TABLE dbo.Clients ADD UpdatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.Clients','IsDeleted') IS NULL ALTER TABLE dbo.Clients ADD IsDeleted BIT NOT NULL CONSTRAINT DF_Clients_IsDeleted_Compat2 DEFAULT(0);
    IF COL_LENGTH('dbo.Clients','DeletedAt') IS NULL ALTER TABLE dbo.Clients ADD DeletedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.Clients','DeletedBy') IS NULL ALTER TABLE dbo.Clients ADD DeletedBy BIGINT NULL;
END
GO

IF OBJECT_ID(N'dbo.Projects', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Projects','ClientId') IS NULL ALTER TABLE dbo.Projects ADD ClientId BIGINT NULL;
    IF COL_LENGTH('dbo.Projects','ProjectNameEn') IS NULL ALTER TABLE dbo.Projects ADD ProjectNameEn NVARCHAR(300) NULL;
    IF COL_LENGTH('dbo.Projects','District') IS NULL ALTER TABLE dbo.Projects ADD District NVARCHAR(150) NULL;
    IF COL_LENGTH('dbo.Projects','LocationName') IS NULL ALTER TABLE dbo.Projects ADD LocationName NVARCHAR(300) NULL;
    IF COL_LENGTH('dbo.Projects','SiteAreaM2') IS NULL ALTER TABLE dbo.Projects ADD SiteAreaM2 DECIMAL(18,2) NULL;
    IF COL_LENGTH('dbo.Projects','NumberOfFloors') IS NULL ALTER TABLE dbo.Projects ADD NumberOfFloors INT NULL;
    IF COL_LENGTH('dbo.Projects','BasementCount') IS NULL ALTER TABLE dbo.Projects ADD BasementCount INT NULL;
    IF COL_LENGTH('dbo.Projects','ProjectStartDate') IS NULL ALTER TABLE dbo.Projects ADD ProjectStartDate DATE NULL;
    IF COL_LENGTH('dbo.Projects','ProjectEndDate') IS NULL ALTER TABLE dbo.Projects ADD ProjectEndDate DATE NULL;
    IF COL_LENGTH('dbo.Projects','ScopeOfWork') IS NULL ALTER TABLE dbo.Projects ADD ScopeOfWork NVARCHAR(MAX) NULL;
    IF COL_LENGTH('dbo.Projects','GeneralNotes') IS NULL ALTER TABLE dbo.Projects ADD GeneralNotes NVARCHAR(MAX) NULL;
    IF COL_LENGTH('dbo.Projects','IsActive') IS NULL ALTER TABLE dbo.Projects ADD IsActive BIT NOT NULL CONSTRAINT DF_Projects_IsActive_Compat DEFAULT(1);
    IF COL_LENGTH('dbo.Projects','CreatedAt') IS NULL ALTER TABLE dbo.Projects ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Projects_CreatedAt_Compat DEFAULT(SYSDATETIME());
    IF COL_LENGTH('dbo.Projects','CreatedBy') IS NULL ALTER TABLE dbo.Projects ADD CreatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.Projects','UpdatedAt') IS NULL ALTER TABLE dbo.Projects ADD UpdatedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.Projects','UpdatedBy') IS NULL ALTER TABLE dbo.Projects ADD UpdatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.Projects','IsDeleted') IS NULL ALTER TABLE dbo.Projects ADD IsDeleted BIT NOT NULL CONSTRAINT DF_Projects_IsDeleted_Compat DEFAULT(0);
    IF COL_LENGTH('dbo.Projects','DeletedAt') IS NULL ALTER TABLE dbo.Projects ADD DeletedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.Projects','DeletedBy') IS NULL ALTER TABLE dbo.Projects ADD DeletedBy BIGINT NULL;
END
GO

IF COL_LENGTH('dbo.Projects','ClientName') IS NOT NULL
BEGIN
    EXEC(N'
    INSERT INTO dbo.Clients(ClientName)
    SELECT DISTINCT NULLIF(LTRIM(RTRIM(P.ClientName)), N'''')
    FROM dbo.Projects P
    WHERE P.ClientId IS NULL
      AND NULLIF(LTRIM(RTRIM(P.ClientName)), N'''') IS NOT NULL
      AND NOT EXISTS(SELECT 1 FROM dbo.Clients C WHERE C.ClientName = NULLIF(LTRIM(RTRIM(P.ClientName)), N'''') AND C.IsDeleted = 0);

    UPDATE P
    SET ClientId = C.ClientId
    FROM dbo.Projects P
    INNER JOIN dbo.Clients C ON C.ClientName = NULLIF(LTRIM(RTRIM(P.ClientName)), N'''') AND C.IsDeleted = 0
    WHERE P.ClientId IS NULL;
    ');
END
GO

/* ---------- Sprint 2 tables ---------- */
IF OBJECT_ID(N'dbo.Boreholes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Boreholes
    (
        BoreholeId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Boreholes PRIMARY KEY,
        ProjectId BIGINT NOT NULL,
        BoreholeCode NVARCHAR(80) NULL,
        PlannedDepthM DECIMAL(10,2) NULL,
        ActualDepthM DECIMAL(10,2) NULL,
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
        IsActive BIT NOT NULL CONSTRAINT DF_Boreholes_IsActive_Compat DEFAULT(1),
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Boreholes_CreatedAt_Compat DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_Boreholes_IsDeleted_Compat DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.Boreholes', N'U') IS NOT NULL
BEGIN
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
    IF COL_LENGTH('dbo.Boreholes','IsActive') IS NULL ALTER TABLE dbo.Boreholes ADD IsActive BIT NOT NULL CONSTRAINT DF_Boreholes_IsActive_Compat2 DEFAULT(1);
    IF COL_LENGTH('dbo.Boreholes','CreatedAt') IS NULL ALTER TABLE dbo.Boreholes ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Boreholes_CreatedAt_Compat2 DEFAULT(SYSDATETIME());
    IF COL_LENGTH('dbo.Boreholes','CreatedBy') IS NULL ALTER TABLE dbo.Boreholes ADD CreatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.Boreholes','UpdatedAt') IS NULL ALTER TABLE dbo.Boreholes ADD UpdatedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.Boreholes','UpdatedBy') IS NULL ALTER TABLE dbo.Boreholes ADD UpdatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.Boreholes','IsDeleted') IS NULL ALTER TABLE dbo.Boreholes ADD IsDeleted BIT NOT NULL CONSTRAINT DF_Boreholes_IsDeleted_Compat2 DEFAULT(0);
    IF COL_LENGTH('dbo.Boreholes','DeletedAt') IS NULL ALTER TABLE dbo.Boreholes ADD DeletedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.Boreholes','DeletedBy') IS NULL ALTER TABLE dbo.Boreholes ADD DeletedBy BIGINT NULL;
END
GO

UPDATE dbo.Boreholes SET BoreholeCode = N'BH-' + RIGHT(N'000' + CONVERT(NVARCHAR(20), BoreholeId), 3) WHERE BoreholeCode IS NULL;
GO

IF OBJECT_ID(N'dbo.BoreholeLayers', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.BoreholeLayers
    (
        LayerId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_BoreholeLayers PRIMARY KEY,
        BoreholeId BIGINT NOT NULL,
        FromDepthM DECIMAL(10,2) NULL,
        ToDepthM DECIMAL(10,2) NULL,
        SoilRockTypeId BIGINT NULL,
        USCS NVARCHAR(50) NULL,
        Description NVARCHAR(MAX) NULL,
        Color NVARCHAR(100) NULL,
        ConsistencyDensity NVARCHAR(150) NULL,
        MoistureCondition NVARCHAR(150) NULL,
        RecoveryPercent DECIMAL(5,2) NULL,
        RQDPercent DECIMAL(5,2) NULL,
        Notes NVARCHAR(MAX) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_BoreholeLayers_CreatedAt_Compat DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_BoreholeLayers_IsDeleted_Compat DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.Samples', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Samples
    (
        SampleId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Samples PRIMARY KEY,
        ProjectId BIGINT NULL,
        BoreholeId BIGINT NULL,
        SampleCode NVARCHAR(100) NULL,
        FromDepthM DECIMAL(10,2) NULL,
        ToDepthM DECIMAL(10,2) NULL,
        SampleTypeId BIGINT NULL,
        SampleQualityId BIGINT NULL,
        RecoveryLengthM DECIMAL(10,2) NULL,
        Description NVARCHAR(MAX) NULL,
        TakenDate DATE NULL,
        RequiredTests NVARCHAR(500) NULL,
        StorageLocation NVARCHAR(250) NULL,
        Notes NVARCHAR(MAX) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Samples_CreatedAt_Compat DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_Samples_IsDeleted_Compat DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.Samples', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Samples','ProjectId') IS NULL ALTER TABLE dbo.Samples ADD ProjectId BIGINT NULL;
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
    IF COL_LENGTH('dbo.Samples','CreatedAt') IS NULL ALTER TABLE dbo.Samples ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Samples_CreatedAt_Compat2 DEFAULT(SYSDATETIME());
    IF COL_LENGTH('dbo.Samples','CreatedBy') IS NULL ALTER TABLE dbo.Samples ADD CreatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.Samples','UpdatedAt') IS NULL ALTER TABLE dbo.Samples ADD UpdatedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.Samples','UpdatedBy') IS NULL ALTER TABLE dbo.Samples ADD UpdatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.Samples','IsDeleted') IS NULL ALTER TABLE dbo.Samples ADD IsDeleted BIT NOT NULL CONSTRAINT DF_Samples_IsDeleted_Compat2 DEFAULT(0);
    IF COL_LENGTH('dbo.Samples','DeletedAt') IS NULL ALTER TABLE dbo.Samples ADD DeletedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.Samples','DeletedBy') IS NULL ALTER TABLE dbo.Samples ADD DeletedBy BIGINT NULL;
END
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
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_SPTTests_CreatedAt_Compat DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_SPTTests_IsDeleted_Compat DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
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
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_GroundwaterObservations_CreatedAt_Compat DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_GroundwaterObservations_IsDeleted_Compat DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.Reports', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Reports
    (
        ReportId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Reports PRIMARY KEY,
        ProjectId BIGINT NOT NULL,
        ReportTitle NVARCHAR(300) NULL,
        ReportStatus NVARCHAR(100) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Reports_CreatedAt_Compat DEFAULT(SYSDATETIME()),
        IsDeleted BIT NOT NULL CONSTRAINT DF_Reports_IsDeleted_Compat DEFAULT(0)
    );
END
GO

IF OBJECT_ID(N'dbo.Reports', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Reports','ProjectId') IS NULL ALTER TABLE dbo.Reports ADD ProjectId BIGINT NULL;
    IF COL_LENGTH('dbo.Reports','ReportTitle') IS NULL ALTER TABLE dbo.Reports ADD ReportTitle NVARCHAR(300) NULL;
    IF COL_LENGTH('dbo.Reports','ReportStatus') IS NULL ALTER TABLE dbo.Reports ADD ReportStatus NVARCHAR(100) NULL;
    IF COL_LENGTH('dbo.Reports','CreatedAt') IS NULL ALTER TABLE dbo.Reports ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Reports_CreatedAt_Compat2 DEFAULT(SYSDATETIME());
    IF COL_LENGTH('dbo.Reports','IsDeleted') IS NULL ALTER TABLE dbo.Reports ADD IsDeleted BIT NOT NULL CONSTRAINT DF_Reports_IsDeleted_Compat2 DEFAULT(0);
END
GO

PRINT N'Sprint 2 schema compatibility patch completed successfully.';
GO
