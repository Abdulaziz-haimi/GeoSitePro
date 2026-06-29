USE GeoSitePro;
GO

DECLARE @Permissions TABLE(ModuleName NVARCHAR(100), PermissionCode NVARCHAR(150), PermissionNameAr NVARCHAR(200), PermissionNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Permissions VALUES
(N'SystemSettings', N'SystemSettings.View', N'عرض إعدادات النظام', N'View system settings', 1501),
(N'SystemSettings', N'SystemSettings.Manage', N'إدارة إعدادات النظام', N'Manage system settings', 1502),
(N'Backup', N'Backup.View', N'عرض مركز النسخ الاحتياطي', N'View backup center', 1510),
(N'Backup', N'Backup.Create', N'إنشاء طلب نسخة احتياطية', N'Create backup request', 1511),
(N'SystemHealth', N'SystemHealth.View', N'عرض فحص صحة النظام', N'View system health', 1520),
(N'SystemHealth', N'SystemHealth.Run', N'تشغيل فحص صحة النظام', N'Run system health check', 1521),
(N'OperationLogs', N'OperationLogs.View', N'عرض سجل التشغيل', N'View operation logs', 1530);

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
        N'SystemSettings.View', N'SystemSettings.Manage', N'Backup.View', N'Backup.Create',
        N'SystemHealth.View', N'SystemHealth.Run', N'OperationLogs.View'
    )
    AND NOT EXISTS (SELECT 1 FROM dbo.RolePermissions RP WHERE RP.RoleId = @AdminRoleId AND RP.PermissionId = P.PermissionId);
END
GO

PRINT N'Sprint 15 permissions created successfully.';
GO
