USE GeoSitePro;
GO

/* Sprint 7: attachments, export packages, and production-readiness checklist. */
IF OBJECT_ID(N'dbo.ProjectDocuments', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProjectDocuments
    (
        ProjectDocumentId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ProjectDocuments PRIMARY KEY,
        ProjectId BIGINT NOT NULL,
        DocumentTypeId BIGINT NULL,
        DocumentTitle NVARCHAR(300) NOT NULL,
        RelatedEntityName NVARCHAR(100) NULL,
        RelatedEntityId BIGINT NULL,
        OriginalFileName NVARCHAR(500) NOT NULL,
        StoredFileName NVARCHAR(500) NOT NULL,
        FileExtension NVARCHAR(20) NULL,
        ContentType NVARCHAR(150) NULL,
        FileSizeBytes BIGINT NULL,
        StoragePath NVARCHAR(1000) NOT NULL,
        VersionNo INT NOT NULL CONSTRAINT DF_ProjectDocuments_VersionNo DEFAULT(1),
        Notes NVARCHAR(MAX) NULL,
        IsApproved BIT NOT NULL CONSTRAINT DF_ProjectDocuments_IsApproved DEFAULT(0),
        ApprovedAt DATETIME2 NULL,
        ApprovedBy BIGINT NULL,
        UploadedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectDocuments_UploadedAt DEFAULT(SYSDATETIME()),
        UploadedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_ProjectDocuments_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO
IF COL_LENGTH('dbo.ProjectDocuments','ProjectId') IS NULL ALTER TABLE dbo.ProjectDocuments ADD ProjectId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectDocuments','DocumentTypeId') IS NULL ALTER TABLE dbo.ProjectDocuments ADD DocumentTypeId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectDocuments','DocumentTitle') IS NULL ALTER TABLE dbo.ProjectDocuments ADD DocumentTitle NVARCHAR(300) NULL;
IF COL_LENGTH('dbo.ProjectDocuments','RelatedEntityName') IS NULL ALTER TABLE dbo.ProjectDocuments ADD RelatedEntityName NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.ProjectDocuments','RelatedEntityId') IS NULL ALTER TABLE dbo.ProjectDocuments ADD RelatedEntityId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectDocuments','OriginalFileName') IS NULL ALTER TABLE dbo.ProjectDocuments ADD OriginalFileName NVARCHAR(500) NULL;
IF COL_LENGTH('dbo.ProjectDocuments','StoredFileName') IS NULL ALTER TABLE dbo.ProjectDocuments ADD StoredFileName NVARCHAR(500) NULL;
IF COL_LENGTH('dbo.ProjectDocuments','FileExtension') IS NULL ALTER TABLE dbo.ProjectDocuments ADD FileExtension NVARCHAR(20) NULL;
IF COL_LENGTH('dbo.ProjectDocuments','ContentType') IS NULL ALTER TABLE dbo.ProjectDocuments ADD ContentType NVARCHAR(150) NULL;
IF COL_LENGTH('dbo.ProjectDocuments','FileSizeBytes') IS NULL ALTER TABLE dbo.ProjectDocuments ADD FileSizeBytes BIGINT NULL;
IF COL_LENGTH('dbo.ProjectDocuments','StoragePath') IS NULL ALTER TABLE dbo.ProjectDocuments ADD StoragePath NVARCHAR(1000) NULL;
IF COL_LENGTH('dbo.ProjectDocuments','VersionNo') IS NULL ALTER TABLE dbo.ProjectDocuments ADD VersionNo INT NOT NULL CONSTRAINT DF_ProjectDocuments_VersionNo2 DEFAULT(1);
IF COL_LENGTH('dbo.ProjectDocuments','Notes') IS NULL ALTER TABLE dbo.ProjectDocuments ADD Notes NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.ProjectDocuments','IsApproved') IS NULL ALTER TABLE dbo.ProjectDocuments ADD IsApproved BIT NOT NULL CONSTRAINT DF_ProjectDocuments_IsApproved2 DEFAULT(0);
IF COL_LENGTH('dbo.ProjectDocuments','ApprovedAt') IS NULL ALTER TABLE dbo.ProjectDocuments ADD ApprovedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ProjectDocuments','ApprovedBy') IS NULL ALTER TABLE dbo.ProjectDocuments ADD ApprovedBy BIGINT NULL;
IF COL_LENGTH('dbo.ProjectDocuments','UploadedAt') IS NULL ALTER TABLE dbo.ProjectDocuments ADD UploadedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectDocuments_UploadedAt2 DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.ProjectDocuments','UploadedBy') IS NULL ALTER TABLE dbo.ProjectDocuments ADD UploadedBy BIGINT NULL;
IF COL_LENGTH('dbo.ProjectDocuments','IsDeleted') IS NULL ALTER TABLE dbo.ProjectDocuments ADD IsDeleted BIT NOT NULL CONSTRAINT DF_ProjectDocuments_IsDeleted2 DEFAULT(0);
IF COL_LENGTH('dbo.ProjectDocuments','DeletedAt') IS NULL ALTER TABLE dbo.ProjectDocuments ADD DeletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ProjectDocuments','DeletedBy') IS NULL ALTER TABLE dbo.ProjectDocuments ADD DeletedBy BIGINT NULL;
GO

IF OBJECT_ID(N'dbo.ExportPackages', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ExportPackages
    (
        ExportPackageId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ExportPackages PRIMARY KEY,
        ProjectId BIGINT NOT NULL,
        PackageTypeId BIGINT NULL,
        PackageStatusId BIGINT NULL,
        PackageTitle NVARCHAR(300) NULL,
        IncludeBoreholes BIT NOT NULL CONSTRAINT DF_ExportPackages_IncludeBoreholes DEFAULT(1),
        IncludeSamples BIT NOT NULL CONSTRAINT DF_ExportPackages_IncludeSamples DEFAULT(1),
        IncludeSPT BIT NOT NULL CONSTRAINT DF_ExportPackages_IncludeSPT DEFAULT(1),
        IncludeGroundwater BIT NOT NULL CONSTRAINT DF_ExportPackages_IncludeGroundwater DEFAULT(1),
        IncludeLabResults BIT NOT NULL CONSTRAINT DF_ExportPackages_IncludeLabResults DEFAULT(1),
        IncludeReports BIT NOT NULL CONSTRAINT DF_ExportPackages_IncludeReports DEFAULT(1),
        IncludeDocuments BIT NOT NULL CONSTRAINT DF_ExportPackages_IncludeDocuments DEFAULT(1),
        OutputPath NVARCHAR(1000) NULL,
        GeneratedAt DATETIME2 NULL,
        GeneratedBy BIGINT NULL,
        Notes NVARCHAR(MAX) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ExportPackages_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_ExportPackages_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO
IF COL_LENGTH('dbo.ExportPackages','ProjectId') IS NULL ALTER TABLE dbo.ExportPackages ADD ProjectId BIGINT NULL;
IF COL_LENGTH('dbo.ExportPackages','PackageTypeId') IS NULL ALTER TABLE dbo.ExportPackages ADD PackageTypeId BIGINT NULL;
IF COL_LENGTH('dbo.ExportPackages','PackageStatusId') IS NULL ALTER TABLE dbo.ExportPackages ADD PackageStatusId BIGINT NULL;
IF COL_LENGTH('dbo.ExportPackages','PackageTitle') IS NULL ALTER TABLE dbo.ExportPackages ADD PackageTitle NVARCHAR(300) NULL;
IF COL_LENGTH('dbo.ExportPackages','IncludeBoreholes') IS NULL ALTER TABLE dbo.ExportPackages ADD IncludeBoreholes BIT NOT NULL CONSTRAINT DF_ExportPackages_IncludeBoreholes2 DEFAULT(1);
IF COL_LENGTH('dbo.ExportPackages','IncludeSamples') IS NULL ALTER TABLE dbo.ExportPackages ADD IncludeSamples BIT NOT NULL CONSTRAINT DF_ExportPackages_IncludeSamples2 DEFAULT(1);
IF COL_LENGTH('dbo.ExportPackages','IncludeSPT') IS NULL ALTER TABLE dbo.ExportPackages ADD IncludeSPT BIT NOT NULL CONSTRAINT DF_ExportPackages_IncludeSPT2 DEFAULT(1);
IF COL_LENGTH('dbo.ExportPackages','IncludeGroundwater') IS NULL ALTER TABLE dbo.ExportPackages ADD IncludeGroundwater BIT NOT NULL CONSTRAINT DF_ExportPackages_IncludeGroundwater2 DEFAULT(1);
IF COL_LENGTH('dbo.ExportPackages','IncludeLabResults') IS NULL ALTER TABLE dbo.ExportPackages ADD IncludeLabResults BIT NOT NULL CONSTRAINT DF_ExportPackages_IncludeLabResults2 DEFAULT(1);
IF COL_LENGTH('dbo.ExportPackages','IncludeReports') IS NULL ALTER TABLE dbo.ExportPackages ADD IncludeReports BIT NOT NULL CONSTRAINT DF_ExportPackages_IncludeReports2 DEFAULT(1);
IF COL_LENGTH('dbo.ExportPackages','IncludeDocuments') IS NULL ALTER TABLE dbo.ExportPackages ADD IncludeDocuments BIT NOT NULL CONSTRAINT DF_ExportPackages_IncludeDocuments2 DEFAULT(1);
IF COL_LENGTH('dbo.ExportPackages','OutputPath') IS NULL ALTER TABLE dbo.ExportPackages ADD OutputPath NVARCHAR(1000) NULL;
IF COL_LENGTH('dbo.ExportPackages','GeneratedAt') IS NULL ALTER TABLE dbo.ExportPackages ADD GeneratedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ExportPackages','GeneratedBy') IS NULL ALTER TABLE dbo.ExportPackages ADD GeneratedBy BIGINT NULL;
IF COL_LENGTH('dbo.ExportPackages','Notes') IS NULL ALTER TABLE dbo.ExportPackages ADD Notes NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.ExportPackages','CreatedAt') IS NULL ALTER TABLE dbo.ExportPackages ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ExportPackages_CreatedAt2 DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.ExportPackages','CreatedBy') IS NULL ALTER TABLE dbo.ExportPackages ADD CreatedBy BIGINT NULL;
IF COL_LENGTH('dbo.ExportPackages','IsDeleted') IS NULL ALTER TABLE dbo.ExportPackages ADD IsDeleted BIT NOT NULL CONSTRAINT DF_ExportPackages_IsDeleted2 DEFAULT(0);
IF COL_LENGTH('dbo.ExportPackages','DeletedAt') IS NULL ALTER TABLE dbo.ExportPackages ADD DeletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ExportPackages','DeletedBy') IS NULL ALTER TABLE dbo.ExportPackages ADD DeletedBy BIGINT NULL;
GO

IF OBJECT_ID(N'dbo.ProductionReadinessChecks', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProductionReadinessChecks
    (
        ReadinessCheckId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ProductionReadinessChecks PRIMARY KEY,
        ReadinessAreaId BIGINT NULL,
        CheckItem NVARCHAR(1000) NOT NULL,
        ReadinessStatusId BIGINT NULL,
        Evidence NVARCHAR(MAX) NULL,
        Owner NVARCHAR(200) NULL,
        ReviewedDate DATE NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ProductionReadinessChecks_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_ProductionReadinessChecks_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO
IF COL_LENGTH('dbo.ProductionReadinessChecks','ReadinessAreaId') IS NULL ALTER TABLE dbo.ProductionReadinessChecks ADD ReadinessAreaId BIGINT NULL;
IF COL_LENGTH('dbo.ProductionReadinessChecks','CheckItem') IS NULL ALTER TABLE dbo.ProductionReadinessChecks ADD CheckItem NVARCHAR(1000) NULL;
IF COL_LENGTH('dbo.ProductionReadinessChecks','ReadinessStatusId') IS NULL ALTER TABLE dbo.ProductionReadinessChecks ADD ReadinessStatusId BIGINT NULL;
IF COL_LENGTH('dbo.ProductionReadinessChecks','Evidence') IS NULL ALTER TABLE dbo.ProductionReadinessChecks ADD Evidence NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.ProductionReadinessChecks','Owner') IS NULL ALTER TABLE dbo.ProductionReadinessChecks ADD Owner NVARCHAR(200) NULL;
IF COL_LENGTH('dbo.ProductionReadinessChecks','ReviewedDate') IS NULL ALTER TABLE dbo.ProductionReadinessChecks ADD ReviewedDate DATE NULL;
IF COL_LENGTH('dbo.ProductionReadinessChecks','CreatedAt') IS NULL ALTER TABLE dbo.ProductionReadinessChecks ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ProductionReadinessChecks_CreatedAt2 DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.ProductionReadinessChecks','CreatedBy') IS NULL ALTER TABLE dbo.ProductionReadinessChecks ADD CreatedBy BIGINT NULL;
IF COL_LENGTH('dbo.ProductionReadinessChecks','UpdatedAt') IS NULL ALTER TABLE dbo.ProductionReadinessChecks ADD UpdatedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ProductionReadinessChecks','UpdatedBy') IS NULL ALTER TABLE dbo.ProductionReadinessChecks ADD UpdatedBy BIGINT NULL;
IF COL_LENGTH('dbo.ProductionReadinessChecks','IsDeleted') IS NULL ALTER TABLE dbo.ProductionReadinessChecks ADD IsDeleted BIT NOT NULL CONSTRAINT DF_ProductionReadinessChecks_IsDeleted2 DEFAULT(0);
IF COL_LENGTH('dbo.ProductionReadinessChecks','DeletedAt') IS NULL ALTER TABLE dbo.ProductionReadinessChecks ADD DeletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ProductionReadinessChecks','DeletedBy') IS NULL ALTER TABLE dbo.ProductionReadinessChecks ADD DeletedBy BIGINT NULL;
GO

PRINT N'Sprint 7 tables created successfully.';
GO
