USE GeoSitePro;
GO

DECLARE @Categories TABLE(CategoryCode NVARCHAR(100), CategoryNameAr NVARCHAR(200), CategoryNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Categories VALUES
(N'DrillingMethod', N'طريقة الحفر', N'Drilling Method', 100),
(N'BoreholeStatus', N'حالة الجسة', N'Borehole Status', 110),
(N'SoilRockType', N'نوع التربة أو الصخر', N'Soil or Rock Type', 120),
(N'SampleType', N'نوع العينة', N'Sample Type', 130),
(N'SampleQuality', N'جودة العينة', N'Sample Quality', 140),
(N'GroundwaterObservationType', N'نوع قراءة المياه الجوفية', N'Groundwater Observation Type', 150);

MERGE dbo.LookupCategories AS T
USING @Categories AS S ON T.CategoryCode = S.CategoryCode AND T.IsDeleted = 0
WHEN MATCHED THEN UPDATE SET T.CategoryNameAr=S.CategoryNameAr, T.CategoryNameEn=S.CategoryNameEn, T.SortOrder=S.SortOrder, T.IsActive=1
WHEN NOT MATCHED THEN INSERT(CategoryCode, CategoryNameAr, CategoryNameEn, SortOrder, IsActive) VALUES(S.CategoryCode, S.CategoryNameAr, S.CategoryNameEn, S.SortOrder, 1);
GO

DECLARE @Items TABLE(CategoryCode NVARCHAR(100), ItemCode NVARCHAR(100), NameAr NVARCHAR(200), NameEn NVARCHAR(200), SortOrder INT, IsDefault BIT);
INSERT INTO @Items VALUES
(N'DrillingMethod', N'ROTARY_WASH', N'حفر دوراني بالغسيل', N'Rotary Wash', 10, 1),
(N'DrillingMethod', N'ROTARY_CORE', N'حفر لبي صخري', N'Rotary Core', 20, 0),
(N'DrillingMethod', N'AUGER', N'أوجر', N'Auger', 30, 0),
(N'DrillingMethod', N'MANUAL', N'يدوي/اختبار حفرة', N'Manual/Test Pit', 40, 0),
(N'BoreholeStatus', N'PLANNED', N'مخططة', N'Planned', 10, 0),
(N'BoreholeStatus', N'IN_PROGRESS', N'قيد الحفر', N'In Progress', 20, 0),
(N'BoreholeStatus', N'COMPLETED', N'مكتملة', N'Completed', 30, 1),
(N'BoreholeStatus', N'TERMINATED', N'متوقفة', N'Terminated', 40, 0),
(N'SoilRockType', N'FILL', N'ردميات', N'Fill', 10, 0),
(N'SoilRockType', N'SAND', N'رمل', N'Sand', 20, 0),
(N'SoilRockType', N'SILT', N'سلت', N'Silt', 30, 0),
(N'SoilRockType', N'CLAY', N'طين', N'Clay', 40, 0),
(N'SoilRockType', N'GRAVEL', N'حصى', N'Gravel', 50, 0),
(N'SoilRockType', N'WEATHERED_ROCK', N'صخر متجوى', N'Weathered Rock', 60, 0),
(N'SoilRockType', N'ROCK', N'صخر', N'Rock', 70, 0),
(N'SampleType', N'DISTURBED', N'مضطربة', N'Disturbed', 10, 1),
(N'SampleType', N'UNDISTURBED', N'غير مضطربة', N'Undisturbed', 20, 0),
(N'SampleType', N'SPT', N'عينة SPT', N'SPT Sample', 30, 0),
(N'SampleType', N'CORE', N'عينة لبية صخرية', N'Core Sample', 40, 0),
(N'SampleQuality', N'GOOD', N'جيدة', N'Good', 10, 1),
(N'SampleQuality', N'FAIR', N'متوسطة', N'Fair', 20, 0),
(N'SampleQuality', N'POOR', N'ضعيفة', N'Poor', 30, 0),
(N'GroundwaterObservationType', N'WHILE_DRILLING', N'أثناء الحفر', N'While Drilling', 10, 0),
(N'GroundwaterObservationType', N'AFTER_24H', N'بعد 24 ساعة', N'After 24 Hours', 20, 1),
(N'GroundwaterObservationType', N'STABILIZED', N'منسوب مستقر', N'Stabilized Level', 30, 0),
(N'GroundwaterObservationType', N'NOT_ENCOUNTERED', N'لم تظهر مياه', N'Not Encountered', 40, 0);

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
(N'Boreholes', N'Boreholes.View', N'عرض الجسات', N'View Boreholes', 10),
(N'Boreholes', N'Boreholes.Create', N'إضافة جسة', N'Create Borehole', 20),
(N'Boreholes', N'Boreholes.Edit', N'تعديل جسة وسجلها', N'Edit Borehole and Log', 30),
(N'Boreholes', N'Boreholes.Delete', N'حذف جسة', N'Delete Borehole', 40),
(N'BoreholeLog', N'BoreholeLog.View', N'عرض سجل الجسة', N'View Borehole Log', 10),
(N'Samples', N'Samples.View', N'عرض العينات', N'View Samples', 10),
(N'Samples', N'Samples.Create', N'إضافة عينة', N'Create Sample', 20),
(N'Samples', N'Samples.Edit', N'تعديل عينة', N'Edit Sample', 30),
(N'Samples', N'Samples.Delete', N'حذف عينة', N'Delete Sample', 40),
(N'SPT', N'SPT.View', N'عرض اختبارات SPT', N'View SPT Tests', 10),
(N'SPT', N'SPT.Create', N'إضافة اختبار SPT', N'Create SPT Test', 20),
(N'SPT', N'SPT.Edit', N'تعديل اختبار SPT', N'Edit SPT Test', 30),
(N'SPT', N'SPT.Delete', N'حذف اختبار SPT', N'Delete SPT Test', 40),
(N'Groundwater', N'Groundwater.View', N'عرض قراءات المياه الجوفية', N'View Groundwater Observations', 10),
(N'Groundwater', N'Groundwater.Create', N'إضافة قراءة مياه جوفية', N'Create Groundwater Observation', 20),
(N'Groundwater', N'Groundwater.Edit', N'تعديل قراءة مياه جوفية', N'Edit Groundwater Observation', 30),
(N'Groundwater', N'Groundwater.Delete', N'حذف قراءة مياه جوفية', N'Delete Groundwater Observation', 40);

MERGE dbo.Permissions AS T
USING @Permissions AS S ON T.PermissionCode = S.PermissionCode AND T.IsDeleted = 0
WHEN MATCHED THEN UPDATE SET T.ModuleName=S.ModuleName, T.PermissionNameAr=S.PermissionNameAr, T.PermissionNameEn=S.PermissionNameEn, T.SortOrder=S.SortOrder, T.IsActive=1
WHEN NOT MATCHED THEN INSERT(ModuleName, PermissionCode, PermissionNameAr, PermissionNameEn, SortOrder, IsActive) VALUES(S.ModuleName, S.PermissionCode, S.PermissionNameAr, S.PermissionNameEn, S.SortOrder, 1);
GO

DECLARE @AdminRoleId BIGINT = (SELECT TOP 1 RoleId FROM dbo.Roles WHERE RoleName IN (N'System Admin', N'Administrators') AND IsDeleted = 0 ORDER BY RoleId);
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

PRINT N'Sprint 2 lookups and permissions created successfully.';
GO
