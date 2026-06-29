USE GeoSitePro;
GO

/*
GeoSitePro Sprint 5 compatibility patch
Run before Sprint 5 permissions and stored procedures.
It keeps existing data and only adds missing columns needed by Users/Roles/Permissions/Audit Log pages.
*/

IF OBJECT_ID(N'dbo.Users', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Users','Email') IS NULL ALTER TABLE dbo.Users ADD Email NVARCHAR(200) NULL;
    IF COL_LENGTH('dbo.Users','Mobile') IS NULL ALTER TABLE dbo.Users ADD Mobile NVARCHAR(50) NULL;
    IF COL_LENGTH('dbo.Users','CreatedBy') IS NULL ALTER TABLE dbo.Users ADD CreatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.Users','UpdatedAt') IS NULL ALTER TABLE dbo.Users ADD UpdatedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.Users','UpdatedBy') IS NULL ALTER TABLE dbo.Users ADD UpdatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.Users','IsDeleted') IS NULL ALTER TABLE dbo.Users ADD IsDeleted BIT NOT NULL CONSTRAINT DF_Users_IsDeleted_S5 DEFAULT(0);
    IF COL_LENGTH('dbo.Users','DeletedAt') IS NULL ALTER TABLE dbo.Users ADD DeletedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.Users','DeletedBy') IS NULL ALTER TABLE dbo.Users ADD DeletedBy BIGINT NULL;
END
GO

IF OBJECT_ID(N'dbo.Roles', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Roles','Description') IS NULL ALTER TABLE dbo.Roles ADD Description NVARCHAR(500) NULL;
    IF COL_LENGTH('dbo.Roles','CreatedAt') IS NULL ALTER TABLE dbo.Roles ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Roles_CreatedAt_S5 DEFAULT(SYSDATETIME());
    IF COL_LENGTH('dbo.Roles','CreatedBy') IS NULL ALTER TABLE dbo.Roles ADD CreatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.Roles','UpdatedAt') IS NULL ALTER TABLE dbo.Roles ADD UpdatedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.Roles','UpdatedBy') IS NULL ALTER TABLE dbo.Roles ADD UpdatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.Roles','IsDeleted') IS NULL ALTER TABLE dbo.Roles ADD IsDeleted BIT NOT NULL CONSTRAINT DF_Roles_IsDeleted_S5 DEFAULT(0);
    IF COL_LENGTH('dbo.Roles','DeletedAt') IS NULL ALTER TABLE dbo.Roles ADD DeletedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.Roles','DeletedBy') IS NULL ALTER TABLE dbo.Roles ADD DeletedBy BIGINT NULL;
END
GO

IF OBJECT_ID(N'dbo.Permissions', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Permissions','ModuleName') IS NULL ALTER TABLE dbo.Permissions ADD ModuleName NVARCHAR(100) NULL;
    IF COL_LENGTH('dbo.Permissions','PermissionNameEn') IS NULL ALTER TABLE dbo.Permissions ADD PermissionNameEn NVARCHAR(200) NULL;
    IF COL_LENGTH('dbo.Permissions','Description') IS NULL ALTER TABLE dbo.Permissions ADD Description NVARCHAR(500) NULL;
    IF COL_LENGTH('dbo.Permissions','SortOrder') IS NULL ALTER TABLE dbo.Permissions ADD SortOrder INT NOT NULL CONSTRAINT DF_Permissions_SortOrder_S5 DEFAULT(100);
    IF COL_LENGTH('dbo.Permissions','IsActive') IS NULL ALTER TABLE dbo.Permissions ADD IsActive BIT NOT NULL CONSTRAINT DF_Permissions_IsActive_S5 DEFAULT(1);
    IF COL_LENGTH('dbo.Permissions','CreatedAt') IS NULL ALTER TABLE dbo.Permissions ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Permissions_CreatedAt_S5 DEFAULT(SYSDATETIME());
    IF COL_LENGTH('dbo.Permissions','IsDeleted') IS NULL ALTER TABLE dbo.Permissions ADD IsDeleted BIT NOT NULL CONSTRAINT DF_Permissions_IsDeleted_S5 DEFAULT(0);
END
GO

IF OBJECT_ID(N'dbo.UserRoles', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.UserRoles','AssignedAt') IS NULL ALTER TABLE dbo.UserRoles ADD AssignedAt DATETIME2 NOT NULL CONSTRAINT DF_UserRoles_AssignedAt_S5 DEFAULT(SYSDATETIME());
    IF COL_LENGTH('dbo.UserRoles','AssignedBy') IS NULL ALTER TABLE dbo.UserRoles ADD AssignedBy BIGINT NULL;
    IF COL_LENGTH('dbo.UserRoles','IsActive') IS NULL ALTER TABLE dbo.UserRoles ADD IsActive BIT NOT NULL CONSTRAINT DF_UserRoles_IsActive_S5 DEFAULT(1);
END
GO

IF OBJECT_ID(N'dbo.RolePermissions', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.RolePermissions','GrantedAt') IS NULL ALTER TABLE dbo.RolePermissions ADD GrantedAt DATETIME2 NOT NULL CONSTRAINT DF_RolePermissions_GrantedAt_S5 DEFAULT(SYSDATETIME());
    IF COL_LENGTH('dbo.RolePermissions','GrantedBy') IS NULL ALTER TABLE dbo.RolePermissions ADD GrantedBy BIGINT NULL;
END
GO

IF OBJECT_ID(N'dbo.AuditLogs', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.AuditLogs','OldValues') IS NULL ALTER TABLE dbo.AuditLogs ADD OldValues NVARCHAR(MAX) NULL;
    IF COL_LENGTH('dbo.AuditLogs','NewValues') IS NULL ALTER TABLE dbo.AuditLogs ADD NewValues NVARCHAR(MAX) NULL;
    IF COL_LENGTH('dbo.AuditLogs','IpAddress') IS NULL ALTER TABLE dbo.AuditLogs ADD IpAddress NVARCHAR(100) NULL;
    IF COL_LENGTH('dbo.AuditLogs','UserAgent') IS NULL ALTER TABLE dbo.AuditLogs ADD UserAgent NVARCHAR(1000) NULL;
    IF COL_LENGTH('dbo.AuditLogs','ActionDate') IS NULL ALTER TABLE dbo.AuditLogs ADD ActionDate DATETIME2 NOT NULL CONSTRAINT DF_AuditLogs_ActionDate_S5 DEFAULT(SYSDATETIME());
END
GO

PRINT N'Sprint 5 schema compatibility completed.';
GO
