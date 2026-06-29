USE GeoSitePro;
GO

/* Sprint 4 lookups and permissions. Run after Sprint 3 scripts. */

DECLARE @Categories TABLE(CategoryCode NVARCHAR(100), CategoryNameAr NVARCHAR(200), CategoryNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Categories VALUES
(N'ReportType', N'نوع التقرير الفني', N'Technical Report Type', 300),
(N'ReportStatus', N'حالة التقرير الفني', N'Technical Report Status', 310),
(N'ReportSectionType', N'نوع قسم التقرير', N'Report Section Type', 320);

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
(N'ReportType', N'GEOTECHNICAL_INVESTIGATION', N'تقرير تحريات جيوتقنية', N'Geotechnical Investigation Report', 10, 1),
(N'ReportType', N'BOREHOLE_LOG_PACKAGE', N'حزمة سجلات الجسات', N'Borehole Log Package', 20, 0),
(N'ReportType', N'LAB_SUMMARY', N'ملخص نتائج المختبر', N'Laboratory Results Summary', 30, 0),
(N'ReportType', N'GROUNDWATER_SUMMARY', N'ملخص المياه الجوفية', N'Groundwater Summary', 40, 0),
(N'ReportType', N'FINAL_REPORT', N'تقرير نهائي', N'Final Report', 50, 0),
(N'ReportStatus', N'DRAFT', N'مسودة', N'Draft', 10, 1),
(N'ReportStatus', N'IN_REVIEW', N'قيد المراجعة', N'In Review', 20, 0),
(N'ReportStatus', N'APPROVED', N'معتمد', N'Approved', 30, 0),
(N'ReportStatus', N'ISSUED', N'مصدر', N'Issued', 40, 0),
(N'ReportStatus', N'ARCHIVED', N'مؤرشف', N'Archived', 50, 0),
(N'ReportSectionType', N'EXECUTIVE_SUMMARY', N'الملخص التنفيذي', N'Executive Summary', 10, 1),
(N'ReportSectionType', N'PROJECT_INFO', N'بيانات المشروع', N'Project Information', 20, 0),
(N'ReportSectionType', N'FIELD_INVESTIGATION', N'التحريات الحقلية', N'Field Investigation', 30, 0),
(N'ReportSectionType', N'BOREHOLE_LOGS', N'سجلات الجسات', N'Borehole Logs', 40, 0),
(N'ReportSectionType', N'SPT_SUMMARY', N'ملخص SPT', N'SPT Summary', 50, 0),
(N'ReportSectionType', N'GROUNDWATER', N'المياه الجوفية', N'Groundwater', 60, 0),
(N'ReportSectionType', N'LAB_RESULTS', N'النتائج المعملية', N'Laboratory Results', 70, 0),
(N'ReportSectionType', N'RECOMMENDATIONS', N'التوصيات', N'Recommendations', 80, 0),
(N'ReportSectionType', N'APPENDICES', N'الملاحق', N'Appendices', 90, 0),
(N'ReportSectionType', N'CUSTOM', N'قسم مخصص', N'Custom Section', 100, 0);

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
    SELECT 1 FROM dbo.LookupItems T
    WHERE (T.LookupCategoryId = S.LookupCategoryId OR T.CategoryCode = S.CategoryCode)
      AND (T.ItemCode = S.ItemCode OR T.Code = S.ItemCode)
      AND T.IsDeleted = 0
);
GO

DECLARE @Permissions TABLE(ModuleName NVARCHAR(100), PermissionCode NVARCHAR(150), PermissionNameAr NVARCHAR(200), PermissionNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Permissions VALUES
(N'Reports', N'Reports.View', N'عرض التقارير الفنية', N'View Reports', 10),
(N'Reports', N'Reports.Create', N'إضافة تقرير فني', N'Create Report', 20),
(N'Reports', N'Reports.Edit', N'تعديل تقرير فني', N'Edit Report', 30),
(N'Reports', N'Reports.Delete', N'حذف تقرير فني', N'Delete Report', 40),
(N'Reports', N'Reports.Generate', N'توليد أقسام التقرير تلقائيًا', N'Generate Report Sections', 50),
(N'Reports', N'Reports.Approve', N'اعتماد تقرير فني', N'Approve Report', 60),
(N'Reports', N'Reports.Print', N'طباعة تقرير فني', N'Print Report', 70);

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
      AND P.PermissionCode LIKE N'Reports.%'
      AND NOT EXISTS(SELECT 1 FROM dbo.RolePermissions RP WHERE RP.RoleId = @AdminRoleId AND RP.PermissionId = P.PermissionId);
END
GO

PRINT N'Sprint 4 lookups and permissions created successfully.';
GO
