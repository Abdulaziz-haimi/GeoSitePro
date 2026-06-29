USE GeoSitePro;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Reports_Get
    @ProjectId BIGINT = NULL,
    @SearchText NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @SearchText = NULLIF(LTRIM(RTRIM(@SearchText)), N'');

    SELECT
        R.ReportId, R.ProjectId, R.ReportNo, R.ReportTitle, R.ReportTypeId, R.ReportStatusId,
        R.IssueDate, R.RevisionNo, R.PreparedBy, R.ReviewedBy, R.ApprovedBy, R.ApprovedAt,
        P.ProjectCode, P.ProjectName, ISNULL(C.ClientName, N'') AS ClientName,
        RT.NameAr AS ReportTypeNameAr, RT.NameEn AS ReportTypeNameEn,
        RS.NameAr AS ReportStatusNameAr, RS.NameEn AS ReportStatusNameEn,
        (SELECT COUNT(1) FROM dbo.TechnicalReportSections S WHERE S.ReportId = R.ReportId AND S.IsDeleted = 0) AS SectionCount
    FROM dbo.TechnicalReports R
    INNER JOIN dbo.Projects P ON P.ProjectId = R.ProjectId AND P.IsDeleted = 0
    LEFT JOIN dbo.Clients C ON C.ClientId = P.ClientId AND C.IsDeleted = 0
    LEFT JOIN dbo.LookupItems RT ON RT.LookupItemId = R.ReportTypeId AND RT.IsDeleted = 0
    LEFT JOIN dbo.LookupItems RS ON RS.LookupItemId = R.ReportStatusId AND RS.IsDeleted = 0
    WHERE R.IsDeleted = 0
      AND (@ProjectId IS NULL OR R.ProjectId = @ProjectId)
      AND (
          @SearchText IS NULL
          OR R.ReportNo LIKE N'%' + @SearchText + N'%'
          OR R.ReportTitle LIKE N'%' + @SearchText + N'%'
          OR R.PreparedBy LIKE N'%' + @SearchText + N'%'
          OR R.ReviewedBy LIKE N'%' + @SearchText + N'%'
          OR R.ApprovedBy LIKE N'%' + @SearchText + N'%'
          OR P.ProjectCode LIKE N'%' + @SearchText + N'%'
          OR P.ProjectName LIKE N'%' + @SearchText + N'%'
          OR C.ClientName LIKE N'%' + @SearchText + N'%'
      )
    ORDER BY R.CreatedAt DESC, R.ReportId DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Report_GetById
    @ReportId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT R.*, P.ProjectCode, P.ProjectName, ISNULL(C.ClientName, N'') AS ClientName,
           RT.NameAr AS ReportTypeNameAr, RS.NameAr AS ReportStatusNameAr
    FROM dbo.TechnicalReports R
    INNER JOIN dbo.Projects P ON P.ProjectId = R.ProjectId AND P.IsDeleted = 0
    LEFT JOIN dbo.Clients C ON C.ClientId = P.ClientId AND C.IsDeleted = 0
    LEFT JOIN dbo.LookupItems RT ON RT.LookupItemId = R.ReportTypeId AND RT.IsDeleted = 0
    LEFT JOIN dbo.LookupItems RS ON RS.LookupItemId = R.ReportStatusId AND RS.IsDeleted = 0
    WHERE R.ReportId = @ReportId AND R.IsDeleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Report_Save
    @ReportId BIGINT = NULL,
    @ProjectId BIGINT,
    @ReportNo NVARCHAR(80) = NULL,
    @ReportTitle NVARCHAR(300),
    @ReportTypeId BIGINT = NULL,
    @ReportStatusId BIGINT = NULL,
    @IssueDate DATE = NULL,
    @RevisionNo NVARCHAR(50) = NULL,
    @PreparedBy NVARCHAR(200) = NULL,
    @ReviewedBy NVARCHAR(200) = NULL,
    @ApprovedBy NVARCHAR(200) = NULL,
    @ExecutiveSummary NVARCHAR(MAX) = NULL,
    @Recommendations NVARCHAR(MAX) = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS(SELECT 1 FROM dbo.Projects WHERE ProjectId = @ProjectId AND IsDeleted = 0) THROW 54001, N'Project does not exist.', 1;
    SET @ReportNo = NULLIF(LTRIM(RTRIM(@ReportNo)), N'');
    SET @ReportTitle = NULLIF(LTRIM(RTRIM(@ReportTitle)), N'');
    IF @ReportTitle IS NULL THROW 54002, N'Report title is required.', 1;

    IF @ReportTypeId IS NULL
        SELECT TOP 1 @ReportTypeId = LI.LookupItemId FROM dbo.LookupItems LI INNER JOIN dbo.LookupCategories LC ON LC.LookupCategoryId = LI.LookupCategoryId WHERE LC.CategoryCode=N'ReportType' AND LI.ItemCode=N'GEOTECHNICAL_INVESTIGATION' AND LI.IsDeleted=0;
    IF @ReportStatusId IS NULL
        SELECT TOP 1 @ReportStatusId = LI.LookupItemId FROM dbo.LookupItems LI INNER JOIN dbo.LookupCategories LC ON LC.LookupCategoryId = LI.LookupCategoryId WHERE LC.CategoryCode=N'ReportStatus' AND LI.ItemCode=N'DRAFT' AND LI.IsDeleted=0;

    IF @ReportId IS NULL OR @ReportId = 0
    BEGIN
        INSERT INTO dbo.TechnicalReports
        (ProjectId, ReportNo, ReportTitle, ReportTypeId, ReportStatusId, IssueDate, RevisionNo, LanguageCode,
         ExecutiveSummary, Recommendations, PreparedBy, ReviewedBy, ApprovedBy, CreatedBy)
        VALUES
        (@ProjectId, @ReportNo, @ReportTitle, @ReportTypeId, @ReportStatusId, @IssueDate, ISNULL(NULLIF(@RevisionNo,N''), N'Rev.0'), N'ar',
         @ExecutiveSummary, @Recommendations, @PreparedBy, @ReviewedBy, @ApprovedBy, @UserId);

        SET @ReportId = SCOPE_IDENTITY();
        IF @ReportNo IS NULL
        BEGIN
            UPDATE dbo.TechnicalReports
            SET ReportNo = N'RPT-' + RIGHT(N'00000' + CONVERT(NVARCHAR(20), @ReportId), 5)
            WHERE ReportId = @ReportId;
        END
    END
    ELSE
    BEGIN
        UPDATE dbo.TechnicalReports
        SET ProjectId = @ProjectId,
            ReportNo = COALESCE(@ReportNo, ReportNo),
            ReportTitle = @ReportTitle,
            ReportTypeId = @ReportTypeId,
            ReportStatusId = @ReportStatusId,
            IssueDate = @IssueDate,
            RevisionNo = ISNULL(NULLIF(@RevisionNo,N''), RevisionNo),
            ExecutiveSummary = @ExecutiveSummary,
            Recommendations = @Recommendations,
            PreparedBy = @PreparedBy,
            ReviewedBy = @ReviewedBy,
            ApprovedBy = @ApprovedBy,
            UpdatedAt = SYSDATETIME(),
            UpdatedBy = @UserId
        WHERE ReportId = @ReportId AND IsDeleted = 0;
    END

    SELECT @ReportId AS ReportId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Report_Delete
    @ReportId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.TechnicalReports SET IsDeleted = 1, DeletedAt = SYSDATETIME(), DeletedBy = @UserId WHERE ReportId = @ReportId AND IsDeleted = 0;
    UPDATE dbo.TechnicalReportSections SET IsDeleted = 1, DeletedAt = SYSDATETIME(), DeletedBy = @UserId WHERE ReportId = @ReportId AND IsDeleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Report_Approve
    @ReportId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ApprovedStatusId BIGINT = (SELECT TOP 1 LI.LookupItemId FROM dbo.LookupItems LI INNER JOIN dbo.LookupCategories LC ON LC.LookupCategoryId = LI.LookupCategoryId WHERE LC.CategoryCode=N'ReportStatus' AND LI.ItemCode=N'APPROVED' AND LI.IsDeleted=0);
    UPDATE dbo.TechnicalReports
    SET ReportStatusId = COALESCE(@ApprovedStatusId, ReportStatusId), ApprovedAt = SYSDATETIME(), UpdatedAt = SYSDATETIME(), UpdatedBy = @UserId
    WHERE ReportId = @ReportId AND IsDeleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ReportSections_Get
    @ReportId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT S.*, ST.NameAr AS SectionTypeNameAr, ST.NameEn AS SectionTypeNameEn
    FROM dbo.TechnicalReportSections S
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId = S.SectionTypeId AND ST.IsDeleted = 0
    WHERE S.ReportId = @ReportId AND S.IsDeleted = 0
    ORDER BY S.SortOrder, S.ReportSectionId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ReportSection_GetById
    @ReportSectionId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT S.*, ST.NameAr AS SectionTypeNameAr
    FROM dbo.TechnicalReportSections S
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId = S.SectionTypeId AND ST.IsDeleted = 0
    WHERE S.ReportSectionId = @ReportSectionId AND S.IsDeleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ReportSection_Save
    @ReportSectionId BIGINT = NULL,
    @ReportId BIGINT,
    @SectionTypeId BIGINT = NULL,
    @SectionTitle NVARCHAR(300),
    @SectionContent NVARCHAR(MAX) = NULL,
    @SortOrder INT = NULL,
    @IsIncluded BIT = 1,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS(SELECT 1 FROM dbo.TechnicalReports WHERE ReportId=@ReportId AND IsDeleted=0) THROW 54010, N'Report does not exist.', 1;
    SET @SectionTitle = NULLIF(LTRIM(RTRIM(@SectionTitle)), N'');
    IF @SectionTitle IS NULL THROW 54011, N'Section title is required.', 1;

    IF @ReportSectionId IS NULL OR @ReportSectionId = 0
    BEGIN
        IF @SortOrder IS NULL SELECT @SortOrder = ISNULL(MAX(SortOrder),0) + 10 FROM dbo.TechnicalReportSections WHERE ReportId=@ReportId AND IsDeleted=0;
        INSERT INTO dbo.TechnicalReportSections(ReportId, SectionTypeId, SectionTitle, SectionContent, SortOrder, IsIncluded, CreatedBy)
        VALUES(@ReportId, @SectionTypeId, @SectionTitle, @SectionContent, @SortOrder, @IsIncluded, @UserId);
        SET @ReportSectionId = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.TechnicalReportSections
        SET SectionTypeId=@SectionTypeId, SectionTitle=@SectionTitle, SectionContent=@SectionContent,
            SortOrder=ISNULL(@SortOrder, SortOrder), IsIncluded=@IsIncluded, UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId
        WHERE ReportSectionId=@ReportSectionId AND ReportId=@ReportId AND IsDeleted=0;
    END
    SELECT @ReportSectionId AS ReportSectionId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ReportSection_Delete
    @ReportSectionId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.TechnicalReportSections SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE ReportSectionId=@ReportSectionId AND IsDeleted=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Report_GenerateDefaultSections
    @ReportId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProjectId BIGINT, @ExecutiveSummary NVARCHAR(MAX), @Recommendations NVARCHAR(MAX);
    SELECT @ProjectId = ProjectId, @ExecutiveSummary = ExecutiveSummary, @Recommendations = Recommendations FROM dbo.TechnicalReports WHERE ReportId=@ReportId AND IsDeleted=0;
    IF @ProjectId IS NULL THROW 54020, N'Report does not exist.', 1;

    DECLARE @BHCount INT = (SELECT COUNT(1) FROM dbo.Boreholes WHERE ProjectId=@ProjectId AND IsDeleted=0);
    DECLARE @SampleCount INT = (SELECT COUNT(1) FROM dbo.Samples WHERE ProjectId=@ProjectId AND IsDeleted=0);
    DECLARE @SPTCount INT = (SELECT COUNT(1) FROM dbo.SPTTests WHERE ProjectId=@ProjectId AND IsDeleted=0);
    DECLARE @GWCount INT = (SELECT COUNT(1) FROM dbo.GroundwaterObservations WHERE ProjectId=@ProjectId AND IsDeleted=0);
    DECLARE @LabCount INT = (SELECT COUNT(1) FROM dbo.LabTestResults WHERE ProjectId=@ProjectId AND IsDeleted=0);
    DECLARE @MaxDepth DECIMAL(10,2) = (SELECT MAX(ActualDepthM) FROM dbo.Boreholes WHERE ProjectId=@ProjectId AND IsDeleted=0);

    DECLARE @ProjectInfo NVARCHAR(MAX);
    SELECT TOP 1 @ProjectInfo =
        N'Project Code: ' + ISNULL(P.ProjectCode,N'') + CHAR(13)+CHAR(10) +
        N'Project Name: ' + ISNULL(P.ProjectName,N'') + CHAR(13)+CHAR(10) +
        N'Client: ' + ISNULL(C.ClientName,N'') + CHAR(13)+CHAR(10) +
        N'City: ' + ISNULL(P.City,N'') + CHAR(13)+CHAR(10) +
        N'Location: ' + ISNULL(P.LocationName,N'') + CHAR(13)+CHAR(10) +
        N'Site Area: ' + ISNULL(CONVERT(NVARCHAR(50), P.SiteAreaM2),N'') + N' m²' + CHAR(13)+CHAR(10) +
        N'Floors / Basements: ' + ISNULL(CONVERT(NVARCHAR(20), P.NumberOfFloors),N'') + N' / ' + ISNULL(CONVERT(NVARCHAR(20), P.BasementCount),N'') + CHAR(13)+CHAR(10) +
        N'Scope of Work: ' + ISNULL(P.ScopeOfWork,N'')
    FROM dbo.Projects P LEFT JOIN dbo.Clients C ON C.ClientId=P.ClientId AND C.IsDeleted=0
    WHERE P.ProjectId=@ProjectId AND P.IsDeleted=0;

    DECLARE @FieldSummary NVARCHAR(MAX) =
        N'The field investigation record currently includes:' + CHAR(13)+CHAR(10) +
        N'- Boreholes: ' + CONVERT(NVARCHAR(20), @BHCount) + CHAR(13)+CHAR(10) +
        N'- Samples: ' + CONVERT(NVARCHAR(20), @SampleCount) + CHAR(13)+CHAR(10) +
        N'- SPT tests: ' + CONVERT(NVARCHAR(20), @SPTCount) + CHAR(13)+CHAR(10) +
        N'- Groundwater observations: ' + CONVERT(NVARCHAR(20), @GWCount) + CHAR(13)+CHAR(10) +
        N'- Maximum recorded borehole depth: ' + ISNULL(CONVERT(NVARCHAR(50), @MaxDepth), N'N/A') + N' m.';

    DECLARE @SPTSummary NVARCHAR(MAX) =
        N'This section summarizes Standard Penetration Test results recorded in the system. Review the detailed table in the printed appendix and interpret N-values according to soil type, depth, groundwater condition, overburden correction, and project design requirements.';

    DECLARE @GWSummary NVARCHAR(MAX) =
        N'Groundwater conditions are summarized from field observations. Seasonal variation, tidal/coastal influence, nearby pumping, and delayed water level stabilization should be considered before final design recommendations.';

    DECLARE @LabSummary NVARCHAR(MAX) =
        N'The laboratory database currently includes ' + CONVERT(NVARCHAR(20), @LabCount) + N' recorded test result(s). Review all test standards, sample IDs, and approval status before issuing the final report.';

    DECLARE @Appendices NVARCHAR(MAX) =
        N'Appendices may include borehole logs, laboratory sheets, SPT records, groundwater readings, site photographs, location plan, coordinates, and calculation notes.';

    DECLARE @Sections TABLE(SectionCode NVARCHAR(100), SectionTypeCode NVARCHAR(100), SectionTitle NVARCHAR(300), SectionContent NVARCHAR(MAX), SortOrder INT);
    INSERT INTO @Sections VALUES
    (N'EXECUTIVE_SUMMARY', N'EXECUTIVE_SUMMARY', N'Executive Summary / الملخص التنفيذي', ISNULL(NULLIF(@ExecutiveSummary,N''), N'This report presents the available geotechnical investigation data recorded in GeoSite Pro. The content should be reviewed and completed by the responsible geotechnical engineer.'), 10),
    (N'PROJECT_INFO', N'PROJECT_INFO', N'Project Information / بيانات المشروع', @ProjectInfo, 20),
    (N'FIELD_INVESTIGATION', N'FIELD_INVESTIGATION', N'Field Investigation / التحريات الحقلية', @FieldSummary, 30),
    (N'BOREHOLE_LOGS', N'BOREHOLE_LOGS', N'Borehole Logs / سجلات الجسات', N'Borehole logs and strata descriptions are listed in the report tables. Verify lithology, depths, sample intervals, groundwater observations, and termination reasons.', 40),
    (N'SPT_SUMMARY', N'SPT_SUMMARY', N'SPT Summary / ملخص اختبارات SPT', @SPTSummary, 50),
    (N'GROUNDWATER', N'GROUNDWATER', N'Groundwater Conditions / المياه الجوفية', @GWSummary, 60),
    (N'LAB_RESULTS', N'LAB_RESULTS', N'Laboratory Test Results / النتائج المعملية', @LabSummary, 70),
    (N'RECOMMENDATIONS', N'RECOMMENDATIONS', N'Engineering Recommendations / التوصيات الهندسية', ISNULL(NULLIF(@Recommendations,N''), N'Add bearing capacity, foundation type, excavation support, dewatering, compaction, and ground improvement recommendations after engineering review.'), 80),
    (N'APPENDICES', N'APPENDICES', N'Appendices / الملاحق', @Appendices, 90);

    INSERT INTO dbo.TechnicalReportSections(ReportId, SectionTypeId, SectionCode, SectionTitle, SectionContent, SortOrder, IsIncluded, CreatedBy)
    SELECT @ReportId,
           (SELECT TOP 1 LI.LookupItemId FROM dbo.LookupItems LI INNER JOIN dbo.LookupCategories LC ON LC.LookupCategoryId=LI.LookupCategoryId WHERE LC.CategoryCode=N'ReportSectionType' AND LI.ItemCode=S.SectionTypeCode AND LI.IsDeleted=0),
           S.SectionCode, S.SectionTitle, S.SectionContent, S.SortOrder, 1, @UserId
    FROM @Sections S
    WHERE NOT EXISTS(SELECT 1 FROM dbo.TechnicalReportSections T WHERE T.ReportId=@ReportId AND T.SectionCode=S.SectionCode AND T.IsDeleted=0);
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Report_GetFullData
    @ReportId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProjectId BIGINT;
    SELECT @ProjectId = ProjectId FROM dbo.TechnicalReports WHERE ReportId=@ReportId AND IsDeleted=0;

    SELECT R.*, P.ProjectCode, P.ProjectName, P.City, P.LocationName, P.SiteAreaM2, P.NumberOfFloors, P.BasementCount,
           ISNULL(C.ClientName,N'') AS ClientName,
           RT.NameAr AS ReportTypeNameAr, RS.NameAr AS ReportStatusNameAr
    FROM dbo.TechnicalReports R
    INNER JOIN dbo.Projects P ON P.ProjectId = R.ProjectId AND P.IsDeleted = 0
    LEFT JOIN dbo.Clients C ON C.ClientId = P.ClientId AND C.IsDeleted = 0
    LEFT JOIN dbo.LookupItems RT ON RT.LookupItemId = R.ReportTypeId AND RT.IsDeleted = 0
    LEFT JOIN dbo.LookupItems RS ON RS.LookupItemId = R.ReportStatusId AND RS.IsDeleted = 0
    WHERE R.ReportId = @ReportId AND R.IsDeleted = 0;

    SELECT S.ReportSectionId, S.SectionTitle, S.SectionContent, S.SortOrder, ST.NameAr AS SectionTypeNameAr
    FROM dbo.TechnicalReportSections S
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId = S.SectionTypeId AND ST.IsDeleted = 0
    WHERE S.ReportId = @ReportId AND S.IsDeleted = 0 AND S.IsIncluded = 1
    ORDER BY S.SortOrder, S.ReportSectionId;

    SELECT B.BoreholeId, B.BoreholeCode, B.PlannedDepthM, B.ActualDepthM, B.GroundwaterDepthM, B.FieldEngineer, B.LocationDescription, BS.NameAr AS BoreholeStatusNameAr
    FROM dbo.Boreholes B
    LEFT JOIN dbo.LookupItems BS ON BS.LookupItemId = B.BoreholeStatusId AND BS.IsDeleted = 0
    WHERE B.ProjectId = @ProjectId AND B.IsDeleted = 0
    ORDER BY B.BoreholeCode;

    SELECT B.BoreholeCode, L.FromDepthM AS DepthFromM, L.ToDepthM AS DepthToM, L.Description AS SoilDescription, L.USCS, L.Color AS StratumCode, L.Notes AS Remarks
    FROM dbo.BoreholeLayers L
    INNER JOIN dbo.Boreholes B ON B.BoreholeId = L.BoreholeId AND B.IsDeleted = 0
    WHERE B.ProjectId = @ProjectId AND L.IsDeleted = 0
    ORDER BY B.BoreholeCode, L.FromDepthM;

    SELECT B.BoreholeCode, S.TestDepthM, S.BlowCount1 AS N1, S.BlowCount2 AS N2, S.BlowCount3 AS N3, S.NValue, S.Notes AS Remarks
    FROM dbo.SPTTests S
    INNER JOIN dbo.Boreholes B ON B.BoreholeId = S.BoreholeId AND B.IsDeleted = 0
    WHERE S.ProjectId = @ProjectId AND S.IsDeleted = 0
    ORDER BY B.BoreholeCode, S.TestDepthM;

    SELECT B.BoreholeCode, G.ObservationDate, G.DepthToWaterM, G.Notes AS Remarks
    FROM dbo.GroundwaterObservations G
    INNER JOIN dbo.Boreholes B ON B.BoreholeId = G.BoreholeId AND B.IsDeleted = 0
    WHERE G.ProjectId = @ProjectId AND G.IsDeleted = 0
    ORDER BY B.BoreholeCode, G.ObservationDate;

    SELECT S.SampleCode, B.BoreholeCode, S.FromDepthM AS DepthFromM, S.ToDepthM AS DepthToM, ST.NameAr AS SampleTypeNameAr, S.Description AS VisualDescription, S.Notes AS Remarks
    FROM dbo.Samples S
    INNER JOIN dbo.Boreholes B ON B.BoreholeId = S.BoreholeId AND B.IsDeleted = 0
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId = S.SampleTypeId AND ST.IsDeleted = 0
    WHERE S.ProjectId = @ProjectId AND S.IsDeleted = 0
    ORDER BY B.BoreholeCode, S.FromDepthM;

    SELECT L.TestCode, S.SampleCode, B.BoreholeCode, LTT.NameAr AS LabTestTypeNameAr, L.TestStandard, L.NumericValue, L.Unit, L.ResultValue, L.IsApproved
    FROM dbo.LabTestResults L
    INNER JOIN dbo.Samples S ON S.SampleId = L.SampleId AND S.IsDeleted = 0
    INNER JOIN dbo.Boreholes B ON B.BoreholeId = L.BoreholeId AND B.IsDeleted = 0
    LEFT JOIN dbo.LookupItems LTT ON LTT.LookupItemId = L.LabTestTypeId AND LTT.IsDeleted = 0
    WHERE L.ProjectId = @ProjectId AND L.IsDeleted = 0
    ORDER BY B.BoreholeCode, S.SampleCode, L.TestDate, L.LabTestResultId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProjectDashboard_Get
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT P.*, C.ClientName, PT.NameAr AS ProjectTypeNameAr, ST.NameAr AS ProjectStatusNameAr, STR.NameAr AS StructureTypeNameAr
    FROM dbo.Projects P
    LEFT JOIN dbo.Clients C ON C.ClientId = P.ClientId AND C.IsDeleted = 0
    LEFT JOIN dbo.LookupItems PT ON PT.LookupItemId = P.ProjectTypeId AND PT.IsDeleted = 0
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId = P.ProjectStatusId AND ST.IsDeleted = 0
    LEFT JOIN dbo.LookupItems STR ON STR.LookupItemId = P.StructureTypeId AND STR.IsDeleted = 0
    WHERE P.ProjectId = @ProjectId AND P.IsDeleted = 0;

    SELECT
        0 AS BoreholePlanCount,
        (SELECT COUNT(1) FROM dbo.Boreholes WHERE ProjectId = @ProjectId AND IsDeleted = 0) AS BoreholeCount,
        (SELECT COUNT(1) FROM dbo.Samples WHERE ProjectId = @ProjectId AND IsDeleted = 0) AS SampleCount,
        (SELECT COUNT(1) FROM dbo.LabTestResults WHERE ProjectId = @ProjectId AND IsDeleted = 0) AS LabTestCount,
        (SELECT COUNT(1) FROM dbo.TechnicalReports WHERE ProjectId = @ProjectId AND IsDeleted = 0) AS ReportCount;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Dashboard_GetSummary
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        (SELECT COUNT(1) FROM dbo.Projects WHERE IsDeleted = 0) AS TotalProjects,
        (SELECT COUNT(1) FROM dbo.Projects WHERE IsDeleted = 0 AND IsActive = 1) AS ActiveProjects,
        (SELECT COUNT(1) FROM dbo.Boreholes WHERE IsDeleted = 0) AS TotalBoreholes,
        (SELECT COUNT(1) FROM dbo.LabTestResults WHERE IsDeleted = 0) AS TotalLabTests,
        (SELECT COUNT(1) FROM dbo.TechnicalReports WHERE IsDeleted = 0) AS TotalReports;

    SELECT TOP 10 P.ProjectId, P.ProjectCode, P.ProjectName, C.ClientName, ST.NameAr AS ProjectStatusNameAr, P.CreatedAt
    FROM dbo.Projects P
    LEFT JOIN dbo.Clients C ON C.ClientId = P.ClientId AND C.IsDeleted = 0
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId = P.ProjectStatusId AND ST.IsDeleted = 0
    WHERE P.IsDeleted = 0
    ORDER BY P.CreatedAt DESC, P.ProjectId DESC;

    SELECT ISNULL(ST.NameAr, N'غير محدد') AS ProjectStatusNameAr, COUNT(1) AS ProjectCount
    FROM dbo.Projects P
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId = P.ProjectStatusId AND ST.IsDeleted = 0
    WHERE P.IsDeleted = 0
    GROUP BY ISNULL(ST.NameAr, N'غير محدد')
    ORDER BY ProjectCount DESC;
END
GO

PRINT N'Sprint 4 stored procedures created successfully.';
GO
