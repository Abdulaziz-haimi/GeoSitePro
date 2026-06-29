USE GeoSitePro;
GO

/*
Sprint 9: Site Map, Borehole Layout, and Cross Sections.
This script is additive and safe for existing databases.
*/

IF OBJECT_ID(N'dbo.ProjectMapSettings', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProjectMapSettings
    (
        MapSettingId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ProjectMapSettings PRIMARY KEY,
        ProjectId BIGINT NOT NULL,
        CoordinateSystem NVARCHAR(200) NULL,
        EPSGCode NVARCHAR(50) NULL,
        OriginEasting DECIMAL(18,3) NULL,
        OriginNorthing DECIMAL(18,3) NULL,
        ScaleDenominator DECIMAL(18,2) NULL,
        NorthAngleDeg DECIMAL(10,3) NULL,
        SiteBoundaryText NVARCHAR(MAX) NULL,
        Notes NVARCHAR(MAX) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectMapSettings_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_ProjectMapSettings_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO
IF COL_LENGTH('dbo.ProjectMapSettings','ProjectId') IS NULL ALTER TABLE dbo.ProjectMapSettings ADD ProjectId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectMapSettings','CoordinateSystem') IS NULL ALTER TABLE dbo.ProjectMapSettings ADD CoordinateSystem NVARCHAR(200) NULL;
IF COL_LENGTH('dbo.ProjectMapSettings','EPSGCode') IS NULL ALTER TABLE dbo.ProjectMapSettings ADD EPSGCode NVARCHAR(50) NULL;
IF COL_LENGTH('dbo.ProjectMapSettings','OriginEasting') IS NULL ALTER TABLE dbo.ProjectMapSettings ADD OriginEasting DECIMAL(18,3) NULL;
IF COL_LENGTH('dbo.ProjectMapSettings','OriginNorthing') IS NULL ALTER TABLE dbo.ProjectMapSettings ADD OriginNorthing DECIMAL(18,3) NULL;
IF COL_LENGTH('dbo.ProjectMapSettings','ScaleDenominator') IS NULL ALTER TABLE dbo.ProjectMapSettings ADD ScaleDenominator DECIMAL(18,2) NULL;
IF COL_LENGTH('dbo.ProjectMapSettings','NorthAngleDeg') IS NULL ALTER TABLE dbo.ProjectMapSettings ADD NorthAngleDeg DECIMAL(10,3) NULL;
IF COL_LENGTH('dbo.ProjectMapSettings','SiteBoundaryText') IS NULL ALTER TABLE dbo.ProjectMapSettings ADD SiteBoundaryText NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.ProjectMapSettings','Notes') IS NULL ALTER TABLE dbo.ProjectMapSettings ADD Notes NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.ProjectMapSettings','CreatedAt') IS NULL ALTER TABLE dbo.ProjectMapSettings ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectMapSettings_CreatedAt2 DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.ProjectMapSettings','CreatedBy') IS NULL ALTER TABLE dbo.ProjectMapSettings ADD CreatedBy BIGINT NULL;
IF COL_LENGTH('dbo.ProjectMapSettings','UpdatedAt') IS NULL ALTER TABLE dbo.ProjectMapSettings ADD UpdatedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ProjectMapSettings','UpdatedBy') IS NULL ALTER TABLE dbo.ProjectMapSettings ADD UpdatedBy BIGINT NULL;
IF COL_LENGTH('dbo.ProjectMapSettings','IsDeleted') IS NULL ALTER TABLE dbo.ProjectMapSettings ADD IsDeleted BIT NOT NULL CONSTRAINT DF_ProjectMapSettings_IsDeleted2 DEFAULT(0);
IF COL_LENGTH('dbo.ProjectMapSettings','DeletedAt') IS NULL ALTER TABLE dbo.ProjectMapSettings ADD DeletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ProjectMapSettings','DeletedBy') IS NULL ALTER TABLE dbo.ProjectMapSettings ADD DeletedBy BIGINT NULL;
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'UX_ProjectMapSettings_Project' AND object_id=OBJECT_ID(N'dbo.ProjectMapSettings'))
    CREATE UNIQUE INDEX UX_ProjectMapSettings_Project ON dbo.ProjectMapSettings(ProjectId) WHERE IsDeleted=0;
GO

IF OBJECT_ID(N'dbo.ProjectBoreholeLayoutPoints', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProjectBoreholeLayoutPoints
    (
        LayoutPointId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ProjectBoreholeLayoutPoints PRIMARY KEY,
        ProjectId BIGINT NOT NULL,
        BoreholeId BIGINT NULL,
        PlanId BIGINT NULL,
        SourceTypeId BIGINT NULL,
        BoreholeCode NVARCHAR(80) NOT NULL,
        Easting DECIMAL(18,3) NULL,
        Northing DECIMAL(18,3) NULL,
        ElevationM DECIMAL(10,3) NULL,
        PlannedDepthM DECIMAL(10,2) NULL,
        ActualDepthM DECIMAL(10,2) NULL,
        SortOrder INT NOT NULL CONSTRAINT DF_ProjectBoreholeLayoutPoints_SortOrder DEFAULT(100),
        Notes NVARCHAR(MAX) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectBoreholeLayoutPoints_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_ProjectBoreholeLayoutPoints_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO
IF COL_LENGTH('dbo.ProjectBoreholeLayoutPoints','ProjectId') IS NULL ALTER TABLE dbo.ProjectBoreholeLayoutPoints ADD ProjectId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectBoreholeLayoutPoints','BoreholeId') IS NULL ALTER TABLE dbo.ProjectBoreholeLayoutPoints ADD BoreholeId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectBoreholeLayoutPoints','PlanId') IS NULL ALTER TABLE dbo.ProjectBoreholeLayoutPoints ADD PlanId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectBoreholeLayoutPoints','SourceTypeId') IS NULL ALTER TABLE dbo.ProjectBoreholeLayoutPoints ADD SourceTypeId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectBoreholeLayoutPoints','BoreholeCode') IS NULL ALTER TABLE dbo.ProjectBoreholeLayoutPoints ADD BoreholeCode NVARCHAR(80) NULL;
IF COL_LENGTH('dbo.ProjectBoreholeLayoutPoints','Easting') IS NULL ALTER TABLE dbo.ProjectBoreholeLayoutPoints ADD Easting DECIMAL(18,3) NULL;
IF COL_LENGTH('dbo.ProjectBoreholeLayoutPoints','Northing') IS NULL ALTER TABLE dbo.ProjectBoreholeLayoutPoints ADD Northing DECIMAL(18,3) NULL;
IF COL_LENGTH('dbo.ProjectBoreholeLayoutPoints','ElevationM') IS NULL ALTER TABLE dbo.ProjectBoreholeLayoutPoints ADD ElevationM DECIMAL(10,3) NULL;
IF COL_LENGTH('dbo.ProjectBoreholeLayoutPoints','PlannedDepthM') IS NULL ALTER TABLE dbo.ProjectBoreholeLayoutPoints ADD PlannedDepthM DECIMAL(10,2) NULL;
IF COL_LENGTH('dbo.ProjectBoreholeLayoutPoints','ActualDepthM') IS NULL ALTER TABLE dbo.ProjectBoreholeLayoutPoints ADD ActualDepthM DECIMAL(10,2) NULL;
IF COL_LENGTH('dbo.ProjectBoreholeLayoutPoints','SortOrder') IS NULL ALTER TABLE dbo.ProjectBoreholeLayoutPoints ADD SortOrder INT NOT NULL CONSTRAINT DF_ProjectBoreholeLayoutPoints_SortOrder2 DEFAULT(100);
IF COL_LENGTH('dbo.ProjectBoreholeLayoutPoints','Notes') IS NULL ALTER TABLE dbo.ProjectBoreholeLayoutPoints ADD Notes NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.ProjectBoreholeLayoutPoints','CreatedAt') IS NULL ALTER TABLE dbo.ProjectBoreholeLayoutPoints ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectBoreholeLayoutPoints_CreatedAt2 DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.ProjectBoreholeLayoutPoints','CreatedBy') IS NULL ALTER TABLE dbo.ProjectBoreholeLayoutPoints ADD CreatedBy BIGINT NULL;
IF COL_LENGTH('dbo.ProjectBoreholeLayoutPoints','UpdatedAt') IS NULL ALTER TABLE dbo.ProjectBoreholeLayoutPoints ADD UpdatedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ProjectBoreholeLayoutPoints','UpdatedBy') IS NULL ALTER TABLE dbo.ProjectBoreholeLayoutPoints ADD UpdatedBy BIGINT NULL;
IF COL_LENGTH('dbo.ProjectBoreholeLayoutPoints','IsDeleted') IS NULL ALTER TABLE dbo.ProjectBoreholeLayoutPoints ADD IsDeleted BIT NOT NULL CONSTRAINT DF_ProjectBoreholeLayoutPoints_IsDeleted2 DEFAULT(0);
IF COL_LENGTH('dbo.ProjectBoreholeLayoutPoints','DeletedAt') IS NULL ALTER TABLE dbo.ProjectBoreholeLayoutPoints ADD DeletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ProjectBoreholeLayoutPoints','DeletedBy') IS NULL ALTER TABLE dbo.ProjectBoreholeLayoutPoints ADD DeletedBy BIGINT NULL;
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'IX_ProjectBoreholeLayoutPoints_Project' AND object_id=OBJECT_ID(N'dbo.ProjectBoreholeLayoutPoints'))
    CREATE INDEX IX_ProjectBoreholeLayoutPoints_Project ON dbo.ProjectBoreholeLayoutPoints(ProjectId, IsDeleted, SortOrder);
GO

IF OBJECT_ID(N'dbo.ProjectCrossSections', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProjectCrossSections
    (
        CrossSectionId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ProjectCrossSections PRIMARY KEY,
        ProjectId BIGINT NOT NULL,
        SectionCode NVARCHAR(80) NOT NULL,
        SectionName NVARCHAR(250) NULL,
        BaselineType NVARCHAR(50) NOT NULL CONSTRAINT DF_ProjectCrossSections_BaselineType DEFAULT(N'EASTING'),
        SectionStatusId BIGINT NULL,
        StartEasting DECIMAL(18,3) NULL,
        StartNorthing DECIMAL(18,3) NULL,
        EndEasting DECIMAL(18,3) NULL,
        EndNorthing DECIMAL(18,3) NULL,
        HorizontalScale DECIMAL(18,2) NULL,
        VerticalScale DECIMAL(18,2) NULL,
        Notes NVARCHAR(MAX) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectCrossSections_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_ProjectCrossSections_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO
IF COL_LENGTH('dbo.ProjectCrossSections','ProjectId') IS NULL ALTER TABLE dbo.ProjectCrossSections ADD ProjectId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectCrossSections','SectionCode') IS NULL ALTER TABLE dbo.ProjectCrossSections ADD SectionCode NVARCHAR(80) NULL;
IF COL_LENGTH('dbo.ProjectCrossSections','SectionName') IS NULL ALTER TABLE dbo.ProjectCrossSections ADD SectionName NVARCHAR(250) NULL;
IF COL_LENGTH('dbo.ProjectCrossSections','BaselineType') IS NULL ALTER TABLE dbo.ProjectCrossSections ADD BaselineType NVARCHAR(50) NOT NULL CONSTRAINT DF_ProjectCrossSections_BaselineType2 DEFAULT(N'EASTING');
IF COL_LENGTH('dbo.ProjectCrossSections','SectionStatusId') IS NULL ALTER TABLE dbo.ProjectCrossSections ADD SectionStatusId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectCrossSections','StartEasting') IS NULL ALTER TABLE dbo.ProjectCrossSections ADD StartEasting DECIMAL(18,3) NULL;
IF COL_LENGTH('dbo.ProjectCrossSections','StartNorthing') IS NULL ALTER TABLE dbo.ProjectCrossSections ADD StartNorthing DECIMAL(18,3) NULL;
IF COL_LENGTH('dbo.ProjectCrossSections','EndEasting') IS NULL ALTER TABLE dbo.ProjectCrossSections ADD EndEasting DECIMAL(18,3) NULL;
IF COL_LENGTH('dbo.ProjectCrossSections','EndNorthing') IS NULL ALTER TABLE dbo.ProjectCrossSections ADD EndNorthing DECIMAL(18,3) NULL;
IF COL_LENGTH('dbo.ProjectCrossSections','HorizontalScale') IS NULL ALTER TABLE dbo.ProjectCrossSections ADD HorizontalScale DECIMAL(18,2) NULL;
IF COL_LENGTH('dbo.ProjectCrossSections','VerticalScale') IS NULL ALTER TABLE dbo.ProjectCrossSections ADD VerticalScale DECIMAL(18,2) NULL;
IF COL_LENGTH('dbo.ProjectCrossSections','Notes') IS NULL ALTER TABLE dbo.ProjectCrossSections ADD Notes NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.ProjectCrossSections','CreatedAt') IS NULL ALTER TABLE dbo.ProjectCrossSections ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectCrossSections_CreatedAt2 DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.ProjectCrossSections','CreatedBy') IS NULL ALTER TABLE dbo.ProjectCrossSections ADD CreatedBy BIGINT NULL;
IF COL_LENGTH('dbo.ProjectCrossSections','UpdatedAt') IS NULL ALTER TABLE dbo.ProjectCrossSections ADD UpdatedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ProjectCrossSections','UpdatedBy') IS NULL ALTER TABLE dbo.ProjectCrossSections ADD UpdatedBy BIGINT NULL;
IF COL_LENGTH('dbo.ProjectCrossSections','IsDeleted') IS NULL ALTER TABLE dbo.ProjectCrossSections ADD IsDeleted BIT NOT NULL CONSTRAINT DF_ProjectCrossSections_IsDeleted2 DEFAULT(0);
IF COL_LENGTH('dbo.ProjectCrossSections','DeletedAt') IS NULL ALTER TABLE dbo.ProjectCrossSections ADD DeletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ProjectCrossSections','DeletedBy') IS NULL ALTER TABLE dbo.ProjectCrossSections ADD DeletedBy BIGINT NULL;
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'IX_ProjectCrossSections_Project' AND object_id=OBJECT_ID(N'dbo.ProjectCrossSections'))
    CREATE INDEX IX_ProjectCrossSections_Project ON dbo.ProjectCrossSections(ProjectId, IsDeleted, SectionCode);
GO

IF OBJECT_ID(N'dbo.ProjectCrossSectionBoreholes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProjectCrossSectionBoreholes
    (
        CrossSectionBoreholeId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ProjectCrossSectionBoreholes PRIMARY KEY,
        CrossSectionId BIGINT NOT NULL,
        BoreholeId BIGINT NOT NULL,
        ChainageM DECIMAL(18,3) NULL,
        OffsetM DECIMAL(18,3) NULL,
        SortOrder INT NOT NULL CONSTRAINT DF_ProjectCrossSectionBoreholes_SortOrder DEFAULT(100),
        Notes NVARCHAR(MAX) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectCrossSectionBoreholes_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_ProjectCrossSectionBoreholes_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO
IF COL_LENGTH('dbo.ProjectCrossSectionBoreholes','CrossSectionId') IS NULL ALTER TABLE dbo.ProjectCrossSectionBoreholes ADD CrossSectionId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectCrossSectionBoreholes','BoreholeId') IS NULL ALTER TABLE dbo.ProjectCrossSectionBoreholes ADD BoreholeId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectCrossSectionBoreholes','ChainageM') IS NULL ALTER TABLE dbo.ProjectCrossSectionBoreholes ADD ChainageM DECIMAL(18,3) NULL;
IF COL_LENGTH('dbo.ProjectCrossSectionBoreholes','OffsetM') IS NULL ALTER TABLE dbo.ProjectCrossSectionBoreholes ADD OffsetM DECIMAL(18,3) NULL;
IF COL_LENGTH('dbo.ProjectCrossSectionBoreholes','SortOrder') IS NULL ALTER TABLE dbo.ProjectCrossSectionBoreholes ADD SortOrder INT NOT NULL CONSTRAINT DF_ProjectCrossSectionBoreholes_SortOrder2 DEFAULT(100);
IF COL_LENGTH('dbo.ProjectCrossSectionBoreholes','Notes') IS NULL ALTER TABLE dbo.ProjectCrossSectionBoreholes ADD Notes NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.ProjectCrossSectionBoreholes','CreatedAt') IS NULL ALTER TABLE dbo.ProjectCrossSectionBoreholes ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectCrossSectionBoreholes_CreatedAt2 DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.ProjectCrossSectionBoreholes','CreatedBy') IS NULL ALTER TABLE dbo.ProjectCrossSectionBoreholes ADD CreatedBy BIGINT NULL;
IF COL_LENGTH('dbo.ProjectCrossSectionBoreholes','IsDeleted') IS NULL ALTER TABLE dbo.ProjectCrossSectionBoreholes ADD IsDeleted BIT NOT NULL CONSTRAINT DF_ProjectCrossSectionBoreholes_IsDeleted2 DEFAULT(0);
IF COL_LENGTH('dbo.ProjectCrossSectionBoreholes','DeletedAt') IS NULL ALTER TABLE dbo.ProjectCrossSectionBoreholes ADD DeletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ProjectCrossSectionBoreholes','DeletedBy') IS NULL ALTER TABLE dbo.ProjectCrossSectionBoreholes ADD DeletedBy BIGINT NULL;
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'IX_ProjectCrossSectionBoreholes_Section' AND object_id=OBJECT_ID(N'dbo.ProjectCrossSectionBoreholes'))
    CREATE INDEX IX_ProjectCrossSectionBoreholes_Section ON dbo.ProjectCrossSectionBoreholes(CrossSectionId, IsDeleted, SortOrder);
GO

PRINT N'Sprint 9 tables created successfully.';
GO
