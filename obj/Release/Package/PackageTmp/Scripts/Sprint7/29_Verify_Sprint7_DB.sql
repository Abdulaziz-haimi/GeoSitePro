USE GeoSitePro;
GO
SELECT MissingTable FROM (VALUES (N'ProjectDocuments'),(N'ExportPackages'),(N'ProductionReadinessChecks')) V(MissingTable)
WHERE OBJECT_ID(N'dbo.' + V.MissingTable, N'U') IS NULL;
SELECT MissingProcedure FROM (VALUES (N'sp_ProjectDocuments_Get'),(N'sp_ExportPackages_Get'),(N'sp_ProductionReadiness_Get')) V(MissingProcedure)
WHERE OBJECT_ID(N'dbo.' + V.MissingProcedure, N'P') IS NULL;
SELECT MissingPermission FROM (VALUES (N'ProjectDocuments.View'),(N'ExportCenter.View'),(N'ProductionReadiness.View')) V(MissingPermission)
WHERE NOT EXISTS(SELECT 1 FROM dbo.Permissions WHERE PermissionCode=V.MissingPermission AND IsDeleted=0);
GO
