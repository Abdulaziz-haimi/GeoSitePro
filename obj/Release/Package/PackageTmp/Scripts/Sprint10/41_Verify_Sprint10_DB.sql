USE GeoSitePro;
GO

PRINT N'Checking Sprint 10 database objects...';

SELECT MissingTable
FROM (VALUES
    (N'DataExportJobs')
) V(MissingTable)
WHERE OBJECT_ID(N'dbo.' + V.MissingTable, N'U') IS NULL;

SELECT MissingProcedure
FROM (VALUES
    (N'sp_DataExchange_ProjectOverview'),
    (N'sp_DataExportJob_Save'),
    (N'sp_DataExportJobs_Get'),
    (N'sp_Export_Boreholes_CSV'),
    (N'sp_Export_BoreholeLayers_CSV'),
    (N'sp_Export_Samples_CSV'),
    (N'sp_Export_SPT_CSV'),
    (N'sp_Export_Groundwater_CSV'),
    (N'sp_Export_LabResults_CSV'),
    (N'sp_Export_ReportsIndex_CSV'),
    (N'sp_Export_GIS_BoreholePoints'),
    (N'sp_Export_GIS_LayerIntervals'),
    (N'sp_Export_CAD_PointSchedule'),
    (N'sp_Export_CrossSectionSummary'),
    (N'sp_Export_CrossSectionLayers')
) V(MissingProcedure)
WHERE OBJECT_ID(N'dbo.' + V.MissingProcedure, N'P') IS NULL;

SELECT MissingPermission
FROM (VALUES
    (N'DataExchange.View'),
    (N'DataExchange.Export'),
    (N'GisCadExport.View'),
    (N'GisCadExport.Export')
) V(MissingPermission)
WHERE NOT EXISTS(SELECT 1 FROM dbo.Permissions P WHERE P.PermissionCode=V.MissingPermission AND P.IsDeleted=0);

PRINT N'If all result sets above are empty, Sprint 10 database is ready.';
GO
