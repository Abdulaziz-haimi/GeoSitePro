USE GeoSitePro;
GO

/* Quick verification after running the fixed scripts. It should return zero missing items. */

DECLARE @RequiredColumns TABLE(TableName SYSNAME, ColumnName SYSNAME);
INSERT INTO @RequiredColumns VALUES
(N'LookupCategories',N'LookupCategoryId'),(N'LookupCategories',N'IsDeleted'),(N'LookupCategories',N'IsActive'),
(N'LookupItems',N'LookupCategoryId'),(N'LookupItems',N'ItemCode'),(N'LookupItems',N'IsDeleted'),(N'LookupItems',N'IsDefault'),
(N'Permissions',N'ModuleName'),(N'Permissions',N'PermissionNameEn'),(N'Permissions',N'IsActive'),(N'Permissions',N'IsDeleted'),
(N'RolePermissions',N'GrantedBy'),
(N'UserRoles',N'IsActive'),
(N'Users',N'IsDeleted'),(N'Roles',N'IsDeleted'),
(N'AuditLogs',N'NewValues'),
(N'Projects',N'ClientId'),(N'Projects',N'IsDeleted'),
(N'Boreholes',N'BoreholeCode'),(N'Boreholes',N'ActualDepthM'),(N'Boreholes',N'IsDeleted'),
(N'BoreholeLayers',N'LayerId'),
(N'Samples',N'BoreholeId'),(N'Samples',N'SampleCode'),(N'Samples',N'IsDeleted'),
(N'SPTTests',N'SPTTestId'),
(N'GroundwaterObservations',N'GroundwaterObservationId');

SELECT RC.TableName, RC.ColumnName
FROM @RequiredColumns RC
WHERE COL_LENGTH(N'dbo.' + RC.TableName, RC.ColumnName) IS NULL
ORDER BY RC.TableName, RC.ColumnName;

DECLARE @RequiredProcedures TABLE(ProcedureName SYSNAME);
INSERT INTO @RequiredProcedures VALUES
(N'sp_Boreholes_Get'),(N'sp_Borehole_GetById'),(N'sp_Borehole_Save'),(N'sp_Borehole_Delete'),
(N'sp_BoreholeLayers_Get'),(N'sp_BoreholeLayer_Save'),
(N'sp_Samples_Get'),(N'sp_Sample_Save'),
(N'sp_SPTTests_Get'),(N'sp_SPTTest_Save'),
(N'sp_GroundwaterObservations_Get'),(N'sp_GroundwaterObservation_Save'),
(N'sp_BoreholeLog_Get'),(N'sp_ProjectDashboard_Get');

SELECT RP.ProcedureName
FROM @RequiredProcedures RP
WHERE OBJECT_ID(N'dbo.' + RP.ProcedureName, N'P') IS NULL
ORDER BY RP.ProcedureName;
GO
