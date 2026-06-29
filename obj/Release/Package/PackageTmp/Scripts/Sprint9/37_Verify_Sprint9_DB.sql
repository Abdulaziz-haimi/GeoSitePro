USE GeoSitePro;
GO

/* Sprint 9 verification. Empty result sets mean OK. */

SELECT MissingTable = V.Name
FROM (VALUES
(N'ProjectMapSettings'),
(N'ProjectBoreholeLayoutPoints'),
(N'ProjectCrossSections'),
(N'ProjectCrossSectionBoreholes')
) V(Name)
WHERE OBJECT_ID(N'dbo.' + V.Name, N'U') IS NULL;
GO

SELECT MissingProcedure = V.Name
FROM (VALUES
(N'sp_LookupItems_GetByCategory'),
(N'sp_ProjectMap_Get'),
(N'sp_ProjectMapSettings_Save'),
(N'sp_ProjectBoreholeLayoutPoints_Get'),
(N'sp_ProjectBoreholeLayoutPoint_GetById'),
(N'sp_ProjectBoreholeLayoutPoint_Save'),
(N'sp_ProjectBoreholeLayoutPoint_Delete'),
(N'sp_ProjectBoreholeLayout_GenerateFromActual'),
(N'sp_ProjectBoreholeLayout_GenerateFromApprovedPlan'),
(N'sp_ProjectCrossSections_Get'),
(N'sp_ProjectCrossSection_GetById'),
(N'sp_ProjectCrossSection_Save'),
(N'sp_ProjectCrossSection_GenerateBoreholes'),
(N'sp_ProjectCrossSectionData_Get'),
(N'sp_ProjectCrossSection_Delete')
) V(Name)
WHERE OBJECT_ID(N'dbo.' + V.Name, N'P') IS NULL;
GO

SELECT MissingPermission = V.PermissionCode
FROM (VALUES
(N'SiteMap.View'),
(N'SiteMap.Edit'),
(N'SiteMap.Generate'),
(N'SiteMap.Export'),
(N'CrossSections.View'),
(N'CrossSections.Edit'),
(N'CrossSections.Generate'),
(N'CrossSections.Export')
) V(PermissionCode)
WHERE NOT EXISTS(SELECT 1 FROM dbo.Permissions P WHERE P.PermissionCode=V.PermissionCode AND P.IsDeleted=0);
GO

PRINT N'Sprint 9 verification completed.';
GO
