USE GeoSitePro;
GO

SELECT 'Missing table' AS CheckType, v.TableName
FROM (VALUES ('SystemSecurityEvents'),('PasswordPolicies'),('DeploymentChecklistItems')) v(TableName)
WHERE OBJECT_ID('dbo.' + v.TableName, 'U') IS NULL;

SELECT 'Missing procedure' AS CheckType, v.ProcName
FROM (VALUES
('sp_SecurityEvent_Log'),('sp_SecurityEvents_Get'),('sp_SecurityDashboard_Get'),('sp_PasswordPolicy_Get'),('sp_PasswordPolicy_Save'),
('sp_DeploymentChecklist_SeedDefaults'),('sp_DeploymentChecklist_Get'),('sp_DeploymentChecklist_GetById'),('sp_DeploymentChecklist_Save'),('sp_DeploymentChecklist_Delete'),('sp_DeploymentChecklist_Summary')) v(ProcName)
WHERE OBJECT_ID('dbo.' + v.ProcName, 'P') IS NULL;

SELECT 'Missing permission' AS CheckType, v.PermissionCode
FROM (VALUES ('Security.View'),('Security.Manage'),('Security.Policy'),('DeploymentChecklist.View'),('DeploymentChecklist.Manage')) v(PermissionCode)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Permissions p WHERE p.PermissionCode = v.PermissionCode);

PRINT 'Sprint 16 verification completed. Empty result sets mean OK.';
GO
