USE GeoSitePro;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Roles_Dropdown_Get
AS
BEGIN
    SET NOCOUNT ON;
    SELECT RoleId, RoleName
    FROM dbo.Roles
    WHERE IsDeleted = 0 AND IsActive = 1
    ORDER BY RoleName;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Users_Get
    @SearchText NVARCHAR(200) = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @SearchText = NULLIF(LTRIM(RTRIM(@SearchText)), N'');

    SELECT
        U.UserId, U.Username, U.FullName, U.Email, U.Mobile, U.IsActive, U.LastLoginAt, U.CreatedAt,
        RoleNames = STUFF((
            SELECT N', ' + R.RoleName
            FROM dbo.UserRoles UR
            INNER JOIN dbo.Roles R ON R.RoleId = UR.RoleId AND R.IsDeleted = 0
            WHERE UR.UserId = U.UserId AND UR.IsActive = 1
            ORDER BY R.RoleName
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, N'')
    FROM dbo.Users U
    WHERE U.IsDeleted = 0
      AND (@IsActive IS NULL OR U.IsActive = @IsActive)
      AND (
          @SearchText IS NULL
          OR U.Username LIKE N'%' + @SearchText + N'%'
          OR U.FullName LIKE N'%' + @SearchText + N'%'
          OR U.Email LIKE N'%' + @SearchText + N'%'
          OR U.Mobile LIKE N'%' + @SearchText + N'%'
      )
    ORDER BY U.CreatedAt DESC, U.UserId DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_User_GetById
    @UserId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT UserId, Username, FullName, Email, Mobile, IsActive, LastLoginAt, CreatedAt, UpdatedAt
    FROM dbo.Users
    WHERE UserId = @UserId AND IsDeleted = 0;

    SELECT UR.RoleId, R.RoleName
    FROM dbo.UserRoles UR
    INNER JOIN dbo.Roles R ON R.RoleId = UR.RoleId AND R.IsDeleted = 0
    WHERE UR.UserId = @UserId AND UR.IsActive = 1
    ORDER BY R.RoleName;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_User_Save
    @UserId BIGINT = NULL,
    @Username NVARCHAR(100),
    @FullName NVARCHAR(200),
    @Email NVARCHAR(200) = NULL,
    @Mobile NVARCHAR(50) = NULL,
    @PasswordHash NVARCHAR(500) = NULL,
    @PasswordSalt NVARCHAR(500) = NULL,
    @IsActive BIT = 1,
    @ActorUserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SavedUserId BIGINT;
    SET @Username = NULLIF(LTRIM(RTRIM(@Username)), N'');
    SET @FullName = NULLIF(LTRIM(RTRIM(@FullName)), N'');
    SET @Email = NULLIF(LTRIM(RTRIM(@Email)), N'');
    SET @Mobile = NULLIF(LTRIM(RTRIM(@Mobile)), N'');

    IF @Username IS NULL THROW 55001, N'Username is required.', 1;
    IF @FullName IS NULL THROW 55002, N'Full name is required.', 1;
    IF EXISTS(SELECT 1 FROM dbo.Users WHERE Username=@Username AND IsDeleted=0 AND (@UserId IS NULL OR UserId<>@UserId)) THROW 55003, N'Username already exists.', 1;

    IF @UserId IS NULL OR @UserId <= 0
    BEGIN
        IF @PasswordHash IS NULL OR @PasswordSalt IS NULL THROW 55004, N'Password is required for new users.', 1;
        INSERT INTO dbo.Users(Username, FullName, Email, Mobile, PasswordHash, PasswordSalt, IsActive, CreatedBy)
        VALUES(@Username, @FullName, @Email, @Mobile, @PasswordHash, @PasswordSalt, @IsActive, @ActorUserId);
        SET @SavedUserId = SCOPE_IDENTITY();
        INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription, NewValues)
        VALUES(@ActorUserId, (SELECT Username FROM dbo.Users WHERE UserId=@ActorUserId), N'Insert', N'Users', CONVERT(NVARCHAR(100),@SavedUserId), N'تم إنشاء مستخدم جديد.', N'Username=' + @Username);
    END
    ELSE
    BEGIN
        IF NOT EXISTS(SELECT 1 FROM dbo.Users WHERE UserId=@UserId AND IsDeleted=0) THROW 55005, N'User does not exist.', 1;
        UPDATE dbo.Users
        SET Username=@Username,
            FullName=@FullName,
            Email=@Email,
            Mobile=@Mobile,
            PasswordHash=COALESCE(@PasswordHash, PasswordHash),
            PasswordSalt=COALESCE(@PasswordSalt, PasswordSalt),
            IsActive=@IsActive,
            UpdatedAt=SYSDATETIME(),
            UpdatedBy=@ActorUserId
        WHERE UserId=@UserId;
        SET @SavedUserId = @UserId;
        INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription, NewValues)
        VALUES(@ActorUserId, (SELECT Username FROM dbo.Users WHERE UserId=@ActorUserId), N'Update', N'Users', CONVERT(NVARCHAR(100),@SavedUserId), N'تم تعديل بيانات مستخدم.', N'Username=' + @Username);
    END

    SELECT @SavedUserId AS UserId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_UserRole_Save
    @TargetUserId BIGINT,
    @RoleId BIGINT,
    @IsAssigned BIT,
    @ActorUserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS(SELECT 1 FROM dbo.Users WHERE UserId=@TargetUserId AND IsDeleted=0) THROW 55010, N'User does not exist.', 1;
    IF NOT EXISTS(SELECT 1 FROM dbo.Roles WHERE RoleId=@RoleId AND IsDeleted=0) THROW 55011, N'Role does not exist.', 1;

    IF @IsAssigned = 1
    BEGIN
        IF NOT EXISTS(SELECT 1 FROM dbo.UserRoles WHERE UserId=@TargetUserId AND RoleId=@RoleId)
            INSERT INTO dbo.UserRoles(UserId, RoleId, AssignedAt, AssignedBy, IsActive) VALUES(@TargetUserId, @RoleId, SYSDATETIME(), @ActorUserId, 1);
        ELSE
            UPDATE dbo.UserRoles SET IsActive=1, AssignedAt=SYSDATETIME(), AssignedBy=@ActorUserId WHERE UserId=@TargetUserId AND RoleId=@RoleId;
    END
    ELSE
    BEGIN
        UPDATE dbo.UserRoles SET IsActive=0 WHERE UserId=@TargetUserId AND RoleId=@RoleId;
    END
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_User_Delete
    @UserId BIGINT,
    @ActorUserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @UserId = @ActorUserId THROW 55020, N'Current user cannot delete himself.', 1;
    IF NOT EXISTS(SELECT 1 FROM dbo.Users WHERE UserId=@UserId AND IsDeleted=0) THROW 55021, N'User does not exist.', 1;
    UPDATE dbo.Users SET IsDeleted=1, IsActive=0, DeletedAt=SYSDATETIME(), DeletedBy=@ActorUserId WHERE UserId=@UserId;
    UPDATE dbo.UserRoles SET IsActive=0 WHERE UserId=@UserId;
    INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription)
    VALUES(@ActorUserId, (SELECT Username FROM dbo.Users WHERE UserId=@ActorUserId), N'Delete', N'Users', CONVERT(NVARCHAR(100),@UserId), N'تم حذف مستخدم منطقيًا.');
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_User_ResetPassword
    @UserId BIGINT,
    @PasswordHash NVARCHAR(500),
    @PasswordSalt NVARCHAR(500),
    @ActorUserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS(SELECT 1 FROM dbo.Users WHERE UserId=@UserId AND IsDeleted=0) THROW 55030, N'User does not exist.', 1;
    UPDATE dbo.Users SET PasswordHash=@PasswordHash, PasswordSalt=@PasswordSalt, UpdatedAt=SYSDATETIME(), UpdatedBy=@ActorUserId WHERE UserId=@UserId;
    INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription)
    VALUES(@ActorUserId, (SELECT Username FROM dbo.Users WHERE UserId=@ActorUserId), N'ResetPassword', N'Users', CONVERT(NVARCHAR(100),@UserId), N'تمت إعادة تعيين كلمة مرور مستخدم.');
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Roles_Get
    @SearchText NVARCHAR(200) = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @SearchText = NULLIF(LTRIM(RTRIM(@SearchText)), N'');

    SELECT
        R.RoleId, R.RoleName, R.Description, R.IsActive, R.CreatedAt,
        UserCount = (SELECT COUNT(1) FROM dbo.UserRoles UR INNER JOIN dbo.Users U ON U.UserId=UR.UserId AND U.IsDeleted=0 WHERE UR.RoleId=R.RoleId AND UR.IsActive=1),
        PermissionCount = (SELECT COUNT(1) FROM dbo.RolePermissions RP INNER JOIN dbo.Permissions P ON P.PermissionId=RP.PermissionId AND P.IsDeleted=0 AND P.IsActive=1 WHERE RP.RoleId=R.RoleId)
    FROM dbo.Roles R
    WHERE R.IsDeleted = 0
      AND (@IsActive IS NULL OR R.IsActive = @IsActive)
      AND (@SearchText IS NULL OR R.RoleName LIKE N'%' + @SearchText + N'%' OR R.Description LIKE N'%' + @SearchText + N'%')
    ORDER BY R.RoleName;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Role_GetById
    @RoleId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT RoleId, RoleName, Description, IsActive, CreatedAt, UpdatedAt
    FROM dbo.Roles
    WHERE RoleId=@RoleId AND IsDeleted=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Role_Save
    @RoleId BIGINT = NULL,
    @RoleName NVARCHAR(150),
    @Description NVARCHAR(500) = NULL,
    @IsActive BIT = 1,
    @ActorUserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SavedRoleId BIGINT;
    SET @RoleName = NULLIF(LTRIM(RTRIM(@RoleName)), N'');
    SET @Description = NULLIF(LTRIM(RTRIM(@Description)), N'');
    IF @RoleName IS NULL THROW 55101, N'Role name is required.', 1;
    IF EXISTS(SELECT 1 FROM dbo.Roles WHERE RoleName=@RoleName AND IsDeleted=0 AND (@RoleId IS NULL OR RoleId<>@RoleId)) THROW 55102, N'Role name already exists.', 1;

    IF @RoleId IS NULL OR @RoleId <= 0
    BEGIN
        INSERT INTO dbo.Roles(RoleName, Description, IsActive, CreatedBy) VALUES(@RoleName, @Description, @IsActive, @ActorUserId);
        SET @SavedRoleId = SCOPE_IDENTITY();
        INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription, NewValues)
        VALUES(@ActorUserId, (SELECT Username FROM dbo.Users WHERE UserId=@ActorUserId), N'Insert', N'Roles', CONVERT(NVARCHAR(100),@SavedRoleId), N'تم إنشاء دور جديد.', N'RoleName=' + @RoleName);
    END
    ELSE
    BEGIN
        IF NOT EXISTS(SELECT 1 FROM dbo.Roles WHERE RoleId=@RoleId AND IsDeleted=0) THROW 55103, N'Role does not exist.', 1;
        UPDATE dbo.Roles SET RoleName=@RoleName, Description=@Description, IsActive=@IsActive, UpdatedAt=SYSDATETIME(), UpdatedBy=@ActorUserId WHERE RoleId=@RoleId;
        SET @SavedRoleId = @RoleId;
        INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription, NewValues)
        VALUES(@ActorUserId, (SELECT Username FROM dbo.Users WHERE UserId=@ActorUserId), N'Update', N'Roles', CONVERT(NVARCHAR(100),@SavedRoleId), N'تم تعديل دور.', N'RoleName=' + @RoleName);
    END

    SELECT @SavedRoleId AS RoleId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Role_Delete
    @RoleId BIGINT,
    @ActorUserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS(SELECT 1 FROM dbo.Roles WHERE RoleId=@RoleId AND IsDeleted=0) THROW 55110, N'Role does not exist.', 1;
    IF EXISTS(SELECT 1 FROM dbo.UserRoles WHERE RoleId=@RoleId AND IsActive=1) THROW 55111, N'Cannot delete role assigned to active users.', 1;
    UPDATE dbo.Roles SET IsDeleted=1, IsActive=0, DeletedAt=SYSDATETIME(), DeletedBy=@ActorUserId WHERE RoleId=@RoleId;
    INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription)
    VALUES(@ActorUserId, (SELECT Username FROM dbo.Users WHERE UserId=@ActorUserId), N'Delete', N'Roles', CONVERT(NVARCHAR(100),@RoleId), N'تم حذف دور منطقيًا.');
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_RolePermissions_Get
    @RoleId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.PermissionId,
        P.ModuleName,
        P.PermissionCode,
        P.PermissionNameAr,
        P.PermissionNameEn,
        P.SortOrder,
        IsGranted = CASE WHEN RP.PermissionId IS NULL THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
    FROM dbo.Permissions P
    LEFT JOIN dbo.RolePermissions RP ON RP.PermissionId = P.PermissionId AND RP.RoleId = @RoleId
    WHERE P.IsDeleted = 0 AND P.IsActive = 1
    ORDER BY P.ModuleName, P.SortOrder, P.PermissionCode;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_RolePermission_Save
    @RoleId BIGINT,
    @PermissionId BIGINT,
    @IsGranted BIT,
    @ActorUserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS(SELECT 1 FROM dbo.Roles WHERE RoleId=@RoleId AND IsDeleted=0) THROW 55120, N'Role does not exist.', 1;
    IF NOT EXISTS(SELECT 1 FROM dbo.Permissions WHERE PermissionId=@PermissionId AND IsDeleted=0) THROW 55121, N'Permission does not exist.', 1;

    IF @IsGranted = 1
    BEGIN
        IF NOT EXISTS(SELECT 1 FROM dbo.RolePermissions WHERE RoleId=@RoleId AND PermissionId=@PermissionId)
            INSERT INTO dbo.RolePermissions(RoleId, PermissionId, GrantedAt, GrantedBy) VALUES(@RoleId, @PermissionId, SYSDATETIME(), @ActorUserId);
        ELSE
            UPDATE dbo.RolePermissions SET GrantedAt=SYSDATETIME(), GrantedBy=@ActorUserId WHERE RoleId=@RoleId AND PermissionId=@PermissionId;
    END
    ELSE
    BEGIN
        DELETE FROM dbo.RolePermissions WHERE RoleId=@RoleId AND PermissionId=@PermissionId;
    END
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_AuditLogs_Get
    @SearchText NVARCHAR(200) = NULL,
    @ActionType NVARCHAR(80) = NULL,
    @EntityName NVARCHAR(150) = NULL,
    @UserId BIGINT = NULL,
    @DateFrom DATE = NULL,
    @DateTo DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @SearchText = NULLIF(LTRIM(RTRIM(@SearchText)), N'');
    SET @ActionType = NULLIF(LTRIM(RTRIM(@ActionType)), N'');
    SET @EntityName = NULLIF(LTRIM(RTRIM(@EntityName)), N'');

    SELECT TOP 500
        A.AuditLogId, A.UserId, A.Username, A.ActionType, A.EntityName, A.EntityId,
        A.ActionDescription, A.OldValues, A.NewValues, A.IpAddress, A.UserAgent, A.ActionDate
    FROM dbo.AuditLogs A
    WHERE (@UserId IS NULL OR A.UserId = @UserId)
      AND (@ActionType IS NULL OR A.ActionType LIKE N'%' + @ActionType + N'%')
      AND (@EntityName IS NULL OR A.EntityName LIKE N'%' + @EntityName + N'%')
      AND (@DateFrom IS NULL OR CAST(A.ActionDate AS DATE) >= @DateFrom)
      AND (@DateTo IS NULL OR CAST(A.ActionDate AS DATE) <= @DateTo)
      AND (
          @SearchText IS NULL
          OR A.Username LIKE N'%' + @SearchText + N'%'
          OR A.ActionType LIKE N'%' + @SearchText + N'%'
          OR A.EntityName LIKE N'%' + @SearchText + N'%'
          OR A.EntityId LIKE N'%' + @SearchText + N'%'
          OR A.ActionDescription LIKE N'%' + @SearchText + N'%'
      )
    ORDER BY A.ActionDate DESC, A.AuditLogId DESC;
END
GO

PRINT N'Sprint 5 stored procedures created successfully.';
GO
