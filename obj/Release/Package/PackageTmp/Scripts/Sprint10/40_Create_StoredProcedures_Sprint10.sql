USE GeoSitePro;
GO

/* Sprint 10 stored procedures: data exchange, CSV exports, GIS/CAD schedules. */

CREATE OR ALTER PROCEDURE dbo.sp_DataExchange_ProjectOverview
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.ProjectId,
        P.ProjectCode,
        P.ProjectName,
        ISNULL(PT.NameAr, N'-') AS ProjectTypeNameAr,
        P.City,
        P.LocationName,
        ISNULL((SELECT COUNT(1) FROM dbo.Boreholes B WHERE B.ProjectId=@ProjectId AND ISNULL(B.IsDeleted,0)=0),0) AS BoreholeCount,
        ISNULL((SELECT COUNT(1) FROM dbo.BoreholeLayers L INNER JOIN dbo.Boreholes B ON B.BoreholeId=L.BoreholeId WHERE B.ProjectId=@ProjectId AND ISNULL(B.IsDeleted,0)=0 AND ISNULL(L.IsDeleted,0)=0),0) AS LayerCount,
        ISNULL((SELECT COUNT(1) FROM dbo.Samples S WHERE S.ProjectId=@ProjectId AND ISNULL(S.IsDeleted,0)=0),0) AS SampleCount,
        ISNULL((SELECT COUNT(1) FROM dbo.SPTTests SPT WHERE SPT.ProjectId=@ProjectId AND ISNULL(SPT.IsDeleted,0)=0),0) AS SPTCount,
        ISNULL((SELECT COUNT(1) FROM dbo.GroundwaterObservations GW WHERE GW.ProjectId=@ProjectId AND ISNULL(GW.IsDeleted,0)=0),0) AS GroundwaterCount,
        ISNULL((SELECT COUNT(1) FROM dbo.LabTestResults LR WHERE LR.ProjectId=@ProjectId AND ISNULL(LR.IsDeleted,0)=0),0) AS LabResultCount,
        ISNULL((SELECT COUNT(1) FROM dbo.TechnicalReports R WHERE R.ProjectId=@ProjectId AND ISNULL(R.IsDeleted,0)=0),0) AS ReportCount,
        ISNULL((SELECT COUNT(1) FROM dbo.ProjectBoreholeLayoutPoints LP WHERE LP.ProjectId=@ProjectId AND ISNULL(LP.IsDeleted,0)=0),0) AS LayoutPointCount,
        ISNULL((SELECT COUNT(1) FROM dbo.ProjectCrossSections CS WHERE CS.ProjectId=@ProjectId AND ISNULL(CS.IsDeleted,0)=0),0) AS CrossSectionCount,
        ISNULL((SELECT TOP 1 CoordinateSystem FROM dbo.ProjectMapSettings MS WHERE MS.ProjectId=@ProjectId AND ISNULL(MS.IsDeleted,0)=0 ORDER BY MS.MapSettingId DESC), N'-') AS CoordinateSystem,
        ISNULL((SELECT TOP 1 EPSGCode FROM dbo.ProjectMapSettings MS WHERE MS.ProjectId=@ProjectId AND ISNULL(MS.IsDeleted,0)=0 ORDER BY MS.MapSettingId DESC), N'-') AS EPSGCode
    FROM dbo.Projects P
    LEFT JOIN dbo.LookupItems PT ON PT.LookupItemId=P.ProjectTypeId
    WHERE P.ProjectId=@ProjectId AND ISNULL(P.IsDeleted,0)=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DataExportJob_Save
    @ProjectId BIGINT,
    @DatasetCode NVARCHAR(100),
    @ExportFormat NVARCHAR(30),
    @FileName NVARCHAR(300),
    @RowCount INT,
    @Status NVARCHAR(50),
    @RequestedBy BIGINT = NULL,
    @Notes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.DataExportJobs(ProjectId, DatasetCode, ExportFormat, FileName, RowCount, Status, RequestedBy, RequestedAt, CompletedAt, Notes)
    VALUES(@ProjectId, @DatasetCode, @ExportFormat, @FileName, @RowCount, @Status, @RequestedBy, SYSDATETIME(), SYSDATETIME(), @Notes);

    INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription, NewValues)
    SELECT @RequestedBy, U.Username, N'Export', N'DataExportJobs', CONVERT(NVARCHAR(100), SCOPE_IDENTITY()),
           N'تم تصدير بيانات المشروع بصيغة CSV.',
           CONCAT(N'Dataset=', @DatasetCode, N'; File=', @FileName, N'; Rows=', @RowCount)
    FROM dbo.Users U WHERE U.UserId=@RequestedBy;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DataExportJobs_Get
    @ProjectId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 200
        J.ExportJobId,
        J.ProjectId,
        P.ProjectCode,
        P.ProjectName,
        J.DatasetCode,
        J.ExportFormat,
        J.FileName,
        J.RowCount,
        J.Status,
        U.FullName AS RequestedByName,
        J.RequestedAt,
        J.CompletedAt,
        J.Notes
    FROM dbo.DataExportJobs J
    INNER JOIN dbo.Projects P ON P.ProjectId=J.ProjectId
    LEFT JOIN dbo.Users U ON U.UserId=J.RequestedBy
    WHERE ISNULL(J.IsDeleted,0)=0 AND (@ProjectId IS NULL OR J.ProjectId=@ProjectId)
    ORDER BY J.RequestedAt DESC, J.ExportJobId DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Export_Boreholes_CSV
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.ProjectCode, P.ProjectName,
        B.BoreholeCode, B.PlannedDepthM, B.ActualDepthM, B.Easting, B.Northing, B.ElevationM,
        DM.NameEn AS DrillingMethod, ST.NameEn AS BoreholeStatus,
        B.StartDate, B.EndDate, B.GroundwaterDepthM,
        B.LocationDescription, B.FieldEngineer, B.TerminationReason, B.Notes
    FROM dbo.Boreholes B
    INNER JOIN dbo.Projects P ON P.ProjectId=B.ProjectId
    LEFT JOIN dbo.LookupItems DM ON DM.LookupItemId=B.DrillingMethodId
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId=B.BoreholeStatusId
    WHERE B.ProjectId=@ProjectId AND ISNULL(B.IsDeleted,0)=0
    ORDER BY B.BoreholeCode;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Export_BoreholeLayers_CSV
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.ProjectCode, P.ProjectName,
        B.BoreholeCode,
        L.FromDepthM, L.ToDepthM,
        SRT.NameEn AS SoilRockType,
        L.USCS, L.Description, L.Color, L.ConsistencyDensity, L.MoistureCondition,
        L.RecoveryPercent, L.RQDPercent, L.Notes
    FROM dbo.BoreholeLayers L
    INNER JOIN dbo.Boreholes B ON B.BoreholeId=L.BoreholeId
    INNER JOIN dbo.Projects P ON P.ProjectId=B.ProjectId
    LEFT JOIN dbo.LookupItems SRT ON SRT.LookupItemId=L.SoilRockTypeId
    WHERE B.ProjectId=@ProjectId AND ISNULL(B.IsDeleted,0)=0 AND ISNULL(L.IsDeleted,0)=0
    ORDER BY B.BoreholeCode, L.FromDepthM;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Export_Samples_CSV
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.ProjectCode, P.ProjectName,
        B.BoreholeCode,
        S.SampleCode, S.FromDepthM, S.ToDepthM,
        ST.NameEn AS SampleType,
        SQ.NameEn AS SampleQuality,
        S.RecoveryLengthM, S.Description, S.TakenDate, S.RequiredTests, S.StorageLocation, S.Notes
    FROM dbo.Samples S
    INNER JOIN dbo.Projects P ON P.ProjectId=S.ProjectId
    INNER JOIN dbo.Boreholes B ON B.BoreholeId=S.BoreholeId
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId=S.SampleTypeId
    LEFT JOIN dbo.LookupItems SQ ON SQ.LookupItemId=S.SampleQualityId
    WHERE S.ProjectId=@ProjectId AND ISNULL(S.IsDeleted,0)=0
    ORDER BY B.BoreholeCode, S.FromDepthM, S.SampleCode;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Export_SPT_CSV
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.ProjectCode, P.ProjectName,
        B.BoreholeCode,
        SPT.TestDepthM,
        SPT.BlowCount1, SPT.BlowCount2, SPT.BlowCount3,
        ISNULL(SPT.NValue, ISNULL(SPT.BlowCount2,0)+ISNULL(SPT.BlowCount3,0)) AS NValue,
        SPT.HammerEnergyRatio, SPT.CorrectedN, SPT.RecoveryLengthM, SPT.TestDate, SPT.Notes
    FROM dbo.SPTTests SPT
    INNER JOIN dbo.Projects P ON P.ProjectId=SPT.ProjectId
    INNER JOIN dbo.Boreholes B ON B.BoreholeId=SPT.BoreholeId
    WHERE SPT.ProjectId=@ProjectId AND ISNULL(SPT.IsDeleted,0)=0
    ORDER BY B.BoreholeCode, SPT.TestDepthM;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Export_Groundwater_CSV
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.ProjectCode, P.ProjectName,
        B.BoreholeCode,
        GW.ObservationDate, GW.DepthToWaterM,
        OT.NameEn AS ObservationType,
        GW.CasingDepthM, GW.StabilizedAfterHours, GW.Notes
    FROM dbo.GroundwaterObservations GW
    INNER JOIN dbo.Projects P ON P.ProjectId=GW.ProjectId
    INNER JOIN dbo.Boreholes B ON B.BoreholeId=GW.BoreholeId
    LEFT JOIN dbo.LookupItems OT ON OT.LookupItemId=GW.ObservationTypeId
    WHERE GW.ProjectId=@ProjectId AND ISNULL(GW.IsDeleted,0)=0
    ORDER BY B.BoreholeCode, GW.ObservationDate;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Export_LabResults_CSV
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.ProjectCode, P.ProjectName,
        B.BoreholeCode,
        S.SampleCode,
        LTT.NameEn AS LabTestType,
        LR.TestCode, LR.TestStandard, LR.TestDate,
        RS.NameEn AS ResultStatus,
        LR.NumericValue, LR.Unit, LR.ResultValue, LR.ResultText,
        LR.Technician, LR.ReviewedBy,
        LR.IsApproved, LR.ApprovedAt, LR.Remarks
    FROM dbo.LabTestResults LR
    INNER JOIN dbo.Projects P ON P.ProjectId=LR.ProjectId
    INNER JOIN dbo.Boreholes B ON B.BoreholeId=LR.BoreholeId
    INNER JOIN dbo.Samples S ON S.SampleId=LR.SampleId
    LEFT JOIN dbo.LookupItems LTT ON LTT.LookupItemId=LR.LabTestTypeId
    LEFT JOIN dbo.LookupItems RS ON RS.LookupItemId=LR.ResultStatusId
    WHERE LR.ProjectId=@ProjectId AND ISNULL(LR.IsDeleted,0)=0
    ORDER BY B.BoreholeCode, S.FromDepthM, S.SampleCode, LTT.SortOrder;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Export_ReportsIndex_CSV
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.ProjectCode, P.ProjectName,
        R.ReportNo, R.ReportTitle,
        RT.NameEn AS ReportType,
        RS.NameEn AS ReportStatus,
        R.IssueDate, R.RevisionNo, R.LanguageCode,
        R.PreparedBy, R.ReviewedBy, R.ApprovedBy, R.ApprovedAt, R.IssuedAt
    FROM dbo.TechnicalReports R
    INNER JOIN dbo.Projects P ON P.ProjectId=R.ProjectId
    LEFT JOIN dbo.LookupItems RT ON RT.LookupItemId=R.ReportTypeId
    LEFT JOIN dbo.LookupItems RS ON RS.LookupItemId=R.ReportStatusId
    WHERE R.ProjectId=@ProjectId AND ISNULL(R.IsDeleted,0)=0
    ORDER BY R.CreatedAt DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Export_GIS_BoreholePoints
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.ProjectCode,
        P.ProjectName,
        MS.CoordinateSystem,
        MS.EPSGCode,
        COALESCE(LP.BoreholeCode, B.BoreholeCode) AS PointCode,
        COALESCE(LP.Easting, B.Easting) AS X_Easting,
        COALESCE(LP.Northing, B.Northing) AS Y_Northing,
        COALESCE(LP.ElevationM, B.ElevationM) AS Z_ElevationM,
        COALESCE(LP.PlannedDepthM, B.PlannedDepthM) AS PlannedDepthM,
        COALESCE(LP.ActualDepthM, B.ActualDepthM) AS ActualDepthM,
        SRC.NameEn AS SourceType,
        LP.SortOrder,
        COALESCE(LP.Notes, B.Notes) AS Notes
    FROM dbo.ProjectBoreholeLayoutPoints LP
    INNER JOIN dbo.Projects P ON P.ProjectId=LP.ProjectId
    LEFT JOIN dbo.Boreholes B ON B.BoreholeId=LP.BoreholeId
    LEFT JOIN dbo.ProjectMapSettings MS ON MS.ProjectId=LP.ProjectId AND ISNULL(MS.IsDeleted,0)=0
    LEFT JOIN dbo.LookupItems SRC ON SRC.LookupItemId=LP.SourceTypeId
    WHERE LP.ProjectId=@ProjectId AND ISNULL(LP.IsDeleted,0)=0
    UNION ALL
    SELECT
        P.ProjectCode,
        P.ProjectName,
        MS.CoordinateSystem,
        MS.EPSGCode,
        B.BoreholeCode AS PointCode,
        B.Easting AS X_Easting,
        B.Northing AS Y_Northing,
        B.ElevationM AS Z_ElevationM,
        B.PlannedDepthM,
        B.ActualDepthM,
        N'Actual Borehole' AS SourceType,
        1000 AS SortOrder,
        B.Notes
    FROM dbo.Boreholes B
    INNER JOIN dbo.Projects P ON P.ProjectId=B.ProjectId
    LEFT JOIN dbo.ProjectMapSettings MS ON MS.ProjectId=B.ProjectId AND ISNULL(MS.IsDeleted,0)=0
    WHERE B.ProjectId=@ProjectId AND ISNULL(B.IsDeleted,0)=0
      AND NOT EXISTS(SELECT 1 FROM dbo.ProjectBoreholeLayoutPoints LP WHERE LP.ProjectId=B.ProjectId AND LP.BoreholeId=B.BoreholeId AND ISNULL(LP.IsDeleted,0)=0)
    ORDER BY SortOrder, PointCode;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Export_GIS_LayerIntervals
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.ProjectCode, P.ProjectName,
        MS.CoordinateSystem, MS.EPSGCode,
        B.BoreholeCode,
        B.Easting AS X_Easting, B.Northing AS Y_Northing, B.ElevationM AS Z_ElevationM,
        L.FromDepthM, L.ToDepthM,
        CASE WHEN B.ElevationM IS NULL THEN NULL ELSE B.ElevationM - L.FromDepthM END AS TopElevationM,
        CASE WHEN B.ElevationM IS NULL THEN NULL ELSE B.ElevationM - L.ToDepthM END AS BottomElevationM,
        SRT.NameEn AS SoilRockType, L.USCS, L.Description, L.Color, L.ConsistencyDensity, L.MoistureCondition, L.RecoveryPercent, L.RQDPercent
    FROM dbo.BoreholeLayers L
    INNER JOIN dbo.Boreholes B ON B.BoreholeId=L.BoreholeId
    INNER JOIN dbo.Projects P ON P.ProjectId=B.ProjectId
    LEFT JOIN dbo.ProjectMapSettings MS ON MS.ProjectId=B.ProjectId AND ISNULL(MS.IsDeleted,0)=0
    LEFT JOIN dbo.LookupItems SRT ON SRT.LookupItemId=L.SoilRockTypeId
    WHERE B.ProjectId=@ProjectId AND ISNULL(B.IsDeleted,0)=0 AND ISNULL(L.IsDeleted,0)=0
    ORDER BY B.BoreholeCode, L.FromDepthM;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Export_CAD_PointSchedule
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ROW_NUMBER() OVER(ORDER BY COALESCE(LP.SortOrder, 1000), COALESCE(LP.BoreholeCode, B.BoreholeCode)) AS PointNo,
        COALESCE(LP.BoreholeCode, B.BoreholeCode) AS PointName,
        COALESCE(LP.Easting, B.Easting) AS Easting,
        COALESCE(LP.Northing, B.Northing) AS Northing,
        COALESCE(LP.ElevationM, B.ElevationM) AS Elevation,
        COALESCE(LP.ActualDepthM, B.ActualDepthM, LP.PlannedDepthM, B.PlannedDepthM) AS DepthM,
        COALESCE(LP.Notes, B.LocationDescription) AS Description
    FROM dbo.ProjectBoreholeLayoutPoints LP
    LEFT JOIN dbo.Boreholes B ON B.BoreholeId=LP.BoreholeId
    WHERE LP.ProjectId=@ProjectId AND ISNULL(LP.IsDeleted,0)=0
    UNION ALL
    SELECT
        ROW_NUMBER() OVER(ORDER BY B.BoreholeCode) + 10000 AS PointNo,
        B.BoreholeCode AS PointName,
        B.Easting,
        B.Northing,
        B.ElevationM AS Elevation,
        B.ActualDepthM AS DepthM,
        B.LocationDescription AS Description
    FROM dbo.Boreholes B
    WHERE B.ProjectId=@ProjectId AND ISNULL(B.IsDeleted,0)=0
      AND NOT EXISTS(SELECT 1 FROM dbo.ProjectBoreholeLayoutPoints LP WHERE LP.ProjectId=B.ProjectId AND LP.BoreholeId=B.BoreholeId AND ISNULL(LP.IsDeleted,0)=0)
    ORDER BY PointNo;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Export_CrossSectionSummary
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        CS.SectionCode,
        CS.SectionName,
        CS.BaselineType,
        ST.NameEn AS SectionStatus,
        CS.StartEasting, CS.StartNorthing, CS.EndEasting, CS.EndNorthing,
        CS.HorizontalScale, CS.VerticalScale,
        COUNT(CSB.CrossSectionBoreholeId) AS BoreholeCount
    FROM dbo.ProjectCrossSections CS
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId=CS.SectionStatusId
    LEFT JOIN dbo.ProjectCrossSectionBoreholes CSB ON CSB.CrossSectionId=CS.CrossSectionId AND ISNULL(CSB.IsDeleted,0)=0
    WHERE CS.ProjectId=@ProjectId AND ISNULL(CS.IsDeleted,0)=0
    GROUP BY CS.SectionCode, CS.SectionName, CS.BaselineType, ST.NameEn, CS.StartEasting, CS.StartNorthing, CS.EndEasting, CS.EndNorthing, CS.HorizontalScale, CS.VerticalScale
    ORDER BY CS.SectionCode;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Export_CrossSectionLayers
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.ProjectCode, P.ProjectName,
        CS.SectionCode,
        CS.SectionName,
        B.BoreholeCode,
        CSB.ChainageM,
        CSB.OffsetM,
        B.ElevationM AS GroundElevationM,
        L.FromDepthM,
        L.ToDepthM,
        CASE WHEN B.ElevationM IS NULL THEN NULL ELSE B.ElevationM - L.FromDepthM END AS TopElevationM,
        CASE WHEN B.ElevationM IS NULL THEN NULL ELSE B.ElevationM - L.ToDepthM END AS BottomElevationM,
        SRT.NameEn AS SoilRockType,
        L.USCS,
        L.Description,
        L.RecoveryPercent,
        L.RQDPercent
    FROM dbo.ProjectCrossSections CS
    INNER JOIN dbo.Projects P ON P.ProjectId=CS.ProjectId
    INNER JOIN dbo.ProjectCrossSectionBoreholes CSB ON CSB.CrossSectionId=CS.CrossSectionId AND ISNULL(CSB.IsDeleted,0)=0
    INNER JOIN dbo.Boreholes B ON B.BoreholeId=CSB.BoreholeId AND ISNULL(B.IsDeleted,0)=0
    INNER JOIN dbo.BoreholeLayers L ON L.BoreholeId=B.BoreholeId AND ISNULL(L.IsDeleted,0)=0
    LEFT JOIN dbo.LookupItems SRT ON SRT.LookupItemId=L.SoilRockTypeId
    WHERE CS.ProjectId=@ProjectId AND ISNULL(CS.IsDeleted,0)=0
    ORDER BY CS.SectionCode, CSB.SortOrder, B.BoreholeCode, L.FromDepthM;
END
GO

PRINT N'Sprint 10 stored procedures created successfully.';
GO
