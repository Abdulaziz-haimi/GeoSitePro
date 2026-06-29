USE GeoSitePro;
GO

SELECT MissingTable = V.TableName
FROM (VALUES
    (N'PrintOutputTemplates'),
    (N'PrintJobs')
) V(TableName)
WHERE OBJECT_ID(N'dbo.' + V.TableName, N'U') IS NULL;

SELECT MissingProcedure = V.ProcedureName
FROM (VALUES
    (N'sp_Print_ProjectOverview'),
    (N'sp_Print_ProjectHeader'),
    (N'sp_Print_Boreholes_Index'),
    (N'sp_Print_Borehole_Header'),
    (N'sp_Print_Borehole_Layers'),
    (N'sp_Print_Borehole_Samples'),
    (N'sp_Print_Borehole_SPT'),
    (N'sp_Print_Borehole_Groundwater'),
    (N'sp_Print_ProjectSamples'),
    (N'sp_Print_ProjectSPT'),
    (N'sp_Print_ProjectGroundwater'),
    (N'sp_Print_ProjectLabResults'),
    (N'sp_Print_ProjectReports'),
    (N'sp_PrintJob_Save'),
    (N'sp_PrintJobs_Get')
) V(ProcedureName)
WHERE OBJECT_ID(N'dbo.' + V.ProcedureName, N'P') IS NULL;

SELECT MissingPermission = V.PermissionCode
FROM (VALUES
    (N'PrintOutputs.View'),
    (N'PrintOutputs.Print'),
    (N'PrintOutputs.History')
) V(PermissionCode)
WHERE NOT EXISTS(SELECT 1 FROM dbo.Permissions P WHERE P.PermissionCode=V.PermissionCode AND ISNULL(P.IsDeleted,0)=0);
GO
