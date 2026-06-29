USE GeoSitePro;
GO

/* Sprint 4: Technical reports and report sections. Compatible with existing GeoSitePro databases. */

IF OBJECT_ID(N'dbo.TechnicalReports', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TechnicalReports
    (
        ReportId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TechnicalReports PRIMARY KEY,
        ProjectId BIGINT NOT NULL,
        ReportNo NVARCHAR(80) NULL,
        ReportTitle NVARCHAR(300) NOT NULL,
        ReportTypeId BIGINT NULL,
        ReportStatusId BIGINT NULL,
        IssueDate DATE NULL,
        RevisionNo NVARCHAR(50) NULL,
        LanguageCode NVARCHAR(10) NULL,
        ExecutiveSummary NVARCHAR(MAX) NULL,
        Recommendations NVARCHAR(MAX) NULL,
        PreparedBy NVARCHAR(200) NULL,
        ReviewedBy NVARCHAR(200) NULL,
        ApprovedBy NVARCHAR(200) NULL,
        ApprovedAt DATETIME2 NULL,
        IssuedAt DATETIME2 NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_TechnicalReports_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_TechnicalReports_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL,
        CONSTRAINT FK_TechnicalReports_Projects FOREIGN KEY(ProjectId) REFERENCES dbo.Projects(ProjectId)
    );
END
GO

IF COL_LENGTH('dbo.TechnicalReports','ProjectId') IS NULL ALTER TABLE dbo.TechnicalReports ADD ProjectId BIGINT NULL;
IF COL_LENGTH('dbo.TechnicalReports','ReportNo') IS NULL ALTER TABLE dbo.TechnicalReports ADD ReportNo NVARCHAR(80) NULL;
IF COL_LENGTH('dbo.TechnicalReports','ReportTitle') IS NULL ALTER TABLE dbo.TechnicalReports ADD ReportTitle NVARCHAR(300) NULL;
IF COL_LENGTH('dbo.TechnicalReports','ReportTypeId') IS NULL ALTER TABLE dbo.TechnicalReports ADD ReportTypeId BIGINT NULL;
IF COL_LENGTH('dbo.TechnicalReports','ReportStatusId') IS NULL ALTER TABLE dbo.TechnicalReports ADD ReportStatusId BIGINT NULL;
IF COL_LENGTH('dbo.TechnicalReports','IssueDate') IS NULL ALTER TABLE dbo.TechnicalReports ADD IssueDate DATE NULL;
IF COL_LENGTH('dbo.TechnicalReports','RevisionNo') IS NULL ALTER TABLE dbo.TechnicalReports ADD RevisionNo NVARCHAR(50) NULL;
IF COL_LENGTH('dbo.TechnicalReports','LanguageCode') IS NULL ALTER TABLE dbo.TechnicalReports ADD LanguageCode NVARCHAR(10) NULL;
IF COL_LENGTH('dbo.TechnicalReports','ExecutiveSummary') IS NULL ALTER TABLE dbo.TechnicalReports ADD ExecutiveSummary NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.TechnicalReports','Recommendations') IS NULL ALTER TABLE dbo.TechnicalReports ADD Recommendations NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.TechnicalReports','PreparedBy') IS NULL ALTER TABLE dbo.TechnicalReports ADD PreparedBy NVARCHAR(200) NULL;
IF COL_LENGTH('dbo.TechnicalReports','ReviewedBy') IS NULL ALTER TABLE dbo.TechnicalReports ADD ReviewedBy NVARCHAR(200) NULL;
IF COL_LENGTH('dbo.TechnicalReports','ApprovedBy') IS NULL ALTER TABLE dbo.TechnicalReports ADD ApprovedBy NVARCHAR(200) NULL;
IF COL_LENGTH('dbo.TechnicalReports','ApprovedAt') IS NULL ALTER TABLE dbo.TechnicalReports ADD ApprovedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.TechnicalReports','IssuedAt') IS NULL ALTER TABLE dbo.TechnicalReports ADD IssuedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.TechnicalReports','CreatedAt') IS NULL ALTER TABLE dbo.TechnicalReports ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_TechnicalReports_CreatedAt_Compat DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.TechnicalReports','CreatedBy') IS NULL ALTER TABLE dbo.TechnicalReports ADD CreatedBy BIGINT NULL;
IF COL_LENGTH('dbo.TechnicalReports','UpdatedAt') IS NULL ALTER TABLE dbo.TechnicalReports ADD UpdatedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.TechnicalReports','UpdatedBy') IS NULL ALTER TABLE dbo.TechnicalReports ADD UpdatedBy BIGINT NULL;
IF COL_LENGTH('dbo.TechnicalReports','IsDeleted') IS NULL ALTER TABLE dbo.TechnicalReports ADD IsDeleted BIT NOT NULL CONSTRAINT DF_TechnicalReports_IsDeleted_Compat DEFAULT(0);
IF COL_LENGTH('dbo.TechnicalReports','DeletedAt') IS NULL ALTER TABLE dbo.TechnicalReports ADD DeletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.TechnicalReports','DeletedBy') IS NULL ALTER TABLE dbo.TechnicalReports ADD DeletedBy BIGINT NULL;
GO

IF OBJECT_ID(N'dbo.TechnicalReportSections', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TechnicalReportSections
    (
        ReportSectionId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TechnicalReportSections PRIMARY KEY,
        ReportId BIGINT NOT NULL,
        SectionTypeId BIGINT NULL,
        SectionCode NVARCHAR(100) NULL,
        SectionTitle NVARCHAR(300) NOT NULL,
        SectionContent NVARCHAR(MAX) NULL,
        SortOrder INT NOT NULL CONSTRAINT DF_TechnicalReportSections_SortOrder DEFAULT(100),
        IsIncluded BIT NOT NULL CONSTRAINT DF_TechnicalReportSections_IsIncluded DEFAULT(1),
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_TechnicalReportSections_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_TechnicalReportSections_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL,
        CONSTRAINT FK_TechnicalReportSections_Reports FOREIGN KEY(ReportId) REFERENCES dbo.TechnicalReports(ReportId)
    );
END
GO

IF COL_LENGTH('dbo.TechnicalReportSections','ReportId') IS NULL ALTER TABLE dbo.TechnicalReportSections ADD ReportId BIGINT NULL;
IF COL_LENGTH('dbo.TechnicalReportSections','SectionTypeId') IS NULL ALTER TABLE dbo.TechnicalReportSections ADD SectionTypeId BIGINT NULL;
IF COL_LENGTH('dbo.TechnicalReportSections','SectionCode') IS NULL ALTER TABLE dbo.TechnicalReportSections ADD SectionCode NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.TechnicalReportSections','SectionTitle') IS NULL ALTER TABLE dbo.TechnicalReportSections ADD SectionTitle NVARCHAR(300) NULL;
IF COL_LENGTH('dbo.TechnicalReportSections','SectionContent') IS NULL ALTER TABLE dbo.TechnicalReportSections ADD SectionContent NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.TechnicalReportSections','SortOrder') IS NULL ALTER TABLE dbo.TechnicalReportSections ADD SortOrder INT NOT NULL CONSTRAINT DF_TechnicalReportSections_SortOrder_Compat DEFAULT(100);
IF COL_LENGTH('dbo.TechnicalReportSections','IsIncluded') IS NULL ALTER TABLE dbo.TechnicalReportSections ADD IsIncluded BIT NOT NULL CONSTRAINT DF_TechnicalReportSections_IsIncluded_Compat DEFAULT(1);
IF COL_LENGTH('dbo.TechnicalReportSections','CreatedAt') IS NULL ALTER TABLE dbo.TechnicalReportSections ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_TechnicalReportSections_CreatedAt_Compat DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.TechnicalReportSections','CreatedBy') IS NULL ALTER TABLE dbo.TechnicalReportSections ADD CreatedBy BIGINT NULL;
IF COL_LENGTH('dbo.TechnicalReportSections','UpdatedAt') IS NULL ALTER TABLE dbo.TechnicalReportSections ADD UpdatedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.TechnicalReportSections','UpdatedBy') IS NULL ALTER TABLE dbo.TechnicalReportSections ADD UpdatedBy BIGINT NULL;
IF COL_LENGTH('dbo.TechnicalReportSections','IsDeleted') IS NULL ALTER TABLE dbo.TechnicalReportSections ADD IsDeleted BIT NOT NULL CONSTRAINT DF_TechnicalReportSections_IsDeleted_Compat DEFAULT(0);
IF COL_LENGTH('dbo.TechnicalReportSections','DeletedAt') IS NULL ALTER TABLE dbo.TechnicalReportSections ADD DeletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.TechnicalReportSections','DeletedBy') IS NULL ALTER TABLE dbo.TechnicalReportSections ADD DeletedBy BIGINT NULL;
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name = N'IX_TechnicalReports_Project' AND object_id = OBJECT_ID(N'dbo.TechnicalReports'))
CREATE INDEX IX_TechnicalReports_Project ON dbo.TechnicalReports(ProjectId, ReportStatusId) WHERE IsDeleted = 0;
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name = N'IX_TechnicalReportSections_Report' AND object_id = OBJECT_ID(N'dbo.TechnicalReportSections'))
CREATE INDEX IX_TechnicalReportSections_Report ON dbo.TechnicalReportSections(ReportId, SortOrder) WHERE IsDeleted = 0;
GO

PRINT N'Sprint 4 report tables created successfully.';
GO
