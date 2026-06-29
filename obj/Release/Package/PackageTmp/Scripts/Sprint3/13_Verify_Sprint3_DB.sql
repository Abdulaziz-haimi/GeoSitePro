USE GeoSitePro;
GO

SELECT MissingTable = N'LabTestResults'
WHERE OBJECT_ID(N'dbo.LabTestResults', N'U') IS NULL;

DECLARE @RequiredProcedures TABLE(ProcedureName SYSNAME);
INSERT INTO @RequiredProcedures VALUES
(N'sp_LabResults_Get'),
(N'sp_LabResult_GetById'),
(N'sp_LabResult_Save'),
(N'sp_LabResult_Delete'),
(N'sp_LabResult_Approve'),
(N'sp_ProjectDashboard_Get'),
(N'sp_Dashboard_GetSummary');

SELECT MissingProcedure = R.ProcedureName
FROM @RequiredProcedures R
WHERE OBJECT_ID(N'dbo.' + R.ProcedureName, N'P') IS NULL;

DECLARE @RequiredPermissions TABLE(PermissionCode NVARCHAR(150));
INSERT INTO @RequiredPermissions VALUES
(N'LabResults.View'),
(N'LabResults.Create'),
(N'LabResults.Edit'),
(N'LabResults.Delete'),
(N'LabResults.Approve');

SELECT MissingPermission = R.PermissionCode
FROM @RequiredPermissions R
WHERE NOT EXISTS(SELECT 1 FROM dbo.Permissions P WHERE P.PermissionCode = R.PermissionCode AND P.IsDeleted = 0);

SELECT MissingLookupCategory = V.CategoryCode
FROM (VALUES (N'LabTestType'), (N'LabResultStatus')) V(CategoryCode)
WHERE NOT EXISTS(SELECT 1 FROM dbo.LookupCategories C WHERE C.CategoryCode = V.CategoryCode AND C.IsDeleted = 0);

PRINT N'If all result sets above are empty, Sprint 3 database objects are ready.';
GO
