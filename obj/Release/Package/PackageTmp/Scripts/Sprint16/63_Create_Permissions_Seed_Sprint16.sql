USE GeoSitePro;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Permissions WHERE PermissionCode = 'Security.View')
    INSERT INTO dbo.Permissions (PermissionCode, PermissionNameAr, PermissionNameEn, ModuleName, IsActive) VALUES ('Security.View', N'عرض مركز الأمان', 'View Security Center', 'Security', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.Permissions WHERE PermissionCode = 'Security.Manage')
    INSERT INTO dbo.Permissions (PermissionCode, PermissionNameAr, PermissionNameEn, ModuleName, IsActive) VALUES ('Security.Manage', N'إدارة أحداث الأمان', 'Manage Security Events', 'Security', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.Permissions WHERE PermissionCode = 'Security.Policy')
    INSERT INTO dbo.Permissions (PermissionCode, PermissionNameAr, PermissionNameEn, ModuleName, IsActive) VALUES ('Security.Policy', N'إدارة سياسة الأمان', 'Manage Security Policy', 'Security', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.Permissions WHERE PermissionCode = 'DeploymentChecklist.View')
    INSERT INTO dbo.Permissions (PermissionCode, PermissionNameAr, PermissionNameEn, ModuleName, IsActive) VALUES ('DeploymentChecklist.View', N'عرض قائمة جاهزية النشر', 'View Deployment Checklist', 'Deployment', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.Permissions WHERE PermissionCode = 'DeploymentChecklist.Manage')
    INSERT INTO dbo.Permissions (PermissionCode, PermissionNameAr, PermissionNameEn, ModuleName, IsActive) VALUES ('DeploymentChecklist.Manage', N'إدارة قائمة جاهزية النشر', 'Manage Deployment Checklist', 'Deployment', 1);
GO

DECLARE @AdminRoleId BIGINT;
SELECT TOP 1 @AdminRoleId = RoleId FROM dbo.Roles WHERE RoleNameEn = 'Administrator' OR RoleCode = 'ADMIN' ORDER BY RoleId;
IF @AdminRoleId IS NOT NULL
BEGIN
    INSERT INTO dbo.RolePermissions (RoleId, PermissionId, GrantedBy, GrantedAt)
    SELECT @AdminRoleId, p.PermissionId, 1, GETDATE()
    FROM dbo.Permissions p
    WHERE p.PermissionCode IN ('Security.View','Security.Manage','Security.Policy','DeploymentChecklist.View','DeploymentChecklist.Manage')
      AND NOT EXISTS (SELECT 1 FROM dbo.RolePermissions rp WHERE rp.RoleId = @AdminRoleId AND rp.PermissionId = p.PermissionId);
END
GO

PRINT 'Sprint 16 permissions created successfully.';
GO
