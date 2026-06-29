USE GeoSitePro;
GO

DECLARE @Categories TABLE(CategoryCode NVARCHAR(100), CategoryNameAr NVARCHAR(200), CategoryNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Categories VALUES
(N'DocumentType', N'أنواع مرفقات المشروع', N'Document Types', 700),
(N'ExportPackageType', N'أنواع حزم التصدير', N'Export Package Types', 710),
(N'ExportPackageStatus', N'حالات حزم التصدير', N'Export Package Status', 720),
(N'ReadinessArea', N'محاور جاهزية الإنتاج', N'Production Readiness Areas', 730),
(N'ReadinessStatus', N'حالة جاهزية الإنتاج', N'Readiness Status', 740);

UPDATE LC SET LC.CategoryNameAr=C.CategoryNameAr, LC.CategoryNameEn=C.CategoryNameEn, LC.SortOrder=C.SortOrder, LC.IsActive=1, LC.IsDeleted=0
FROM dbo.LookupCategories LC INNER JOIN @Categories C ON C.CategoryCode=LC.CategoryCode;
INSERT INTO dbo.LookupCategories(CategoryCode, CategoryNameAr, CategoryNameEn, SortOrder, IsActive, IsDeleted)
SELECT CategoryCode, CategoryNameAr, CategoryNameEn, SortOrder, 1, 0 FROM @Categories C
WHERE NOT EXISTS(SELECT 1 FROM dbo.LookupCategories LC WHERE LC.CategoryCode=C.CategoryCode);

DECLARE @Items TABLE(CategoryCode NVARCHAR(100), ItemCode NVARCHAR(100), NameAr NVARCHAR(200), NameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Items VALUES
(N'DocumentType', N'SITE_PHOTO', N'صور الموقع', N'Site Photos', 10),
(N'DocumentType', N'BOREHOLE_LOG', N'سجل جسة', N'Borehole Log', 20),
(N'DocumentType', N'SAMPLE_PHOTO', N'صور عينات', N'Sample Photos', 30),
(N'DocumentType', N'CORE_BOX', N'صور Core Box', N'Core Box Photos', 40),
(N'DocumentType', N'LAB_SHEET', N'نموذج مختبر', N'Lab Sheet', 50),
(N'DocumentType', N'MAP', N'خريطة / مخطط', N'Map / Plan', 60),
(N'DocumentType', N'REPORT', N'تقرير', N'Report', 70),
(N'DocumentType', N'OTHER', N'أخرى', N'Other', 99),
(N'ExportPackageType', N'GIR_FULL', N'تقرير تحريات جيوتقنية كامل', N'Full Geotechnical Investigation Report', 10),
(N'ExportPackageType', N'BOREHOLE_PACKAGE', N'حزمة سجلات الجسات', N'Borehole Log Package', 20),
(N'ExportPackageType', N'LAB_PACKAGE', N'حزمة نتائج المختبر', N'Laboratory Package', 30),
(N'ExportPackageType', N'CLIENT_PACKAGE', N'حزمة تسليم للعميل', N'Client Submission Package', 40),
(N'ExportPackageStatus', N'DRAFT', N'مسودة', N'Draft', 10),
(N'ExportPackageStatus', N'GENERATED', N'جاهزة', N'Generated', 20),
(N'ExportPackageStatus', N'ISSUED', N'صادرة', N'Issued', 30),
(N'ReadinessArea', N'SECURITY', N'الأمن والصلاحيات', N'Security', 10),
(N'ReadinessArea', N'DATABASE', N'قاعدة البيانات والنسخ الاحتياطي', N'Database and Backup', 20),
(N'ReadinessArea', N'QUALITY', N'الجودة والاعتماد', N'Quality and Approval', 30),
(N'ReadinessArea', N'PERFORMANCE', N'الأداء والاستضافة', N'Performance and Hosting', 40),
(N'ReadinessArea', N'EXPORT', N'التصدير والتقارير', N'Export and Reporting', 50),
(N'ReadinessArea', N'TESTING', N'اختبار النظام', N'Testing', 60),
(N'ReadinessStatus', N'NOT_STARTED', N'لم يبدأ', N'Not Started', 10),
(N'ReadinessStatus', N'IN_PROGRESS', N'قيد التنفيذ', N'In Progress', 20),
(N'ReadinessStatus', N'DONE', N'منجز', N'Done', 30),
(N'ReadinessStatus', N'BLOCKED', N'متوقف', N'Blocked', 40);

UPDATE LI SET LI.NameAr=I.NameAr, LI.NameEn=I.NameEn, LI.SortOrder=I.SortOrder, LI.IsActive=1, LI.IsDeleted=0
FROM dbo.LookupItems LI INNER JOIN dbo.LookupCategories LC ON LC.LookupCategoryId=LI.LookupCategoryId INNER JOIN @Items I ON I.CategoryCode=LC.CategoryCode AND I.ItemCode=LI.ItemCode;
INSERT INTO dbo.LookupItems(LookupCategoryId, ItemCode, NameAr, NameEn, SortOrder, IsDefault, IsActive, IsDeleted)
SELECT LC.LookupCategoryId, I.ItemCode, I.NameAr, I.NameEn, I.SortOrder, CASE WHEN I.SortOrder=10 THEN 1 ELSE 0 END, 1, 0
FROM @Items I INNER JOIN dbo.LookupCategories LC ON LC.CategoryCode=I.CategoryCode
WHERE NOT EXISTS(SELECT 1 FROM dbo.LookupItems LI WHERE LI.LookupCategoryId=LC.LookupCategoryId AND LI.ItemCode=I.ItemCode);
GO

DECLARE @Permissions TABLE(ModuleName NVARCHAR(100), PermissionCode NVARCHAR(150), PermissionNameAr NVARCHAR(200), PermissionNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Permissions VALUES
(N'ProjectDocuments', N'ProjectDocuments.View', N'عرض مرفقات المشروع', N'View Project Documents', 10),
(N'ProjectDocuments', N'ProjectDocuments.Create', N'إضافة مرفق', N'Create Project Document', 20),
(N'ProjectDocuments', N'ProjectDocuments.Delete', N'حذف مرفق', N'Delete Project Document', 30),
(N'ProjectDocuments', N'ProjectDocuments.Approve', N'اعتماد مرفق', N'Approve Project Document', 40),
(N'ExportCenter', N'ExportCenter.View', N'عرض مركز التصدير', N'View Export Center', 10),
(N'ExportCenter', N'ExportCenter.Create', N'إنشاء حزمة تصدير', N'Create Export Package', 20),
(N'ExportCenter', N'ExportCenter.Generate', N'تجهيز حزمة تصدير', N'Generate Export Package', 30),
(N'ExportCenter', N'ExportCenter.Delete', N'حذف حزمة تصدير', N'Delete Export Package', 40),
(N'ProductionReadiness', N'ProductionReadiness.View', N'عرض جاهزية الإنتاج', N'View Production Readiness', 10),
(N'ProductionReadiness', N'ProductionReadiness.Edit', N'تعديل جاهزية الإنتاج', N'Edit Production Readiness', 20);

UPDATE P SET P.ModuleName=S.ModuleName, P.PermissionNameAr=S.PermissionNameAr, P.PermissionNameEn=S.PermissionNameEn, P.SortOrder=S.SortOrder, P.IsActive=1, P.IsDeleted=0
FROM dbo.Permissions P INNER JOIN @Permissions S ON S.PermissionCode=P.PermissionCode;
INSERT INTO dbo.Permissions(ModuleName, PermissionCode, PermissionNameAr, PermissionNameEn, SortOrder, IsActive, IsDeleted)
SELECT ModuleName, PermissionCode, PermissionNameAr, PermissionNameEn, SortOrder, 1, 0 FROM @Permissions S
WHERE NOT EXISTS(SELECT 1 FROM dbo.Permissions P WHERE P.PermissionCode=S.PermissionCode);

DECLARE @AdminUserId BIGINT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Username=N'admin' AND IsDeleted=0 ORDER BY UserId);
DECLARE @AdminRoleId BIGINT = (SELECT TOP 1 RoleId FROM dbo.Roles WHERE RoleName IN (N'System Admin', N'Admin', N'Administrator') AND IsDeleted=0 ORDER BY RoleId);
IF @AdminRoleId IS NOT NULL
BEGIN
    INSERT INTO dbo.RolePermissions(RoleId, PermissionId, GrantedBy)
    SELECT @AdminRoleId, P.PermissionId, @AdminUserId
    FROM dbo.Permissions P
    WHERE P.IsActive=1 AND P.IsDeleted=0
      AND NOT EXISTS(SELECT 1 FROM dbo.RolePermissions RP WHERE RP.RoleId=@AdminRoleId AND RP.PermissionId=P.PermissionId);
END
GO

PRINT N'Sprint 7 lookups and permissions created successfully.';
GO
