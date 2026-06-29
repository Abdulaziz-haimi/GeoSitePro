USE GeoSitePro;
GO

/* Sprint 12 permissions. */

DECLARE @Permissions TABLE(ModuleName NVARCHAR(100), PermissionCode NVARCHAR(150), PermissionNameAr NVARCHAR(200), PermissionNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Permissions(ModuleName, PermissionCode, PermissionNameAr, PermissionNameEn, SortOrder)
VALUES
(N'Workflow', N'Workflow.View', N'عرض سير العمل', N'View workflow', 1200),
(N'Workflow', N'Workflow.Create', N'إنشاء طلب اعتماد', N'Create approval request', 1210),
(N'Workflow', N'Workflow.Approve', N'اعتماد الطلبات', N'Approve requests', 1220),
(N'Workflow', N'Workflow.Reject', N'رفض أو إرجاع الطلبات', N'Reject or return requests', 1230),
(N'Workflow', N'Workflow.Matrix', N'إدارة مصفوفة الاعتماد', N'Manage approval matrix', 1240);

MERGE dbo.Permissions AS T
USING @Permissions AS S
ON T.PermissionCode = S.PermissionCode AND ISNULL(T.IsDeleted,0)=0
WHEN MATCHED THEN UPDATE SET ModuleName=S.ModuleName, PermissionNameAr=S.PermissionNameAr, PermissionNameEn=S.PermissionNameEn, SortOrder=S.SortOrder, IsActive=1
WHEN NOT MATCHED THEN INSERT(ModuleName, PermissionCode, PermissionNameAr, PermissionNameEn, SortOrder, IsActive, IsDeleted)
VALUES(S.ModuleName, S.PermissionCode, S.PermissionNameAr, S.PermissionNameEn, S.SortOrder, 1, 0);

DECLARE @AdminRoleId BIGINT;
SELECT TOP(1) @AdminRoleId = RoleId FROM dbo.Roles WHERE RoleName IN (N'Admin', N'Administrator', N'مدير النظام') AND ISNULL(IsDeleted,0)=0 ORDER BY RoleId;
IF @AdminRoleId IS NULL SELECT TOP(1) @AdminRoleId = RoleId FROM dbo.Roles WHERE ISNULL(IsDeleted,0)=0 ORDER BY RoleId;

IF @AdminRoleId IS NOT NULL
BEGIN
    INSERT INTO dbo.RolePermissions(RoleId, PermissionId, GrantedBy)
    SELECT @AdminRoleId, P.PermissionId, NULL
    FROM dbo.Permissions P
    WHERE P.PermissionCode IN (SELECT PermissionCode FROM @Permissions)
      AND NOT EXISTS(SELECT 1 FROM dbo.RolePermissions RP WHERE RP.RoleId=@AdminRoleId AND RP.PermissionId=P.PermissionId);
END
GO

PRINT N'Sprint 12 workflow permissions created successfully.';
GO
