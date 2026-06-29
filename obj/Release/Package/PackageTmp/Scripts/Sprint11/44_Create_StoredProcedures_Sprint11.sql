USE GeoSitePro;
GO

/* Sprint 11 stored procedures: print package and printable borehole logs. */

CREATE OR ALTER PROCEDURE dbo.sp_Print_ProjectOverview
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.ProjectId,
        P.ProjectCode,
        P.ProjectName,
        ISNULL((SELECT COUNT(1) FROM dbo.Boreholes B WHERE B.ProjectId=@ProjectId AND ISNULL(B.IsDeleted,0)=0),0) AS BoreholeCount,
        ISNULL((SELECT COUNT(1) FROM dbo.BoreholeLayers L INNER JOIN dbo.Boreholes B ON B.BoreholeId=L.BoreholeId WHERE B.ProjectId=@ProjectId AND ISNULL(B.IsDeleted,0)=0 AND ISNULL(L.IsDeleted,0)=0),0) AS LayerCount,
        ISNULL((SELECT COUNT(1) FROM dbo.Samples S WHERE S.ProjectId=@ProjectId AND ISNULL(S.IsDeleted,0)=0),0) AS SampleCount,
        ISNULL((SELECT COUNT(1) FROM dbo.SPTTests SPT WHERE SPT.ProjectId=@ProjectId AND ISNULL(SPT.IsDeleted,0)=0),0) AS SPTCount,
        ISNULL((SELECT COUNT(1) FROM dbo.GroundwaterObservations GW WHERE GW.ProjectId=@ProjectId AND ISNULL(GW.IsDeleted,0)=0),0) AS GroundwaterCount,
        ISNULL((SELECT COUNT(1) FROM dbo.LabTestResults LR WHERE LR.ProjectId=@ProjectId AND ISNULL(LR.IsDeleted,0)=0),0) AS LabResultCount,
        ISNULL((SELECT COUNT(1) FROM dbo.TechnicalReports R WHERE R.ProjectId=@ProjectId AND ISNULL(R.IsDeleted,0)=0),0) AS ReportCount,
        ISNULL((SELECT COUNT(1) FROM dbo.ProjectDocuments D WHERE D.ProjectId=@ProjectId AND ISNULL(D.IsDeleted,0)=0),0) AS DocumentCount
    FROM dbo.Projects P
    WHERE P.ProjectId=@ProjectId AND ISNULL(P.IsDeleted,0)=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Print_ProjectHeader
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.ProjectId,
        P.ProjectCode,
        P.ProjectName,
        P.ProjectNameEn,
        ISNULL(C.ClientName, N'-') AS ClientName,
        ISNULL(PT.NameAr, N'-') AS ProjectTypeNameAr,
        ISNULL(ST.NameAr, N'-') AS StructureTypeNameAr,
        ISNULL(IST.NameAr, N'-') AS InvestigationStageNameAr,
        P.Country,
        P.City,
        P.District,
        P.LocationName,
        P.Address,
        P.SiteAreaM2,
        P.NumberOfFloors,
        P.BasementCount,
        CONCAT(ISNULL(CONVERT(NVARCHAR(30), P.NumberOfFloors), N'-'), N' / ', ISNULL(CONVERT(NVARCHAR(30), P.BasementCount), N'-')) AS FloorsBasements,
        P.ProjectStartDate,
        P.ProjectEndDate,
        P.ScopeOfWork,
        P.GeneralNotes
    FROM dbo.Projects P
    LEFT JOIN dbo.Clients C ON C.ClientId=P.ClientId
    LEFT JOIN dbo.LookupItems PT ON PT.LookupItemId=P.ProjectTypeId
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId=P.StructureTypeId
    LEFT JOIN dbo.LookupItems IST ON IST.LookupItemId=P.InvestigationStageId
    WHERE P.ProjectId=@ProjectId AND ISNULL(P.IsDeleted,0)=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Print_Boreholes_Index
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        B.ProjectId,
        B.BoreholeId,
        B.BoreholeCode,
        B.PlannedDepthM,
        B.ActualDepthM,
        B.Easting,
        B.Northing,
        B.ElevationM,
        DM.NameAr AS DrillingMethod,
        B.StartDate,
        B.EndDate,
        B.GroundwaterDepthM,
        B.FieldEngineer,
        B.LocationDescription,
        B.TerminationReason,
        (SELECT COUNT(1) FROM dbo.BoreholeLayers L WHERE L.BoreholeId=B.BoreholeId AND ISNULL(L.IsDeleted,0)=0) AS LayerCount,
        (SELECT COUNT(1) FROM dbo.Samples S WHERE S.BoreholeId=B.BoreholeId AND ISNULL(S.IsDeleted,0)=0) AS SampleCount,
        (SELECT COUNT(1) FROM dbo.SPTTests SPT WHERE SPT.BoreholeId=B.BoreholeId AND ISNULL(SPT.IsDeleted,0)=0) AS SPTCount
    FROM dbo.Boreholes B
    LEFT JOIN dbo.LookupItems DM ON DM.LookupItemId=B.DrillingMethodId
    WHERE B.ProjectId=@ProjectId AND ISNULL(B.IsDeleted,0)=0
    ORDER BY B.BoreholeCode, B.BoreholeId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Print_Borehole_Header
    @ProjectId BIGINT,
    @BoreholeId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.ProjectCode,
        P.ProjectName,
        ISNULL(C.ClientName, N'-') AS ClientName,
        B.ProjectId,
        B.BoreholeId,
        B.BoreholeCode,
        B.PlannedDepthM,
        B.ActualDepthM,
        B.Easting,
        B.Northing,
        B.ElevationM,
        DM.NameAr AS DrillingMethod,
        ST.NameAr AS BoreholeStatus,
        B.StartDate,
        B.EndDate,
        B.GroundwaterDepthM,
        B.LocationDescription,
        B.FieldEngineer,
        B.TerminationReason,
        B.Notes
    FROM dbo.Boreholes B
    INNER JOIN dbo.Projects P ON P.ProjectId=B.ProjectId
    LEFT JOIN dbo.Clients C ON C.ClientId=P.ClientId
    LEFT JOIN dbo.LookupItems DM ON DM.LookupItemId=B.DrillingMethodId
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId=B.BoreholeStatusId
    WHERE B.ProjectId=@ProjectId AND B.BoreholeId=@BoreholeId AND ISNULL(B.IsDeleted,0)=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Print_Borehole_Layers
    @BoreholeId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        L.FromDepthM,
        L.ToDepthM,
        SRT.NameAr AS SoilRockType,
        L.USCS,
        L.Description,
        L.Color,
        L.ConsistencyDensity,
        L.MoistureCondition,
        L.RecoveryPercent,
        L.RQDPercent,
        L.Notes
    FROM dbo.BoreholeLayers L
    LEFT JOIN dbo.LookupItems SRT ON SRT.LookupItemId=L.SoilRockTypeId
    WHERE L.BoreholeId=@BoreholeId AND ISNULL(L.IsDeleted,0)=0
    ORDER BY L.FromDepthM, L.ToDepthM, L.LayerId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Print_Borehole_Samples
    @BoreholeId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        S.SampleCode,
        S.FromDepthM,
        S.ToDepthM,
        ST.NameAr AS SampleType,
        SQ.NameAr AS SampleQuality,
        S.RecoveryLengthM,
        S.Description,
        S.TakenDate,
        S.RequiredTests,
        S.StorageLocation,
        S.Notes
    FROM dbo.Samples S
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId=S.SampleTypeId
    LEFT JOIN dbo.LookupItems SQ ON SQ.LookupItemId=S.SampleQualityId
    WHERE S.BoreholeId=@BoreholeId AND ISNULL(S.IsDeleted,0)=0
    ORDER BY S.FromDepthM, S.ToDepthM, S.SampleCode;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Print_Borehole_SPT
    @BoreholeId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        SPT.TestDepthM,
        SPT.BlowCount1,
        SPT.BlowCount2,
        SPT.BlowCount3,
        ISNULL(SPT.NValue, ISNULL(SPT.BlowCount2,0)+ISNULL(SPT.BlowCount3,0)) AS NValue,
        SPT.HammerEnergyRatio,
        SPT.CorrectedN,
        SPT.RecoveryLengthM,
        SPT.TestDate,
        SPT.Notes
    FROM dbo.SPTTests SPT
    WHERE SPT.BoreholeId=@BoreholeId AND ISNULL(SPT.IsDeleted,0)=0
    ORDER BY SPT.TestDepthM, SPT.SPTTestId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Print_Borehole_Groundwater
    @BoreholeId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        GW.ObservationDate,
        GW.DepthToWaterM,
        OT.NameAr AS ObservationType,
        GW.CasingDepthM,
        GW.StabilizedAfterHours,
        GW.Notes
    FROM dbo.GroundwaterObservations GW
    LEFT JOIN dbo.LookupItems OT ON OT.LookupItemId=GW.ObservationTypeId
    WHERE GW.BoreholeId=@BoreholeId AND ISNULL(GW.IsDeleted,0)=0
    ORDER BY GW.ObservationDate, GW.GroundwaterObservationId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Print_ProjectSamples
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        B.BoreholeCode,
        S.SampleCode,
        S.FromDepthM,
        S.ToDepthM,
        ST.NameAr AS SampleType,
        SQ.NameAr AS SampleQuality,
        S.RecoveryLengthM,
        S.TakenDate,
        S.RequiredTests,
        S.StorageLocation,
        S.Description
    FROM dbo.Samples S
    INNER JOIN dbo.Boreholes B ON B.BoreholeId=S.BoreholeId
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId=S.SampleTypeId
    LEFT JOIN dbo.LookupItems SQ ON SQ.LookupItemId=S.SampleQualityId
    WHERE S.ProjectId=@ProjectId AND ISNULL(S.IsDeleted,0)=0
    ORDER BY B.BoreholeCode, S.FromDepthM, S.SampleCode;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Print_ProjectSPT
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        B.BoreholeCode,
        SPT.TestDepthM,
        SPT.BlowCount1,
        SPT.BlowCount2,
        SPT.BlowCount3,
        ISNULL(SPT.NValue, ISNULL(SPT.BlowCount2,0)+ISNULL(SPT.BlowCount3,0)) AS NValue,
        SPT.CorrectedN,
        SPT.RecoveryLengthM,
        SPT.TestDate,
        SPT.Notes
    FROM dbo.SPTTests SPT
    INNER JOIN dbo.Boreholes B ON B.BoreholeId=SPT.BoreholeId
    WHERE SPT.ProjectId=@ProjectId AND ISNULL(SPT.IsDeleted,0)=0
    ORDER BY B.BoreholeCode, SPT.TestDepthM;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Print_ProjectGroundwater
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        B.BoreholeCode,
        GW.ObservationDate,
        GW.DepthToWaterM,
        OT.NameAr AS ObservationType,
        GW.CasingDepthM,
        GW.StabilizedAfterHours,
        GW.Notes
    FROM dbo.GroundwaterObservations GW
    INNER JOIN dbo.Boreholes B ON B.BoreholeId=GW.BoreholeId
    LEFT JOIN dbo.LookupItems OT ON OT.LookupItemId=GW.ObservationTypeId
    WHERE GW.ProjectId=@ProjectId AND ISNULL(GW.IsDeleted,0)=0
    ORDER BY B.BoreholeCode, GW.ObservationDate;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Print_ProjectLabResults
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        B.BoreholeCode,
        S.SampleCode,
        LTT.NameAr AS LabTestType,
        LR.TestCode,
        LR.TestStandard,
        LR.TestDate,
        RS.NameAr AS ResultStatus,
        LR.NumericValue,
        LR.Unit,
        LR.ResultValue,
        LR.Technician,
        LR.ReviewedBy,
        CASE WHEN LR.IsApproved=1 THEN N'Approved' ELSE N'Not approved' END AS IsApprovedText,
        LR.Remarks
    FROM dbo.LabTestResults LR
    INNER JOIN dbo.Boreholes B ON B.BoreholeId=LR.BoreholeId
    INNER JOIN dbo.Samples S ON S.SampleId=LR.SampleId
    LEFT JOIN dbo.LookupItems LTT ON LTT.LookupItemId=LR.LabTestTypeId
    LEFT JOIN dbo.LookupItems RS ON RS.LookupItemId=LR.ResultStatusId
    WHERE LR.ProjectId=@ProjectId AND ISNULL(LR.IsDeleted,0)=0
    ORDER BY B.BoreholeCode, S.FromDepthM, S.SampleCode, LTT.SortOrder;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Print_ProjectReports
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        R.ReportNo,
        R.ReportTitle,
        RT.NameAr AS ReportType,
        RS.NameAr AS ReportStatus,
        R.RevisionNo,
        R.IssueDate,
        R.PreparedBy,
        R.ReviewedBy,
        R.ApprovedBy,
        R.ApprovedAt
    FROM dbo.TechnicalReports R
    LEFT JOIN dbo.LookupItems RT ON RT.LookupItemId=R.ReportTypeId
    LEFT JOIN dbo.LookupItems RS ON RS.LookupItemId=R.ReportStatusId
    WHERE R.ProjectId=@ProjectId AND ISNULL(R.IsDeleted,0)=0
    ORDER BY R.IssueDate DESC, R.ReportId DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_PrintJob_Save
    @ProjectId BIGINT,
    @BoreholeId BIGINT = NULL,
    @TemplateCode NVARCHAR(100),
    @OutputTitle NVARCHAR(300),
    @PrintedBy BIGINT = NULL,
    @Notes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.PrintJobs(ProjectId, BoreholeId, TemplateCode, OutputTitle, OutputFormat, PrintedBy, PrintedAt, Status, Notes)
    VALUES(@ProjectId, @BoreholeId, @TemplateCode, @OutputTitle, N'BrowserPrint', @PrintedBy, SYSDATETIME(), N'Generated', @Notes);

    INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription, NewValues)
    SELECT @PrintedBy, U.Username, N'Print', N'PrintJobs', CONVERT(NVARCHAR(100), SCOPE_IDENTITY()),
           N'تم توليد مخرج طباعة من النظام.',
           CONCAT(N'Template=', @TemplateCode, N'; ProjectId=', @ProjectId, N'; BoreholeId=', ISNULL(CONVERT(NVARCHAR(30), @BoreholeId), N'-'))
    FROM dbo.Users U WHERE U.UserId=@PrintedBy;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_PrintJobs_Get
    @ProjectId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 200
        PJ.PrintJobId,
        PJ.ProjectId,
        P.ProjectCode,
        P.ProjectName,
        B.BoreholeCode,
        PJ.TemplateCode,
        PJ.OutputTitle,
        PJ.OutputFormat,
        U.FullName AS PrintedByName,
        PJ.PrintedAt,
        PJ.Status,
        PJ.Notes
    FROM dbo.PrintJobs PJ
    INNER JOIN dbo.Projects P ON P.ProjectId=PJ.ProjectId
    LEFT JOIN dbo.Boreholes B ON B.BoreholeId=PJ.BoreholeId
    LEFT JOIN dbo.Users U ON U.UserId=PJ.PrintedBy
    WHERE ISNULL(PJ.IsDeleted,0)=0 AND (@ProjectId IS NULL OR PJ.ProjectId=@ProjectId)
    ORDER BY PJ.PrintedAt DESC, PJ.PrintJobId DESC;
END
GO

PRINT N'Sprint 11 print stored procedures created successfully.';
GO
