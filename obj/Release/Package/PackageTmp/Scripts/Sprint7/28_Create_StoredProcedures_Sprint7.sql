USE GeoSitePro;
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProjectDocuments_Get
    @ProjectId BIGINT = NULL,
    @DocumentTypeId BIGINT = NULL,
    @SearchText NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT D.ProjectDocumentId, D.ProjectId, P.ProjectCode, P.ProjectName, D.DocumentTypeId, LI.NameAr AS DocumentTypeNameAr,
           D.DocumentTitle, D.RelatedEntityName, D.RelatedEntityId, D.OriginalFileName, D.StoredFileName,
           D.FileExtension, D.ContentType, D.FileSizeBytes, CAST(ISNULL(D.FileSizeBytes,0)/1024.0 AS DECIMAL(18,1)) AS FileSizeKB,
           D.StoragePath, D.VersionNo, D.IsApproved, D.UploadedAt, D.UploadedBy, D.Notes
    FROM dbo.ProjectDocuments D
    LEFT JOIN dbo.Projects P ON P.ProjectId=D.ProjectId
    LEFT JOIN dbo.LookupItems LI ON LI.LookupItemId=D.DocumentTypeId
    WHERE D.IsDeleted=0
      AND (@ProjectId IS NULL OR D.ProjectId=@ProjectId)
      AND (@DocumentTypeId IS NULL OR D.DocumentTypeId=@DocumentTypeId)
      AND (@SearchText IS NULL OR D.DocumentTitle LIKE N'%'+@SearchText+N'%' OR D.OriginalFileName LIKE N'%'+@SearchText+N'%' OR D.RelatedEntityName LIKE N'%'+@SearchText+N'%')
    ORDER BY D.UploadedAt DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProjectDocument_GetById @ProjectDocumentId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.ProjectDocuments WHERE ProjectDocumentId=@ProjectDocumentId AND IsDeleted=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProjectDocument_Save
    @ProjectId BIGINT,
    @DocumentTypeId BIGINT = NULL,
    @DocumentTitle NVARCHAR(300),
    @RelatedEntityName NVARCHAR(100) = NULL,
    @RelatedEntityId BIGINT = NULL,
    @OriginalFileName NVARCHAR(500),
    @StoredFileName NVARCHAR(500),
    @FileExtension NVARCHAR(20) = NULL,
    @ContentType NVARCHAR(150) = NULL,
    @FileSizeBytes BIGINT = NULL,
    @StoragePath NVARCHAR(1000),
    @VersionNo INT = 1,
    @Notes NVARCHAR(MAX) = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.ProjectDocuments(ProjectId, DocumentTypeId, DocumentTitle, RelatedEntityName, RelatedEntityId, OriginalFileName, StoredFileName, FileExtension, ContentType, FileSizeBytes, StoragePath, VersionNo, Notes, UploadedBy)
    VALUES(@ProjectId, @DocumentTypeId, @DocumentTitle, @RelatedEntityName, @RelatedEntityId, @OriginalFileName, @StoredFileName, @FileExtension, @ContentType, @FileSizeBytes, @StoragePath, ISNULL(@VersionNo,1), @Notes, @UserId);
    DECLARE @Id BIGINT=SCOPE_IDENTITY();
    INSERT INTO dbo.AuditLogs(UserId, ActionType, EntityName, EntityId, ActionDescription, NewValues)
    VALUES(@UserId, N'Upload', N'ProjectDocuments', CONVERT(NVARCHAR(100),@Id), N'تم رفع مرفق مشروع.', @OriginalFileName);
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProjectDocument_Approve @ProjectDocumentId BIGINT, @UserId BIGINT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProjectDocuments SET IsApproved=1, ApprovedAt=SYSDATETIME(), ApprovedBy=@UserId WHERE ProjectDocumentId=@ProjectDocumentId;
    INSERT INTO dbo.AuditLogs(UserId, ActionType, EntityName, EntityId, ActionDescription)
    VALUES(@UserId, N'Approve', N'ProjectDocuments', CONVERT(NVARCHAR(100),@ProjectDocumentId), N'تم اعتماد مرفق مشروع.');
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProjectDocument_Delete @ProjectDocumentId BIGINT, @UserId BIGINT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProjectDocuments SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE ProjectDocumentId=@ProjectDocumentId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ExportPackages_Get
    @ProjectId BIGINT = NULL,
    @SearchText NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT E.ExportPackageId, E.ProjectId, P.ProjectCode, P.ProjectName, E.PackageTypeId, PT.NameAr AS PackageTypeNameAr,
           E.PackageStatusId, PS.NameAr AS PackageStatusNameAr, E.PackageTitle, E.IncludeBoreholes, E.IncludeSamples,
           E.IncludeSPT, E.IncludeGroundwater, E.IncludeLabResults, E.IncludeReports, E.IncludeDocuments,
           E.OutputPath, E.GeneratedAt, E.GeneratedBy, E.Notes, E.CreatedAt
    FROM dbo.ExportPackages E
    LEFT JOIN dbo.Projects P ON P.ProjectId=E.ProjectId
    LEFT JOIN dbo.LookupItems PT ON PT.LookupItemId=E.PackageTypeId
    LEFT JOIN dbo.LookupItems PS ON PS.LookupItemId=E.PackageStatusId
    WHERE E.IsDeleted=0
      AND (@ProjectId IS NULL OR E.ProjectId=@ProjectId)
      AND (@SearchText IS NULL OR E.PackageTitle LIKE N'%'+@SearchText+N'%' OR P.ProjectName LIKE N'%'+@SearchText+N'%' OR P.ProjectCode LIKE N'%'+@SearchText+N'%')
    ORDER BY E.CreatedAt DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ExportPackage_Save
    @ProjectId BIGINT,
    @PackageTypeId BIGINT = NULL,
    @PackageTitle NVARCHAR(300) = NULL,
    @IncludeBoreholes BIT = 1,
    @IncludeSamples BIT = 1,
    @IncludeSPT BIT = 1,
    @IncludeGroundwater BIT = 1,
    @IncludeLabResults BIT = 1,
    @IncludeReports BIT = 1,
    @IncludeDocuments BIT = 1,
    @Notes NVARCHAR(MAX) = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DraftStatusId BIGINT = (SELECT TOP 1 LI.LookupItemId FROM dbo.LookupItems LI INNER JOIN dbo.LookupCategories LC ON LC.LookupCategoryId=LI.LookupCategoryId WHERE LC.CategoryCode=N'ExportPackageStatus' AND LI.ItemCode=N'DRAFT' AND LI.IsDeleted=0);
    INSERT INTO dbo.ExportPackages(ProjectId, PackageTypeId, PackageStatusId, PackageTitle, IncludeBoreholes, IncludeSamples, IncludeSPT, IncludeGroundwater, IncludeLabResults, IncludeReports, IncludeDocuments, Notes, CreatedBy)
    VALUES(@ProjectId, @PackageTypeId, @DraftStatusId, @PackageTitle, @IncludeBoreholes, @IncludeSamples, @IncludeSPT, @IncludeGroundwater, @IncludeLabResults, @IncludeReports, @IncludeDocuments, @Notes, @UserId);
    DECLARE @Id BIGINT=SCOPE_IDENTITY();
    INSERT INTO dbo.AuditLogs(UserId, ActionType, EntityName, EntityId, ActionDescription)
    VALUES(@UserId, N'Create', N'ExportPackages', CONVERT(NVARCHAR(100),@Id), N'تم إنشاء حزمة تصدير.');
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ExportPackage_MarkGenerated @ExportPackageId BIGINT, @UserId BIGINT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @GeneratedStatusId BIGINT = (SELECT TOP 1 LI.LookupItemId FROM dbo.LookupItems LI INNER JOIN dbo.LookupCategories LC ON LC.LookupCategoryId=LI.LookupCategoryId WHERE LC.CategoryCode=N'ExportPackageStatus' AND LI.ItemCode=N'GENERATED' AND LI.IsDeleted=0);
    UPDATE dbo.ExportPackages SET PackageStatusId=@GeneratedStatusId, GeneratedAt=SYSDATETIME(), GeneratedBy=@UserId WHERE ExportPackageId=@ExportPackageId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ExportPackage_Delete @ExportPackageId BIGINT, @UserId BIGINT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ExportPackages SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE ExportPackageId=@ExportPackageId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProductionReadiness_Get
AS
BEGIN
    SET NOCOUNT ON;
    SELECT R.ReadinessCheckId, R.ReadinessAreaId, A.NameAr AS ReadinessAreaNameAr, R.CheckItem,
           R.ReadinessStatusId, S.NameAr AS ReadinessStatusNameAr, R.Evidence, R.Owner, R.ReviewedDate, R.CreatedAt
    FROM dbo.ProductionReadinessChecks R
    LEFT JOIN dbo.LookupItems A ON A.LookupItemId=R.ReadinessAreaId
    LEFT JOIN dbo.LookupItems S ON S.LookupItemId=R.ReadinessStatusId
    WHERE R.IsDeleted=0
    ORDER BY A.SortOrder, R.ReadinessCheckId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProductionReadiness_GetById @ReadinessCheckId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.ProductionReadinessChecks WHERE ReadinessCheckId=@ReadinessCheckId AND IsDeleted=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProductionReadiness_Save
    @ReadinessCheckId BIGINT = NULL,
    @ReadinessAreaId BIGINT = NULL,
    @CheckItem NVARCHAR(1000),
    @ReadinessStatusId BIGINT = NULL,
    @Evidence NVARCHAR(MAX) = NULL,
    @Owner NVARCHAR(200) = NULL,
    @ReviewedDate DATE = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @ReadinessCheckId IS NULL OR @ReadinessCheckId=0
    BEGIN
        INSERT INTO dbo.ProductionReadinessChecks(ReadinessAreaId, CheckItem, ReadinessStatusId, Evidence, Owner, ReviewedDate, CreatedBy)
        VALUES(@ReadinessAreaId, @CheckItem, @ReadinessStatusId, @Evidence, @Owner, @ReviewedDate, @UserId);
    END
    ELSE
    BEGIN
        UPDATE dbo.ProductionReadinessChecks SET ReadinessAreaId=@ReadinessAreaId, CheckItem=@CheckItem, ReadinessStatusId=@ReadinessStatusId, Evidence=@Evidence, Owner=@Owner, ReviewedDate=@ReviewedDate, UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId WHERE ReadinessCheckId=@ReadinessCheckId;
    END
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProductionReadiness_Delete @ReadinessCheckId BIGINT, @UserId BIGINT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProductionReadinessChecks SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE ReadinessCheckId=@ReadinessCheckId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProductionReadiness_SeedDefaults @UserId BIGINT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @NotStarted BIGINT=(SELECT TOP 1 LI.LookupItemId FROM dbo.LookupItems LI INNER JOIN dbo.LookupCategories LC ON LC.LookupCategoryId=LI.LookupCategoryId WHERE LC.CategoryCode=N'ReadinessStatus' AND LI.ItemCode=N'NOT_STARTED');
    DECLARE @Items TABLE(AreaCode NVARCHAR(100), CheckItem NVARCHAR(1000));
    INSERT INTO @Items VALUES
    (N'SECURITY', N'إيقاف debug وcustomErrors=Off قبل الإنتاج وتفعيل إعدادات أمان مناسبة.'),
    (N'SECURITY', N'مراجعة جميع الصلاحيات والتأكد من عدم استخدام حساب admin للتشغيل اليومي.'),
    (N'DATABASE', N'إعداد خطة نسخ احتياطي واسترجاع مجربة لقاعدة البيانات ومجلد App_Data/Uploads.'),
    (N'QUALITY', N'اختبار دورة اعتماد كاملة: إدخال بيانات، مراجعة، اعتماد، ثم تقرير نهائي.'),
    (N'EXPORT', N'اختبار تصدير وطباعة تقرير مشروع كامل ومقارنة المخرجات مع نموذج الشركة.'),
    (N'TESTING', N'تشغيل Build فعلي على Visual Studio وإصلاح أي أخطاء compile أو runtime.'),
    (N'TESTING', N'إدخال مشروع جيوتقني حقيقي كبيانات تجريبية ومراجعته من مهندس مختص.'),
    (N'PERFORMANCE', N'اختبار النظام بعدد كبير من الجسات والعينات والمرفقات قبل الاستخدام الرسمي.');

    INSERT INTO dbo.ProductionReadinessChecks(ReadinessAreaId, CheckItem, ReadinessStatusId, CreatedBy)
    SELECT A.LookupItemId, I.CheckItem, @NotStarted, @UserId
    FROM @Items I
    INNER JOIN dbo.LookupCategories LC ON LC.CategoryCode=N'ReadinessArea'
    INNER JOIN dbo.LookupItems A ON A.LookupCategoryId=LC.LookupCategoryId AND A.ItemCode=I.AreaCode
    WHERE NOT EXISTS(SELECT 1 FROM dbo.ProductionReadinessChecks R WHERE R.CheckItem=I.CheckItem AND R.IsDeleted=0);
END
GO

PRINT N'Sprint 7 stored procedures created successfully.';
GO
