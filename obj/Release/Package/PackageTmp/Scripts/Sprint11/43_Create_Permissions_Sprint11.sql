USE GeoSitePro;
GO

/* Sprint 11 permissions for print outputs. */

DECLARE @Permissions TABLE(ModuleName NVARCHAR(100), PermissionCode NVARCHAR(150), PermissionNameAr NVARCHAR(200), PermissionNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Permissions(ModuleName, PermissionCode, PermissionNameAr, PermissionNameEn, SortOrder)
VALUES
(N'Print Outputs', N'PrintOutputs.View', N'عرض مخرجات الطباعة', N'View print outputs', 1100),
(N'Print Outputs', N'PrintOutputs.Print', N'طباعة وحفظ مخرجات المشروع', N'Print/save project outputs', 1110),
(N'Print Outputs', N'PrintOutputs.History', N'عرض سجل الطباعة', N'View print history', 1120);

MERGE dbo.Permissions AS T
USING @Permissions AS S
ON T.PermissionCode=S.PermissionCode
WHEN MATCHED THEN UPDATE SET ModuleName=S.ModuleName, PermissionNameAr=S.PermissionNameAr, PermissionNameEn=S.PermissionNameEn, SortOrder=S.SortOrder, IsActive=1, IsDeleted=0
WHEN NOT MATCHED THEN INSERT(ModuleName, PermissionCode, PermissionNameAr, PermissionNameEn, SortOrder, IsActive, IsDeleted)
VALUES(S.ModuleName, S.PermissionCode, S.PermissionNameAr, S.PermissionNameEn, S.SortOrder, 1, 0);

DECLARE @AdminRoleId BIGINT = (SELECT TOP 1 RoleId FROM dbo.Roles WHERE RoleName=N'System Admin' AND ISNULL(IsDeleted,0)=0 ORDER BY RoleId);
DECLARE @AdminUserId BIGINT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Username=N'admin' AND ISNULL(IsDeleted,0)=0 ORDER BY UserId);

IF @AdminRoleId IS NOT NULL
BEGIN
    INSERT INTO dbo.RolePermissions(RoleId, PermissionId, GrantedBy)
    SELECT @AdminRoleId, P.PermissionId, @AdminUserId
    FROM dbo.Permissions P
    WHERE P.PermissionCode IN (SELECT PermissionCode FROM @Permissions)
      AND NOT EXISTS(SELECT 1 FROM dbo.RolePermissions RP WHERE RP.RoleId=@AdminRoleId AND RP.PermissionId=P.PermissionId);
END
GO

PRINT N'Sprint 11 print permissions created successfully.';
GO
