USE GeoSitePro;
GO

DECLARE @AdminUsername NVARCHAR(100) = N'admin';
DECLARE @AdminFullName NVARCHAR(200) = N'System Administrator';
DECLARE @AdminEmail NVARCHAR(200) = N'admin@geositepro.local';
DECLARE @AdminPasswordHash NVARCHAR(500) = N'ysmSMl25b4OI/2wmJL+Z7Y0vBIfpUT8JQ8snVndno0I=';
DECLARE @AdminPasswordSalt NVARCHAR(500) = N'ZTbriBEzS+Jpr4eMDF67ww==';
DECLARE @AdminRoleName NVARCHAR(150) = N'System Admin';
DECLARE @AdminUserId BIGINT;
DECLARE @AdminRoleId BIGINT;

IF NOT EXISTS(SELECT 1 FROM dbo.Roles WHERE RoleName=@AdminRoleName AND IsDeleted=0)
BEGIN
    INSERT INTO dbo.Roles(RoleName, Description, IsActive) VALUES(@AdminRoleName, N'Sprint 1 administrator role with all available permissions.', 1);
END
SELECT @AdminRoleId = RoleId FROM dbo.Roles WHERE RoleName=@AdminRoleName AND IsDeleted=0;

IF NOT EXISTS(SELECT 1 FROM dbo.Users WHERE Username=@AdminUsername AND IsDeleted=0)
BEGIN
    INSERT INTO dbo.Users(Username, FullName, Email, PasswordHash, PasswordSalt, IsActive)
    VALUES(@AdminUsername, @AdminFullName, @AdminEmail, @AdminPasswordHash, @AdminPasswordSalt, 1);
END
ELSE
BEGIN
    UPDATE dbo.Users SET FullName=@AdminFullName, Email=@AdminEmail, PasswordHash=@AdminPasswordHash, PasswordSalt=@AdminPasswordSalt, IsActive=1, UpdatedAt=SYSDATETIME()
    WHERE Username=@AdminUsername AND IsDeleted=0;
END
SELECT @AdminUserId = UserId FROM dbo.Users WHERE Username=@AdminUsername AND IsDeleted=0;

IF NOT EXISTS(SELECT 1 FROM dbo.UserRoles WHERE UserId=@AdminUserId AND RoleId=@AdminRoleId)
BEGIN
    INSERT INTO dbo.UserRoles(UserId, RoleId, AssignedBy, IsActive) VALUES(@AdminUserId, @AdminRoleId, @AdminUserId, 1);
END
ELSE
BEGIN
    UPDATE dbo.UserRoles SET IsActive=1, AssignedAt=SYSDATETIME(), AssignedBy=@AdminUserId WHERE UserId=@AdminUserId AND RoleId=@AdminRoleId;
END

INSERT INTO dbo.RolePermissions(RoleId, PermissionId, GrantedBy)
SELECT @AdminRoleId, P.PermissionId, @AdminUserId
FROM dbo.Permissions P
WHERE P.IsDeleted=0 AND P.IsActive=1
  AND NOT EXISTS(SELECT 1 FROM dbo.RolePermissions RP WHERE RP.RoleId=@AdminRoleId AND RP.PermissionId=P.PermissionId);

INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription, NewValues)
VALUES(@AdminUserId, @AdminUsername, N'Insert', N'SeedAdminUser', CONVERT(NVARCHAR(100),@AdminUserId), N'تم إنشاء أو تحديث مستخدم المدير الأول لسبرنت 1.', N'Username=admin; Password=Admin@123');

PRINT N'Admin user seeded successfully.';
SELECT AdminUserId=@AdminUserId, AdminUsername=@AdminUsername, AdminRoleId=@AdminRoleId, AdminRoleName=@AdminRoleName,
       PermissionCount=(SELECT COUNT(*) FROM dbo.RolePermissions WHERE RoleId=@AdminRoleId);
GO
