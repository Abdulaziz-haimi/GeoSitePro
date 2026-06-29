USE GeoSitePro;
GO

IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Users
(
    UserId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Users PRIMARY KEY,
    Username NVARCHAR(100) NOT NULL,
    FullName NVARCHAR(200) NOT NULL,
    Email NVARCHAR(200) NULL,
    Mobile NVARCHAR(50) NULL,
    PasswordHash NVARCHAR(500) NOT NULL,
    PasswordSalt NVARCHAR(500) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Users_IsActive DEFAULT(1),
    LastLoginAt DATETIME2 NULL,
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT(SYSDATETIME()),
    CreatedBy BIGINT NULL,
    UpdatedAt DATETIME2 NULL,
    UpdatedBy BIGINT NULL,
    IsDeleted BIT NOT NULL CONSTRAINT DF_Users_IsDeleted DEFAULT(0),
    DeletedAt DATETIME2 NULL,
    DeletedBy BIGINT NULL
);
CREATE UNIQUE INDEX UX_Users_Username ON dbo.Users(Username) WHERE IsDeleted = 0;
END
GO

IF OBJECT_ID(N'dbo.Roles', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Roles
(
    RoleId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Roles PRIMARY KEY,
    RoleName NVARCHAR(150) NOT NULL,
    Description NVARCHAR(500) NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Roles_IsActive DEFAULT(1),
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Roles_CreatedAt DEFAULT(SYSDATETIME()),
    CreatedBy BIGINT NULL,
    UpdatedAt DATETIME2 NULL,
    UpdatedBy BIGINT NULL,
    IsDeleted BIT NOT NULL CONSTRAINT DF_Roles_IsDeleted DEFAULT(0),
    DeletedAt DATETIME2 NULL,
    DeletedBy BIGINT NULL
);
CREATE UNIQUE INDEX UX_Roles_RoleName ON dbo.Roles(RoleName) WHERE IsDeleted = 0;
END
GO

IF OBJECT_ID(N'dbo.UserRoles', N'U') IS NULL
BEGIN
CREATE TABLE dbo.UserRoles
(
    UserRoleId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_UserRoles PRIMARY KEY,
    UserId BIGINT NOT NULL,
    RoleId BIGINT NOT NULL,
    AssignedAt DATETIME2 NOT NULL CONSTRAINT DF_UserRoles_AssignedAt DEFAULT(SYSDATETIME()),
    AssignedBy BIGINT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_UserRoles_IsActive DEFAULT(1),
    CONSTRAINT FK_UserRoles_Users FOREIGN KEY(UserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_UserRoles_Roles FOREIGN KEY(RoleId) REFERENCES dbo.Roles(RoleId)
);
CREATE UNIQUE INDEX UX_UserRoles_User_Role_Active ON dbo.UserRoles(UserId, RoleId) WHERE IsActive = 1;
END
GO

IF OBJECT_ID(N'dbo.Permissions', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Permissions
(
    PermissionId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Permissions PRIMARY KEY,
    ModuleName NVARCHAR(100) NOT NULL,
    PermissionCode NVARCHAR(150) NOT NULL,
    PermissionNameAr NVARCHAR(200) NOT NULL,
    PermissionNameEn NVARCHAR(200) NULL,
    Description NVARCHAR(500) NULL,
    SortOrder INT NOT NULL CONSTRAINT DF_Permissions_SortOrder DEFAULT(100),
    IsActive BIT NOT NULL CONSTRAINT DF_Permissions_IsActive DEFAULT(1),
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Permissions_CreatedAt DEFAULT(SYSDATETIME()),
    IsDeleted BIT NOT NULL CONSTRAINT DF_Permissions_IsDeleted DEFAULT(0)
);
CREATE UNIQUE INDEX UX_Permissions_Code ON dbo.Permissions(PermissionCode) WHERE IsDeleted = 0;
END
GO

IF OBJECT_ID(N'dbo.RolePermissions', N'U') IS NULL
BEGIN
CREATE TABLE dbo.RolePermissions
(
    RolePermissionId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_RolePermissions PRIMARY KEY,
    RoleId BIGINT NOT NULL,
    PermissionId BIGINT NOT NULL,
    GrantedAt DATETIME2 NOT NULL CONSTRAINT DF_RolePermissions_GrantedAt DEFAULT(SYSDATETIME()),
    GrantedBy BIGINT NULL,
    CONSTRAINT FK_RolePermissions_Roles FOREIGN KEY(RoleId) REFERENCES dbo.Roles(RoleId),
    CONSTRAINT FK_RolePermissions_Permissions FOREIGN KEY(PermissionId) REFERENCES dbo.Permissions(PermissionId)
);
CREATE UNIQUE INDEX UX_RolePermissions_Role_Permission ON dbo.RolePermissions(RoleId, PermissionId);
END
GO

IF OBJECT_ID(N'dbo.UserSessions', N'U') IS NULL
BEGIN
CREATE TABLE dbo.UserSessions
(
    UserSessionId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_UserSessions PRIMARY KEY,
    UserId BIGINT NOT NULL,
    SessionToken NVARCHAR(200) NULL,
    LoginAt DATETIME2 NOT NULL CONSTRAINT DF_UserSessions_LoginAt DEFAULT(SYSDATETIME()),
    LogoutAt DATETIME2 NULL,
    IpAddress NVARCHAR(100) NULL,
    UserAgent NVARCHAR(1000) NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_UserSessions_IsActive DEFAULT(1),
    CONSTRAINT FK_UserSessions_Users FOREIGN KEY(UserId) REFERENCES dbo.Users(UserId)
);
END
GO

IF OBJECT_ID(N'dbo.AuditLogs', N'U') IS NULL
BEGIN
CREATE TABLE dbo.AuditLogs
(
    AuditLogId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_AuditLogs PRIMARY KEY,
    UserId BIGINT NULL,
    Username NVARCHAR(100) NULL,
    ActionType NVARCHAR(80) NOT NULL,
    EntityName NVARCHAR(150) NULL,
    EntityId NVARCHAR(100) NULL,
    ActionDescription NVARCHAR(MAX) NULL,
    OldValues NVARCHAR(MAX) NULL,
    NewValues NVARCHAR(MAX) NULL,
    IpAddress NVARCHAR(100) NULL,
    UserAgent NVARCHAR(1000) NULL,
    ActionDate DATETIME2 NOT NULL CONSTRAINT DF_AuditLogs_ActionDate DEFAULT(SYSDATETIME()),
    CONSTRAINT FK_AuditLogs_Users FOREIGN KEY(UserId) REFERENCES dbo.Users(UserId)
);
END
GO

IF OBJECT_ID(N'dbo.LookupCategories', N'U') IS NULL
BEGIN
CREATE TABLE dbo.LookupCategories
(
    LookupCategoryId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_LookupCategories PRIMARY KEY,
    CategoryCode NVARCHAR(100) NOT NULL,
    CategoryNameAr NVARCHAR(200) NOT NULL,
    CategoryNameEn NVARCHAR(200) NULL,
    SortOrder INT NOT NULL CONSTRAINT DF_LookupCategories_SortOrder DEFAULT(100),
    IsActive BIT NOT NULL CONSTRAINT DF_LookupCategories_IsActive DEFAULT(1),
    IsDeleted BIT NOT NULL CONSTRAINT DF_LookupCategories_IsDeleted DEFAULT(0)
);
CREATE UNIQUE INDEX UX_LookupCategories_CategoryCode ON dbo.LookupCategories(CategoryCode) WHERE IsDeleted = 0;
END
GO

IF OBJECT_ID(N'dbo.LookupItems', N'U') IS NULL
BEGIN
CREATE TABLE dbo.LookupItems
(
    LookupItemId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_LookupItems PRIMARY KEY,
    LookupCategoryId BIGINT NOT NULL,
    ItemCode NVARCHAR(100) NOT NULL,
    NameAr NVARCHAR(200) NOT NULL,
    NameEn NVARCHAR(200) NULL,
    Description NVARCHAR(500) NULL,
    SortOrder INT NOT NULL CONSTRAINT DF_LookupItems_SortOrder DEFAULT(100),
    IsDefault BIT NOT NULL CONSTRAINT DF_LookupItems_IsDefault DEFAULT(0),
    IsActive BIT NOT NULL CONSTRAINT DF_LookupItems_IsActive DEFAULT(1),
    IsDeleted BIT NOT NULL CONSTRAINT DF_LookupItems_IsDeleted DEFAULT(0),
    CONSTRAINT FK_LookupItems_Categories FOREIGN KEY(LookupCategoryId) REFERENCES dbo.LookupCategories(LookupCategoryId)
);
CREATE UNIQUE INDEX UX_LookupItems_Category_ItemCode ON dbo.LookupItems(LookupCategoryId, ItemCode) WHERE IsDeleted = 0;
END
GO

IF OBJECT_ID(N'dbo.Clients', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Clients
(
    ClientId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Clients PRIMARY KEY,
    ClientName NVARCHAR(250) NOT NULL,
    ContactPerson NVARCHAR(200) NULL,
    Email NVARCHAR(200) NULL,
    Mobile NVARCHAR(50) NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Clients_IsActive DEFAULT(1),
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Clients_CreatedAt DEFAULT(SYSDATETIME()),
    CreatedBy BIGINT NULL,
    UpdatedAt DATETIME2 NULL,
    UpdatedBy BIGINT NULL,
    IsDeleted BIT NOT NULL CONSTRAINT DF_Clients_IsDeleted DEFAULT(0),
    DeletedAt DATETIME2 NULL,
    DeletedBy BIGINT NULL
);
END
GO

IF OBJECT_ID(N'dbo.Projects', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Projects
(
    ProjectId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Projects PRIMARY KEY,
    ProjectCode NVARCHAR(80) NOT NULL,
    ProjectName NVARCHAR(300) NOT NULL,
    ProjectNameEn NVARCHAR(300) NULL,
    ClientId BIGINT NULL,
    ProjectTypeId BIGINT NULL,
    ProjectStatusId BIGINT NULL,
    StructureTypeId BIGINT NULL,
    InvestigationStageId BIGINT NULL,
    Country NVARCHAR(150) NULL,
    City NVARCHAR(150) NULL,
    District NVARCHAR(150) NULL,
    LocationName NVARCHAR(300) NULL,
    Address NVARCHAR(500) NULL,
    SiteAreaM2 DECIMAL(18,2) NULL,
    NumberOfFloors INT NULL,
    BasementCount INT NULL,
    ProjectStartDate DATE NULL,
    ProjectEndDate DATE NULL,
    ScopeOfWork NVARCHAR(MAX) NULL,
    GeneralNotes NVARCHAR(MAX) NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Projects_IsActive DEFAULT(1),
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Projects_CreatedAt DEFAULT(SYSDATETIME()),
    CreatedBy BIGINT NULL,
    UpdatedAt DATETIME2 NULL,
    UpdatedBy BIGINT NULL,
    IsDeleted BIT NOT NULL CONSTRAINT DF_Projects_IsDeleted DEFAULT(0),
    DeletedAt DATETIME2 NULL,
    DeletedBy BIGINT NULL,
    CONSTRAINT FK_Projects_Clients FOREIGN KEY(ClientId) REFERENCES dbo.Clients(ClientId),
    CONSTRAINT CK_Projects_Dates CHECK(ProjectEndDate IS NULL OR ProjectStartDate IS NULL OR ProjectEndDate >= ProjectStartDate)
);
CREATE UNIQUE INDEX UX_Projects_ProjectCode ON dbo.Projects(ProjectCode) WHERE IsDeleted = 0;
END
GO

PRINT N'Sprint 1 tables created successfully.';
GO
