USE GeoSitePro;
GO

/* Sprint 12: Workflow and approvals tables. */

IF OBJECT_ID(N'dbo.WorkflowSteps', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.WorkflowSteps
    (
        WorkflowStepId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_WorkflowSteps PRIMARY KEY,
        EntityType NVARCHAR(80) NOT NULL,
        StepCode NVARCHAR(100) NOT NULL,
        StepNameAr NVARCHAR(250) NOT NULL,
        StepNameEn NVARCHAR(250) NULL,
        RequiredPermission NVARCHAR(150) NULL,
        SortOrder INT NOT NULL CONSTRAINT DF_WorkflowSteps_SortOrder DEFAULT(100),
        IsFinal BIT NOT NULL CONSTRAINT DF_WorkflowSteps_IsFinal DEFAULT(0),
        IsActive BIT NOT NULL CONSTRAINT DF_WorkflowSteps_IsActive DEFAULT(1),
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_WorkflowSteps_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_WorkflowSteps_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.WorkflowSteps', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.WorkflowSteps','EntityType') IS NULL ALTER TABLE dbo.WorkflowSteps ADD EntityType NVARCHAR(80) NULL;
    IF COL_LENGTH('dbo.WorkflowSteps','StepCode') IS NULL ALTER TABLE dbo.WorkflowSteps ADD StepCode NVARCHAR(100) NULL;
    IF COL_LENGTH('dbo.WorkflowSteps','StepNameAr') IS NULL ALTER TABLE dbo.WorkflowSteps ADD StepNameAr NVARCHAR(250) NULL;
    IF COL_LENGTH('dbo.WorkflowSteps','StepNameEn') IS NULL ALTER TABLE dbo.WorkflowSteps ADD StepNameEn NVARCHAR(250) NULL;
    IF COL_LENGTH('dbo.WorkflowSteps','RequiredPermission') IS NULL ALTER TABLE dbo.WorkflowSteps ADD RequiredPermission NVARCHAR(150) NULL;
    IF COL_LENGTH('dbo.WorkflowSteps','SortOrder') IS NULL ALTER TABLE dbo.WorkflowSteps ADD SortOrder INT NOT NULL CONSTRAINT DF_WorkflowSteps_SortOrder_Compat DEFAULT(100);
    IF COL_LENGTH('dbo.WorkflowSteps','IsFinal') IS NULL ALTER TABLE dbo.WorkflowSteps ADD IsFinal BIT NOT NULL CONSTRAINT DF_WorkflowSteps_IsFinal_Compat DEFAULT(0);
    IF COL_LENGTH('dbo.WorkflowSteps','IsActive') IS NULL ALTER TABLE dbo.WorkflowSteps ADD IsActive BIT NOT NULL CONSTRAINT DF_WorkflowSteps_IsActive_Compat DEFAULT(1);
    IF COL_LENGTH('dbo.WorkflowSteps','CreatedAt') IS NULL ALTER TABLE dbo.WorkflowSteps ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_WorkflowSteps_CreatedAt_Compat DEFAULT(SYSDATETIME());
    IF COL_LENGTH('dbo.WorkflowSteps','CreatedBy') IS NULL ALTER TABLE dbo.WorkflowSteps ADD CreatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.WorkflowSteps','UpdatedAt') IS NULL ALTER TABLE dbo.WorkflowSteps ADD UpdatedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.WorkflowSteps','UpdatedBy') IS NULL ALTER TABLE dbo.WorkflowSteps ADD UpdatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.WorkflowSteps','IsDeleted') IS NULL ALTER TABLE dbo.WorkflowSteps ADD IsDeleted BIT NOT NULL CONSTRAINT DF_WorkflowSteps_IsDeleted_Compat DEFAULT(0);
    IF COL_LENGTH('dbo.WorkflowSteps','DeletedAt') IS NULL ALTER TABLE dbo.WorkflowSteps ADD DeletedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.WorkflowSteps','DeletedBy') IS NULL ALTER TABLE dbo.WorkflowSteps ADD DeletedBy BIGINT NULL;
END
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'UX_WorkflowSteps_Entity_Code' AND object_id=OBJECT_ID(N'dbo.WorkflowSteps'))
    CREATE UNIQUE INDEX UX_WorkflowSteps_Entity_Code ON dbo.WorkflowSteps(EntityType, StepCode) WHERE IsDeleted=0;
GO

IF OBJECT_ID(N'dbo.ApprovalRequests', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ApprovalRequests
    (
        ApprovalRequestId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ApprovalRequests PRIMARY KEY,
        ProjectId BIGINT NOT NULL,
        EntityType NVARCHAR(80) NOT NULL,
        EntityId BIGINT NULL,
        RequestTitle NVARCHAR(300) NOT NULL,
        RequestDescription NVARCHAR(MAX) NULL,
        WorkflowStepId BIGINT NULL,
        CurrentStepCode NVARCHAR(100) NULL,
        CurrentStepName NVARCHAR(250) NULL,
        RequiredPermission NVARCHAR(150) NULL,
        Status NVARCHAR(50) NOT NULL CONSTRAINT DF_ApprovalRequests_Status DEFAULT(N'Pending'),
        Priority NVARCHAR(50) NOT NULL CONSTRAINT DF_ApprovalRequests_Priority DEFAULT(N'Normal'),
        AssignedToUserId BIGINT NULL,
        AssignedToRoleId BIGINT NULL,
        RequestedBy BIGINT NULL,
        RequestedAt DATETIME2 NOT NULL CONSTRAINT DF_ApprovalRequests_RequestedAt DEFAULT(SYSDATETIME()),
        DecidedBy BIGINT NULL,
        DecidedAt DATETIME2 NULL,
        DecisionNotes NVARCHAR(MAX) NULL,
        IsLocked BIT NOT NULL CONSTRAINT DF_ApprovalRequests_IsLocked DEFAULT(0),
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ApprovalRequests_CreatedAt DEFAULT(SYSDATETIME()),
        CreatedBy BIGINT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy BIGINT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_ApprovalRequests_IsDeleted DEFAULT(0),
        DeletedAt DATETIME2 NULL,
        DeletedBy BIGINT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.ApprovalRequests', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.ApprovalRequests','ProjectId') IS NULL ALTER TABLE dbo.ApprovalRequests ADD ProjectId BIGINT NULL;
    IF COL_LENGTH('dbo.ApprovalRequests','EntityType') IS NULL ALTER TABLE dbo.ApprovalRequests ADD EntityType NVARCHAR(80) NULL;
    IF COL_LENGTH('dbo.ApprovalRequests','EntityId') IS NULL ALTER TABLE dbo.ApprovalRequests ADD EntityId BIGINT NULL;
    IF COL_LENGTH('dbo.ApprovalRequests','RequestTitle') IS NULL ALTER TABLE dbo.ApprovalRequests ADD RequestTitle NVARCHAR(300) NULL;
    IF COL_LENGTH('dbo.ApprovalRequests','RequestDescription') IS NULL ALTER TABLE dbo.ApprovalRequests ADD RequestDescription NVARCHAR(MAX) NULL;
    IF COL_LENGTH('dbo.ApprovalRequests','WorkflowStepId') IS NULL ALTER TABLE dbo.ApprovalRequests ADD WorkflowStepId BIGINT NULL;
    IF COL_LENGTH('dbo.ApprovalRequests','CurrentStepCode') IS NULL ALTER TABLE dbo.ApprovalRequests ADD CurrentStepCode NVARCHAR(100) NULL;
    IF COL_LENGTH('dbo.ApprovalRequests','CurrentStepName') IS NULL ALTER TABLE dbo.ApprovalRequests ADD CurrentStepName NVARCHAR(250) NULL;
    IF COL_LENGTH('dbo.ApprovalRequests','RequiredPermission') IS NULL ALTER TABLE dbo.ApprovalRequests ADD RequiredPermission NVARCHAR(150) NULL;
    IF COL_LENGTH('dbo.ApprovalRequests','Status') IS NULL ALTER TABLE dbo.ApprovalRequests ADD Status NVARCHAR(50) NOT NULL CONSTRAINT DF_ApprovalRequests_Status_Compat DEFAULT(N'Pending');
    IF COL_LENGTH('dbo.ApprovalRequests','Priority') IS NULL ALTER TABLE dbo.ApprovalRequests ADD Priority NVARCHAR(50) NOT NULL CONSTRAINT DF_ApprovalRequests_Priority_Compat DEFAULT(N'Normal');
    IF COL_LENGTH('dbo.ApprovalRequests','AssignedToUserId') IS NULL ALTER TABLE dbo.ApprovalRequests ADD AssignedToUserId BIGINT NULL;
    IF COL_LENGTH('dbo.ApprovalRequests','AssignedToRoleId') IS NULL ALTER TABLE dbo.ApprovalRequests ADD AssignedToRoleId BIGINT NULL;
    IF COL_LENGTH('dbo.ApprovalRequests','RequestedBy') IS NULL ALTER TABLE dbo.ApprovalRequests ADD RequestedBy BIGINT NULL;
    IF COL_LENGTH('dbo.ApprovalRequests','RequestedAt') IS NULL ALTER TABLE dbo.ApprovalRequests ADD RequestedAt DATETIME2 NOT NULL CONSTRAINT DF_ApprovalRequests_RequestedAt_Compat DEFAULT(SYSDATETIME());
    IF COL_LENGTH('dbo.ApprovalRequests','DecidedBy') IS NULL ALTER TABLE dbo.ApprovalRequests ADD DecidedBy BIGINT NULL;
    IF COL_LENGTH('dbo.ApprovalRequests','DecidedAt') IS NULL ALTER TABLE dbo.ApprovalRequests ADD DecidedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.ApprovalRequests','DecisionNotes') IS NULL ALTER TABLE dbo.ApprovalRequests ADD DecisionNotes NVARCHAR(MAX) NULL;
    IF COL_LENGTH('dbo.ApprovalRequests','IsLocked') IS NULL ALTER TABLE dbo.ApprovalRequests ADD IsLocked BIT NOT NULL CONSTRAINT DF_ApprovalRequests_IsLocked_Compat DEFAULT(0);
    IF COL_LENGTH('dbo.ApprovalRequests','CreatedAt') IS NULL ALTER TABLE dbo.ApprovalRequests ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ApprovalRequests_CreatedAt_Compat DEFAULT(SYSDATETIME());
    IF COL_LENGTH('dbo.ApprovalRequests','CreatedBy') IS NULL ALTER TABLE dbo.ApprovalRequests ADD CreatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.ApprovalRequests','UpdatedAt') IS NULL ALTER TABLE dbo.ApprovalRequests ADD UpdatedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.ApprovalRequests','UpdatedBy') IS NULL ALTER TABLE dbo.ApprovalRequests ADD UpdatedBy BIGINT NULL;
    IF COL_LENGTH('dbo.ApprovalRequests','IsDeleted') IS NULL ALTER TABLE dbo.ApprovalRequests ADD IsDeleted BIT NOT NULL CONSTRAINT DF_ApprovalRequests_IsDeleted_Compat DEFAULT(0);
    IF COL_LENGTH('dbo.ApprovalRequests','DeletedAt') IS NULL ALTER TABLE dbo.ApprovalRequests ADD DeletedAt DATETIME2 NULL;
    IF COL_LENGTH('dbo.ApprovalRequests','DeletedBy') IS NULL ALTER TABLE dbo.ApprovalRequests ADD DeletedBy BIGINT NULL;
END
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'IX_ApprovalRequests_Project_Status' AND object_id=OBJECT_ID(N'dbo.ApprovalRequests'))
    CREATE INDEX IX_ApprovalRequests_Project_Status ON dbo.ApprovalRequests(ProjectId, Status, RequestedAt DESC) WHERE IsDeleted=0;
GO

IF OBJECT_ID(N'dbo.ApprovalRequestHistory', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ApprovalRequestHistory
    (
        ApprovalHistoryId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ApprovalRequestHistory PRIMARY KEY,
        ApprovalRequestId BIGINT NOT NULL,
        ActionType NVARCHAR(80) NOT NULL,
        FromStatus NVARCHAR(50) NULL,
        ToStatus NVARCHAR(50) NULL,
        Comments NVARCHAR(MAX) NULL,
        ActionBy BIGINT NULL,
        ActionAt DATETIME2 NOT NULL CONSTRAINT DF_ApprovalRequestHistory_ActionAt DEFAULT(SYSDATETIME())
    );
END
GO

IF OBJECT_ID(N'dbo.ApprovalRequestHistory', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.ApprovalRequestHistory','ApprovalRequestId') IS NULL ALTER TABLE dbo.ApprovalRequestHistory ADD ApprovalRequestId BIGINT NULL;
    IF COL_LENGTH('dbo.ApprovalRequestHistory','ActionType') IS NULL ALTER TABLE dbo.ApprovalRequestHistory ADD ActionType NVARCHAR(80) NULL;
    IF COL_LENGTH('dbo.ApprovalRequestHistory','FromStatus') IS NULL ALTER TABLE dbo.ApprovalRequestHistory ADD FromStatus NVARCHAR(50) NULL;
    IF COL_LENGTH('dbo.ApprovalRequestHistory','ToStatus') IS NULL ALTER TABLE dbo.ApprovalRequestHistory ADD ToStatus NVARCHAR(50) NULL;
    IF COL_LENGTH('dbo.ApprovalRequestHistory','Comments') IS NULL ALTER TABLE dbo.ApprovalRequestHistory ADD Comments NVARCHAR(MAX) NULL;
    IF COL_LENGTH('dbo.ApprovalRequestHistory','ActionBy') IS NULL ALTER TABLE dbo.ApprovalRequestHistory ADD ActionBy BIGINT NULL;
    IF COL_LENGTH('dbo.ApprovalRequestHistory','ActionAt') IS NULL ALTER TABLE dbo.ApprovalRequestHistory ADD ActionAt DATETIME2 NOT NULL CONSTRAINT DF_ApprovalRequestHistory_ActionAt_Compat DEFAULT(SYSDATETIME());
END
GO

MERGE dbo.WorkflowSteps AS T
USING (VALUES
    (N'PROJECT', N'PREPARED', N'تم الإعداد', N'Prepared', N'Workflow.Create', 10, 0),
    (N'PROJECT', N'TECHNICAL_REVIEW', N'مراجعة فنية', N'Technical Review', N'Workflow.Approve', 20, 0),
    (N'PROJECT', N'APPROVAL', N'اعتماد نهائي', N'Final Approval', N'Workflow.Approve', 30, 1),
    (N'TECHNICAL_REPORT', N'REPORT_REVIEW', N'مراجعة التقرير', N'Report Review', N'Workflow.Approve', 10, 0),
    (N'TECHNICAL_REPORT', N'REPORT_APPROVAL', N'اعتماد التقرير', N'Report Approval', N'Workflow.Approve', 20, 1),
    (N'PRINT_PACKAGE', N'PACKAGE_CHECK', N'فحص حزمة التسليم', N'Package Check', N'Workflow.Approve', 10, 0),
    (N'PRINT_PACKAGE', N'PACKAGE_ISSUE', N'اعتماد الإصدار', N'Package Issue Approval', N'Workflow.Approve', 20, 1),
    (N'INVESTIGATION_PLAN', N'PLAN_REVIEW', N'مراجعة خطة التحري', N'Investigation Plan Review', N'Workflow.Approve', 10, 0),
    (N'INVESTIGATION_PLAN', N'PLAN_APPROVAL', N'اعتماد خطة التحري', N'Investigation Plan Approval', N'Workflow.Approve', 20, 1),
    (N'LAB_RESULTS', N'LAB_REVIEW', N'مراجعة نتائج المختبر', N'Lab Results Review', N'Workflow.Approve', 10, 0),
    (N'LAB_RESULTS', N'LAB_APPROVAL', N'اعتماد نتائج المختبر', N'Lab Results Approval', N'Workflow.Approve', 20, 1)
) AS S(EntityType, StepCode, StepNameAr, StepNameEn, RequiredPermission, SortOrder, IsFinal)
ON T.EntityType=S.EntityType AND T.StepCode=S.StepCode AND ISNULL(T.IsDeleted,0)=0
WHEN MATCHED THEN UPDATE SET StepNameAr=S.StepNameAr, StepNameEn=S.StepNameEn, RequiredPermission=S.RequiredPermission, SortOrder=S.SortOrder, IsFinal=S.IsFinal, IsActive=1, UpdatedAt=SYSDATETIME()
WHEN NOT MATCHED THEN INSERT(EntityType, StepCode, StepNameAr, StepNameEn, RequiredPermission, SortOrder, IsFinal, IsActive)
VALUES(S.EntityType, S.StepCode, S.StepNameAr, S.StepNameEn, S.RequiredPermission, S.SortOrder, S.IsFinal, 1);
GO

PRINT N'Sprint 12 workflow tables created successfully.';
GO
