USE GeoSitePro;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.NotificationRules WHERE RuleCode = N'FOLLOWUP_DUE' AND IsDeleted = 0)
INSERT INTO dbo.NotificationRules(RuleCode, RuleNameAr, RuleNameEn, RuleType, EntityType, DaysOffset, Severity, MessageTemplate, IsActive, CreatedBy)
VALUES (N'FOLLOWUP_DUE', N'بند متابعة مستحق اليوم', N'Follow-up due today', N'FOLLOWUP_DUE', N'FOLLOWUP', 0, N'Warning', N'يوجد بند متابعة مستحق للمشروع {ProjectCode}.', 1, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.NotificationRules WHERE RuleCode = N'FOLLOWUP_OVERDUE' AND IsDeleted = 0)
INSERT INTO dbo.NotificationRules(RuleCode, RuleNameAr, RuleNameEn, RuleType, EntityType, DaysOffset, Severity, MessageTemplate, IsActive, CreatedBy)
VALUES (N'FOLLOWUP_OVERDUE', N'بند متابعة متأخر', N'Overdue follow-up', N'FOLLOWUP_OVERDUE', N'FOLLOWUP', -1, N'Critical', N'يوجد بند متابعة متأخر للمشروع {ProjectCode}.', 1, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.NotificationRules WHERE RuleCode = N'WORKFLOW_PENDING' AND IsDeleted = 0)
INSERT INTO dbo.NotificationRules(RuleCode, RuleNameAr, RuleNameEn, RuleType, EntityType, DaysOffset, Severity, MessageTemplate, IsActive, CreatedBy)
VALUES (N'WORKFLOW_PENDING', N'طلب اعتماد معلق', N'Pending approval request', N'WORKFLOW_PENDING', N'WORKFLOW', 0, N'Info', N'يوجد طلب اعتماد معلق يحتاج متابعة.', 1, 1);
GO

DECLARE @Permissions TABLE(ModuleName NVARCHAR(100), PermissionCode NVARCHAR(150), PermissionNameAr NVARCHAR(200), PermissionNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Permissions VALUES
(N'Notifications', N'Notifications.View', N'عرض التنبيهات', N'View notifications', 1301),
(N'Notifications', N'Notifications.Generate', N'توليد تنبيهات المتابعة', N'Generate notifications', 1302),
(N'Notifications', N'Notifications.Manage', N'إدارة قواعد التنبيهات', N'Manage notification rules', 1303),
(N'FollowUp', N'FollowUp.View', N'عرض لوحة المتابعة', N'View follow-up board', 1310),
(N'FollowUp', N'FollowUp.Create', N'إنشاء وتعديل بنود المتابعة', N'Create and edit follow-up items', 1311),
(N'FollowUp', N'FollowUp.Close', N'إغلاق بنود المتابعة', N'Close follow-up items', 1312);

INSERT INTO dbo.Permissions(ModuleName, PermissionCode, PermissionNameAr, PermissionNameEn, SortOrder, IsActive, IsDeleted)
SELECT P.ModuleName, P.PermissionCode, P.PermissionNameAr, P.PermissionNameEn, P.SortOrder, 1, 0
FROM @Permissions P
WHERE NOT EXISTS (SELECT 1 FROM dbo.Permissions X WHERE X.PermissionCode = P.PermissionCode AND X.IsDeleted = 0);
GO

DECLARE @AdminRoleId BIGINT;
SELECT TOP 1 @AdminRoleId = RoleId FROM dbo.Roles WHERE IsDeleted = 0 AND (RoleName IN (N'Administrator', N'Admin', N'System Administrator', N'مدير النظام') OR RoleId = 1) ORDER BY RoleId;

IF @AdminRoleId IS NOT NULL
BEGIN
    INSERT INTO dbo.RolePermissions(RoleId, PermissionId, GrantedBy)
    SELECT @AdminRoleId, P.PermissionId, 1
    FROM dbo.Permissions P
    WHERE P.PermissionCode IN (N'Notifications.View', N'Notifications.Generate', N'Notifications.Manage', N'FollowUp.View', N'FollowUp.Create', N'FollowUp.Close')
      AND NOT EXISTS (SELECT 1 FROM dbo.RolePermissions RP WHERE RP.RoleId = @AdminRoleId AND RP.PermissionId = P.PermissionId);
END
GO

PRINT N'Sprint 13 permissions and default notification rules created successfully.';
GO
