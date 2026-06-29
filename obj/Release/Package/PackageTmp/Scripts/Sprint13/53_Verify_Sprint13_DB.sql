USE GeoSitePro;
GO

SELECT MissingTables = V.Name
FROM (VALUES
(N'NotificationRules'),
(N'UserNotifications'),
(N'ProjectFollowUpItems')
) V(Name)
WHERE OBJECT_ID(N'dbo.' + V.Name, N'U') IS NULL;

SELECT MissingProcedures = V.Name
FROM (VALUES
(N'sp_NotificationRules_Get'),
(N'sp_NotificationRule_GetById'),
(N'sp_NotificationRule_Save'),
(N'sp_Notifications_Get'),
(N'sp_Notifications_Summary'),
(N'sp_Notification_UpdateStatus'),
(N'sp_Notifications_MarkAllRead'),
(N'sp_FollowUpItems_Get'),
(N'sp_FollowUpItem_GetById'),
(N'sp_FollowUpItem_Save'),
(N'sp_FollowUpItem_Close'),
(N'sp_Notifications_Generate')
) V(Name)
WHERE OBJECT_ID(N'dbo.' + V.Name, N'P') IS NULL;

SELECT MissingPermissions = V.PermissionCode
FROM (VALUES
(N'Notifications.View'),
(N'Notifications.Generate'),
(N'Notifications.Manage'),
(N'FollowUp.View'),
(N'FollowUp.Create'),
(N'FollowUp.Close')
) V(PermissionCode)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Permissions P WHERE P.PermissionCode = V.PermissionCode AND P.IsDeleted = 0);
GO
