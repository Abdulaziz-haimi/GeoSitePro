USE GeoSitePro;
GO

/* Sprint 8: Project Type Investigation Templates.
   Safe compatibility script: adds project-type templates, template items,
   project investigation plans, and generated plan items. */

IF OBJECT_ID(N'dbo.AuditLogs', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.AuditLogs','OldValues') IS NULL ALTER TABLE dbo.AuditLogs ADD OldValues NVARCHAR(MAX) NULL;
    IF COL_LENGTH('dbo.AuditLogs','NewValues') IS NULL ALTER TABLE dbo.AuditLogs ADD NewValues NVARCHAR(MAX) NULL;
END
GO

IF OBJECT_ID(N'dbo.InvestigationTemplates', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.InvestigationTemplates
    (
        TemplateId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_InvestigationTemplates PRIMARY KEY,
        ProjectTypeId BIGINT NULL,
        InvestigationStageId BIGINT NULL,
        RiskLevelId BIGINT NULL,
        TemplateCode NVARCHAR(100) NOT NULL,
        TemplateNameAr NVARCHAR(300) NOT NULL,
        TemplateNameEn NVARCHAR(300) NULL,
        ApplicabilitySummary NVARCHAR(MAX) NULL,
        MinSiteAreaM2 DECIMAL(18,2) NULL,
        MaxSiteAreaM2 DECIMAL(18,2) NULL,
        MinFloors INT NULL,
        MaxFloors INT NULL,
        DefaultBoreholeCount INT NULL,
        DefaultMinDepthM DECIMAL(18,2) NULL,
        DefaultSPTIntervalM DECIMAL(18,2) NULL,
        IsDefault BIT NOT NULL CONSTRAINT DF_InvestigationTemplates_IsDefault DEFAULT(0),
        IsActive BIT NOT NULL CONSTRAINT DF_InvestigationTemplates_IsActive DEFAULT(1),
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_InvestigationTemplates_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_InvestigationTemplates_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO

IF COL_LENGTH('dbo.InvestigationTemplates','ProjectTypeId') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD ProjectTypeId BIGINT NULL;
IF COL_LENGTH('dbo.InvestigationTemplates','InvestigationStageId') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD InvestigationStageId BIGINT NULL;
IF COL_LENGTH('dbo.InvestigationTemplates','RiskLevelId') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD RiskLevelId BIGINT NULL;
IF COL_LENGTH('dbo.InvestigationTemplates','TemplateCode') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD TemplateCode NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.InvestigationTemplates','TemplateNameAr') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD TemplateNameAr NVARCHAR(300) NULL;
IF COL_LENGTH('dbo.InvestigationTemplates','TemplateNameEn') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD TemplateNameEn NVARCHAR(300) NULL;
IF COL_LENGTH('dbo.InvestigationTemplates','ApplicabilitySummary') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD ApplicabilitySummary NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.InvestigationTemplates','MinSiteAreaM2') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD MinSiteAreaM2 DECIMAL(18,2) NULL;
IF COL_LENGTH('dbo.InvestigationTemplates','MaxSiteAreaM2') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD MaxSiteAreaM2 DECIMAL(18,2) NULL;
IF COL_LENGTH('dbo.InvestigationTemplates','MinFloors') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD MinFloors INT NULL;
IF COL_LENGTH('dbo.InvestigationTemplates','MaxFloors') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD MaxFloors INT NULL;
IF COL_LENGTH('dbo.InvestigationTemplates','DefaultBoreholeCount') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD DefaultBoreholeCount INT NULL;
IF COL_LENGTH('dbo.InvestigationTemplates','DefaultMinDepthM') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD DefaultMinDepthM DECIMAL(18,2) NULL;
IF COL_LENGTH('dbo.InvestigationTemplates','DefaultSPTIntervalM') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD DefaultSPTIntervalM DECIMAL(18,2) NULL;
IF COL_LENGTH('dbo.InvestigationTemplates','IsDefault') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD IsDefault BIT NOT NULL CONSTRAINT DF_InvestigationTemplates_IsDefault2 DEFAULT(0);
IF COL_LENGTH('dbo.InvestigationTemplates','IsActive') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD IsActive BIT NOT NULL CONSTRAINT DF_InvestigationTemplates_IsActive2 DEFAULT(1);
IF COL_LENGTH('dbo.InvestigationTemplates','CreatedAt') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_InvestigationTemplates_CreatedAt2 DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.InvestigationTemplates','CreatedBy') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD CreatedBy BIGINT NULL;
IF COL_LENGTH('dbo.InvestigationTemplates','UpdatedAt') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD UpdatedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.InvestigationTemplates','UpdatedBy') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD UpdatedBy BIGINT NULL;
IF COL_LENGTH('dbo.InvestigationTemplates','IsDeleted') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD IsDeleted BIT NOT NULL CONSTRAINT DF_InvestigationTemplates_IsDeleted2 DEFAULT(0);
IF COL_LENGTH('dbo.InvestigationTemplates','DeletedAt') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD DeletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.InvestigationTemplates','DeletedBy') IS NULL ALTER TABLE dbo.InvestigationTemplates ADD DeletedBy BIGINT NULL;
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'UX_InvestigationTemplates_Code' AND object_id=OBJECT_ID(N'dbo.InvestigationTemplates'))
    CREATE UNIQUE INDEX UX_InvestigationTemplates_Code ON dbo.InvestigationTemplates(TemplateCode) WHERE IsDeleted=0;
GO

IF OBJECT_ID(N'dbo.InvestigationTemplateItems', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.InvestigationTemplateItems
    (
        TemplateItemId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_InvestigationTemplateItems PRIMARY KEY,
        TemplateId BIGINT NOT NULL,
        ItemCategoryId BIGINT NULL,
        ItemCode NVARCHAR(100) NOT NULL,
        ItemTitleAr NVARCHAR(300) NOT NULL,
        ItemTitleEn NVARCHAR(300) NULL,
        RecommendationText NVARCHAR(MAX) NULL,
        MinQuantity DECIMAL(18,2) NULL,
        SpacingMeters DECIMAL(18,2) NULL,
        MinDepthM DECIMAL(18,2) NULL,
        MaxDepthM DECIMAL(18,2) NULL,
        FrequencyRule NVARCHAR(500) NULL,
        DepthRule NVARCHAR(500) NULL,
        StandardReference NVARCHAR(300) NULL,
        IsMandatory BIT NOT NULL CONSTRAINT DF_InvestigationTemplateItems_IsMandatory DEFAULT(1),
        SortOrder INT NOT NULL CONSTRAINT DF_InvestigationTemplateItems_SortOrder DEFAULT(100),
        IsActive BIT NOT NULL CONSTRAINT DF_InvestigationTemplateItems_IsActive DEFAULT(1),
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_InvestigationTemplateItems_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_InvestigationTemplateItems_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO
IF COL_LENGTH('dbo.InvestigationTemplateItems','TemplateId') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD TemplateId BIGINT NULL;
IF COL_LENGTH('dbo.InvestigationTemplateItems','ItemCategoryId') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD ItemCategoryId BIGINT NULL;
IF COL_LENGTH('dbo.InvestigationTemplateItems','ItemCode') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD ItemCode NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.InvestigationTemplateItems','ItemTitleAr') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD ItemTitleAr NVARCHAR(300) NULL;
IF COL_LENGTH('dbo.InvestigationTemplateItems','ItemTitleEn') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD ItemTitleEn NVARCHAR(300) NULL;
IF COL_LENGTH('dbo.InvestigationTemplateItems','RecommendationText') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD RecommendationText NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.InvestigationTemplateItems','MinQuantity') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD MinQuantity DECIMAL(18,2) NULL;
IF COL_LENGTH('dbo.InvestigationTemplateItems','SpacingMeters') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD SpacingMeters DECIMAL(18,2) NULL;
IF COL_LENGTH('dbo.InvestigationTemplateItems','MinDepthM') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD MinDepthM DECIMAL(18,2) NULL;
IF COL_LENGTH('dbo.InvestigationTemplateItems','MaxDepthM') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD MaxDepthM DECIMAL(18,2) NULL;
IF COL_LENGTH('dbo.InvestigationTemplateItems','FrequencyRule') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD FrequencyRule NVARCHAR(500) NULL;
IF COL_LENGTH('dbo.InvestigationTemplateItems','DepthRule') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD DepthRule NVARCHAR(500) NULL;
IF COL_LENGTH('dbo.InvestigationTemplateItems','StandardReference') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD StandardReference NVARCHAR(300) NULL;
IF COL_LENGTH('dbo.InvestigationTemplateItems','IsMandatory') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD IsMandatory BIT NOT NULL CONSTRAINT DF_InvestigationTemplateItems_IsMandatory2 DEFAULT(1);
IF COL_LENGTH('dbo.InvestigationTemplateItems','SortOrder') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD SortOrder INT NOT NULL CONSTRAINT DF_InvestigationTemplateItems_SortOrder2 DEFAULT(100);
IF COL_LENGTH('dbo.InvestigationTemplateItems','IsActive') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD IsActive BIT NOT NULL CONSTRAINT DF_InvestigationTemplateItems_IsActive2 DEFAULT(1);
IF COL_LENGTH('dbo.InvestigationTemplateItems','CreatedAt') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_InvestigationTemplateItems_CreatedAt2 DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.InvestigationTemplateItems','CreatedBy') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD CreatedBy BIGINT NULL;
IF COL_LENGTH('dbo.InvestigationTemplateItems','UpdatedAt') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD UpdatedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.InvestigationTemplateItems','UpdatedBy') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD UpdatedBy BIGINT NULL;
IF COL_LENGTH('dbo.InvestigationTemplateItems','IsDeleted') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD IsDeleted BIT NOT NULL CONSTRAINT DF_InvestigationTemplateItems_IsDeleted2 DEFAULT(0);
IF COL_LENGTH('dbo.InvestigationTemplateItems','DeletedAt') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD DeletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.InvestigationTemplateItems','DeletedBy') IS NULL ALTER TABLE dbo.InvestigationTemplateItems ADD DeletedBy BIGINT NULL;
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'IX_InvestigationTemplateItems_Template' AND object_id=OBJECT_ID(N'dbo.InvestigationTemplateItems'))
    CREATE INDEX IX_InvestigationTemplateItems_Template ON dbo.InvestigationTemplateItems(TemplateId, SortOrder);
GO

IF OBJECT_ID(N'dbo.ProjectInvestigationPlans', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProjectInvestigationPlans
    (
        PlanId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ProjectInvestigationPlans PRIMARY KEY,
        ProjectId BIGINT NOT NULL,
        TemplateId BIGINT NULL,
        PlanTitle NVARCHAR(300) NULL,
        PlanStatusId BIGINT NULL,
        GeneratedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectInvestigationPlans_GeneratedAt DEFAULT(SYSDATETIME()),
        GeneratedBy BIGINT NULL,
        IsApproved BIT NOT NULL CONSTRAINT DF_ProjectInvestigationPlans_IsApproved DEFAULT(0),
        ApprovedAt DATETIME2 NULL,
        ApprovedBy BIGINT NULL,
        ApprovalNotes NVARCHAR(MAX) NULL,
        RevisionNo INT NOT NULL CONSTRAINT DF_ProjectInvestigationPlans_RevisionNo DEFAULT(1),
        Notes NVARCHAR(MAX) NULL,
        IsActive BIT NOT NULL CONSTRAINT DF_ProjectInvestigationPlans_IsActive DEFAULT(1),
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectInvestigationPlans_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_ProjectInvestigationPlans_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO
IF COL_LENGTH('dbo.ProjectInvestigationPlans','ProjectId') IS NULL ALTER TABLE dbo.ProjectInvestigationPlans ADD ProjectId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlans','TemplateId') IS NULL ALTER TABLE dbo.ProjectInvestigationPlans ADD TemplateId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlans','PlanTitle') IS NULL ALTER TABLE dbo.ProjectInvestigationPlans ADD PlanTitle NVARCHAR(300) NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlans','PlanStatusId') IS NULL ALTER TABLE dbo.ProjectInvestigationPlans ADD PlanStatusId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlans','GeneratedAt') IS NULL ALTER TABLE dbo.ProjectInvestigationPlans ADD GeneratedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectInvestigationPlans_GeneratedAt2 DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.ProjectInvestigationPlans','GeneratedBy') IS NULL ALTER TABLE dbo.ProjectInvestigationPlans ADD GeneratedBy BIGINT NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlans','IsApproved') IS NULL ALTER TABLE dbo.ProjectInvestigationPlans ADD IsApproved BIT NOT NULL CONSTRAINT DF_ProjectInvestigationPlans_IsApproved2 DEFAULT(0);
IF COL_LENGTH('dbo.ProjectInvestigationPlans','ApprovedAt') IS NULL ALTER TABLE dbo.ProjectInvestigationPlans ADD ApprovedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlans','ApprovedBy') IS NULL ALTER TABLE dbo.ProjectInvestigationPlans ADD ApprovedBy BIGINT NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlans','ApprovalNotes') IS NULL ALTER TABLE dbo.ProjectInvestigationPlans ADD ApprovalNotes NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlans','RevisionNo') IS NULL ALTER TABLE dbo.ProjectInvestigationPlans ADD RevisionNo INT NOT NULL CONSTRAINT DF_ProjectInvestigationPlans_RevisionNo2 DEFAULT(1);
IF COL_LENGTH('dbo.ProjectInvestigationPlans','Notes') IS NULL ALTER TABLE dbo.ProjectInvestigationPlans ADD Notes NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlans','IsActive') IS NULL ALTER TABLE dbo.ProjectInvestigationPlans ADD IsActive BIT NOT NULL CONSTRAINT DF_ProjectInvestigationPlans_IsActive2 DEFAULT(1);
IF COL_LENGTH('dbo.ProjectInvestigationPlans','CreatedAt') IS NULL ALTER TABLE dbo.ProjectInvestigationPlans ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectInvestigationPlans_CreatedAt2 DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.ProjectInvestigationPlans','CreatedBy') IS NULL ALTER TABLE dbo.ProjectInvestigationPlans ADD CreatedBy BIGINT NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlans','UpdatedAt') IS NULL ALTER TABLE dbo.ProjectInvestigationPlans ADD UpdatedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlans','UpdatedBy') IS NULL ALTER TABLE dbo.ProjectInvestigationPlans ADD UpdatedBy BIGINT NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlans','IsDeleted') IS NULL ALTER TABLE dbo.ProjectInvestigationPlans ADD IsDeleted BIT NOT NULL CONSTRAINT DF_ProjectInvestigationPlans_IsDeleted2 DEFAULT(0);
IF COL_LENGTH('dbo.ProjectInvestigationPlans','DeletedAt') IS NULL ALTER TABLE dbo.ProjectInvestigationPlans ADD DeletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlans','DeletedBy') IS NULL ALTER TABLE dbo.ProjectInvestigationPlans ADD DeletedBy BIGINT NULL;
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'IX_ProjectInvestigationPlans_Project' AND object_id=OBJECT_ID(N'dbo.ProjectInvestigationPlans'))
    CREATE INDEX IX_ProjectInvestigationPlans_Project ON dbo.ProjectInvestigationPlans(ProjectId, IsDeleted, IsActive);
GO

IF OBJECT_ID(N'dbo.ProjectInvestigationPlanItems', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProjectInvestigationPlanItems
    (
        PlanItemId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ProjectInvestigationPlanItems PRIMARY KEY,
        PlanId BIGINT NOT NULL,
        TemplateItemId BIGINT NULL,
        ItemCategoryId BIGINT NULL,
        ItemCode NVARCHAR(100) NULL,
        ItemTitleAr NVARCHAR(300) NOT NULL,
        RecommendationText NVARCHAR(MAX) NULL,
        PlannedQuantity DECIMAL(18,2) NULL,
        PlannedSpacingM DECIMAL(18,2) NULL,
        PlannedDepthM DECIMAL(18,2) NULL,
        FrequencyRule NVARCHAR(500) NULL,
        DepthRule NVARCHAR(500) NULL,
        StandardReference NVARCHAR(300) NULL,
        IsMandatory BIT NOT NULL CONSTRAINT DF_ProjectInvestigationPlanItems_IsMandatory DEFAULT(1),
        IsAccepted BIT NOT NULL CONSTRAINT DF_ProjectInvestigationPlanItems_IsAccepted DEFAULT(1),
        ItemStatusId BIGINT NULL,
        EngineerNotes NVARCHAR(MAX) NULL,
        SortOrder INT NOT NULL CONSTRAINT DF_ProjectInvestigationPlanItems_SortOrder DEFAULT(100),
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectInvestigationPlanItems_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_ProjectInvestigationPlanItems_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','PlanId') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD PlanId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','TemplateItemId') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD TemplateItemId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','ItemCategoryId') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD ItemCategoryId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','ItemCode') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD ItemCode NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','ItemTitleAr') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD ItemTitleAr NVARCHAR(300) NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','RecommendationText') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD RecommendationText NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','PlannedQuantity') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD PlannedQuantity DECIMAL(18,2) NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','PlannedSpacingM') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD PlannedSpacingM DECIMAL(18,2) NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','PlannedDepthM') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD PlannedDepthM DECIMAL(18,2) NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','FrequencyRule') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD FrequencyRule NVARCHAR(500) NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','DepthRule') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD DepthRule NVARCHAR(500) NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','StandardReference') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD StandardReference NVARCHAR(300) NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','IsMandatory') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD IsMandatory BIT NOT NULL CONSTRAINT DF_ProjectInvestigationPlanItems_IsMandatory2 DEFAULT(1);
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','IsAccepted') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD IsAccepted BIT NOT NULL CONSTRAINT DF_ProjectInvestigationPlanItems_IsAccepted2 DEFAULT(1);
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','ItemStatusId') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD ItemStatusId BIGINT NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','EngineerNotes') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD EngineerNotes NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','SortOrder') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD SortOrder INT NOT NULL CONSTRAINT DF_ProjectInvestigationPlanItems_SortOrder2 DEFAULT(100);
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','CreatedAt') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectInvestigationPlanItems_CreatedAt2 DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','CreatedBy') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD CreatedBy BIGINT NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','UpdatedAt') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD UpdatedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','UpdatedBy') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD UpdatedBy BIGINT NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','IsDeleted') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD IsDeleted BIT NOT NULL CONSTRAINT DF_ProjectInvestigationPlanItems_IsDeleted2 DEFAULT(0);
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','DeletedAt') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD DeletedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.ProjectInvestigationPlanItems','DeletedBy') IS NULL ALTER TABLE dbo.ProjectInvestigationPlanItems ADD DeletedBy BIGINT NULL;
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'IX_ProjectInvestigationPlanItems_Plan' AND object_id=OBJECT_ID(N'dbo.ProjectInvestigationPlanItems'))
    CREATE INDEX IX_ProjectInvestigationPlanItems_Plan ON dbo.ProjectInvestigationPlanItems(PlanId, SortOrder);
GO

PRINT N'Sprint 8 tables created successfully.';
GO
