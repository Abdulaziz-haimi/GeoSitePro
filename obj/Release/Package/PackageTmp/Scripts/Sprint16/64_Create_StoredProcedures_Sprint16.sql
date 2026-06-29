USE GeoSitePro;
GO

CREATE OR ALTER PROCEDURE dbo.sp_SecurityEvent_Log
    @EventType NVARCHAR(80),
    @Severity NVARCHAR(30),
    @UserId BIGINT = NULL,
    @Username NVARCHAR(150) = NULL,
    @IpAddress NVARCHAR(80) = NULL,
    @UserAgent NVARCHAR(500) = NULL,
    @EntityName NVARCHAR(120) = NULL,
    @EntityId BIGINT = NULL,
    @Message NVARCHAR(500),
    @Details NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.SystemSecurityEvents(EventType, Severity, UserId, Username, IpAddress, UserAgent, EntityName, EntityId, Message, Details)
    VALUES(@EventType, ISNULL(NULLIF(@Severity,''),'Info'), @UserId, @Username, @IpAddress, @UserAgent, @EntityName, @EntityId, @Message, @Details);
    SELECT SCOPE_IDENTITY() AS EventId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_SecurityEvents_Get
    @Severity NVARCHAR(30) = NULL,
    @SearchText NVARCHAR(200) = NULL,
    @Top INT = 100
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (ISNULL(@Top,100))
        EventId, CreatedAt, EventType, Severity, UserId, Username, IpAddress, EntityName, EntityId, Message, Details
    FROM dbo.SystemSecurityEvents
    WHERE (@Severity IS NULL OR @Severity = '' OR Severity = @Severity)
      AND (@SearchText IS NULL OR @SearchText = '' OR Message LIKE '%' + @SearchText + '%' OR Username LIKE '%' + @SearchText + '%' OR EventType LIKE '%' + @SearchText + '%')
    ORDER BY CreatedAt DESC, EventId DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_SecurityDashboard_Get
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        (SELECT COUNT(*) FROM dbo.SystemSecurityEvents WHERE CreatedAt >= DATEADD(DAY,-7,GETDATE())) AS EventsLast7Days,
        (SELECT COUNT(*) FROM dbo.SystemSecurityEvents WHERE Severity IN ('Critical','High') AND CreatedAt >= DATEADD(DAY,-30,GETDATE())) AS CriticalEvents,
        (SELECT COUNT(*) FROM dbo.SystemSecurityEvents WHERE EventType = 'LOGIN_FAILED' AND CreatedAt >= DATEADD(DAY,-30,GETDATE())) AS FailedLogins,
        (SELECT COUNT(*) FROM dbo.DeploymentChecklistItems WHERE IsDeleted = 0 AND IsActive = 1 AND RequiredForProduction = 1 AND Status NOT IN ('Completed','Not Applicable')) AS OpenProductionItems;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_PasswordPolicy_Get
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.PasswordPolicies WHERE IsActive = 1)
    BEGIN
        INSERT INTO dbo.PasswordPolicies(MinLength, RequireUppercase, RequireLowercase, RequireNumber, RequireSpecial, ExpiryDays, MaxFailedAttempts, LockoutMinutes, SessionTimeoutMinutes, AllowRememberMe, ForceChangeDefaultPassword, IsActive)
        VALUES(10,1,1,1,1,90,5,15,30,0,1,1);
    END
    SELECT TOP 1 * FROM dbo.PasswordPolicies WHERE IsActive = 1 ORDER BY PolicyId DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_PasswordPolicy_Save
    @PolicyId BIGINT = NULL,
    @MinLength INT,
    @RequireUppercase BIT,
    @RequireLowercase BIT,
    @RequireNumber BIT,
    @RequireSpecial BIT,
    @ExpiryDays INT,
    @MaxFailedAttempts INT,
    @LockoutMinutes INT,
    @SessionTimeoutMinutes INT,
    @AllowRememberMe BIT,
    @ForceChangeDefaultPassword BIT,
    @IsActive BIT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @IsActive = 1 UPDATE dbo.PasswordPolicies SET IsActive = 0 WHERE PolicyId <> ISNULL(@PolicyId,0);
    IF @PolicyId IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.PasswordPolicies WHERE PolicyId = @PolicyId)
    BEGIN
        INSERT INTO dbo.PasswordPolicies(MinLength, RequireUppercase, RequireLowercase, RequireNumber, RequireSpecial, ExpiryDays, MaxFailedAttempts, LockoutMinutes, SessionTimeoutMinutes, AllowRememberMe, ForceChangeDefaultPassword, IsActive, CreatedBy)
        VALUES(@MinLength, @RequireUppercase, @RequireLowercase, @RequireNumber, @RequireSpecial, @ExpiryDays, @MaxFailedAttempts, @LockoutMinutes, @SessionTimeoutMinutes, @AllowRememberMe, @ForceChangeDefaultPassword, @IsActive, @UserId);
        SELECT SCOPE_IDENTITY() AS PolicyId;
    END
    ELSE
    BEGIN
        UPDATE dbo.PasswordPolicies
           SET MinLength=@MinLength, RequireUppercase=@RequireUppercase, RequireLowercase=@RequireLowercase, RequireNumber=@RequireNumber, RequireSpecial=@RequireSpecial,
               ExpiryDays=@ExpiryDays, MaxFailedAttempts=@MaxFailedAttempts, LockoutMinutes=@LockoutMinutes, SessionTimeoutMinutes=@SessionTimeoutMinutes,
               AllowRememberMe=@AllowRememberMe, ForceChangeDefaultPassword=@ForceChangeDefaultPassword, IsActive=@IsActive, UpdatedAt=GETDATE(), UpdatedBy=@UserId
         WHERE PolicyId=@PolicyId;
        SELECT @PolicyId AS PolicyId;
    END
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeploymentChecklist_SeedDefaults
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @items TABLE(Area NVARCHAR(80), ItemCode NVARCHAR(80), ItemTitle NVARCHAR(250), Description NVARCHAR(MAX), SortOrder INT);
    INSERT INTO @items VALUES
    ('Security','SEC-001',N'إيقاف debug في Web.config',N'يجب أن يكون debug=false في بيئة الإنتاج.',10),
    ('Security','SEC-002',N'تفعيل customErrors للإنتاج',N'منع ظهور تفاصيل الأخطاء للمستخدم النهائي.',20),
    ('Security','SEC-003',N'سياسة كلمات مرور قوية',N'مراجعة الحد الأدنى للطول والمتطلبات ومحاولات الدخول.',30),
    ('Database','DB-001',N'نسخة احتياطية مجربة',N'إنشاء نسخة احتياطية واختبار الاسترجاع قبل الإطلاق.',40),
    ('Database','DB-002',N'تشغيل كل ملفات Verify',N'يجب أن تعود ملفات التحقق بدون نواقص.',50),
    ('Backup','BKP-001',N'خطة احتفاظ بالنسخ',N'تحديد مسار النسخ وعدد أيام الاحتفاظ.',60),
    ('Testing','TST-001',N'اختبار تسجيل الدخول والصلاحيات',N'اختبار دخول admin ومستخدم محدود.',70),
    ('Testing','TST-002',N'اختبار إدخال مشروع كامل',N'مشروع، جسات، عينات، SPT، مختبر، تقرير، طباعة.',80),
    ('Reporting','REP-001',N'اختبار الطباعة والتصدير',N'تجربة PDF من المتصفح وCSV/GIS.',90),
    ('Operations','OPS-001',N'تحديد مسؤول النظام',N'تحديد مسؤول قاعدة البيانات ومسؤول النظام.',100);

    MERGE dbo.DeploymentChecklistItems AS t
    USING @items AS s ON t.ItemCode = s.ItemCode
    WHEN MATCHED THEN UPDATE SET t.Area=s.Area, t.ItemTitle=s.ItemTitle, t.Description=s.Description, t.SortOrder=s.SortOrder, t.IsDeleted=0, t.IsActive=1, t.UpdatedAt=GETDATE(), t.UpdatedBy=@UserId
    WHEN NOT MATCHED THEN INSERT(Area,ItemCode,ItemTitle,Description,RequiredForProduction,Status,SortOrder,CreatedBy)
         VALUES(s.Area,s.ItemCode,s.ItemTitle,s.Description,1,'Not Started',s.SortOrder,@UserId);
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeploymentChecklist_Get
    @Area NVARCHAR(80) = NULL,
    @Status NVARCHAR(40) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ItemId, Area, ItemCode, ItemTitle, Description, RequiredForProduction,
           CASE WHEN RequiredForProduction = 1 THEN N'نعم' ELSE N'لا' END AS RequiredText,
           Status, EvidenceNotes, ResponsiblePerson, CheckedAt, IsActive
    FROM dbo.DeploymentChecklistItems
    WHERE IsDeleted = 0
      AND (@Area IS NULL OR @Area = '' OR Area = @Area)
      AND (@Status IS NULL OR @Status = '' OR Status = @Status)
    ORDER BY Area, SortOrder, ItemId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeploymentChecklist_GetById
    @ItemId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.DeploymentChecklistItems WHERE ItemId = @ItemId AND IsDeleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeploymentChecklist_Save
    @ItemId BIGINT = NULL,
    @Area NVARCHAR(80),
    @ItemCode NVARCHAR(80),
    @ItemTitle NVARCHAR(250),
    @Description NVARCHAR(MAX) = NULL,
    @RequiredForProduction BIT,
    @Status NVARCHAR(40),
    @EvidenceNotes NVARCHAR(MAX) = NULL,
    @ResponsiblePerson NVARCHAR(150) = NULL,
    @IsActive BIT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @ItemId IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.DeploymentChecklistItems WHERE ItemId = @ItemId)
    BEGIN
        INSERT INTO dbo.DeploymentChecklistItems(Area,ItemCode,ItemTitle,Description,RequiredForProduction,Status,EvidenceNotes,ResponsiblePerson,IsActive,CreatedBy,CheckedAt,CheckedBy)
        VALUES(@Area,@ItemCode,@ItemTitle,@Description,@RequiredForProduction,@Status,@EvidenceNotes,@ResponsiblePerson,@IsActive,@UserId,CASE WHEN @Status='Completed' THEN GETDATE() ELSE NULL END,CASE WHEN @Status='Completed' THEN @UserId ELSE NULL END);
        SELECT SCOPE_IDENTITY() AS ItemId;
    END
    ELSE
    BEGIN
        UPDATE dbo.DeploymentChecklistItems
           SET Area=@Area, ItemCode=@ItemCode, ItemTitle=@ItemTitle, Description=@Description, RequiredForProduction=@RequiredForProduction,
               Status=@Status, EvidenceNotes=@EvidenceNotes, ResponsiblePerson=@ResponsiblePerson, IsActive=@IsActive,
               CheckedAt=CASE WHEN @Status='Completed' THEN ISNULL(CheckedAt,GETDATE()) ELSE CheckedAt END,
               CheckedBy=CASE WHEN @Status='Completed' THEN ISNULL(CheckedBy,@UserId) ELSE CheckedBy END,
               UpdatedAt=GETDATE(), UpdatedBy=@UserId
         WHERE ItemId=@ItemId;
        SELECT @ItemId AS ItemId;
    END
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeploymentChecklist_Delete
    @ItemId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.DeploymentChecklistItems SET IsDeleted=1, UpdatedAt=GETDATE(), UpdatedBy=@UserId WHERE ItemId=@ItemId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeploymentChecklist_Summary
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Total INT = (SELECT COUNT(*) FROM dbo.DeploymentChecklistItems WHERE IsDeleted=0 AND IsActive=1 AND RequiredForProduction=1);
    DECLARE @Completed INT = (SELECT COUNT(*) FROM dbo.DeploymentChecklistItems WHERE IsDeleted=0 AND IsActive=1 AND RequiredForProduction=1 AND Status IN ('Completed','Not Applicable'));
    SELECT @Total AS TotalItems, @Completed AS CompletedItems, (@Total-@Completed) AS OpenItems,
           CASE WHEN @Total = 0 THEN 0 ELSE CAST(ROUND((@Completed * 100.0) / @Total, 0) AS INT) END AS ReadinessScore;
END
GO

PRINT 'Sprint 16 stored procedures created successfully.';
GO
