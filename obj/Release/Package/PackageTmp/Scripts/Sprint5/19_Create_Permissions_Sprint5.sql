USE GeoSitePro;
GO

/* Sprint 5 security permissions: users, roles, role permissions, and audit log. */

DECLARE @Permissions TABLE(ModuleName NVARCHAR(100), PermissionCode NVARCHAR(150), PermissionNameAr NVARCHAR(200), PermissionNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Permissions VALUES
(N'Users', N'Users.View', N'عرض المستخدمين', N'View Users', 10),
(N'Users', N'Users.Create', N'إضافة مستخدم', N'Create User', 20),
(N'Users', N'Users.Edit', N'تعديل مستخدم', N'Edit User', 30),
(N'Users', N'Users.Delete', N'حذف مستخدم', N'Delete User', 40),
(N'Users', N'Users.ResetPassword', N'إعادة تعيين كلمة مرور مستخدم', N'Reset User Password', 50),
(N'Roles', N'Roles.View', N'عرض الأدوار', N'View Roles', 10),
(N'Roles', N'Roles.Create', N'إضافة دور', N'Create Role', 20),
(N'Roles', N'Roles.Edit', N'تعديل دور', N'Edit Role', 30),
(N'Roles', N'Roles.Delete', N'حذف دور', N'Delete Role', 40),
(N'Roles', N'Roles.Permissions', N'إدارة صلاحيات الأدوار', N'Manage Role Permissions', 50),
(N'AuditLog', N'AuditLog.View', N'عرض سجل التدقيق', N'View Audit Log', 10);

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
WHERE NOT EXISTS(SELECT 1 FROM dbo.Permissions P WHERE P.PermissionCode = S.PermissionCode);
GO

/* Grant all current permissions to the main admin role so the existing admin can open Sprint 5 pages. */
DECLARE @AdminUserId BIGINT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Username=N'admin' AND IsDeleted=0 ORDER BY UserId);
DECLARE @AdminRoleId BIGINT = (SELECT TOP 1 RoleId FROM dbo.Roles WHERE RoleName IN (N'System Admin', N'Admin', N'Administrator') AND IsDeleted=0 ORDER BY RoleId);

IF @AdminRoleId IS NULL
BEGIN
    INSERT INTO dbo.Roles(RoleName, Description, IsActive, CreatedBy)
    VALUES(N'System Admin', N'Full system administrator role.', 1, @AdminUserId);
    SET @AdminRoleId = SCOPE_IDENTITY();
END

IF @AdminUserId IS NOT NULL
BEGIN
    IF NOT EXISTS(SELECT 1 FROM dbo.UserRoles WHERE UserId=@AdminUserId AND RoleId=@AdminRoleId)
        INSERT INTO dbo.UserRoles(UserId, RoleId, AssignedBy, IsActive) VALUES(@AdminUserId, @AdminRoleId, @AdminUserId, 1);
    ELSE
        UPDATE dbo.UserRoles SET IsActive=1, AssignedAt=SYSDATETIME(), AssignedBy=@AdminUserId WHERE UserId=@AdminUserId AND RoleId=@AdminRoleId;
END

INSERT INTO dbo.RolePermissions(RoleId, PermissionId, GrantedBy)
SELECT @AdminRoleId, P.PermissionId, @AdminUserId
FROM dbo.Permissions P
WHERE P.IsActive=1 AND P.IsDeleted=0
  AND NOT EXISTS(SELECT 1 FROM dbo.RolePermissions RP WHERE RP.RoleId=@AdminRoleId AND RP.PermissionId=P.PermissionId);

PRINT N'Sprint 5 permissions created and granted to admin role.';
GO
