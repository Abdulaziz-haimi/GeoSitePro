USE GeoSitePro;
GO

SELECT MissingTable = T.Name
FROM (VALUES
(N'ProjectRiskRegister'),
(N'ProjectKpiSnapshots')
) T(Name)
WHERE OBJECT_ID(N'dbo.' + T.Name, N'U') IS NULL;

SELECT MissingProcedure = P.Name
FROM (VALUES
(N'sp_ExecutiveDashboard_GetSummary'),
(N'sp_ProjectRisks_Get'),
(N'sp_ProjectRisk_Save'),
(N'sp_ProjectRisk_UpdateStatus'),
(N'sp_QualityKpi_GenerateSnapshot'),
(N'sp_QualityKpi_Get'),
(N'sp_Projects_Lookup'),
(N'sp_Users_Lookup')
) P(Name)
WHERE OBJECT_ID(N'dbo.' + P.Name, N'P') IS NULL;

SELECT MissingPermission = P.Code
FROM (VALUES
(N'ExecutiveDashboard.View'),
(N'Risks.View'),
(N'Risks.Create'),
(N'Risks.Edit'),
(N'Risks.Close'),
(N'KpiDashboard.View'),
(N'KpiDashboard.Generate')
) P(Code)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Permissions X WHERE X.PermissionCode = P.Code AND X.IsDeleted = 0);
GO

PRINT N'Sprint 14 verification completed.';
GO
