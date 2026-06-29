USE GeoSitePro;
GO

/* Sprint 9 lookups and permissions */

DECLARE @Categories TABLE(CategoryCode NVARCHAR(100), CategoryNameAr NVARCHAR(200), CategoryNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Categories VALUES
(N'MapPointSource', N'مصدر نقطة الجسة على الخريطة', N'Map Point Source', 900),
(N'CrossSectionStatus', N'حالة المقطع الجيوتقني', N'Cross Section Status', 910);

UPDATE T
SET T.CategoryNameAr=S.CategoryNameAr, T.CategoryNameEn=S.CategoryNameEn, T.SortOrder=S.SortOrder, T.IsActive=1, T.IsDeleted=0
FROM dbo.LookupCategories T INNER JOIN @Categories S ON S.CategoryCode=T.CategoryCode;
INSERT INTO dbo.LookupCategories(CategoryCode, CategoryNameAr, CategoryNameEn, SortOrder, IsActive, IsDeleted)
SELECT S.CategoryCode, S.CategoryNameAr, S.CategoryNameEn, S.SortOrder, 1, 0
FROM @Categories S WHERE NOT EXISTS(SELECT 1 FROM dbo.LookupCategories C WHERE C.CategoryCode=S.CategoryCode);
GO

DECLARE @Items TABLE(CategoryCode NVARCHAR(100), ItemCode NVARCHAR(100), NameAr NVARCHAR(200), NameEn NVARCHAR(200), Description NVARCHAR(500), SortOrder INT, IsDefault BIT);
INSERT INTO @Items VALUES
(N'MapPointSource', N'PLANNED', N'مخططة', N'Planned', N'Point generated from investigation plan or entered before drilling.', 10, 1),
(N'MapPointSource', N'ACTUAL', N'فعلية من جسة منفذة', N'Actual borehole', N'Point generated from an actual borehole record.', 20, 0),
(N'MapPointSource', N'MANUAL', N'مدخلة يدويًا', N'Manual', N'Manually added layout point.', 30, 0),
(N'CrossSectionStatus', N'DRAFT', N'مسودة', N'Draft', N'Initial schematic section.', 10, 1),
(N'CrossSectionStatus', N'REVIEWED', N'مراجع', N'Reviewed', N'Reviewed by technical team.', 20, 0),
(N'CrossSectionStatus', N'APPROVED', N'معتمد', N'Approved', N'Approved for reporting.', 30, 0),
(N'CrossSectionStatus', N'ARCHIVED', N'مؤرشف', N'Archived', N'Old or superseded section.', 40, 0);

UPDATE T
SET T.NameAr=S.NameAr, T.NameEn=S.NameEn, T.Description=S.Description, T.SortOrder=S.SortOrder, T.IsDefault=S.IsDefault, T.IsActive=1, T.IsDeleted=0
FROM dbo.LookupItems T
INNER JOIN dbo.LookupCategories C ON C.LookupCategoryId=T.LookupCategoryId
INNER JOIN @Items S ON S.CategoryCode=C.CategoryCode AND S.ItemCode=T.ItemCode;

INSERT INTO dbo.LookupItems(LookupCategoryId, ItemCode, NameAr, NameEn, Description, SortOrder, IsDefault, IsActive, IsDeleted)
SELECT C.LookupCategoryId, S.ItemCode, S.NameAr, S.NameEn, S.Description, S.SortOrder, S.IsDefault, 1, 0
FROM @Items S INNER JOIN dbo.LookupCategories C ON C.CategoryCode=S.CategoryCode AND C.IsDeleted=0
WHERE NOT EXISTS(SELECT 1 FROM dbo.LookupItems I WHERE I.LookupCategoryId=C.LookupCategoryId AND I.ItemCode=S.ItemCode);
GO

DECLARE @Permissions TABLE(ModuleName NVARCHAR(100), PermissionCode NVARCHAR(150), PermissionNameAr NVARCHAR(200), PermissionNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Permissions VALUES
(N'SiteMap', N'SiteMap.View', N'عرض خريطة الموقع والجسات', N'View Site Map', 10),
(N'SiteMap', N'SiteMap.Edit', N'تعديل إعدادات ونقاط خريطة الموقع', N'Edit Site Map', 20),
(N'SiteMap', N'SiteMap.Generate', N'توليد نقاط الجسات على الخريطة', N'Generate Borehole Layout Points', 30),
(N'SiteMap', N'SiteMap.Export', N'تصدير خريطة الموقع', N'Export Site Map', 40),
(N'CrossSections', N'CrossSections.View', N'عرض المقاطع الجيوتقنية', N'View Cross Sections', 10),
(N'CrossSections', N'CrossSections.Edit', N'تعديل المقاطع الجيوتقنية', N'Edit Cross Sections', 20),
(N'CrossSections', N'CrossSections.Generate', N'توليد ربط الجسات بالمقاطع', N'Generate Cross Section Boreholes', 30),
(N'CrossSections', N'CrossSections.Export', N'تصدير المقاطع الجيوتقنية', N'Export Cross Sections', 40);

UPDATE T
SET T.ModuleName=S.ModuleName, T.PermissionNameAr=S.PermissionNameAr, T.PermissionNameEn=S.PermissionNameEn, T.SortOrder=S.SortOrder, T.IsActive=1, T.IsDeleted=0
FROM dbo.Permissions T INNER JOIN @Permissions S ON S.PermissionCode=T.PermissionCode;
INSERT INTO dbo.Permissions(ModuleName, PermissionCode, PermissionNameAr, PermissionNameEn, SortOrder, IsActive, IsDeleted)
SELECT S.ModuleName, S.PermissionCode, S.PermissionNameAr, S.PermissionNameEn, S.SortOrder, 1, 0
FROM @Permissions S WHERE NOT EXISTS(SELECT 1 FROM dbo.Permissions P WHERE P.PermissionCode=S.PermissionCode);
GO

DECLARE @AdminUserId BIGINT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Username=N'admin' AND IsDeleted=0 ORDER BY UserId);
DECLARE @AdminRoleId BIGINT = (SELECT TOP 1 RoleId FROM dbo.Roles WHERE RoleName IN (N'System Admin', N'Admin', N'Administrator') AND IsDeleted=0 ORDER BY RoleId);
IF @AdminRoleId IS NULL
BEGIN
    INSERT INTO dbo.Roles(RoleName, Description, IsActive, CreatedBy) VALUES(N'System Admin', N'Full system administrator role.', 1, @AdminUserId);
    SET @AdminRoleId = SCOPE_IDENTITY();
END
INSERT INTO dbo.RolePermissions(RoleId, PermissionId, GrantedBy)
SELECT @AdminRoleId, P.PermissionId, @AdminUserId
FROM dbo.Permissions P
WHERE P.IsActive=1 AND P.IsDeleted=0
  AND P.PermissionCode IN (N'SiteMap.View',N'SiteMap.Edit',N'SiteMap.Generate',N'SiteMap.Export',N'CrossSections.View',N'CrossSections.Edit',N'CrossSections.Generate',N'CrossSections.Export')
  AND NOT EXISTS(SELECT 1 FROM dbo.RolePermissions RP WHERE RP.RoleId=@AdminRoleId AND RP.PermissionId=P.PermissionId);
GO

PRINT N'Sprint 9 lookups and permissions created successfully.';
GO
