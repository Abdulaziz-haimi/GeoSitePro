USE GeoSitePro;
GO

IF OBJECT_ID(N'dbo.NotificationRules', N'U') IS NULL
BEGIN
CREATE TABLE dbo.NotificationRules
(
    NotificationRuleId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_NotificationRules PRIMARY KEY,
    RuleCode NVARCHAR(100) NOT NULL,
    RuleNameAr NVARCHAR(250) NOT NULL,
    RuleNameEn NVARCHAR(250) NULL,
    RuleType NVARCHAR(80) NOT NULL,
    EntityType NVARCHAR(80) NOT NULL,
    DaysOffset INT NOT NULL CONSTRAINT DF_NotificationRules_DaysOffset DEFAULT(0),
    Severity NVARCHAR(30) NOT NULL CONSTRAINT DF_NotificationRules_Severity DEFAULT(N'Info'),
    MessageTemplate NVARCHAR(1000) NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_NotificationRules_IsActive DEFAULT(1),
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_NotificationRules_CreatedAt DEFAULT(SYSDATETIME()),
    CreatedBy BIGINT NULL,
    UpdatedAt DATETIME2 NULL,
    UpdatedBy BIGINT NULL,
    IsDeleted BIT NOT NULL CONSTRAINT DF_NotificationRules_IsDeleted DEFAULT(0)
);
CREATE UNIQUE INDEX UX_NotificationRules_Code ON dbo.NotificationRules(RuleCode) WHERE IsDeleted = 0;
END
GO

IF OBJECT_ID(N'dbo.UserNotifications', N'U') IS NULL
BEGIN
CREATE TABLE dbo.UserNotifications
(
    NotificationId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_UserNotifications PRIMARY KEY,
    UserId BIGINT NULL,
    ProjectId BIGINT NULL,
    EntityType NVARCHAR(80) NULL,
    EntityId BIGINT NULL,
    NotificationTitle NVARCHAR(300) NOT NULL,
    NotificationBody NVARCHAR(1000) NULL,
    Severity NVARCHAR(30) NOT NULL CONSTRAINT DF_UserNotifications_Severity DEFAULT(N'Info'),
    Status NVARCHAR(30) NOT NULL CONSTRAINT DF_UserNotifications_Status DEFAULT(N'Unread'),
    DueDate DATE NULL,
    SourceCode NVARCHAR(100) NULL,
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_UserNotifications_CreatedAt DEFAULT(SYSDATETIME()),
    ReadAt DATETIME2 NULL,
    ArchivedAt DATETIME2 NULL,
    IsDeleted BIT NOT NULL CONSTRAINT DF_UserNotifications_IsDeleted DEFAULT(0),
    CONSTRAINT FK_UserNotifications_Users FOREIGN KEY(UserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_UserNotifications_Projects FOREIGN KEY(ProjectId) REFERENCES dbo.Projects(ProjectId)
);
CREATE INDEX IX_UserNotifications_User_Status ON dbo.UserNotifications(UserId, Status, IsDeleted, CreatedAt DESC);
CREATE INDEX IX_UserNotifications_Project ON dbo.UserNotifications(ProjectId, EntityType, EntityId);
END
GO

IF OBJECT_ID(N'dbo.ProjectFollowUpItems', N'U') IS NULL
BEGIN
CREATE TABLE dbo.ProjectFollowUpItems
(
    FollowUpItemId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ProjectFollowUpItems PRIMARY KEY,
    ProjectId BIGINT NOT NULL,
    RelatedEntityType NVARCHAR(80) NULL,
    RelatedEntityId BIGINT NULL,
    ItemTitle NVARCHAR(300) NOT NULL,
    ItemDescription NVARCHAR(MAX) NULL,
    DueDate DATE NULL,
    Priority NVARCHAR(30) NOT NULL CONSTRAINT DF_ProjectFollowUpItems_Priority DEFAULT(N'Normal'),
    Status NVARCHAR(30) NOT NULL CONSTRAINT DF_ProjectFollowUpItems_Status DEFAULT(N'Open'),
    AssignedToUserId BIGINT NULL,
    CreatedBy BIGINT NULL,
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectFollowUpItems_CreatedAt DEFAULT(SYSDATETIME()),
    UpdatedBy BIGINT NULL,
    UpdatedAt DATETIME2 NULL,
    ClosedBy BIGINT NULL,
    ClosedAt DATETIME2 NULL,
    IsDeleted BIT NOT NULL CONSTRAINT DF_ProjectFollowUpItems_IsDeleted DEFAULT(0),
    CONSTRAINT FK_ProjectFollowUpItems_Projects FOREIGN KEY(ProjectId) REFERENCES dbo.Projects(ProjectId),
    CONSTRAINT FK_ProjectFollowUpItems_AssignedUsers FOREIGN KEY(AssignedToUserId) REFERENCES dbo.Users(UserId)
);
CREATE INDEX IX_ProjectFollowUpItems_Project_Status ON dbo.ProjectFollowUpItems(ProjectId, Status, IsDeleted);
CREATE INDEX IX_ProjectFollowUpItems_DueDate ON dbo.ProjectFollowUpItems(DueDate, Status, IsDeleted);
END
GO

PRINT N'Sprint 13 notification and follow-up tables created successfully.';
GO
