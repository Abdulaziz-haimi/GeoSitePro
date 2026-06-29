USE GeoSitePro;
GO

DECLARE @Permissions TABLE(ModuleName NVARCHAR(100), PermissionCode NVARCHAR(150), PermissionNameAr NVARCHAR(200), PermissionNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Permissions VALUES
(N'ExecutiveDashboard', N'ExecutiveDashboard.View', N'عرض لوحة المؤشرات التنفيذية', N'View executive dashboard', 1401),
(N'Risks', N'Risks.View', N'عرض سجل المخاطر', N'View risk register', 1410),
(N'Risks', N'Risks.Create', N'إضافة مخاطر', N'Create risks', 1411),
(N'Risks', N'Risks.Edit', N'تعديل المخاطر', N'Edit risks', 1412),
(N'Risks', N'Risks.Close', N'إغلاق المخاطر', N'Close risks', 1413),
(N'Risks', N'Risks.Delete', N'حذف المخاطر', N'Delete risks', 1414),
(N'KpiDashboard', N'KpiDashboard.View', N'عرض مؤشرات الجودة', N'View quality KPIs', 1420),
(N'KpiDashboard', N'KpiDashboard.Generate', N'توليد مؤشرات الجودة', N'Generate quality KPI snapshots', 1421);

INSERT INTO dbo.Permissions(ModuleName, PermissionCode, PermissionNameAr, PermissionNameEn, SortOrder, IsActive, IsDeleted)
SELECT P.ModuleName, P.PermissionCode, P.PermissionNameAr, P.PermissionNameEn, P.SortOrder, 1, 0
FROM @Permissions P
WHERE NOT EXISTS (SELECT 1 FROM dbo.Permissions X WHERE X.PermissionCode = P.PermissionCode AND X.IsDeleted = 0);
GO

DECLARE @AdminRoleId BIGINT;
SELECT TOP 1 @AdminRoleId = RoleId
FROM dbo.Roles
WHERE IsDeleted = 0 AND (RoleName IN (N'Administrator', N'Admin', N'System Administrator', N'مدير النظام') OR RoleId = 1)
ORDER BY RoleId;

IF @AdminRoleId IS NOT NULL
BEGIN
    INSERT INTO dbo.RolePermissions(RoleId, PermissionId, GrantedBy)
    SELECT @AdminRoleId, P.PermissionId, 1
    FROM dbo.Permissions P
    WHERE P.PermissionCode IN (
        N'ExecutiveDashboard.View', N'Risks.View', N'Risks.Create', N'Risks.Edit', N'Risks.Close', N'Risks.Delete',
        N'KpiDashboard.View', N'KpiDashboard.Generate'
    )
    AND NOT EXISTS (SELECT 1 FROM dbo.RolePermissions RP WHERE RP.RoleId = @AdminRoleId AND RP.PermissionId = P.PermissionId);
END
GO

PRINT N'Sprint 14 permissions created successfully.';
GO
