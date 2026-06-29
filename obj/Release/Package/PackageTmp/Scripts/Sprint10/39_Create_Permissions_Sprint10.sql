USE GeoSitePro;
GO

/* Sprint 10 permissions */

DECLARE @Permissions TABLE(ModuleName NVARCHAR(100), PermissionCode NVARCHAR(150), PermissionNameAr NVARCHAR(200), PermissionNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Permissions VALUES
(N'DataExchange', N'DataExchange.View', N'عرض مركز تبادل البيانات', N'View Data Exchange', 10),
(N'DataExchange', N'DataExchange.Export', N'تصدير بيانات المشروع CSV', N'Export Project Data CSV', 20),
(N'GisCadExport', N'GisCadExport.View', N'عرض تصدير GIS/CAD', N'View GIS/CAD Export', 10),
(N'GisCadExport', N'GisCadExport.Export', N'تصدير ملفات GIS/CAD الأولية', N'Export GIS/CAD CSV Files', 20);

UPDATE T
SET T.ModuleName=S.ModuleName, T.PermissionNameAr=S.PermissionNameAr, T.PermissionNameEn=S.PermissionNameEn, T.SortOrder=S.SortOrder, T.IsActive=1, T.IsDeleted=0
FROM dbo.Permissions T INNER JOIN @Permissions S ON S.PermissionCode=T.PermissionCode;

INSERT INTO dbo.Permissions(ModuleName, PermissionCode, PermissionNameAr, PermissionNameEn, SortOrder, IsActive, IsDeleted)
SELECT S.ModuleName, S.PermissionCode, S.PermissionNameAr, S.PermissionNameEn, S.SortOrder, 1, 0
FROM @Permissions S WHERE NOT EXISTS(SELECT 1 FROM dbo.Permissions P WHERE P.PermissionCode=S.PermissionCode);
GO

DECLARE @AdminUserId BIGINT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Username=N'admin' AND ISNULL(IsDeleted,0)=0 ORDER BY UserId);
DECLARE @AdminRoleId BIGINT = (SELECT TOP 1 RoleId FROM dbo.Roles WHERE RoleName IN (N'System Admin', N'Admin', N'Administrator') AND ISNULL(IsDeleted,0)=0 ORDER BY RoleId);
IF @AdminRoleId IS NULL
BEGIN
    INSERT INTO dbo.Roles(RoleName, Description, IsActive, CreatedBy) VALUES(N'System Admin', N'Full system administrator role.', 1, @AdminUserId);
    SET @AdminRoleId = SCOPE_IDENTITY();
END

INSERT INTO dbo.RolePermissions(RoleId, PermissionId, GrantedBy)
SELECT @AdminRoleId, P.PermissionId, @AdminUserId
FROM dbo.Permissions P
WHERE P.IsActive=1 AND P.IsDeleted=0
  AND P.PermissionCode IN (N'DataExchange.View',N'DataExchange.Export',N'GisCadExport.View',N'GisCadExport.Export')
  AND NOT EXISTS(SELECT 1 FROM dbo.RolePermissions RP WHERE RP.RoleId=@AdminRoleId AND RP.PermissionId=P.PermissionId);
GO

PRINT N'Sprint 10 permissions created successfully.';
GO
