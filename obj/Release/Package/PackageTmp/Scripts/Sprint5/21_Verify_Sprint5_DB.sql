USE GeoSitePro;
GO

PRINT N'Verifying Sprint 5 database objects...';

SELECT MissingProcedure = V.ProcedureName
FROM (VALUES
(N'sp_Users_Get'), (N'sp_User_GetById'), (N'sp_User_Save'), (N'sp_UserRole_Save'),
(N'sp_User_Delete'), (N'sp_User_ResetPassword'), (N'sp_Roles_Get'), (N'sp_Roles_Dropdown_Get'),
(N'sp_Role_GetById'), (N'sp_Role_Save'), (N'sp_Role_Delete'),
(N'sp_RolePermissions_Get'), (N'sp_RolePermission_Save'), (N'sp_AuditLogs_Get')) V(ProcedureName)
WHERE OBJECT_ID(N'dbo.' + V.ProcedureName, N'P') IS NULL;

SELECT MissingPermission = V.PermissionCode
FROM (VALUES
(N'Users.View'), (N'Users.Create'), (N'Users.Edit'), (N'Users.Delete'), (N'Users.ResetPassword'),
(N'Roles.View'), (N'Roles.Create'), (N'Roles.Edit'), (N'Roles.Delete'), (N'Roles.Permissions'),
(N'AuditLog.View')) V(PermissionCode)
WHERE NOT EXISTS(SELECT 1 FROM dbo.Permissions P WHERE P.PermissionCode = V.PermissionCode AND P.IsDeleted = 0);

SELECT MissingColumn = V.TableName + N'.' + V.ColumnName
FROM (VALUES
(N'Users', N'Email'), (N'Users', N'Mobile'), (N'Users', N'IsDeleted'),
(N'Roles', N'Description'), (N'Roles', N'IsDeleted'),
(N'Permissions', N'ModuleName'), (N'Permissions', N'IsDeleted'),
(N'UserRoles', N'IsActive'), (N'RolePermissions', N'GrantedBy'),
(N'AuditLogs', N'NewValues'), (N'AuditLogs', N'ActionDate')) V(TableName, ColumnName)
WHERE COL_LENGTH(N'dbo.' + V.TableName, V.ColumnName) IS NULL;

SELECT AdminSprint5PermissionCount = COUNT(1)
FROM dbo.RolePermissions RP
INNER JOIN dbo.Roles R ON R.RoleId = RP.RoleId AND R.IsDeleted = 0
INNER JOIN dbo.Permissions P ON P.PermissionId = RP.PermissionId AND P.IsDeleted = 0
WHERE R.RoleName IN (N'System Admin', N'Admin', N'Administrator')
  AND P.PermissionCode IN (N'Users.View', N'Roles.View', N'Roles.Permissions', N'AuditLog.View');

PRINT N'If the missing result sets above are empty, Sprint 5 DB objects are ready.';
GO
