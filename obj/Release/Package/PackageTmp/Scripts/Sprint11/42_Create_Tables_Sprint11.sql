USE GeoSitePro;
GO

/* Sprint 11: Print & submission package tables. */

IF OBJECT_ID(N'dbo.PrintOutputTemplates', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PrintOutputTemplates
    (
        PrintTemplateId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_PrintOutputTemplates PRIMARY KEY,
        TemplateCode NVARCHAR(100) NOT NULL,
        TemplateNameAr NVARCHAR(250) NOT NULL,
        TemplateNameEn NVARCHAR(250) NULL,
        OutputType NVARCHAR(100) NOT NULL,
        Description NVARCHAR(500) NULL,
        IsDefault BIT NOT NULL CONSTRAINT DF_PrintOutputTemplates_IsDefault DEFAULT(0),
        SortOrder INT NOT NULL CONSTRAINT DF_PrintOutputTemplates_SortOrder DEFAULT(100),
        IsActive BIT NOT NULL CONSTRAINT DF_PrintOutputTemplates_IsActive DEFAULT(1),
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_PrintOutputTemplates_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_PrintOutputTemplates_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.PrintOutputTemplates', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.PrintOutputTemplates','TemplateCode') IS NULL ALTER TABLE dbo.PrintOutputTemplates ADD TemplateCode NVARCHAR(100) NULL;
    IF COL_LENGTH('dbo.PrintOutputTemplates','TemplateNameAr') IS NULL ALTER TABLE dbo.PrintOutputTemplates ADD TemplateNameAr NVARCHAR(250) NULL;
    IF COL_LENGTH('dbo.PrintOutputTemplates','TemplateNameEn') IS NULL ALTER TABLE dbo.PrintOutputTemplates ADD TemplateNameEn NVARCHAR(250) NULL;
    IF COL_LENGTH('dbo.PrintOutputTemplates','OutputType') IS NULL ALTER TABLE dbo.PrintOutputTemplates ADD OutputType NVARCHAR(100) NULL;
    IF COL_LENGTH('dbo.PrintOutputTemplates','Description') IS NULL ALTER TABLE dbo.PrintOutputTemplates ADD Description NVARCHAR(500) NULL;
    IF COL_LENGTH('dbo.PrintOutputTemplates','IsDefault') IS NULL ALTER TABLE dbo.PrintOutputTemplates ADD IsDefault BIT NOT NULL CONSTRAINT DF_PrintOutputTemplates_IsDefault_Compat DEFAULT(0);
    IF COL_LENGTH('dbo.PrintOutputTemplates','SortOrder') IS NULL ALTER TABLE dbo.PrintOutputTemplates ADD SortOrder INT NOT NULL CONSTRAINT DF_PrintOutputTemplates_SortOrder_Compat DEFAULT(100);
    IF COL_LENGTH('dbo.PrintOutputTemplates','IsActive') IS NULL ALTER TABLE dbo.PrintOutputTemplates ADD IsActive BIT NOT NULL CONSTRAINT DF_PrintOutputTemplates_IsActive_Compat DEFAULT(1);
    IF COL_LENGTH('dbo.PrintOutputTemplates','CreatedAt') IS NULL ALTER TABLE dbo.PrintOutputTemplates ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_PrintOutputTemplates_CreatedAt_Compat DEFAULT(SYSDATETIME());
    IF COL_LENGTH('dbo.PrintOutputTemplates','CreatedBy') IS NULL ALTER TABLE dbo.PrintOutputTemplates ADD CreatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.PrintOutputTemplates','UpdatedAt') IS NULL ALTER TABLE dbo.PrintOutputTemplates ADD UpdatedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.PrintOutputTemplates','UpdatedBy') IS NULL ALTER TABLE dbo.PrintOutputTemplates ADD UpdatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.PrintOutputTemplates','IsDeleted') IS NULL ALTER TABLE dbo.PrintOutputTemplates ADD IsDeleted BIT NOT NULL CONSTRAINT DF_PrintOutputTemplates_IsDeleted_Compat DEFAULT(0);
    IF COL_LENGTH('dbo.PrintOutputTemplates','DeletedAt') IS NULL ALTER TABLE dbo.PrintOutputTemplates ADD DeletedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.PrintOutputTemplates','DeletedBy') IS NULL ALTER TABLE dbo.PrintOutputTemplates ADD DeletedBy BIGINT NULL;
END
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'UX_PrintOutputTemplates_Code' AND object_id=OBJECT_ID(N'dbo.PrintOutputTemplates'))
    CREATE UNIQUE INDEX UX_PrintOutputTemplates_Code ON dbo.PrintOutputTemplates(TemplateCode) WHERE IsDeleted=0;
GO

IF OBJECT_ID(N'dbo.PrintJobs', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PrintJobs
    (
        PrintJobId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_PrintJobs PRIMARY KEY,
        ProjectId BIGINT NOT NULL,
        BoreholeId BIGINT NULL,
        TemplateCode NVARCHAR(100) NOT NULL,
        OutputTitle NVARCHAR(300) NULL,
        OutputFormat NVARCHAR(50) NOT NULL CONSTRAINT DF_PrintJobs_OutputFormat DEFAULT(N'BrowserPrint'),
        PrintedBy BIGINT NULL,
        PrintedAt DATETIME2 NOT NULL CONSTRAINT DF_PrintJobs_PrintedAt DEFAULT(SYSDATETIME()),
        Status NVARCHAR(50) NOT NULL CONSTRAINT DF_PrintJobs_Status DEFAULT(N'Generated'),
        Notes NVARCHAR(MAX) NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_PrintJobs_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.PrintJobs', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.PrintJobs','ProjectId') IS NULL ALTER TABLE dbo.PrintJobs ADD ProjectId BIGINT NULL;
    IF COL_LENGTH('dbo.PrintJobs','BoreholeId') IS NULL ALTER TABLE dbo.PrintJobs ADD BoreholeId BIGINT NULL;
    IF COL_LENGTH('dbo.PrintJobs','TemplateCode') IS NULL ALTER TABLE dbo.PrintJobs ADD TemplateCode NVARCHAR(100) NULL;
    IF COL_LENGTH('dbo.PrintJobs','OutputTitle') IS NULL ALTER TABLE dbo.PrintJobs ADD OutputTitle NVARCHAR(300) NULL;
    IF COL_LENGTH('dbo.PrintJobs','OutputFormat') IS NULL ALTER TABLE dbo.PrintJobs ADD OutputFormat NVARCHAR(50) NOT NULL CONSTRAINT DF_PrintJobs_OutputFormat_Compat DEFAULT(N'BrowserPrint');
    IF COL_LENGTH('dbo.PrintJobs','PrintedBy') IS NULL ALTER TABLE dbo.PrintJobs ADD PrintedBy BIGINT NULL;
    IF COL_LENGTH('dbo.PrintJobs','PrintedAt') IS NULL ALTER TABLE dbo.PrintJobs ADD PrintedAt DATETIME2 NOT NULL CONSTRAINT DF_PrintJobs_PrintedAt_Compat DEFAULT(SYSDATETIME());
    IF COL_LENGTH('dbo.PrintJobs','Status') IS NULL ALTER TABLE dbo.PrintJobs ADD Status NVARCHAR(50) NOT NULL CONSTRAINT DF_PrintJobs_Status_Compat DEFAULT(N'Generated');
    IF COL_LENGTH('dbo.PrintJobs','Notes') IS NULL ALTER TABLE dbo.PrintJobs ADD Notes NVARCHAR(MAX) NULL;
    IF COL_LENGTH('dbo.PrintJobs','IsDeleted') IS NULL ALTER TABLE dbo.PrintJobs ADD IsDeleted BIT NOT NULL CONSTRAINT DF_PrintJobs_IsDeleted_Compat DEFAULT(0);
    IF COL_LENGTH('dbo.PrintJobs','DeletedAt') IS NULL ALTER TABLE dbo.PrintJobs ADD DeletedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.PrintJobs','DeletedBy') IS NULL ALTER TABLE dbo.PrintJobs ADD DeletedBy BIGINT NULL;
END
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'IX_PrintJobs_Project' AND object_id=OBJECT_ID(N'dbo.PrintJobs'))
    CREATE INDEX IX_PrintJobs_Project ON dbo.PrintJobs(ProjectId, PrintedAt DESC) WHERE IsDeleted=0;
GO

MERGE dbo.PrintOutputTemplates AS T
USING (VALUES
    (N'PROJECT_PRINT_PACKAGE', N'حزمة طباعة المشروع', N'Project Print Package', N'PROJECT_PACKAGE', N'حزمة مشروع قابلة للطباعة تضم بيانات المشروع والجسات والعينات وSPT والمياه والمختبر.', 1, 10),
    (N'BOREHOLE_LOG_PRINT', N'سجل الجسة للطباعة', N'Borehole Log Print', N'BOREHOLE_LOG', N'نموذج سجل جسة قابل للطباعة أو الحفظ PDF من المتصفح.', 1, 20),
    (N'SPT_SUMMARY_PRINT', N'ملخص اختبارات SPT', N'SPT Summary Print', N'SPT_SUMMARY', N'ملخص اختبارات SPT ضمن حزمة المشروع.', 0, 30),
    (N'LAB_SUMMARY_PRINT', N'ملخص نتائج المختبر', N'Lab Results Summary Print', N'LAB_SUMMARY', N'ملخص نتائج المختبر ضمن حزمة المشروع.', 0, 40)
) AS S(TemplateCode, TemplateNameAr, TemplateNameEn, OutputType, Description, IsDefault, SortOrder)
ON T.TemplateCode=S.TemplateCode AND ISNULL(T.IsDeleted,0)=0
WHEN MATCHED THEN UPDATE SET TemplateNameAr=S.TemplateNameAr, TemplateNameEn=S.TemplateNameEn, OutputType=S.OutputType, Description=S.Description, IsDefault=S.IsDefault, SortOrder=S.SortOrder, IsActive=1
WHEN NOT MATCHED THEN INSERT(TemplateCode, TemplateNameAr, TemplateNameEn, OutputType, Description, IsDefault, SortOrder, IsActive)
VALUES(S.TemplateCode, S.TemplateNameAr, S.TemplateNameEn, S.OutputType, S.Description, S.IsDefault, S.SortOrder, 1);
GO

PRINT N'Sprint 11 print tables created successfully.';
GO
