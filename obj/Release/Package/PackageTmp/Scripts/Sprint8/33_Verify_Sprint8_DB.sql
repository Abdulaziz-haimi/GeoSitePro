USE GeoSitePro;
GO

SELECT MissingTable = V.TableName
FROM (VALUES
 (N'InvestigationTemplates'),
 (N'InvestigationTemplateItems'),
 (N'ProjectInvestigationPlans'),
 (N'ProjectInvestigationPlanItems')
) V(TableName)
WHERE OBJECT_ID(N'dbo.' + V.TableName, N'U') IS NULL;
GO

SELECT MissingProcedure = V.ProcedureName
FROM (VALUES
 (N'sp_ProjectTypes_Get'),
 (N'sp_InvestigationTemplates_Get'),
 (N'sp_InvestigationTemplate_GetDetails'),
 (N'sp_ProjectInvestigationTemplates_Suggest'),
 (N'sp_ProjectInvestigationPlan_Generate'),
 (N'sp_ProjectInvestigationPlans_Get'),
 (N'sp_ProjectInvestigationPlan_GetById'),
 (N'sp_ProjectInvestigationPlanItems_Get'),
 (N'sp_ProjectInvestigationPlanItem_Save'),
 (N'sp_ProjectInvestigationPlan_Approve')
) V(ProcedureName)
WHERE OBJECT_ID(N'dbo.' + V.ProcedureName, N'P') IS NULL;
GO

SELECT MissingPermission = V.PermissionCode
FROM (VALUES
 (N'InvestigationTemplates.View'),
 (N'InvestigationTemplates.Create'),
 (N'InvestigationTemplates.Edit'),
 (N'InvestigationTemplates.Delete'),
 (N'ProjectInvestigationPlan.View'),
 (N'ProjectInvestigationPlan.Generate'),
 (N'ProjectInvestigationPlan.Edit'),
 (N'ProjectInvestigationPlan.Approve')
) V(PermissionCode)
WHERE NOT EXISTS(SELECT 1 FROM dbo.Permissions P WHERE P.PermissionCode=V.PermissionCode AND P.IsDeleted=0);
GO

SELECT TemplateCount = COUNT(*) FROM dbo.InvestigationTemplates WHERE IsDeleted=0;
SELECT TemplateItemCount = COUNT(*) FROM dbo.InvestigationTemplateItems WHERE IsDeleted=0;
GO

PRINT N'Sprint 8 verification completed. The Missing* result sets should be empty.';
GO
