USE GeoSitePro;
GO

CREATE OR ALTER PROCEDURE dbo.sp_SystemSettings_Get
    @Category NVARCHAR(80) = NULL,
    @SearchText NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @Category = NULLIF(LTRIM(RTRIM(@Category)), N'');
    SET @SearchText = NULLIF(LTRIM(RTRIM(@SearchText)), N'');
    SELECT TOP 500
        SettingId, Category, SettingKey,
        SettingValueMasked = CASE WHEN IsEncrypted = 1 THEN N'********' ELSE ISNULL(CONVERT(NVARCHAR(500), SettingValue), N'') END,
        SettingValue, DataType, Description, IsEncrypted, IsActive,
        IsActiveText = CASE WHEN IsActive = 1 THEN N'نشط' ELSE N'موقوف' END,
        CreatedAt, UpdatedAt
    FROM dbo.SystemSettings
    WHERE IsDeleted = 0
      AND (@Category IS NULL OR Category = @Category)
      AND (@SearchText IS NULL OR SettingKey LIKE N'%' + @SearchText + N'%' OR Description LIKE N'%' + @SearchText + N'%')
    ORDER BY Category, SettingKey;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_SystemSetting_GetById
    @SettingId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT SettingId, Category, SettingKey, SettingValue, DataType, Description, IsEncrypted, IsActive
    FROM dbo.SystemSettings
    WHERE SettingId = @SettingId AND IsDeleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_SystemSetting_Save
    @SettingId BIGINT = NULL,
    @Category NVARCHAR(80),
    @SettingKey NVARCHAR(150),
    @SettingValue NVARCHAR(MAX) = NULL,
    @DataType NVARCHAR(30) = N'Text',
    @Description NVARCHAR(500) = NULL,
    @IsEncrypted BIT = 0,
    @IsActive BIT = 1,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @SettingKey = LTRIM(RTRIM(@SettingKey));
    IF NULLIF(@SettingKey, N'') IS NULL THROW 50001, 'Setting key is required.', 1;

    IF EXISTS(SELECT 1 FROM dbo.SystemSettings WHERE SettingKey = @SettingKey AND IsDeleted = 0 AND (@SettingId IS NULL OR SettingId <> @SettingId))
        THROW 50002, 'Setting key already exists.', 1;

    IF @SettingId IS NULL OR @SettingId = 0
    BEGIN
        INSERT INTO dbo.SystemSettings(Category, SettingKey, SettingValue, DataType, Description, IsEncrypted, IsActive, CreatedBy)
        VALUES(@Category, @SettingKey, @SettingValue, @DataType, @Description, @IsEncrypted, @IsActive, @UserId);
        SELECT SCOPE_IDENTITY() AS SettingId;
    END
    ELSE
    BEGIN
        UPDATE dbo.SystemSettings
        SET Category=@Category, SettingKey=@SettingKey, SettingValue=@SettingValue, DataType=@DataType,
            Description=@Description, IsEncrypted=@IsEncrypted, IsActive=@IsActive,
            UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId
        WHERE SettingId=@SettingId AND IsDeleted=0;
        SELECT @SettingId AS SettingId;
    END
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_SystemSetting_Delete
    @SettingId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.SystemSettings
    SET IsDeleted = 1, DeletedAt = SYSDATETIME(), DeletedBy = @UserId
    WHERE SettingId = @SettingId AND IsDeleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_BackupJob_Create
    @BackupType NVARCHAR(40),
    @BackupPath NVARCHAR(500),
    @Description NVARCHAR(1000) = NULL,
    @BackupCommand NVARCHAR(MAX) = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Code NVARCHAR(80) = N'BKP-' + CONVERT(NVARCHAR(20), NEXT VALUE FOR dbo.SeqBackupJobCode);
    INSERT INTO dbo.SystemBackupJobs(BackupCode, BackupType, BackupPath, BackupCommand, Description, Status, RequestedBy)
    VALUES(@Code, @BackupType, @BackupPath, @BackupCommand, @Description, N'Requested', @UserId);

    DECLARE @BackupJobId BIGINT = SCOPE_IDENTITY();

    INSERT INTO dbo.SystemOperationLogs(LogLevel, ModuleName, ActionName, EntityName, EntityId, Message, Details, UserId)
    VALUES(N'Info', N'Backup', N'CreateBackupRequest', N'SystemBackupJobs', @BackupJobId, N'Backup request created.', @BackupCommand, @UserId);

    SELECT BackupJobId = @BackupJobId, BackupCode = @Code, BackupCommand = @BackupCommand;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_BackupJobs_Get
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 200
        B.BackupCode, B.BackupType, B.BackupPath, B.Status,
        RequestedBy = U.FullName,
        B.RequestedAt, B.CompletedAt, B.ResultMessage
    FROM dbo.SystemBackupJobs B
    LEFT JOIN dbo.Users U ON U.UserId = B.RequestedBy
    WHERE B.IsDeleted = 0
    ORDER BY B.RequestedAt DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_SystemOperationLog_Create
    @LogLevel NVARCHAR(30) = N'Info',
    @ModuleName NVARCHAR(100),
    @ActionName NVARCHAR(150),
    @EntityName NVARCHAR(100) = NULL,
    @EntityId BIGINT = NULL,
    @Message NVARCHAR(500),
    @Details NVARCHAR(MAX) = NULL,
    @UserId BIGINT = NULL,
    @ClientIp NVARCHAR(80) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.SystemOperationLogs(LogLevel, ModuleName, ActionName, EntityName, EntityId, Message, Details, UserId, ClientIp)
    VALUES(@LogLevel, @ModuleName, @ActionName, @EntityName, @EntityId, @Message, @Details, @UserId, @ClientIp);
    SELECT SCOPE_IDENTITY() AS SystemLogId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_SystemOperationLogs_Get
    @LogLevel NVARCHAR(30) = NULL,
    @ModuleName NVARCHAR(100) = NULL,
    @FromDate DATE = NULL,
    @ToDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @LogLevel = NULLIF(LTRIM(RTRIM(@LogLevel)), N'');
    SET @ModuleName = NULLIF(LTRIM(RTRIM(@ModuleName)), N'');
    SELECT TOP 500
        L.CreatedAt, L.LogLevel, L.ModuleName, L.ActionName, L.EntityName, L.EntityId,
        L.Message, L.Details, U.FullName AS UserName, L.ClientIp
    FROM dbo.SystemOperationLogs L
    LEFT JOIN dbo.Users U ON U.UserId = L.UserId
    WHERE (@LogLevel IS NULL OR L.LogLevel = @LogLevel)
      AND (@ModuleName IS NULL OR L.ModuleName LIKE N'%' + @ModuleName + N'%')
      AND (@FromDate IS NULL OR L.CreatedAt >= @FromDate)
      AND (@ToDate IS NULL OR L.CreatedAt < DATEADD(DAY, 1, @ToDate))
    ORDER BY L.CreatedAt DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_SystemHealth_Get
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Required TABLE(TableName SYSNAME NOT NULL);
    INSERT INTO @Required(TableName) VALUES
    (N'Projects'),(N'Boreholes'),(N'BoreholeLayers'),(N'Samples'),(N'SPTTests'),(N'GroundwaterObservations'),
    (N'LabTestResults'),(N'TechnicalReports'),(N'WorkflowSteps'),(N'ApprovalRequests'),(N'UserNotifications'),
    (N'ProjectFollowUpItems'),(N'ProjectRiskRegister'),(N'ProjectKpiSnapshots'),(N'SystemSettings'),(N'SystemBackupJobs'),(N'SystemOperationLogs');

    SELECT
        RequiredTables = (SELECT COUNT(1) FROM @Required),
        MissingTables = (SELECT COUNT(1) FROM @Required WHERE OBJECT_ID(N'dbo.' + TableName, N'U') IS NULL),
        ActiveSettings = (SELECT COUNT(1) FROM dbo.SystemSettings WHERE IsDeleted=0 AND IsActive=1),
        BackupJobs = (SELECT COUNT(1) FROM dbo.SystemBackupJobs WHERE IsDeleted=0),
        OperationLogs = (SELECT COUNT(1) FROM dbo.SystemOperationLogs),
        PendingApprovals = (SELECT COUNT(1) FROM dbo.ApprovalRequests WHERE IsDeleted=0 AND Status=N'Pending'),
        OverdueFollowUps = (SELECT COUNT(1) FROM dbo.ProjectFollowUpItems WHERE IsDeleted=0 AND Status<>N'Closed' AND DueDate < CONVERT(DATE, GETDATE())),
        HighRisks = (SELECT COUNT(1) FROM dbo.ProjectRiskRegister WHERE IsDeleted=0 AND Status<>N'Closed' AND RiskLevel IN (N'High', N'Critical'));

    SELECT CheckArea = N'Database', CheckName = N'Required table: ' + TableName,
           Status = CASE WHEN OBJECT_ID(N'dbo.' + TableName, N'U') IS NULL THEN N'Fail' ELSE N'Pass' END,
           Finding = CASE WHEN OBJECT_ID(N'dbo.' + TableName, N'U') IS NULL THEN N'Missing table' ELSE N'Table exists' END,
           Recommendation = CASE WHEN OBJECT_ID(N'dbo.' + TableName, N'U') IS NULL THEN N'Run the related sprint SQL scripts.' ELSE N'No action required.' END
    FROM @Required
    UNION ALL
    SELECT N'Backup', N'Backup requests',
           CASE WHEN EXISTS(SELECT 1 FROM dbo.SystemBackupJobs WHERE IsDeleted=0) THEN N'Warning' ELSE N'Warning' END,
           CASE WHEN EXISTS(SELECT 1 FROM dbo.SystemBackupJobs WHERE IsDeleted=0) THEN N'Backup request records exist; verify real SQL backup execution outside the web app.' ELSE N'No backup requests recorded yet.' END,
           N'Create a backup request and execute the generated BACKUP DATABASE command in SSMS.'
    UNION ALL
    SELECT N'Quality', N'Overdue follow-up items',
           CASE WHEN EXISTS(SELECT 1 FROM dbo.ProjectFollowUpItems WHERE IsDeleted=0 AND Status<>N'Closed' AND DueDate < CONVERT(DATE, GETDATE())) THEN N'Warning' ELSE N'Pass' END,
           N'Overdue follow-up count: ' + CONVERT(NVARCHAR(20),(SELECT COUNT(1) FROM dbo.ProjectFollowUpItems WHERE IsDeleted=0 AND Status<>N'Closed' AND DueDate < CONVERT(DATE, GETDATE()))),
           N'Review Follow-up Board.'
    UNION ALL
    SELECT N'Risk', N'High/Critical open risks',
           CASE WHEN EXISTS(SELECT 1 FROM dbo.ProjectRiskRegister WHERE IsDeleted=0 AND Status<>N'Closed' AND RiskLevel IN (N'High', N'Critical')) THEN N'Warning' ELSE N'Pass' END,
           N'High/Critical open risks: ' + CONVERT(NVARCHAR(20),(SELECT COUNT(1) FROM dbo.ProjectRiskRegister WHERE IsDeleted=0 AND Status<>N'Closed' AND RiskLevel IN (N'High', N'Critical'))),
           N'Review Project Risk Register.'
    ORDER BY CheckArea, CheckName;
END
GO

PRINT N'Sprint 15 stored procedures created successfully.';
GO
