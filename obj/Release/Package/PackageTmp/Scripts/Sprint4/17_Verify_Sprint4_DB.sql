USE GeoSitePro;
GO

PRINT N'Verifying Sprint 4 database objects...';

SELECT MissingTable = V.TableName
FROM (VALUES (N'TechnicalReports'), (N'TechnicalReportSections')) V(TableName)
WHERE OBJECT_ID(N'dbo.' + V.TableName, N'U') IS NULL;

SELECT MissingProcedure = V.ProcedureName
FROM (VALUES
(N'sp_Reports_Get'), (N'sp_Report_GetById'), (N'sp_Report_Save'), (N'sp_Report_Delete'),
(N'sp_Report_Approve'), (N'sp_ReportSections_Get'), (N'sp_ReportSection_GetById'),
(N'sp_ReportSection_Save'), (N'sp_ReportSection_Delete'), (N'sp_Report_GenerateDefaultSections'),
(N'sp_Report_GetFullData')) V(ProcedureName)
WHERE OBJECT_ID(N'dbo.' + V.ProcedureName, N'P') IS NULL;

SELECT MissingPermission = V.PermissionCode
FROM (VALUES
(N'Reports.View'), (N'Reports.Create'), (N'Reports.Edit'), (N'Reports.Delete'),
(N'Reports.Generate'), (N'Reports.Approve'), (N'Reports.Print')) V(PermissionCode)
WHERE NOT EXISTS(SELECT 1 FROM dbo.Permissions P WHERE P.PermissionCode = V.PermissionCode AND P.IsDeleted = 0);

SELECT MissingLookupCategory = V.CategoryCode
FROM (VALUES (N'ReportType'), (N'ReportStatus'), (N'ReportSectionType')) V(CategoryCode)
WHERE NOT EXISTS(SELECT 1 FROM dbo.LookupCategories C WHERE C.CategoryCode = V.CategoryCode AND C.IsDeleted = 0);

PRINT N'If all result sets above are empty, Sprint 4 DB objects are ready.';
GO
