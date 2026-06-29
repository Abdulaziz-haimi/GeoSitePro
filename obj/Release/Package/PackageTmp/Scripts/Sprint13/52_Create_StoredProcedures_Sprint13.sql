USE GeoSitePro;
GO

CREATE OR ALTER PROCEDURE dbo.sp_NotificationRules_Get
    @RuleType NVARCHAR(80) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT NotificationRuleId, RuleCode, RuleNameAr, RuleNameEn, RuleType, EntityType, DaysOffset, Severity, MessageTemplate, IsActive, CreatedAt
    FROM dbo.NotificationRules
    WHERE IsDeleted = 0 AND (@RuleType IS NULL OR RuleType = @RuleType)
    ORDER BY RuleType, RuleCode;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_NotificationRule_GetById
    @NotificationRuleId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT NotificationRuleId, RuleCode, RuleNameAr, RuleNameEn, RuleType, EntityType, DaysOffset, Severity, MessageTemplate, IsActive
    FROM dbo.NotificationRules
    WHERE NotificationRuleId = @NotificationRuleId AND IsDeleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_NotificationRule_Save
    @NotificationRuleId BIGINT = NULL,
    @RuleCode NVARCHAR(100),
    @RuleNameAr NVARCHAR(250),
    @RuleType NVARCHAR(80),
    @EntityType NVARCHAR(80),
    @DaysOffset INT = 0,
    @Severity NVARCHAR(30) = N'Info',
    @MessageTemplate NVARCHAR(1000) = NULL,
    @IsActive BIT = 1,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @NotificationRuleId IS NULL OR @NotificationRuleId = 0
    BEGIN
        INSERT INTO dbo.NotificationRules(RuleCode, RuleNameAr, RuleType, EntityType, DaysOffset, Severity, MessageTemplate, IsActive, CreatedBy)
        VALUES(@RuleCode, @RuleNameAr, @RuleType, @EntityType, @DaysOffset, @Severity, @MessageTemplate, @IsActive, @UserId);
        SELECT SCOPE_IDENTITY() AS NotificationRuleId;
    END
    ELSE
    BEGIN
        UPDATE dbo.NotificationRules
        SET RuleCode=@RuleCode, RuleNameAr=@RuleNameAr, RuleType=@RuleType, EntityType=@EntityType,
            DaysOffset=@DaysOffset, Severity=@Severity, MessageTemplate=@MessageTemplate, IsActive=@IsActive,
            UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId
        WHERE NotificationRuleId=@NotificationRuleId AND IsDeleted=0;
        SELECT @NotificationRuleId AS NotificationRuleId;
    END
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Notifications_Get
    @UserId BIGINT = NULL,
    @Status NVARCHAR(30) = NULL,
    @Severity NVARCHAR(30) = NULL,
    @SearchText NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @SearchText = NULLIF(LTRIM(RTRIM(@SearchText)), N'');
    SELECT TOP 300
        N.NotificationId, N.UserId, N.ProjectId, P.ProjectCode, P.ProjectName,
        N.EntityType, N.EntityId, N.NotificationTitle, N.NotificationBody, N.Severity, N.Status,
        N.DueDate, N.SourceCode, N.CreatedAt, N.ReadAt
    FROM dbo.UserNotifications N
    LEFT JOIN dbo.Projects P ON P.ProjectId = N.ProjectId
    WHERE N.IsDeleted = 0
      AND (@UserId IS NULL OR N.UserId IS NULL OR N.UserId = @UserId)
      AND (@Status IS NULL OR N.Status = @Status)
      AND (@Severity IS NULL OR N.Severity = @Severity)
      AND (
        @SearchText IS NULL OR N.NotificationTitle LIKE N'%' + @SearchText + N'%'
        OR N.NotificationBody LIKE N'%' + @SearchText + N'%'
        OR P.ProjectCode LIKE N'%' + @SearchText + N'%'
        OR P.ProjectName LIKE N'%' + @SearchText + N'%'
      )
    ORDER BY CASE WHEN N.Status = N'Unread' THEN 0 ELSE 1 END, N.CreatedAt DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Notifications_Summary
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        UnreadCount = SUM(CASE WHEN Status = N'Unread' THEN 1 ELSE 0 END),
        CriticalCount = SUM(CASE WHEN Severity = N'Critical' AND Status <> N'Archived' THEN 1 ELSE 0 END),
        OverdueCount = SUM(CASE WHEN DueDate IS NOT NULL AND DueDate < CONVERT(DATE, GETDATE()) AND Status <> N'Archived' THEN 1 ELSE 0 END),
        TotalCount = COUNT(1)
    FROM dbo.UserNotifications
    WHERE IsDeleted = 0 AND (@UserId IS NULL OR UserId IS NULL OR UserId = @UserId);
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Notification_UpdateStatus
    @NotificationId BIGINT,
    @Status NVARCHAR(30),
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.UserNotifications
    SET Status = @Status,
        ReadAt = CASE WHEN @Status = N'Read' AND ReadAt IS NULL THEN SYSDATETIME() ELSE ReadAt END,
        ArchivedAt = CASE WHEN @Status = N'Archived' THEN SYSDATETIME() ELSE ArchivedAt END
    WHERE NotificationId = @NotificationId AND IsDeleted = 0 AND (@UserId IS NULL OR UserId IS NULL OR UserId = @UserId);
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Notifications_MarkAllRead
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.UserNotifications
    SET Status = N'Read', ReadAt = COALESCE(ReadAt, SYSDATETIME())
    WHERE IsDeleted = 0 AND Status = N'Unread' AND (@UserId IS NULL OR UserId IS NULL OR UserId = @UserId);
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_FollowUpItems_Get
    @ProjectId BIGINT = NULL,
    @Status NVARCHAR(30) = NULL,
    @AssignedToUserId BIGINT = NULL,
    @SearchText NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @SearchText = NULLIF(LTRIM(RTRIM(@SearchText)), N'');
    SELECT TOP 500
        F.FollowUpItemId, F.ProjectId, P.ProjectCode, P.ProjectName,
        F.RelatedEntityType, F.RelatedEntityId, F.ItemTitle, F.ItemDescription,
        F.DueDate, F.Priority, F.Status, F.AssignedToUserId, U.FullName AS AssignedToName,
        F.CreatedAt, F.ClosedAt,
        DaysLate = CASE WHEN F.DueDate IS NOT NULL AND F.Status <> N'Closed' AND F.DueDate < CONVERT(DATE, GETDATE()) THEN DATEDIFF(DAY, F.DueDate, CONVERT(DATE, GETDATE())) ELSE 0 END
    FROM dbo.ProjectFollowUpItems F
    INNER JOIN dbo.Projects P ON P.ProjectId = F.ProjectId
    LEFT JOIN dbo.Users U ON U.UserId = F.AssignedToUserId
    WHERE F.IsDeleted = 0
      AND (@ProjectId IS NULL OR F.ProjectId = @ProjectId)
      AND (@Status IS NULL OR F.Status = @Status)
      AND (@AssignedToUserId IS NULL OR F.AssignedToUserId = @AssignedToUserId)
      AND (@SearchText IS NULL OR F.ItemTitle LIKE N'%' + @SearchText + N'%' OR F.ItemDescription LIKE N'%' + @SearchText + N'%' OR P.ProjectCode LIKE N'%' + @SearchText + N'%' OR P.ProjectName LIKE N'%' + @SearchText + N'%')
    ORDER BY CASE WHEN F.Status = N'Closed' THEN 1 ELSE 0 END, F.DueDate, F.CreatedAt DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_FollowUpItem_GetById
    @FollowUpItemId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT FollowUpItemId, ProjectId, RelatedEntityType, RelatedEntityId, ItemTitle, ItemDescription, DueDate, Priority, Status, AssignedToUserId
    FROM dbo.ProjectFollowUpItems
    WHERE FollowUpItemId = @FollowUpItemId AND IsDeleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_FollowUpItem_Save
    @FollowUpItemId BIGINT = NULL,
    @ProjectId BIGINT,
    @RelatedEntityType NVARCHAR(80) = NULL,
    @RelatedEntityId BIGINT = NULL,
    @ItemTitle NVARCHAR(300),
    @ItemDescription NVARCHAR(MAX) = NULL,
    @DueDate DATE = NULL,
    @Priority NVARCHAR(30) = N'Normal',
    @AssignedToUserId BIGINT = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @FollowUpItemId IS NULL OR @FollowUpItemId = 0
    BEGIN
        INSERT INTO dbo.ProjectFollowUpItems(ProjectId, RelatedEntityType, RelatedEntityId, ItemTitle, ItemDescription, DueDate, Priority, AssignedToUserId, CreatedBy)
        VALUES(@ProjectId, @RelatedEntityType, @RelatedEntityId, @ItemTitle, @ItemDescription, @DueDate, @Priority, @AssignedToUserId, @UserId);
        SELECT SCOPE_IDENTITY() AS FollowUpItemId;
    END
    ELSE
    BEGIN
        UPDATE dbo.ProjectFollowUpItems
        SET ProjectId=@ProjectId, RelatedEntityType=@RelatedEntityType, RelatedEntityId=@RelatedEntityId,
            ItemTitle=@ItemTitle, ItemDescription=@ItemDescription, DueDate=@DueDate, Priority=@Priority,
            AssignedToUserId=@AssignedToUserId, UpdatedBy=@UserId, UpdatedAt=SYSDATETIME()
        WHERE FollowUpItemId=@FollowUpItemId AND IsDeleted=0;
        SELECT @FollowUpItemId AS FollowUpItemId;
    END
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_FollowUpItem_Close
    @FollowUpItemId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProjectFollowUpItems
    SET Status=N'Closed', ClosedAt=SYSDATETIME(), ClosedBy=@UserId, UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId
    WHERE FollowUpItemId=@FollowUpItemId AND IsDeleted=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Notifications_Generate
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Today DATE = CONVERT(DATE, GETDATE());

    INSERT INTO dbo.UserNotifications(UserId, ProjectId, EntityType, EntityId, NotificationTitle, NotificationBody, Severity, Status, DueDate, SourceCode)
    SELECT DISTINCT
        F.AssignedToUserId,
        F.ProjectId,
        N'FOLLOWUP',
        F.FollowUpItemId,
        CASE WHEN F.DueDate < @Today THEN N'بند متابعة متأخر' ELSE N'بند متابعة مستحق' END,
        N'المشروع: ' + ISNULL(P.ProjectCode, N'') + N' - ' + F.ItemTitle,
        CASE WHEN F.DueDate < @Today THEN N'Critical' ELSE N'Warning' END,
        N'Unread',
        F.DueDate,
        CASE WHEN F.DueDate < @Today THEN N'FOLLOWUP_OVERDUE' ELSE N'FOLLOWUP_DUE' END
    FROM dbo.ProjectFollowUpItems F
    INNER JOIN dbo.Projects P ON P.ProjectId = F.ProjectId
    WHERE F.IsDeleted=0 AND F.Status <> N'Closed' AND F.DueDate IS NOT NULL AND F.DueDate <= @Today
      AND NOT EXISTS (SELECT 1 FROM dbo.UserNotifications N WHERE N.IsDeleted=0 AND N.EntityType=N'FOLLOWUP' AND N.EntityId=F.FollowUpItemId AND N.SourceCode IN (N'FOLLOWUP_DUE', N'FOLLOWUP_OVERDUE') AND N.Status <> N'Archived');

    IF OBJECT_ID(N'dbo.ApprovalRequests', N'U') IS NOT NULL
    BEGIN
        INSERT INTO dbo.UserNotifications(UserId, ProjectId, EntityType, EntityId, NotificationTitle, NotificationBody, Severity, Status, DueDate, SourceCode)
        SELECT DISTINCT
            NULL,
            A.ProjectId,
            N'WORKFLOW',
            A.ApprovalRequestId,
            N'طلب اعتماد معلق',
            N'يوجد طلب اعتماد معلق: ' + A.RequestTitle,
            N'Info',
            N'Unread',
            NULL,
            N'WORKFLOW_PENDING'
        FROM dbo.ApprovalRequests A
        WHERE A.Status = N'Pending'
          AND NOT EXISTS (SELECT 1 FROM dbo.UserNotifications N WHERE N.IsDeleted=0 AND N.EntityType=N'WORKFLOW' AND N.EntityId=A.ApprovalRequestId AND N.SourceCode=N'WORKFLOW_PENDING' AND N.Status <> N'Archived');
    END
END
GO

PRINT N'Sprint 13 stored procedures created successfully.';
GO
