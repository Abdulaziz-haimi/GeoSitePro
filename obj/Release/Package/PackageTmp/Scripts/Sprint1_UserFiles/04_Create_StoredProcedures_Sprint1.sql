USE GeoSitePro;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Login
    @Username NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT UserId, Username, FullName, Email, Mobile, PasswordHash, PasswordSalt, IsActive, LastLoginAt
    FROM dbo.Users
    WHERE Username = @Username AND IsDeleted = 0;

    SELECT DISTINCT P.PermissionCode
    FROM dbo.Users U
    INNER JOIN dbo.UserRoles UR ON UR.UserId = U.UserId AND UR.IsActive = 1
    INNER JOIN dbo.Roles R ON R.RoleId = UR.RoleId AND R.IsActive = 1 AND R.IsDeleted = 0
    INNER JOIN dbo.RolePermissions RP ON RP.RoleId = R.RoleId
    INNER JOIN dbo.Permissions P ON P.PermissionId = RP.PermissionId AND P.IsActive = 1 AND P.IsDeleted = 0
    WHERE U.Username = @Username AND U.IsActive = 1 AND U.IsDeleted = 0
    ORDER BY P.PermissionCode;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Lookups_GetByCategory
    @CategoryCode NVARCHAR(100),
    @OnlyActive BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SELECT LI.LookupItemId, LI.LookupCategoryId, LC.CategoryCode, LI.ItemCode, LI.NameAr, LI.NameEn, LI.Description, LI.SortOrder, LI.IsDefault, LI.IsActive
    FROM dbo.LookupItems LI
    INNER JOIN dbo.LookupCategories LC ON LC.LookupCategoryId = LI.LookupCategoryId AND LC.IsDeleted = 0 AND LC.IsActive = 1
    WHERE LC.CategoryCode = @CategoryCode AND LI.IsDeleted = 0 AND (@OnlyActive = 0 OR LI.IsActive = 1)
    ORDER BY LI.SortOrder, LI.NameAr;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Dashboard_GetSummary
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        TotalProjects = (SELECT COUNT(*) FROM dbo.Projects WHERE IsDeleted = 0),
        ActiveProjects = (SELECT COUNT(*) FROM dbo.Projects WHERE IsDeleted = 0 AND IsActive = 1),
        TotalBoreholes = 0,
        TotalSamples = 0,
        TotalSPT = 0,
        TotalLabTests = 0,
        TotalReports = 0;

    SELECT TOP 10
        P.ProjectId, P.ProjectCode, P.ProjectName, C.ClientName,
        ProjectStatusNameAr = PS.NameAr, P.City, P.LocationName, P.CreatedAt
    FROM dbo.Projects P
    LEFT JOIN dbo.Clients C ON C.ClientId = P.ClientId AND C.IsDeleted = 0
    LEFT JOIN dbo.LookupItems PS ON PS.LookupItemId = P.ProjectStatusId AND PS.IsDeleted = 0
    WHERE P.IsDeleted = 0
    ORDER BY P.CreatedAt DESC;

    SELECT ProjectStatusNameAr = ISNULL(PS.NameAr, N'غير محدد'), ProjectCount = COUNT(*)
    FROM dbo.Projects P
    LEFT JOIN dbo.LookupItems PS ON PS.LookupItemId = P.ProjectStatusId AND PS.IsDeleted = 0
    WHERE P.IsDeleted = 0
    GROUP BY ISNULL(PS.NameAr, N'غير محدد')
    ORDER BY ProjectCount DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Projects_Get
    @SearchText NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.ProjectId, P.ProjectCode, P.ProjectName, P.ProjectNameEn,
        P.ClientId, C.ClientName,
        P.ProjectTypeId, ProjectTypeNameAr = PT.NameAr, ProjectTypeNameEn = PT.NameEn,
        P.ProjectStatusId, ProjectStatusNameAr = PS.NameAr, ProjectStatusNameEn = PS.NameEn,
        P.StructureTypeId, StructureTypeNameAr = ST.NameAr, StructureTypeNameEn = ST.NameEn,
        P.InvestigationStageId, InvestigationStageNameAr = ISG.NameAr, InvestigationStageNameEn = ISG.NameEn,
        P.Country, P.City, P.District, P.LocationName, P.Address,
        P.SiteAreaM2, P.NumberOfFloors, P.BasementCount,
        P.ProjectStartDate, P.ProjectEndDate,
        P.IsActive, P.CreatedAt,
        BoreholeCount = 0,
        SampleCount = 0,
        ReportCount = 0
    FROM dbo.Projects P
    LEFT JOIN dbo.Clients C ON C.ClientId = P.ClientId AND C.IsDeleted = 0
    LEFT JOIN dbo.LookupItems PT ON PT.LookupItemId = P.ProjectTypeId AND PT.IsDeleted = 0
    LEFT JOIN dbo.LookupItems PS ON PS.LookupItemId = P.ProjectStatusId AND PS.IsDeleted = 0
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId = P.StructureTypeId AND ST.IsDeleted = 0
    LEFT JOIN dbo.LookupItems ISG ON ISG.LookupItemId = P.InvestigationStageId AND ISG.IsDeleted = 0
    WHERE P.IsDeleted = 0
      AND (
            @SearchText IS NULL OR @SearchText = N''
         OR P.ProjectCode LIKE N'%' + @SearchText + N'%'
         OR P.ProjectName LIKE N'%' + @SearchText + N'%'
         OR P.ProjectNameEn LIKE N'%' + @SearchText + N'%'
         OR C.ClientName LIKE N'%' + @SearchText + N'%'
         OR P.City LIKE N'%' + @SearchText + N'%'
         OR P.District LIKE N'%' + @SearchText + N'%'
         OR P.LocationName LIKE N'%' + @SearchText + N'%'
      )
    ORDER BY P.ProjectId DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Project_GetById
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.ProjectId, P.ProjectCode, P.ProjectName, P.ProjectNameEn,
        P.ClientId, C.ClientName,
        P.ProjectTypeId, ProjectTypeNameAr = PT.NameAr, ProjectTypeNameEn = PT.NameEn,
        P.ProjectStatusId, ProjectStatusNameAr = PS.NameAr, ProjectStatusNameEn = PS.NameEn,
        P.StructureTypeId, StructureTypeNameAr = ST.NameAr, StructureTypeNameEn = ST.NameEn,
        P.InvestigationStageId, InvestigationStageNameAr = ISG.NameAr, InvestigationStageNameEn = ISG.NameEn,
        P.Country, P.City, P.District, P.LocationName, P.Address,
        P.SiteAreaM2, P.NumberOfFloors, P.BasementCount,
        P.ProjectStartDate, P.ProjectEndDate,
        P.ScopeOfWork, P.GeneralNotes,
        P.IsActive, P.CreatedAt, P.UpdatedAt
    FROM dbo.Projects P
    LEFT JOIN dbo.Clients C ON C.ClientId = P.ClientId AND C.IsDeleted = 0
    LEFT JOIN dbo.LookupItems PT ON PT.LookupItemId = P.ProjectTypeId AND PT.IsDeleted = 0
    LEFT JOIN dbo.LookupItems PS ON PS.LookupItemId = P.ProjectStatusId AND PS.IsDeleted = 0
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId = P.StructureTypeId AND ST.IsDeleted = 0
    LEFT JOIN dbo.LookupItems ISG ON ISG.LookupItemId = P.InvestigationStageId AND ISG.IsDeleted = 0
    WHERE P.ProjectId = @ProjectId AND P.IsDeleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Project_Save
    @ProjectId BIGINT = NULL,
    @ProjectCode NVARCHAR(80),
    @ProjectName NVARCHAR(300),
    @ProjectNameEn NVARCHAR(300) = NULL,
    @ClientName NVARCHAR(250) = NULL,
    @ProjectTypeId BIGINT = NULL,
    @ProjectStatusId BIGINT = NULL,
    @StructureTypeId BIGINT = NULL,
    @InvestigationStageId BIGINT = NULL,
    @Country NVARCHAR(150) = NULL,
    @City NVARCHAR(150) = NULL,
    @District NVARCHAR(150) = NULL,
    @LocationName NVARCHAR(300) = NULL,
    @Address NVARCHAR(500) = NULL,
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
    DECLARE @SavedProjectId BIGINT;
    DECLARE @ClientId BIGINT = NULL;

    SET @ProjectCode = LTRIM(RTRIM(@ProjectCode));
    SET @ProjectName = LTRIM(RTRIM(@ProjectName));
    SET @ClientName = NULLIF(LTRIM(RTRIM(@ClientName)), N'');

    IF @ProjectCode IS NULL OR @ProjectCode = N'' BEGIN RAISERROR(N'كود المشروع مطلوب.',16,1); RETURN; END
    IF @ProjectName IS NULL OR @ProjectName = N'' BEGIN RAISERROR(N'اسم المشروع مطلوب.',16,1); RETURN; END
    IF @ProjectEndDate IS NOT NULL AND @ProjectStartDate IS NOT NULL AND @ProjectEndDate < @ProjectStartDate BEGIN RAISERROR(N'تاريخ نهاية المشروع لا يمكن أن يكون قبل تاريخ البداية.',16,1); RETURN; END

    IF EXISTS(SELECT 1 FROM dbo.Projects WHERE ProjectCode = @ProjectCode AND IsDeleted = 0 AND (@ProjectId IS NULL OR ProjectId <> @ProjectId))
    BEGIN RAISERROR(N'كود المشروع مستخدم مسبقًا.',16,1); RETURN; END

    IF @ClientName IS NOT NULL
    BEGIN
        SELECT TOP 1 @ClientId = ClientId FROM dbo.Clients WHERE ClientName = @ClientName AND IsDeleted = 0 ORDER BY ClientId;
        IF @ClientId IS NULL
        BEGIN
            INSERT INTO dbo.Clients(ClientName, CreatedBy) VALUES(@ClientName, @UserId);
            SET @ClientId = SCOPE_IDENTITY();
        END
    END

    IF @ProjectId IS NULL OR @ProjectId <= 0
    BEGIN
        INSERT INTO dbo.Projects
        (ProjectCode, ProjectName, ProjectNameEn, ClientId, ProjectTypeId, ProjectStatusId, StructureTypeId, InvestigationStageId, Country, City, District, LocationName, Address, SiteAreaM2, NumberOfFloors, BasementCount, ProjectStartDate, ProjectEndDate, ScopeOfWork, GeneralNotes, IsActive, CreatedBy)
        VALUES
        (@ProjectCode, @ProjectName, NULLIF(LTRIM(RTRIM(@ProjectNameEn)), N''), @ClientId, @ProjectTypeId, @ProjectStatusId, @StructureTypeId, @InvestigationStageId, NULLIF(LTRIM(RTRIM(@Country)), N''), NULLIF(LTRIM(RTRIM(@City)), N''), NULLIF(LTRIM(RTRIM(@District)), N''), NULLIF(LTRIM(RTRIM(@LocationName)), N''), NULLIF(LTRIM(RTRIM(@Address)), N''), @SiteAreaM2, @NumberOfFloors, @BasementCount, @ProjectStartDate, @ProjectEndDate, @ScopeOfWork, @GeneralNotes, @IsActive, @UserId);
        SET @SavedProjectId = SCOPE_IDENTITY();
        INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription, NewValues)
        VALUES(@UserId, (SELECT Username FROM dbo.Users WHERE UserId=@UserId), N'Insert', N'Projects', CONVERT(NVARCHAR(100),@SavedProjectId), N'تم إنشاء مشروع جديد.', N'ProjectCode=' + @ProjectCode);
    END
    ELSE
    BEGIN
        IF NOT EXISTS(SELECT 1 FROM dbo.Projects WHERE ProjectId=@ProjectId AND IsDeleted=0) BEGIN RAISERROR(N'المشروع غير موجود.',16,1); RETURN; END
        UPDATE dbo.Projects SET
            ProjectCode=@ProjectCode,
            ProjectName=@ProjectName,
            ProjectNameEn=NULLIF(LTRIM(RTRIM(@ProjectNameEn)), N''),
            ClientId=@ClientId,
            ProjectTypeId=@ProjectTypeId,
            ProjectStatusId=@ProjectStatusId,
            StructureTypeId=@StructureTypeId,
            InvestigationStageId=@InvestigationStageId,
            Country=NULLIF(LTRIM(RTRIM(@Country)), N''),
            City=NULLIF(LTRIM(RTRIM(@City)), N''),
            District=NULLIF(LTRIM(RTRIM(@District)), N''),
            LocationName=NULLIF(LTRIM(RTRIM(@LocationName)), N''),
            Address=NULLIF(LTRIM(RTRIM(@Address)), N''),
            SiteAreaM2=@SiteAreaM2,
            NumberOfFloors=@NumberOfFloors,
            BasementCount=@BasementCount,
            ProjectStartDate=@ProjectStartDate,
            ProjectEndDate=@ProjectEndDate,
            ScopeOfWork=@ScopeOfWork,
            GeneralNotes=@GeneralNotes,
            IsActive=@IsActive,
            UpdatedAt=SYSDATETIME(),
            UpdatedBy=@UserId
        WHERE ProjectId=@ProjectId;
        SET @SavedProjectId = @ProjectId;
        INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription, NewValues)
        VALUES(@UserId, (SELECT Username FROM dbo.Users WHERE UserId=@UserId), N'Update', N'Projects', CONVERT(NVARCHAR(100),@SavedProjectId), N'تم تعديل بيانات المشروع.', N'ProjectCode=' + @ProjectCode);
    END

    SELECT @SavedProjectId AS ProjectId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Project_Delete
    @ProjectId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS(SELECT 1 FROM dbo.Projects WHERE ProjectId=@ProjectId AND IsDeleted=0) BEGIN RAISERROR(N'المشروع غير موجود.',16,1); RETURN; END
    UPDATE dbo.Projects SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE ProjectId=@ProjectId;
    INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription)
    VALUES(@UserId, (SELECT Username FROM dbo.Users WHERE UserId=@UserId), N'Delete', N'Projects', CONVERT(NVARCHAR(100),@ProjectId), N'تم حذف المشروع منطقيًا.');
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProjectDashboard_Get
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.sp_Project_GetById @ProjectId = @ProjectId;
    SELECT
        BoreholePlanCount = 0,
        BoreholeCount = 0,
        LayerCount = 0,
        SampleCount = 0,
        SPTCount = 0,
        GroundwaterCount = 0,
        LabTestCount = 0,
        ReportCount = 0,
        DocumentCount = 0;
END
GO

PRINT N'Sprint 1 stored procedures created successfully.';
GO
