USE GeoSitePro;
GO

DECLARE @Categories TABLE(CategoryCode NVARCHAR(100), CategoryNameAr NVARCHAR(200), CategoryNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Categories VALUES
(N'ProjectType', N'نوع المشروع', N'Project Type', 10),
(N'ProjectStatus', N'حالة المشروع', N'Project Status', 20),
(N'StructureType', N'نوع المنشأ', N'Structure Type', 30),
(N'InvestigationStage', N'مرحلة التحري', N'Investigation Stage', 40);

MERGE dbo.LookupCategories AS T
USING @Categories AS S ON T.CategoryCode = S.CategoryCode AND T.IsDeleted = 0
WHEN MATCHED THEN UPDATE SET T.CategoryNameAr=S.CategoryNameAr, T.CategoryNameEn=S.CategoryNameEn, T.SortOrder=S.SortOrder, T.IsActive=1
WHEN NOT MATCHED THEN INSERT(CategoryCode, CategoryNameAr, CategoryNameEn, SortOrder, IsActive) VALUES(S.CategoryCode, S.CategoryNameAr, S.CategoryNameEn, S.SortOrder, 1);
GO

DECLARE @Items TABLE(CategoryCode NVARCHAR(100), ItemCode NVARCHAR(100), NameAr NVARCHAR(200), NameEn NVARCHAR(200), SortOrder INT, IsDefault BIT);
INSERT INTO @Items VALUES
(N'ProjectType', N'BUILDING', N'مبنى', N'Building', 10, 1),
(N'ProjectType', N'TOWER', N'برج', N'Tower', 20, 0),
(N'ProjectType', N'ROAD', N'طريق', N'Road', 30, 0),
(N'ProjectType', N'BRIDGE', N'جسر', N'Bridge', 40, 0),
(N'ProjectType', N'DAM', N'سد', N'Dam', 50, 0),
(N'ProjectStatus', N'NEW', N'جديد', N'New', 10, 1),
(N'ProjectStatus', N'IN_PROGRESS', N'قيد التنفيذ', N'In Progress', 20, 0),
(N'ProjectStatus', N'ON_HOLD', N'متوقف مؤقتًا', N'On Hold', 30, 0),
(N'ProjectStatus', N'COMPLETED', N'مكتمل', N'Completed', 40, 0),
(N'StructureType', N'RESIDENTIAL', N'مبنى سكني', N'Residential Building', 10, 1),
(N'StructureType', N'COMMERCIAL', N'مبنى تجاري', N'Commercial Building', 20, 0),
(N'StructureType', N'HIGH_RISE', N'مبنى عالٍ', N'High-Rise Building', 30, 0),
(N'StructureType', N'VILLA', N'فيلا', N'Villa', 40, 0),
(N'InvestigationStage', N'PRELIMINARY', N'أولية', N'Preliminary', 10, 1),
(N'InvestigationStage', N'DETAILED', N'تفصيلية', N'Detailed', 20, 0),
(N'InvestigationStage', N'ADDITIONAL', N'إضافية', N'Additional', 30, 0);

MERGE dbo.LookupItems AS T
USING (
    SELECT C.LookupCategoryId, I.ItemCode, I.NameAr, I.NameEn, I.SortOrder, I.IsDefault
    FROM @Items I INNER JOIN dbo.LookupCategories C ON C.CategoryCode = I.CategoryCode AND C.IsDeleted = 0
) AS S ON T.LookupCategoryId = S.LookupCategoryId AND T.ItemCode = S.ItemCode AND T.IsDeleted = 0
WHEN MATCHED THEN UPDATE SET T.NameAr=S.NameAr, T.NameEn=S.NameEn, T.SortOrder=S.SortOrder, T.IsDefault=S.IsDefault, T.IsActive=1
WHEN NOT MATCHED THEN INSERT(LookupCategoryId, ItemCode, NameAr, NameEn, SortOrder, IsDefault, IsActive) VALUES(S.LookupCategoryId, S.ItemCode, S.NameAr, S.NameEn, S.SortOrder, S.IsDefault, 1);
GO

DECLARE @Permissions TABLE(ModuleName NVARCHAR(100), PermissionCode NVARCHAR(150), PermissionNameAr NVARCHAR(200), PermissionNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Permissions VALUES
(N'Dashboard', N'Dashboard.View', N'عرض لوحة التحكم', N'View Dashboard', 10),
(N'Projects', N'Projects.View', N'عرض المشاريع', N'View Projects', 10),
(N'Projects', N'Projects.Create', N'إضافة مشروع', N'Create Project', 20),
(N'Projects', N'Projects.Edit', N'تعديل مشروع', N'Edit Project', 30),
(N'Projects', N'Projects.Delete', N'حذف مشروع', N'Delete Project', 40);

MERGE dbo.Permissions AS T
USING @Permissions AS S ON T.PermissionCode = S.PermissionCode AND T.IsDeleted = 0
WHEN MATCHED THEN UPDATE SET T.ModuleName=S.ModuleName, T.PermissionNameAr=S.PermissionNameAr, T.PermissionNameEn=S.PermissionNameEn, T.SortOrder=S.SortOrder, T.IsActive=1
WHEN NOT MATCHED THEN INSERT(ModuleName, PermissionCode, PermissionNameAr, PermissionNameEn, SortOrder, IsActive) VALUES(S.ModuleName, S.PermissionCode, S.PermissionNameAr, S.PermissionNameEn, S.SortOrder, 1);
GO

PRINT N'Sprint 1 lookups and permissions created successfully.';
GO
