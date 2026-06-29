USE GeoSitePro;
GO

/* Sprint 3 lookups and permissions. Run after Sprint 2 compatibility/fixed scripts. */

DECLARE @Categories TABLE(CategoryCode NVARCHAR(100), CategoryNameAr NVARCHAR(200), CategoryNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Categories VALUES
(N'LabTestType', N'نوع الاختبار المعملي', N'Laboratory Test Type', 200),
(N'LabResultStatus', N'حالة النتيجة المعملية', N'Lab Result Status', 210);

UPDATE T
SET T.CategoryNameAr = S.CategoryNameAr,
    T.CategoryNameEn = S.CategoryNameEn,
    T.SortOrder = S.SortOrder,
    T.IsActive = 1,
    T.IsDeleted = 0
FROM dbo.LookupCategories T
INNER JOIN @Categories S ON S.CategoryCode = T.CategoryCode;

INSERT INTO dbo.LookupCategories(CategoryCode, CategoryNameAr, CategoryNameEn, SortOrder, IsActive, IsDeleted)
SELECT S.CategoryCode, S.CategoryNameAr, S.CategoryNameEn, S.SortOrder, 1, 0
FROM @Categories S
WHERE NOT EXISTS(SELECT 1 FROM dbo.LookupCategories T WHERE T.CategoryCode = S.CategoryCode);
GO

DECLARE @Items TABLE(CategoryCode NVARCHAR(100), ItemCode NVARCHAR(100), NameAr NVARCHAR(200), NameEn NVARCHAR(200), SortOrder INT, IsDefault BIT);
INSERT INTO @Items VALUES
(N'LabTestType', N'MOISTURE_CONTENT', N'محتوى الرطوبة', N'Moisture Content', 10, 1),
(N'LabTestType', N'SIEVE_ANALYSIS', N'التحليل المنخلي', N'Sieve Analysis', 20, 0),
(N'LabTestType', N'HYDROMETER', N'تحليل الهيدروميتر', N'Hydrometer Analysis', 30, 0),
(N'LabTestType', N'ATTERBERG_LIMITS', N'حدود أتربرج', N'Atterberg Limits', 40, 0),
(N'LabTestType', N'SPECIFIC_GRAVITY', N'الكثافة النوعية', N'Specific Gravity', 50, 0),
(N'LabTestType', N'BULK_DENSITY', N'الكثافة الحجمية', N'Bulk Density', 60, 0),
(N'LabTestType', N'COMPACTION', N'اختبار الدمك', N'Compaction Test', 70, 0),
(N'LabTestType', N'CBR', N'نسبة تحمل كاليفورنيا CBR', N'California Bearing Ratio', 80, 0),
(N'LabTestType', N'CONSOLIDATION', N'الانضغاطية', N'Consolidation', 90, 0),
(N'LabTestType', N'DIRECT_SHEAR', N'القص المباشر', N'Direct Shear', 100, 0),
(N'LabTestType', N'TRIAXIAL_UU', N'ثلاثي المحاور UU', N'Triaxial UU', 110, 0),
(N'LabTestType', N'UCS_ROCK', N'مقاومة الضغط أحادية المحور للصخر', N'Rock UCS', 120, 0),
(N'LabTestType', N'POINT_LOAD', N'اختبار التحميل النقطي', N'Point Load Test', 130, 0),
(N'LabTestType', N'SULPHATE_CHLORIDE', N'الكبريتات والكلوريدات', N'Sulphate and Chloride', 140, 0),
(N'LabResultStatus', N'PENDING', N'بانتظار الاختبار', N'Pending', 10, 1),
(N'LabResultStatus', N'IN_PROGRESS', N'قيد التنفيذ', N'In Progress', 20, 0),
(N'LabResultStatus', N'COMPLETED', N'مكتملة', N'Completed', 30, 0),
(N'LabResultStatus', N'REVIEWED', N'تمت المراجعة', N'Reviewed', 40, 0),
(N'LabResultStatus', N'APPROVED', N'معتمدة', N'Approved', 50, 0),
(N'LabResultStatus', N'REJECTED', N'مرفوضة', N'Rejected', 60, 0);

;WITH SourceItems AS
(
    SELECT C.LookupCategoryId, C.CategoryCode, I.ItemCode, I.NameAr, I.NameEn, I.SortOrder, I.IsDefault
    FROM @Items I
    INNER JOIN dbo.LookupCategories C ON C.CategoryCode = I.CategoryCode AND C.IsDeleted = 0
)
UPDATE T
SET T.LookupCategoryId = S.LookupCategoryId,
    T.CategoryCode = S.CategoryCode,
    T.ItemCode = S.ItemCode,
    T.Code = S.ItemCode,
    T.NameAr = S.NameAr,
    T.NameEn = S.NameEn,
    T.SortOrder = S.SortOrder,
    T.IsDefault = S.IsDefault,
    T.IsActive = 1,
    T.IsDeleted = 0
FROM dbo.LookupItems T
INNER JOIN SourceItems S
    ON (T.LookupCategoryId = S.LookupCategoryId OR T.CategoryCode = S.CategoryCode)
   AND (T.ItemCode = S.ItemCode OR T.Code = S.ItemCode);

;WITH SourceItems AS
(
    SELECT C.LookupCategoryId, C.CategoryCode, I.ItemCode, I.NameAr, I.NameEn, I.SortOrder, I.IsDefault
    FROM @Items I
    INNER JOIN dbo.LookupCategories C ON C.CategoryCode = I.CategoryCode AND C.IsDeleted = 0
)
INSERT INTO dbo.LookupItems(LookupCategoryId, CategoryCode, ItemCode, Code, NameAr, NameEn, SortOrder, IsDefault, IsActive, IsDeleted)
SELECT S.LookupCategoryId, S.CategoryCode, S.ItemCode, S.ItemCode, S.NameAr, S.NameEn, S.SortOrder, S.IsDefault, 1, 0
FROM SourceItems S
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.LookupItems T
    WHERE (T.LookupCategoryId = S.LookupCategoryId OR T.CategoryCode = S.CategoryCode)
      AND (T.ItemCode = S.ItemCode OR T.Code = S.ItemCode)
      AND T.IsDeleted = 0
);
GO

DECLARE @Permissions TABLE(ModuleName NVARCHAR(100), PermissionCode NVARCHAR(150), PermissionNameAr NVARCHAR(200), PermissionNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Permissions VALUES
(N'LabResults', N'LabResults.View', N'عرض النتائج المعملية', N'View Lab Results', 10),
(N'LabResults', N'LabResults.Create', N'إضافة نتيجة معملية', N'Create Lab Result', 20),
(N'LabResults', N'LabResults.Edit', N'تعديل نتيجة معملية', N'Edit Lab Result', 30),
(N'LabResults', N'LabResults.Delete', N'حذف نتيجة معملية', N'Delete Lab Result', 40),
(N'LabResults', N'LabResults.Approve', N'اعتماد نتيجة معملية', N'Approve Lab Result', 50);

UPDATE T
SET T.ModuleName = S.ModuleName,
    T.PermissionNameAr = S.PermissionNameAr,
    T.PermissionNameEn = S.PermissionNameEn,
    T.SortOrder = S.SortOrder,
    T.IsActive = 1,
    T.IsDeleted = 0
FROM dbo.Permissions T
INNER JOIN @Permissions S ON S.PermissionCode = T.PermissionCode;

INSERT INTO dbo.Permissions(ModuleName, PermissionCode, PermissionNameAr, PermissionNameEn, SortOrder, IsActive, IsDeleted)
SELECT S.ModuleName, S.PermissionCode, S.PermissionNameAr, S.PermissionNameEn, S.SortOrder, 1, 0
FROM @Permissions S
WHERE NOT EXISTS(SELECT 1 FROM dbo.Permissions T WHERE T.PermissionCode = S.PermissionCode);
GO

DECLARE @AdminRoleId BIGINT = (SELECT TOP 1 RoleId FROM dbo.Roles WHERE RoleName IN (N'System Admin', N'Administrators', N'Admin') AND IsDeleted = 0 ORDER BY CASE WHEN RoleName=N'System Admin' THEN 1 WHEN RoleName=N'Administrators' THEN 2 ELSE 3 END, RoleId);
DECLARE @AdminUserId BIGINT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Username = N'admin' AND IsDeleted = 0 ORDER BY UserId);

IF @AdminRoleId IS NOT NULL
BEGIN
    INSERT INTO dbo.RolePermissions(RoleId, PermissionId, GrantedBy)
    SELECT @AdminRoleId, P.PermissionId, @AdminUserId
    FROM dbo.Permissions P
    WHERE P.IsDeleted = 0 AND P.IsActive = 1
      AND NOT EXISTS(SELECT 1 FROM dbo.RolePermissions RP WHERE RP.RoleId = @AdminRoleId AND RP.PermissionId = P.PermissionId);
END
GO

PRINT N'Sprint 3 lookups and permissions created successfully.';
GO
