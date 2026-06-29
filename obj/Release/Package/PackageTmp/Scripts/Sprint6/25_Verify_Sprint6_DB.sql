USE GeoSitePro;
GO
SELECT MissingTable FROM (VALUES (N'Standards'),(N'ProjectQualityChecks'),(N'EngineeringCalculations')) V(MissingTable)
WHERE OBJECT_ID(N'dbo.' + V.MissingTable, N'U') IS NULL;
SELECT MissingProcedure FROM (VALUES (N'sp_Standards_Get'),(N'sp_ProjectQualityChecks_Get'),(N'sp_EngineeringCalculations_Get')) V(MissingProcedure)
WHERE OBJECT_ID(N'dbo.' + V.MissingProcedure, N'P') IS NULL;
SELECT MissingPermission FROM (VALUES (N'Standards.View'),(N'QualityChecks.View'),(N'Calculations.View')) V(MissingPermission)
WHERE NOT EXISTS(SELECT 1 FROM dbo.Permissions WHERE PermissionCode=V.MissingPermission AND IsDeleted=0);
GO
