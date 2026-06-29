USE GeoSitePro;
GO

/* Sprint 12 stored procedures: workflow matrix, approval requests, decisions, and dashboard. */

CREATE OR ALTER PROCEDURE dbo.sp_WorkflowSteps_Get
    @EntityType NVARCHAR(80) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @EntityType = NULLIF(LTRIM(RTRIM(@EntityType)), N'');

    SELECT
        WorkflowStepId,
        EntityType,
        StepCode,
        StepNameAr,
        StepNameEn,
        RequiredPermission,
        SortOrder,
        IsFinal,
        IsActive,
        CONCAT(EntityType, N' - ', StepNameAr, N' (', StepCode, N')') AS StepDisplayName
    FROM dbo.WorkflowSteps
    WHERE ISNULL(IsDeleted,0)=0
      AND (@EntityType IS NULL OR EntityType=@EntityType)
    ORDER BY EntityType, SortOrder, WorkflowStepId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_WorkflowStep_GetById
    @WorkflowStepId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT WorkflowStepId, EntityType, StepCode, StepNameAr, StepNameEn, RequiredPermission, SortOrder, IsFinal, IsActive
    FROM dbo.WorkflowSteps
    WHERE WorkflowStepId=@WorkflowStepId AND ISNULL(IsDeleted,0)=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_WorkflowStep_Save
    @WorkflowStepId BIGINT = NULL,
    @EntityType NVARCHAR(80),
    @StepCode NVARCHAR(100),
    @StepNameAr NVARCHAR(250),
    @StepNameEn NVARCHAR(250) = NULL,
    @RequiredPermission NVARCHAR(150) = NULL,
    @SortOrder INT = 100,
    @IsFinal BIT = 0,
    @IsActive BIT = 1,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @EntityType = UPPER(NULLIF(LTRIM(RTRIM(@EntityType)), N''));
    SET @StepCode = UPPER(NULLIF(LTRIM(RTRIM(@StepCode)), N''));
    SET @StepNameAr = NULLIF(LTRIM(RTRIM(@StepNameAr)), N'');
    SET @StepNameEn = NULLIF(LTRIM(RTRIM(@StepNameEn)), N'');
    SET @RequiredPermission = NULLIF(LTRIM(RTRIM(@RequiredPermission)), N'');
    IF @EntityType IS NULL THROW 61201, N'EntityType is required.', 1;
    IF @StepCode IS NULL THROW 61202, N'StepCode is required.', 1;
    IF @StepNameAr IS NULL THROW 61203, N'StepNameAr is required.', 1;

    IF EXISTS(SELECT 1 FROM dbo.WorkflowSteps WHERE EntityType=@EntityType AND StepCode=@StepCode AND ISNULL(IsDeleted,0)=0 AND (@WorkflowStepId IS NULL OR WorkflowStepId<>@WorkflowStepId))
        THROW 61204, N'Workflow step already exists for this entity type.', 1;

    IF @WorkflowStepId IS NULL OR @WorkflowStepId <= 0
    BEGIN
        INSERT INTO dbo.WorkflowSteps(EntityType, StepCode, StepNameAr, StepNameEn, RequiredPermission, SortOrder, IsFinal, IsActive, CreatedBy)
        VALUES(@EntityType, @StepCode, @StepNameAr, @StepNameEn, @RequiredPermission, ISNULL(@SortOrder,100), @IsFinal, @IsActive, @UserId);
        SET @WorkflowStepId = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.WorkflowSteps
        SET EntityType=@EntityType,
            StepCode=@StepCode,
            StepNameAr=@StepNameAr,
            StepNameEn=@StepNameEn,
            RequiredPermission=@RequiredPermission,
            SortOrder=ISNULL(@SortOrder,100),
            IsFinal=@IsFinal,
            IsActive=@IsActive,
            UpdatedAt=SYSDATETIME(),
            UpdatedBy=@UserId
        WHERE WorkflowStepId=@WorkflowStepId AND ISNULL(IsDeleted,0)=0;
    END

    SELECT @WorkflowStepId AS WorkflowStepId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ApprovalRequest_Create
    @ProjectId BIGINT,
    @EntityType NVARCHAR(80),
    @EntityId BIGINT = NULL,
    @WorkflowStepId BIGINT,
    @RequestTitle NVARCHAR(300),
    @RequestDescription NVARCHAR(MAX) = NULL,
    @Priority NVARCHAR(50) = N'Normal',
    @AssignedToUserId BIGINT = NULL,
    @AssignedToRoleId BIGINT = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StepCode NVARCHAR(100), @StepName NVARCHAR(250), @RequiredPermission NVARCHAR(150), @ApprovalRequestId BIGINT;
    SET @EntityType = UPPER(NULLIF(LTRIM(RTRIM(@EntityType)), N''));
    SET @RequestTitle = NULLIF(LTRIM(RTRIM(@RequestTitle)), N'');
    SET @Priority = COALESCE(NULLIF(LTRIM(RTRIM(@Priority)), N''), N'Normal');

    IF NOT EXISTS(SELECT 1 FROM dbo.Projects WHERE ProjectId=@ProjectId AND ISNULL(IsDeleted,0)=0) THROW 61210, N'Project does not exist.', 1;
    IF @EntityType IS NULL THROW 61211, N'EntityType is required.', 1;
    IF @RequestTitle IS NULL THROW 61212, N'Request title is required.', 1;

    SELECT @StepCode=StepCode, @StepName=StepNameAr, @RequiredPermission=RequiredPermission
    FROM dbo.WorkflowSteps
    WHERE WorkflowStepId=@WorkflowStepId AND ISNULL(IsDeleted,0)=0 AND IsActive=1;
    IF @StepCode IS NULL THROW 61213, N'Workflow step does not exist.', 1;

    INSERT INTO dbo.ApprovalRequests(ProjectId, EntityType, EntityId, RequestTitle, RequestDescription, WorkflowStepId, CurrentStepCode, CurrentStepName, RequiredPermission, Status, Priority, AssignedToUserId, AssignedToRoleId, RequestedBy, CreatedBy)
    VALUES(@ProjectId, @EntityType, @EntityId, @RequestTitle, @RequestDescription, @WorkflowStepId, @StepCode, @StepName, @RequiredPermission, N'Pending', @Priority, @AssignedToUserId, @AssignedToRoleId, @UserId, @UserId);
    SET @ApprovalRequestId = SCOPE_IDENTITY();

    INSERT INTO dbo.ApprovalRequestHistory(ApprovalRequestId, ActionType, FromStatus, ToStatus, Comments, ActionBy)
    VALUES(@ApprovalRequestId, N'Create', NULL, N'Pending', @RequestDescription, @UserId);

    INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription, NewValues)
    SELECT @UserId, U.Username, N'Insert', N'ApprovalRequests', CONVERT(NVARCHAR(100), @ApprovalRequestId), N'تم إنشاء طلب اعتماد.', @RequestTitle
    FROM dbo.Users U WHERE U.UserId=@UserId;

    SELECT @ApprovalRequestId AS ApprovalRequestId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ApprovalRequests_Get
    @ProjectId BIGINT = NULL,
    @Status NVARCHAR(50) = NULL,
    @SearchText NVARCHAR(200) = NULL,
    @AssignedToUserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @Status = NULLIF(LTRIM(RTRIM(@Status)), N'');
    SET @SearchText = NULLIF(LTRIM(RTRIM(@SearchText)), N'');

    SELECT
        AR.ApprovalRequestId,
        AR.ProjectId,
        P.ProjectCode,
        P.ProjectName,
        AR.EntityType,
        AR.EntityId,
        AR.RequestTitle,
        AR.RequestDescription,
        AR.WorkflowStepId,
        AR.CurrentStepCode,
        AR.CurrentStepName,
        AR.RequiredPermission,
        AR.Status,
        AR.Priority,
        AR.RequestedAt,
        AR.DecidedAt,
        AR.DecisionNotes,
        RU.FullName AS RequestedByName,
        DU.FullName AS DecidedByName,
        AU.FullName AS AssignedToUserName,
        RR.RoleName AS AssignedToRoleName
    FROM dbo.ApprovalRequests AR
    INNER JOIN dbo.Projects P ON P.ProjectId=AR.ProjectId
    LEFT JOIN dbo.Users RU ON RU.UserId=AR.RequestedBy
    LEFT JOIN dbo.Users DU ON DU.UserId=AR.DecidedBy
    LEFT JOIN dbo.Users AU ON AU.UserId=AR.AssignedToUserId
    LEFT JOIN dbo.Roles RR ON RR.RoleId=AR.AssignedToRoleId
    WHERE ISNULL(AR.IsDeleted,0)=0
      AND ISNULL(P.IsDeleted,0)=0
      AND (@ProjectId IS NULL OR AR.ProjectId=@ProjectId)
      AND (@Status IS NULL OR AR.Status=@Status)
      AND (@AssignedToUserId IS NULL OR AR.AssignedToUserId IS NULL OR AR.AssignedToUserId=@AssignedToUserId)
      AND (
          @SearchText IS NULL
          OR P.ProjectCode LIKE N'%' + @SearchText + N'%'
          OR P.ProjectName LIKE N'%' + @SearchText + N'%'
          OR AR.RequestTitle LIKE N'%' + @SearchText + N'%'
          OR AR.EntityType LIKE N'%' + @SearchText + N'%'
      )
    ORDER BY CASE WHEN AR.Status=N'Pending' THEN 0 ELSE 1 END, AR.RequestedAt DESC, AR.ApprovalRequestId DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ApprovalRequest_Decide
    @ApprovalRequestId BIGINT,
    @Decision NVARCHAR(50),
    @Comments NVARCHAR(MAX) = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @FromStatus NVARCHAR(50), @ToStatus NVARCHAR(50), @Title NVARCHAR(300);
    SET @Decision = UPPER(NULLIF(LTRIM(RTRIM(@Decision)), N''));
    IF @Decision = N'APPROVE' SET @ToStatus = N'Approved';
    ELSE IF @Decision = N'REJECT' SET @ToStatus = N'Rejected';
    ELSE IF @Decision = N'RETURN' SET @ToStatus = N'Returned';
    ELSE THROW 61220, N'Invalid decision.', 1;

    SELECT @FromStatus=Status, @Title=RequestTitle
    FROM dbo.ApprovalRequests
    WHERE ApprovalRequestId=@ApprovalRequestId AND ISNULL(IsDeleted,0)=0;
    IF @FromStatus IS NULL THROW 61221, N'Approval request does not exist.', 1;
    IF @FromStatus <> N'Pending' THROW 61222, N'Only pending requests can be decided.', 1;

    UPDATE dbo.ApprovalRequests
    SET Status=@ToStatus,
        DecidedBy=@UserId,
        DecidedAt=SYSDATETIME(),
        DecisionNotes=@Comments,
        IsLocked=CASE WHEN @ToStatus=N'Approved' THEN 1 ELSE 0 END,
        UpdatedAt=SYSDATETIME(),
        UpdatedBy=@UserId
    WHERE ApprovalRequestId=@ApprovalRequestId;

    INSERT INTO dbo.ApprovalRequestHistory(ApprovalRequestId, ActionType, FromStatus, ToStatus, Comments, ActionBy)
    VALUES(@ApprovalRequestId, @Decision, @FromStatus, @ToStatus, @Comments, @UserId);

    INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription, NewValues)
    SELECT @UserId, U.Username, @Decision, N'ApprovalRequests', CONVERT(NVARCHAR(100), @ApprovalRequestId), N'تم تنفيذ قرار على طلب اعتماد.', @ToStatus + N' - ' + ISNULL(@Title,N'')
    FROM dbo.Users U WHERE U.UserId=@UserId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ApprovalDashboard_Get
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        @ProjectId AS ProjectId,
        ISNULL(SUM(CASE WHEN Status=N'Pending' THEN 1 ELSE 0 END),0) AS PendingCount,
        ISNULL(SUM(CASE WHEN Status=N'Approved' THEN 1 ELSE 0 END),0) AS ApprovedCount,
        ISNULL(SUM(CASE WHEN Status=N'Rejected' THEN 1 ELSE 0 END),0) AS RejectedCount,
        ISNULL(SUM(CASE WHEN Status=N'Returned' THEN 1 ELSE 0 END),0) AS ReturnedCount,
        ISNULL(COUNT(1),0) AS TotalCount
    FROM dbo.ApprovalRequests
    WHERE ProjectId=@ProjectId AND ISNULL(IsDeleted,0)=0;
END
GO

PRINT N'Sprint 12 workflow stored procedures created successfully.';
GO
