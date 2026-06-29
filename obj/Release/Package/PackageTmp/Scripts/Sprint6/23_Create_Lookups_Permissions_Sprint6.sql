USE GeoSitePro;
GO

/* Sprint 6 lookups and permissions. */
DECLARE @AdminUserId BIGINT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Username=N'admin' AND IsDeleted=0 ORDER BY UserId);
DECLARE @AdminRoleId BIGINT = (SELECT TOP 1 RoleId FROM dbo.Roles WHERE RoleName IN (N'System Admin', N'Admin', N'Administrator') AND IsDeleted=0 ORDER BY RoleId);

DECLARE @Categories TABLE(CategoryCode NVARCHAR(100), CategoryNameAr NVARCHAR(200), CategoryNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Categories VALUES
(N'StandardCategory', N'تصنيفات المعايير', N'Standard Categories', 600),
(N'QualityCheckArea', N'مناطق فحص الجودة', N'Quality Check Areas', 610),
(N'QualitySeverity', N'درجة خطورة الجودة', N'Quality Severity', 620),
(N'QualityStatus', N'حالة بند الجودة', N'Quality Status', 630),
(N'CalculationType', N'أنواع الحسابات الجيوتقنية', N'Engineering Calculation Types', 640);

UPDATE LC SET LC.CategoryNameAr=C.CategoryNameAr, LC.CategoryNameEn=C.CategoryNameEn, LC.SortOrder=C.SortOrder, LC.IsActive=1, LC.IsDeleted=0
FROM dbo.LookupCategories LC INNER JOIN @Categories C ON C.CategoryCode=LC.CategoryCode;
INSERT INTO dbo.LookupCategories(CategoryCode, CategoryNameAr, CategoryNameEn, SortOrder, IsActive, IsDeleted)
SELECT CategoryCode, CategoryNameAr, CategoryNameEn, SortOrder, 1, 0 FROM @Categories C
WHERE NOT EXISTS(SELECT 1 FROM dbo.LookupCategories LC WHERE LC.CategoryCode=C.CategoryCode);

DECLARE @Items TABLE(CategoryCode NVARCHAR(100), ItemCode NVARCHAR(100), NameAr NVARCHAR(200), NameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Items VALUES
(N'StandardCategory', N'FIELD_INVESTIGATION', N'تحريات حقلية', N'Field Investigation', 10),
(N'StandardCategory', N'SAMPLING', N'أخذ العينات', N'Sampling', 20),
(N'StandardCategory', N'FIELD_TESTING', N'اختبارات حقلية', N'Field Testing', 30),
(N'StandardCategory', N'LAB_TESTING', N'اختبارات معملية', N'Laboratory Testing', 40),
(N'StandardCategory', N'REPORTING', N'تقارير فنية', N'Technical Reporting', 50),
(N'StandardCategory', N'QA_QC', N'ضبط الجودة', N'Quality Control', 60),
(N'QualityCheckArea', N'DESK_STUDY', N'الدراسة المكتبية', N'Desk Study', 10),
(N'QualityCheckArea', N'BOREHOLES', N'الجسات', N'Boreholes', 20),
(N'QualityCheckArea', N'SAMPLES', N'العينات', N'Samples', 30),
(N'QualityCheckArea', N'SPT', N'اختبارات SPT', N'SPT Tests', 40),
(N'QualityCheckArea', N'GROUNDWATER', N'المياه الجوفية', N'Groundwater', 50),
(N'QualityCheckArea', N'LAB', N'المختبر', N'Laboratory', 60),
(N'QualityCheckArea', N'REPORTS', N'التقارير', N'Reports', 70),
(N'QualitySeverity', N'LOW', N'منخفضة', N'Low', 10),
(N'QualitySeverity', N'MEDIUM', N'متوسطة', N'Medium', 20),
(N'QualitySeverity', N'HIGH', N'عالية', N'High', 30),
(N'QualitySeverity', N'CRITICAL', N'حرجة', N'Critical', 40),
(N'QualityStatus', N'OPEN', N'مفتوح', N'Open', 10),
(N'QualityStatus', N'IN_PROGRESS', N'قيد المعالجة', N'In Progress', 20),
(N'QualityStatus', N'CLOSED', N'مغلق', N'Closed', 30),
(N'QualityStatus', N'WAIVED', N'مستثنى', N'Waived', 40),
(N'CalculationType', N'MOISTURE_CONTENT', N'Moisture Content - نسبة الرطوبة', N'Moisture Content', 10),
(N'CalculationType', N'ATTERBERG_PI', N'Atterberg PI - معامل اللدونة', N'Atterberg Plasticity Index', 20),
(N'CalculationType', N'SPT_N60', N'SPT N60 Correction', N'SPT N60 Correction', 30),
(N'CalculationType', N'SIEVE_COEFFICIENTS', N'Sieve Cu/Cc - معاملات التدرج', N'Sieve Cu and Cc', 40),
(N'CalculationType', N'DRY_DENSITY', N'Dry Density - الكثافة الجافة', N'Dry Density', 50);

UPDATE LI SET LI.NameAr=I.NameAr, LI.NameEn=I.NameEn, LI.SortOrder=I.SortOrder, LI.IsActive=1, LI.IsDeleted=0
FROM dbo.LookupItems LI
INNER JOIN dbo.LookupCategories LC ON LC.LookupCategoryId=LI.LookupCategoryId
INNER JOIN @Items I ON I.CategoryCode=LC.CategoryCode AND I.ItemCode=LI.ItemCode;
INSERT INTO dbo.LookupItems(LookupCategoryId, ItemCode, NameAr, NameEn, SortOrder, IsDefault, IsActive, IsDeleted)
SELECT LC.LookupCategoryId, I.ItemCode, I.NameAr, I.NameEn, I.SortOrder, CASE WHEN I.SortOrder=10 THEN 1 ELSE 0 END, 1, 0
FROM @Items I INNER JOIN dbo.LookupCategories LC ON LC.CategoryCode=I.CategoryCode
WHERE NOT EXISTS(SELECT 1 FROM dbo.LookupItems LI WHERE LI.LookupCategoryId=LC.LookupCategoryId AND LI.ItemCode=I.ItemCode);
GO

/* Seed useful standards library records. */
DECLARE @LabCat BIGINT=(SELECT TOP 1 LI.LookupItemId FROM dbo.LookupItems LI INNER JOIN dbo.LookupCategories LC ON LC.LookupCategoryId=LI.LookupCategoryId WHERE LC.CategoryCode=N'StandardCategory' AND LI.ItemCode=N'LAB_TESTING');
DECLARE @FieldCat BIGINT=(SELECT TOP 1 LI.LookupItemId FROM dbo.LookupItems LI INNER JOIN dbo.LookupCategories LC ON LC.LookupCategoryId=LI.LookupCategoryId WHERE LC.CategoryCode=N'StandardCategory' AND LI.ItemCode=N'FIELD_TESTING');
DECLARE @SamplingCat BIGINT=(SELECT TOP 1 LI.LookupItemId FROM dbo.LookupItems LI INNER JOIN dbo.LookupCategories LC ON LC.LookupCategoryId=LI.LookupCategoryId WHERE LC.CategoryCode=N'StandardCategory' AND LI.ItemCode=N'SAMPLING');
DECLARE @ReportingCat BIGINT=(SELECT TOP 1 LI.LookupItemId FROM dbo.LookupItems LI INNER JOIN dbo.LookupCategories LC ON LC.LookupCategoryId=LI.LookupCategoryId WHERE LC.CategoryCode=N'StandardCategory' AND LI.ItemCode=N'REPORTING');
DECLARE @Std TABLE(StandardCode NVARCHAR(100), StandardTitle NVARCHAR(500), Organization NVARCHAR(100), CategoryId BIGINT, VersionYear INT, StandardType NVARCHAR(100), ScopeSummary NVARCHAR(MAX));
INSERT INTO @Std VALUES
(N'ASTM D1586', N'Standard Penetration Test and Split-Barrel Sampling of Soils', N'ASTM', @FieldCat, NULL, N'Field Testing', N'SPT recording and split-barrel sampling reference.'),
(N'ASTM D1587', N'Thin-Walled Tube Sampling of Fine-Grained Soils', N'ASTM', @SamplingCat, NULL, N'Sampling', N'Undisturbed sampling reference for fine-grained soils.'),
(N'ISO 22475-1', N'Geotechnical investigation and testing - Sampling methods and groundwater measurements', N'ISO', @SamplingCat, NULL, N'Sampling', N'Technical principles for sampling and groundwater measurements.'),
(N'ASTM D2216', N'Laboratory Determination of Water Content of Soil and Rock', N'ASTM', @LabCat, NULL, N'Laboratory Testing', N'Moisture content calculation reference.'),
(N'ASTM D4318', N'Liquid Limit, Plastic Limit, and Plasticity Index of Soils', N'ASTM', @LabCat, NULL, N'Laboratory Testing', N'Atterberg limits and PI reference.'),
(N'ASTM D6913', N'Particle-Size Distribution by Sieve Analysis', N'ASTM', @LabCat, NULL, N'Laboratory Testing', N'Grain size distribution by sieve analysis.'),
(N'BS 5930', N'Code of practice for ground investigations', N'BSI', @ReportingCat, NULL, N'Ground Investigation', N'Ground investigation planning, logging, and reporting reference.');

UPDATE S SET S.StandardTitle=T.StandardTitle, S.Organization=T.Organization, S.CategoryId=T.CategoryId, S.VersionYear=T.VersionYear, S.StandardType=T.StandardType, S.ScopeSummary=T.ScopeSummary, S.IsActive=1, S.IsDeleted=0
FROM dbo.Standards S INNER JOIN @Std T ON T.StandardCode=S.StandardCode;
INSERT INTO dbo.Standards(StandardCode, StandardTitle, Organization, CategoryId, VersionYear, StandardType, ScopeSummary, IsActive, CreatedBy)
SELECT T.StandardCode, T.StandardTitle, T.Organization, T.CategoryId, T.VersionYear, T.StandardType, T.ScopeSummary, 1, @AdminUserId
FROM @Std T WHERE NOT EXISTS(SELECT 1 FROM dbo.Standards S WHERE S.StandardCode=T.StandardCode AND S.IsDeleted=0);
GO

DECLARE @Permissions TABLE(ModuleName NVARCHAR(100), PermissionCode NVARCHAR(150), PermissionNameAr NVARCHAR(200), PermissionNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Permissions VALUES
(N'Standards', N'Standards.View', N'عرض المعايير', N'View Standards', 10),
(N'Standards', N'Standards.Create', N'إضافة معيار', N'Create Standard', 20),
(N'Standards', N'Standards.Edit', N'تعديل معيار', N'Edit Standard', 30),
(N'Standards', N'Standards.Delete', N'حذف معيار', N'Delete Standard', 40),
(N'QualityChecks', N'QualityChecks.View', N'عرض فحص الجودة', N'View Quality Checks', 10),
(N'QualityChecks', N'QualityChecks.Create', N'إضافة بند جودة', N'Create Quality Check', 20),
(N'QualityChecks', N'QualityChecks.Edit', N'تعديل بند جودة', N'Edit Quality Check', 30),
(N'QualityChecks', N'QualityChecks.Delete', N'حذف بند جودة', N'Delete Quality Check', 40),
(N'QualityChecks', N'QualityChecks.Approve', N'اعتماد بند جودة', N'Approve Quality Check', 50),
(N'Calculations', N'Calculations.View', N'عرض الحسابات', N'View Calculations', 10),
(N'Calculations', N'Calculations.Create', N'إضافة حساب', N'Create Calculation', 20),
(N'Calculations', N'Calculations.Edit', N'تعديل حساب', N'Edit Calculation', 30),
(N'Calculations', N'Calculations.Delete', N'حذف حساب', N'Delete Calculation', 40),
(N'Calculations', N'Calculations.Approve', N'اعتماد حساب', N'Approve Calculation', 50);

UPDATE P SET P.ModuleName=S.ModuleName, P.PermissionNameAr=S.PermissionNameAr, P.PermissionNameEn=S.PermissionNameEn, P.SortOrder=S.SortOrder, P.IsActive=1, P.IsDeleted=0
FROM dbo.Permissions P INNER JOIN @Permissions S ON S.PermissionCode=P.PermissionCode;
INSERT INTO dbo.Permissions(ModuleName, PermissionCode, PermissionNameAr, PermissionNameEn, SortOrder, IsActive, IsDeleted)
SELECT ModuleName, PermissionCode, PermissionNameAr, PermissionNameEn, SortOrder, 1, 0 FROM @Permissions S
WHERE NOT EXISTS(SELECT 1 FROM dbo.Permissions P WHERE P.PermissionCode=S.PermissionCode);

DECLARE @AdminUserId2 BIGINT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Username=N'admin' AND IsDeleted=0 ORDER BY UserId);
DECLARE @AdminRoleId2 BIGINT = (SELECT TOP 1 RoleId FROM dbo.Roles WHERE RoleName IN (N'System Admin', N'Admin', N'Administrator') AND IsDeleted=0 ORDER BY RoleId);
IF @AdminRoleId2 IS NOT NULL
BEGIN
    INSERT INTO dbo.RolePermissions(RoleId, PermissionId, GrantedBy)
    SELECT @AdminRoleId2, P.PermissionId, @AdminUserId2
    FROM dbo.Permissions P
    WHERE P.IsActive=1 AND P.IsDeleted=0
      AND NOT EXISTS(SELECT 1 FROM dbo.RolePermissions RP WHERE RP.RoleId=@AdminRoleId2 AND RP.PermissionId=P.PermissionId);
END
GO

PRINT N'Sprint 6 lookups and permissions created successfully.';
GO
