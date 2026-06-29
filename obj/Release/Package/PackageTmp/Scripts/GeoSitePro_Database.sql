/*
GeoSite Pro - Sprint 1 Database Script
Run this script in SQL Server Management Studio before running the ASP.NET project.
Default login after running the script:
Username: admin
Password: Admin@123
*/

IF DB_ID(N'GeoSitePro') IS NULL
BEGIN
    CREATE DATABASE GeoSitePro;
END
GO

USE GeoSitePro;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.RolePermissions', N'U') IS NOT NULL DROP TABLE dbo.RolePermissions;
IF OBJECT_ID(N'dbo.UserRoles', N'U') IS NOT NULL DROP TABLE dbo.UserRoles;
IF OBJECT_ID(N'dbo.Permissions', N'U') IS NOT NULL DROP TABLE dbo.Permissions;
IF OBJECT_ID(N'dbo.Roles', N'U') IS NOT NULL DROP TABLE dbo.Roles;
IF OBJECT_ID(N'dbo.UserSessions', N'U') IS NOT NULL DROP TABLE dbo.UserSessions;
IF OBJECT_ID(N'dbo.AuditLogs', N'U') IS NOT NULL DROP TABLE dbo.AuditLogs;
IF OBJECT_ID(N'dbo.Reports', N'U') IS NOT NULL DROP TABLE dbo.Reports;
IF OBJECT_ID(N'dbo.Samples', N'U') IS NOT NULL DROP TABLE dbo.Samples;
IF OBJECT_ID(N'dbo.Boreholes', N'U') IS NOT NULL DROP TABLE dbo.Boreholes;
IF OBJECT_ID(N'dbo.BoreholePlans', N'U') IS NOT NULL DROP TABLE dbo.BoreholePlans;
IF OBJECT_ID(N'dbo.Projects', N'U') IS NOT NULL DROP TABLE dbo.Projects;
IF OBJECT_ID(N'dbo.LookupItems', N'U') IS NOT NULL DROP TABLE dbo.LookupItems;
IF OBJECT_ID(N'dbo.LookupCategories', N'U') IS NOT NULL DROP TABLE dbo.LookupCategories;
IF OBJECT_ID(N'dbo.Users', N'U') IS NOT NULL DROP TABLE dbo.Users;
GO

CREATE TABLE dbo.Users
(
    UserId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Users PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL CONSTRAINT UQ_Users_Username UNIQUE,
    FullName NVARCHAR(150) NOT NULL,
    PasswordHash NVARCHAR(200) NOT NULL,
    PasswordSalt NVARCHAR(200) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Users_IsActive DEFAULT(1),
    LastLoginAt DATETIME2 NULL,
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT(SYSDATETIME())
);

CREATE TABLE dbo.Roles
(
    RoleId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Roles PRIMARY KEY,
    RoleName NVARCHAR(100) NOT NULL CONSTRAINT UQ_Roles_RoleName UNIQUE,
    IsActive BIT NOT NULL CONSTRAINT DF_Roles_IsActive DEFAULT(1)
);

CREATE TABLE dbo.Permissions
(
    PermissionId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Permissions PRIMARY KEY,
    PermissionCode NVARCHAR(100) NOT NULL CONSTRAINT UQ_Permissions_PermissionCode UNIQUE,
    PermissionNameAr NVARCHAR(200) NOT NULL
);

CREATE TABLE dbo.UserRoles
(
    UserId BIGINT NOT NULL,
    RoleId INT NOT NULL,
    CONSTRAINT PK_UserRoles PRIMARY KEY(UserId, RoleId),
    CONSTRAINT FK_UserRoles_Users FOREIGN KEY(UserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_UserRoles_Roles FOREIGN KEY(RoleId) REFERENCES dbo.Roles(RoleId)
);

CREATE TABLE dbo.RolePermissions
(
    RoleId INT NOT NULL,
    PermissionId INT NOT NULL,
    CONSTRAINT PK_RolePermissions PRIMARY KEY(RoleId, PermissionId),
    CONSTRAINT FK_RolePermissions_Roles FOREIGN KEY(RoleId) REFERENCES dbo.Roles(RoleId),
    CONSTRAINT FK_RolePermissions_Permissions FOREIGN KEY(PermissionId) REFERENCES dbo.Permissions(PermissionId)
);

CREATE TABLE dbo.UserSessions
(
    UserSessionId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_UserSessions PRIMARY KEY,
    UserId BIGINT NOT NULL,
    SessionToken NVARCHAR(100) NOT NULL,
    LoginAt DATETIME2 NOT NULL,
    LogoutAt DATETIME2 NULL,
    IpAddress NVARCHAR(64) NULL,
    UserAgent NVARCHAR(1000) NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_UserSessions_IsActive DEFAULT(1),
    CONSTRAINT FK_UserSessions_Users FOREIGN KEY(UserId) REFERENCES dbo.Users(UserId)
);

CREATE TABLE dbo.AuditLogs
(
    AuditLogId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_AuditLogs PRIMARY KEY,
    UserId BIGINT NULL,
    Username NVARCHAR(100) NULL,
    ActionType NVARCHAR(50) NOT NULL,
    EntityName NVARCHAR(100) NULL,
    EntityId NVARCHAR(100) NULL,
    ActionDescription NVARCHAR(500) NULL,
    IpAddress NVARCHAR(64) NULL,
    UserAgent NVARCHAR(1000) NULL,
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_AuditLogs_CreatedAt DEFAULT(SYSDATETIME())
);

CREATE TABLE dbo.LookupCategories
(
    CategoryCode NVARCHAR(50) NOT NULL CONSTRAINT PK_LookupCategories PRIMARY KEY,
    CategoryNameAr NVARCHAR(100) NOT NULL
);

CREATE TABLE dbo.LookupItems
(
    LookupItemId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_LookupItems PRIMARY KEY,
    CategoryCode NVARCHAR(50) NOT NULL,
    Code NVARCHAR(50) NOT NULL,
    NameAr NVARCHAR(150) NOT NULL,
    NameEn NVARCHAR(150) NULL,
    SortOrder INT NOT NULL CONSTRAINT DF_LookupItems_SortOrder DEFAULT(0),
    IsActive BIT NOT NULL CONSTRAINT DF_LookupItems_IsActive DEFAULT(1),
    CONSTRAINT FK_LookupItems_Categories FOREIGN KEY(CategoryCode) REFERENCES dbo.LookupCategories(CategoryCode),
    CONSTRAINT UQ_LookupItems_Category_Code UNIQUE(CategoryCode, Code)
);

CREATE TABLE dbo.Projects
(
    ProjectId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Projects PRIMARY KEY,
    ProjectCode NVARCHAR(50) NOT NULL,
    ProjectName NVARCHAR(200) NOT NULL,
    ProjectNameEn NVARCHAR(200) NULL,
    ClientName NVARCHAR(200) NULL,
    ProjectTypeId BIGINT NULL,
    ProjectStatusId BIGINT NULL,
    StructureTypeId BIGINT NULL,
    InvestigationStageId BIGINT NULL,
    Country NVARCHAR(100) NULL,
    City NVARCHAR(100) NULL,
    District NVARCHAR(100) NULL,
    LocationName NVARCHAR(200) NULL,
    Address NVARCHAR(MAX) NULL,
    SiteAreaM2 DECIMAL(18,2) NULL,
    NumberOfFloors INT NULL,
    BasementCount INT NULL,
    ProjectStartDate DATE NULL,
    ProjectEndDate DATE NULL,
    ScopeOfWork NVARCHAR(MAX) NULL,
    GeneralNotes NVARCHAR(MAX) NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Projects_IsActive DEFAULT(1),
    IsDeleted BIT NOT NULL CONSTRAINT DF_Projects_IsDeleted DEFAULT(0),
    CreatedByUserId BIGINT NULL,
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Projects_CreatedAt DEFAULT(SYSDATETIME()),
    UpdatedByUserId BIGINT NULL,
    UpdatedAt DATETIME2 NULL,
    DeletedByUserId BIGINT NULL,
    DeletedAt DATETIME2 NULL,
    CONSTRAINT UQ_Projects_ProjectCode UNIQUE(ProjectCode),
    CONSTRAINT FK_Projects_ProjectType FOREIGN KEY(ProjectTypeId) REFERENCES dbo.LookupItems(LookupItemId),
    CONSTRAINT FK_Projects_ProjectStatus FOREIGN KEY(ProjectStatusId) REFERENCES dbo.LookupItems(LookupItemId),
    CONSTRAINT FK_Projects_StructureType FOREIGN KEY(StructureTypeId) REFERENCES dbo.LookupItems(LookupItemId),
    CONSTRAINT FK_Projects_InvestigationStage FOREIGN KEY(InvestigationStageId) REFERENCES dbo.LookupItems(LookupItemId)
);

CREATE TABLE dbo.BoreholePlans
(
    BoreholePlanId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_BoreholePlans PRIMARY KEY,
    ProjectId BIGINT NOT NULL,
    IsDeleted BIT NOT NULL CONSTRAINT DF_BoreholePlans_IsDeleted DEFAULT(0),
    CONSTRAINT FK_BoreholePlans_Projects FOREIGN KEY(ProjectId) REFERENCES dbo.Projects(ProjectId)
);

CREATE TABLE dbo.Boreholes
(
    BoreholeId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Boreholes PRIMARY KEY,
    ProjectId BIGINT NOT NULL,
    IsDeleted BIT NOT NULL CONSTRAINT DF_Boreholes_IsDeleted DEFAULT(0),
    CONSTRAINT FK_Boreholes_Projects FOREIGN KEY(ProjectId) REFERENCES dbo.Projects(ProjectId)
);

CREATE TABLE dbo.Samples
(
    SampleId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Samples PRIMARY KEY,
    ProjectId BIGINT NOT NULL,
    IsDeleted BIT NOT NULL CONSTRAINT DF_Samples_IsDeleted DEFAULT(0),
    CONSTRAINT FK_Samples_Projects FOREIGN KEY(ProjectId) REFERENCES dbo.Projects(ProjectId)
);

CREATE TABLE dbo.Reports
(
    ReportId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Reports PRIMARY KEY,
    ProjectId BIGINT NOT NULL,
    IsDeleted BIT NOT NULL CONSTRAINT DF_Reports_IsDeleted DEFAULT(0),
    CONSTRAINT FK_Reports_Projects FOREIGN KEY(ProjectId) REFERENCES dbo.Projects(ProjectId)
);
GO

INSERT INTO dbo.LookupCategories(CategoryCode, CategoryNameAr) VALUES
(N'ProjectType', N'نوع المشروع'),
(N'ProjectStatus', N'حالة المشروع'),
(N'StructureType', N'نوع المنشأ'),
(N'InvestigationStage', N'مرحلة التحري');

INSERT INTO dbo.LookupItems(CategoryCode, Code, NameAr, NameEn, SortOrder) VALUES
(N'ProjectType', N'BUILDING', N'مبنى', N'Building', 1),
(N'ProjectType', N'ROAD', N'طريق', N'Road', 2),
(N'ProjectType', N'BRIDGE', N'جسر', N'Bridge', 3),
(N'ProjectType', N'DAM', N'سد', N'Dam', 4),
(N'ProjectType', N'MINING', N'تعدين', N'Mining', 5),
(N'ProjectStatus', N'NEW', N'جديد', N'New', 1),
(N'ProjectStatus', N'ACTIVE', N'نشط', N'Active', 2),
(N'ProjectStatus', N'ON_HOLD', N'متوقف مؤقتًا', N'On Hold', 3),
(N'ProjectStatus', N'CLOSED', N'مغلق', N'Closed', 4),
(N'StructureType', N'RESIDENTIAL', N'سكني', N'Residential', 1),
(N'StructureType', N'COMMERCIAL', N'تجاري', N'Commercial', 2),
(N'StructureType', N'TOWER', N'برج', N'Tower', 3),
(N'StructureType', N'INDUSTRIAL', N'صناعي', N'Industrial', 4),
(N'InvestigationStage', N'DESK', N'دراسة مكتبية', N'Desk Study', 1),
(N'InvestigationStage', N'RECON', N'استطلاع موقعي', N'Reconnaissance', 2),
(N'InvestigationStage', N'DETAILED', N'تحري تفصيلي', N'Detailed Investigation', 3),
(N'InvestigationStage', N'MONITORING', N'مراقبة', N'Monitoring', 4);

INSERT INTO dbo.Permissions(PermissionCode, PermissionNameAr) VALUES
(N'Dashboard.View', N'عرض لوحة التحكم'),
(N'Projects.View', N'عرض المشاريع'),
(N'Projects.Create', N'إضافة مشروع'),
(N'Projects.Edit', N'تعديل مشروع'),
(N'Projects.Delete', N'حذف مشروع'),
(N'DeskStudy.View', N'عرض الدراسة المكتبية'),
(N'SiteVisit.View', N'عرض الزيارة الموقعية'),
(N'BoreholePlanning.View', N'عرض تخطيط الجسات'),
(N'Boreholes.View', N'عرض الجسات'),
(N'BoreholeLog.View', N'عرض سجل الجسات'),
(N'SPT.View', N'عرض اختبارات SPT'),
(N'Samples.View', N'عرض العينات'),
(N'Groundwater.View', N'عرض المياه الجوفية'),
(N'LabResults.View', N'عرض نتائج المختبر'),
(N'Documents.View', N'عرض الوثائق'),
(N'Reports.View', N'عرض التقارير'),
(N'Reports.Edit', N'تحرير التقارير'),
(N'Users.View', N'عرض المستخدمين'),
(N'Roles.View', N'عرض الأدوار'),
(N'Roles.Permissions', N'إدارة صلاحيات الأدوار'),
(N'AuditLog.View', N'عرض سجل التدقيق');

INSERT INTO dbo.Roles(RoleName) VALUES(N'Administrators');

INSERT INTO dbo.Users(Username, FullName, PasswordHash, PasswordSalt, IsActive)
VALUES(N'admin', N'مدير النظام', N'vkcA8RV++7C+xfqy5GYELRQOn8GLAvCvpyH6B/fjrWk=', N'AQIDBAUGBwgJCgsMDQ4PEA==', 1);

INSERT INTO dbo.UserRoles(UserId, RoleId)
SELECT u.UserId, r.RoleId FROM dbo.Users u CROSS JOIN dbo.Roles r
WHERE u.Username = N'admin' AND r.RoleName = N'Administrators';

INSERT INTO dbo.RolePermissions(RoleId, PermissionId)
SELECT r.RoleId, p.PermissionId FROM dbo.Roles r CROSS JOIN dbo.Permissions p
WHERE r.RoleName = N'Administrators';
GO

CREATE OR ALTER PROCEDURE dbo.sp_Login
    @Username NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP(1)
        UserId, Username, FullName, PasswordHash, PasswordSalt, IsActive, LastLoginAt
    FROM dbo.Users
    WHERE Username = @Username;

    SELECT DISTINCT p.PermissionCode
    FROM dbo.Users u
    INNER JOIN dbo.UserRoles ur ON u.UserId = ur.UserId
    INNER JOIN dbo.Roles r ON ur.RoleId = r.RoleId AND r.IsActive = 1
    INNER JOIN dbo.RolePermissions rp ON r.RoleId = rp.RoleId
    INNER JOIN dbo.Permissions p ON rp.PermissionId = p.PermissionId
    WHERE u.Username = @Username AND u.IsActive = 1
    ORDER BY p.PermissionCode;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Lookups_GetByCategory
    @CategoryCode NVARCHAR(50),
    @OnlyActive BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SELECT LookupItemId, CategoryCode, Code, NameAr, NameEn, SortOrder, IsActive
    FROM dbo.LookupItems
    WHERE CategoryCode = @CategoryCode
      AND (@OnlyActive = 0 OR IsActive = 1)
    ORDER BY SortOrder, NameAr;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Projects_Get
    @SearchText NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.ProjectId,
        p.ProjectCode,
        p.ProjectName,
        p.ClientName,
        pt.NameAr AS ProjectTypeNameAr,
        ps.NameAr AS ProjectStatusNameAr,
        p.City,
        p.IsActive,
        p.CreatedAt
    FROM dbo.Projects p
    LEFT JOIN dbo.LookupItems pt ON p.ProjectTypeId = pt.LookupItemId
    LEFT JOIN dbo.LookupItems ps ON p.ProjectStatusId = ps.LookupItemId
    WHERE p.IsDeleted = 0
      AND (
          @SearchText IS NULL OR LTRIM(RTRIM(@SearchText)) = N'' OR
          p.ProjectCode LIKE N'%' + @SearchText + N'%' OR
          p.ProjectName LIKE N'%' + @SearchText + N'%' OR
          ISNULL(p.ClientName, N'') LIKE N'%' + @SearchText + N'%' OR
          ISNULL(p.City, N'') LIKE N'%' + @SearchText + N'%'
      )
    ORDER BY p.CreatedAt DESC, p.ProjectId DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Project_Save
    @ProjectId BIGINT = NULL,
    @ProjectCode NVARCHAR(50),
    @ProjectName NVARCHAR(200),
    @ProjectNameEn NVARCHAR(200) = NULL,
    @ClientName NVARCHAR(200) = NULL,
    @ProjectTypeId BIGINT = NULL,
    @ProjectStatusId BIGINT = NULL,
    @StructureTypeId BIGINT = NULL,
    @InvestigationStageId BIGINT = NULL,
    @Country NVARCHAR(100) = NULL,
    @City NVARCHAR(100) = NULL,
    @District NVARCHAR(100) = NULL,
    @LocationName NVARCHAR(200) = NULL,
    @Address NVARCHAR(MAX) = NULL,
    @SiteAreaM2 DECIMAL(18,2) = NULL,
    @NumberOfFloors INT = NULL,
    @BasementCount INT = NULL,
    @ProjectStartDate DATE = NULL,
    @ProjectEndDate DATE = NULL,
    @ScopeOfWork NVARCHAR(MAX) = NULL,
    @GeneralNotes NVARCHAR(MAX) = NULL,
    @IsActive BIT = 1,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS(SELECT 1 FROM dbo.Projects WHERE ProjectCode = @ProjectCode AND IsDeleted = 0 AND (@ProjectId IS NULL OR ProjectId <> @ProjectId))
    BEGIN
        RAISERROR(N'كود المشروع مستخدم مسبقًا.', 16, 1);
        RETURN;
    END

    IF @ProjectId IS NULL OR @ProjectId <= 0
    BEGIN
        INSERT INTO dbo.Projects
        (
            ProjectCode, ProjectName, ProjectNameEn, ClientName, ProjectTypeId, ProjectStatusId,
            StructureTypeId, InvestigationStageId, Country, City, District, LocationName, Address,
            SiteAreaM2, NumberOfFloors, BasementCount, ProjectStartDate, ProjectEndDate,
            ScopeOfWork, GeneralNotes, IsActive, CreatedByUserId
        )
        VALUES
        (
            @ProjectCode, @ProjectName, @ProjectNameEn, @ClientName, @ProjectTypeId, @ProjectStatusId,
            @StructureTypeId, @InvestigationStageId, @Country, @City, @District, @LocationName, @Address,
            @SiteAreaM2, @NumberOfFloors, @BasementCount, @ProjectStartDate, @ProjectEndDate,
            @ScopeOfWork, @GeneralNotes, @IsActive, @UserId
        );
        SELECT CONVERT(BIGINT, SCOPE_IDENTITY()) AS ProjectId;
    END
    ELSE
    BEGIN
        UPDATE dbo.Projects
        SET ProjectCode = @ProjectCode,
            ProjectName = @ProjectName,
            ProjectNameEn = @ProjectNameEn,
            ClientName = @ClientName,
            ProjectTypeId = @ProjectTypeId,
            ProjectStatusId = @ProjectStatusId,
            StructureTypeId = @StructureTypeId,
            InvestigationStageId = @InvestigationStageId,
            Country = @Country,
            City = @City,
            District = @District,
            LocationName = @LocationName,
            Address = @Address,
            SiteAreaM2 = @SiteAreaM2,
            NumberOfFloors = @NumberOfFloors,
            BasementCount = @BasementCount,
            ProjectStartDate = @ProjectStartDate,
            ProjectEndDate = @ProjectEndDate,
            ScopeOfWork = @ScopeOfWork,
            GeneralNotes = @GeneralNotes,
            IsActive = @IsActive,
            UpdatedByUserId = @UserId,
            UpdatedAt = SYSDATETIME()
        WHERE ProjectId = @ProjectId AND IsDeleted = 0;

        SELECT @ProjectId AS ProjectId;
    END
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Project_GetById
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM dbo.Projects
    WHERE ProjectId = @ProjectId AND IsDeleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Project_Delete
    @ProjectId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Projects
    SET IsDeleted = 1,
        DeletedByUserId = @UserId,
        DeletedAt = SYSDATETIME()
    WHERE ProjectId = @ProjectId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Dashboard_GetSummary
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        (SELECT COUNT(*) FROM dbo.Projects WHERE IsDeleted = 0) AS TotalProjects,
        (SELECT COUNT(*) FROM dbo.Projects WHERE IsDeleted = 0 AND IsActive = 1) AS ActiveProjects,
        (SELECT COUNT(*) FROM dbo.Boreholes WHERE IsDeleted = 0) AS TotalBoreholes,
        (SELECT COUNT(*) FROM dbo.Reports WHERE IsDeleted = 0) AS TotalReports;

    SELECT TOP(10)
        p.ProjectId,
        p.ProjectCode,
        p.ProjectName,
        p.ClientName,
        ISNULL(ps.NameAr, N'غير محدد') AS ProjectStatusNameAr
    FROM dbo.Projects p
    LEFT JOIN dbo.LookupItems ps ON p.ProjectStatusId = ps.LookupItemId
    WHERE p.IsDeleted = 0
    ORDER BY p.CreatedAt DESC, p.ProjectId DESC;

    SELECT
        ISNULL(ps.NameAr, N'غير محدد') AS ProjectStatusNameAr,
        COUNT(*) AS ProjectCount
    FROM dbo.Projects p
    LEFT JOIN dbo.LookupItems ps ON p.ProjectStatusId = ps.LookupItemId
    WHERE p.IsDeleted = 0
    GROUP BY ISNULL(ps.NameAr, N'غير محدد')
    ORDER BY ProjectCount DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProjectDashboard_Get
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.ProjectId,
        p.ProjectCode,
        p.ProjectName,
        p.ClientName,
        p.City,
        p.LocationName,
        p.SiteAreaM2,
        p.NumberOfFloors,
        p.BasementCount,
        pt.NameAr AS ProjectTypeNameAr,
        st.NameAr AS StructureTypeNameAr
    FROM dbo.Projects p
    LEFT JOIN dbo.LookupItems pt ON p.ProjectTypeId = pt.LookupItemId
    LEFT JOIN dbo.LookupItems st ON p.StructureTypeId = st.LookupItemId
    WHERE p.ProjectId = @ProjectId AND p.IsDeleted = 0;

    SELECT
        (SELECT COUNT(*) FROM dbo.BoreholePlans WHERE ProjectId = @ProjectId AND IsDeleted = 0) AS BoreholePlanCount,
        (SELECT COUNT(*) FROM dbo.Boreholes WHERE ProjectId = @ProjectId AND IsDeleted = 0) AS BoreholeCount,
        (SELECT COUNT(*) FROM dbo.Samples WHERE ProjectId = @ProjectId AND IsDeleted = 0) AS SampleCount,
        (SELECT COUNT(*) FROM dbo.Reports WHERE ProjectId = @ProjectId AND IsDeleted = 0) AS ReportCount;
END
GO

PRINT N'GeoSite Pro database installed successfully. Login: admin / Admin@123';
GO
