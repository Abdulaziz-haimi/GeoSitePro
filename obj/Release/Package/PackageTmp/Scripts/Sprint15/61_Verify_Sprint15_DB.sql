USE GeoSitePro;
GO

SELECT MissingTable = V.TableName
FROM (VALUES
(N'SystemSettings'),(N'SystemBackupJobs'),(N'SystemOperationLogs')
) V(TableName)
WHERE OBJECT_ID(N'dbo.' + V.TableName, N'U') IS NULL;

SELECT MissingProcedure = V.ProcName
FROM (VALUES
(N'sp_SystemSettings_Get'),(N'sp_SystemSetting_GetById'),(N'sp_SystemSetting_Save'),(N'sp_SystemSetting_Delete'),
(N'sp_BackupJob_Create'),(N'sp_BackupJobs_Get'),(N'sp_SystemHealth_Get'),
(N'sp_SystemOperationLog_Create'),(N'sp_SystemOperationLogs_Get')
) V(ProcName)
WHERE OBJECT_ID(N'dbo.' + V.ProcName, N'P') IS NULL;

SELECT MissingPermission = V.PermissionCode
FROM (VALUES
(N'SystemSettings.View'),(N'SystemSettings.Manage'),(N'Backup.View'),(N'Backup.Create'),
(N'SystemHealth.View'),(N'SystemHealth.Run'),(N'OperationLogs.View')
) V(PermissionCode)
WHERE NOT EXISTS(SELECT 1 FROM dbo.Permissions P WHERE P.PermissionCode = V.PermissionCode AND P.IsDeleted = 0);
GO

PRINT N'Sprint 15 verification completed. Empty result sets mean Sprint 15 DB is ready.';
GO
