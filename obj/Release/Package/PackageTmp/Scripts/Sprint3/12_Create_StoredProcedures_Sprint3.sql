USE GeoSitePro;
GO

CREATE OR ALTER PROCEDURE dbo.sp_LabResults_Get
    @ProjectId BIGINT = NULL,
    @BoreholeId BIGINT = NULL,
    @SampleId BIGINT = NULL,
    @SearchText NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @SearchText = NULLIF(LTRIM(RTRIM(@SearchText)), N'');

    SELECT
        L.LabTestResultId, L.ProjectId, L.BoreholeId, L.SampleId, L.LabTestTypeId, L.TestCode,
        L.TestStandard, L.TestDate, L.ResultStatusId, L.NumericValue, L.Unit, L.ResultValue,
        L.ResultText, L.Technician, L.ReviewedBy, L.IsApproved, L.ApprovedAt, L.Remarks,
        P.ProjectCode, P.ProjectName, B.BoreholeCode, S.SampleCode,
        LTT.NameAr AS LabTestTypeNameAr, LTT.NameEn AS LabTestTypeNameEn,
        RS.NameAr AS ResultStatusNameAr, RS.NameEn AS ResultStatusNameEn
    FROM dbo.LabTestResults L
    INNER JOIN dbo.Projects P ON P.ProjectId = L.ProjectId AND P.IsDeleted = 0
    INNER JOIN dbo.Boreholes B ON B.BoreholeId = L.BoreholeId AND B.IsDeleted = 0
    INNER JOIN dbo.Samples S ON S.SampleId = L.SampleId AND S.IsDeleted = 0
    LEFT JOIN dbo.LookupItems LTT ON LTT.LookupItemId = L.LabTestTypeId AND LTT.IsDeleted = 0
    LEFT JOIN dbo.LookupItems RS ON RS.LookupItemId = L.ResultStatusId AND RS.IsDeleted = 0
    WHERE L.IsDeleted = 0
      AND (@ProjectId IS NULL OR L.ProjectId = @ProjectId)
      AND (@BoreholeId IS NULL OR L.BoreholeId = @BoreholeId)
      AND (@SampleId IS NULL OR L.SampleId = @SampleId)
      AND (
          @SearchText IS NULL
          OR L.TestCode LIKE N'%' + @SearchText + N'%'
          OR L.TestStandard LIKE N'%' + @SearchText + N'%'
          OR L.ResultValue LIKE N'%' + @SearchText + N'%'
          OR L.ResultText LIKE N'%' + @SearchText + N'%'
          OR L.Technician LIKE N'%' + @SearchText + N'%'
          OR L.ReviewedBy LIKE N'%' + @SearchText + N'%'
          OR P.ProjectCode LIKE N'%' + @SearchText + N'%'
          OR P.ProjectName LIKE N'%' + @SearchText + N'%'
          OR B.BoreholeCode LIKE N'%' + @SearchText + N'%'
          OR S.SampleCode LIKE N'%' + @SearchText + N'%'
      )
    ORDER BY P.ProjectCode, B.BoreholeCode, S.SampleCode, L.TestDate DESC, L.LabTestResultId DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_LabResult_GetById
    @LabTestResultId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT L.*, P.ProjectCode, P.ProjectName, B.BoreholeCode, S.SampleCode,
           LTT.NameAr AS LabTestTypeNameAr, RS.NameAr AS ResultStatusNameAr
    FROM dbo.LabTestResults L
    INNER JOIN dbo.Projects P ON P.ProjectId = L.ProjectId AND P.IsDeleted = 0
    INNER JOIN dbo.Boreholes B ON B.BoreholeId = L.BoreholeId AND B.IsDeleted = 0
    INNER JOIN dbo.Samples S ON S.SampleId = L.SampleId AND S.IsDeleted = 0
    LEFT JOIN dbo.LookupItems LTT ON LTT.LookupItemId = L.LabTestTypeId AND LTT.IsDeleted = 0
    LEFT JOIN dbo.LookupItems RS ON RS.LookupItemId = L.ResultStatusId AND RS.IsDeleted = 0
    WHERE L.LabTestResultId = @LabTestResultId AND L.IsDeleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_LabResult_Save
    @LabTestResultId BIGINT = NULL,
    @ProjectId BIGINT,
    @BoreholeId BIGINT,
    @SampleId BIGINT,
    @LabTestTypeId BIGINT,
    @TestCode NVARCHAR(100) = NULL,
    @TestStandard NVARCHAR(150) = NULL,
    @TestDate DATE = NULL,
    @ResultStatusId BIGINT = NULL,
    @NumericValue DECIMAL(18,4) = NULL,
    @Unit NVARCHAR(50) = NULL,
    @ResultValue NVARCHAR(250) = NULL,
    @ResultText NVARCHAR(MAX) = NULL,
    @Technician NVARCHAR(200) = NULL,
    @ReviewedBy NVARCHAR(200) = NULL,
    @IsApproved BIT = 0,
    @Remarks NVARCHAR(MAX) = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS(SELECT 1 FROM dbo.Projects WHERE ProjectId = @ProjectId AND IsDeleted = 0) THROW 53001, N'Project does not exist.', 1;
    IF NOT EXISTS(SELECT 1 FROM dbo.Boreholes WHERE BoreholeId = @BoreholeId AND ProjectId = @ProjectId AND IsDeleted = 0) THROW 53002, N'Borehole does not belong to selected project.', 1;
    IF NOT EXISTS(SELECT 1 FROM dbo.Samples WHERE SampleId = @SampleId AND BoreholeId = @BoreholeId AND ProjectId = @ProjectId AND IsDeleted = 0) THROW 53003, N'Sample does not belong to selected borehole.', 1;

    IF @LabTestResultId IS NULL OR @LabTestResultId = 0
    BEGIN
        INSERT INTO dbo.LabTestResults
        (ProjectId, BoreholeId, SampleId, LabTestTypeId, TestCode, TestStandard, TestDate, ResultStatusId,
         NumericValue, Unit, ResultValue, ResultText, Technician, ReviewedBy, IsApproved, ApprovedAt, ApprovedBy,
         Remarks, CreatedBy)
        VALUES
        (@ProjectId, @BoreholeId, @SampleId, @LabTestTypeId, NULLIF(@TestCode,N''), NULLIF(@TestStandard,N''), @TestDate, @ResultStatusId,
         @NumericValue, NULLIF(@Unit,N''), NULLIF(@ResultValue,N''), NULLIF(@ResultText,N''), NULLIF(@Technician,N''), NULLIF(@ReviewedBy,N''),
         ISNULL(@IsApproved,0), CASE WHEN ISNULL(@IsApproved,0)=1 THEN SYSDATETIME() ELSE NULL END, CASE WHEN ISNULL(@IsApproved,0)=1 THEN @UserId ELSE NULL END,
         NULLIF(@Remarks,N''), @UserId);

        SET @LabTestResultId = SCOPE_IDENTITY();

        IF @TestCode IS NULL OR LTRIM(RTRIM(@TestCode)) = N''
        BEGIN
            UPDATE dbo.LabTestResults
            SET TestCode = N'LAB-' + RIGHT(N'000000' + CONVERT(NVARCHAR(20), @LabTestResultId), 6)
            WHERE LabTestResultId = @LabTestResultId;
        END
    END
    ELSE
    BEGIN
        UPDATE dbo.LabTestResults
        SET ProjectId = @ProjectId,
            BoreholeId = @BoreholeId,
            SampleId = @SampleId,
            LabTestTypeId = @LabTestTypeId,
            TestCode = NULLIF(@TestCode,N''),
            TestStandard = NULLIF(@TestStandard,N''),
            TestDate = @TestDate,
            ResultStatusId = @ResultStatusId,
            NumericValue = @NumericValue,
            Unit = NULLIF(@Unit,N''),
            ResultValue = NULLIF(@ResultValue,N''),
            ResultText = NULLIF(@ResultText,N''),
            Technician = NULLIF(@Technician,N''),
            ReviewedBy = NULLIF(@ReviewedBy,N''),
            IsApproved = ISNULL(@IsApproved,0),
            ApprovedAt = CASE WHEN ISNULL(@IsApproved,0)=1 AND ApprovedAt IS NULL THEN SYSDATETIME() WHEN ISNULL(@IsApproved,0)=0 THEN NULL ELSE ApprovedAt END,
            ApprovedBy = CASE WHEN ISNULL(@IsApproved,0)=1 AND ApprovedBy IS NULL THEN @UserId WHEN ISNULL(@IsApproved,0)=0 THEN NULL ELSE ApprovedBy END,
            Remarks = NULLIF(@Remarks,N''),
            UpdatedAt = SYSDATETIME(),
            UpdatedBy = @UserId
        WHERE LabTestResultId = @LabTestResultId AND IsDeleted = 0;
    END

    INSERT INTO dbo.AuditLogs(UserId, ActionType, EntityName, EntityId, ActionDescription, NewValues)
    VALUES(@UserId, N'Save', N'LabTestResults', CONVERT(NVARCHAR(100), @LabTestResultId), N'تم حفظ نتيجة معملية.', @TestCode);

    SELECT @LabTestResultId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_LabResult_Delete
    @LabTestResultId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.LabTestResults
    SET IsDeleted = 1, DeletedAt = SYSDATETIME(), DeletedBy = @UserId
    WHERE LabTestResultId = @LabTestResultId AND IsDeleted = 0;

    INSERT INTO dbo.AuditLogs(UserId, ActionType, EntityName, EntityId, ActionDescription)
    VALUES(@UserId, N'Delete', N'LabTestResults', CONVERT(NVARCHAR(100), @LabTestResultId), N'تم حذف نتيجة معملية منطقيًا.');
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_LabResult_Approve
    @LabTestResultId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ApprovedStatusId BIGINT = (
        SELECT TOP 1 LI.LookupItemId
        FROM dbo.LookupItems LI
        INNER JOIN dbo.LookupCategories LC ON LC.LookupCategoryId = LI.LookupCategoryId AND LC.CategoryCode = N'LabResultStatus'
        WHERE LI.ItemCode = N'APPROVED' AND LI.IsDeleted = 0
    );

    UPDATE dbo.LabTestResults
    SET IsApproved = 1,
        ResultStatusId = ISNULL(@ApprovedStatusId, ResultStatusId),
        ApprovedAt = SYSDATETIME(),
        ApprovedBy = @UserId,
        UpdatedAt = SYSDATETIME(),
        UpdatedBy = @UserId
    WHERE LabTestResultId = @LabTestResultId AND IsDeleted = 0;

    INSERT INTO dbo.AuditLogs(UserId, ActionType, EntityName, EntityId, ActionDescription)
    VALUES(@UserId, N'Approve', N'LabTestResults', CONVERT(NVARCHAR(100), @LabTestResultId), N'تم اعتماد نتيجة معملية.');
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProjectDashboard_Get
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.sp_Project_GetById @ProjectId = @ProjectId;
    SELECT
        BoreholePlanCount = 0,
        BoreholeCount = (SELECT COUNT(*) FROM dbo.Boreholes WHERE ProjectId = @ProjectId AND IsDeleted = 0),
        LayerCount = (SELECT COUNT(*) FROM dbo.BoreholeLayers L INNER JOIN dbo.Boreholes B ON B.BoreholeId=L.BoreholeId WHERE B.ProjectId=@ProjectId AND B.IsDeleted=0 AND L.IsDeleted=0),
        SampleCount = (SELECT COUNT(*) FROM dbo.Samples WHERE ProjectId = @ProjectId AND IsDeleted = 0),
        SPTCount = (SELECT COUNT(*) FROM dbo.SPTTests WHERE ProjectId = @ProjectId AND IsDeleted = 0),
        GroundwaterCount = (SELECT COUNT(*) FROM dbo.GroundwaterObservations WHERE ProjectId = @ProjectId AND IsDeleted = 0),
        LabTestCount = CASE WHEN OBJECT_ID(N'dbo.LabTestResults', N'U') IS NULL THEN 0 ELSE (SELECT COUNT(*) FROM dbo.LabTestResults WHERE ProjectId = @ProjectId AND IsDeleted = 0) END,
        ReportCount = CASE WHEN OBJECT_ID(N'dbo.Reports', N'U') IS NULL THEN 0 ELSE (SELECT COUNT(*) FROM dbo.Reports WHERE ProjectId = @ProjectId AND IsDeleted = 0) END,
        DocumentCount = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Dashboard_GetSummary
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        TotalProjects = (SELECT COUNT(*) FROM dbo.Projects WHERE IsDeleted = 0),
        ActiveProjects = (SELECT COUNT(*) FROM dbo.Projects WHERE IsDeleted = 0 AND IsActive = 1),
        TotalBoreholes = CASE WHEN OBJECT_ID(N'dbo.Boreholes', N'U') IS NULL THEN 0 ELSE (SELECT COUNT(*) FROM dbo.Boreholes WHERE IsDeleted = 0) END,
        TotalSamples = CASE WHEN OBJECT_ID(N'dbo.Samples', N'U') IS NULL THEN 0 ELSE (SELECT COUNT(*) FROM dbo.Samples WHERE IsDeleted = 0) END,
        TotalSPT = CASE WHEN OBJECT_ID(N'dbo.SPTTests', N'U') IS NULL THEN 0 ELSE (SELECT COUNT(*) FROM dbo.SPTTests WHERE IsDeleted = 0) END,
        TotalLabTests = CASE WHEN OBJECT_ID(N'dbo.LabTestResults', N'U') IS NULL THEN 0 ELSE (SELECT COUNT(*) FROM dbo.LabTestResults WHERE IsDeleted = 0) END,
        TotalReports = CASE WHEN OBJECT_ID(N'dbo.Reports', N'U') IS NULL THEN 0 ELSE (SELECT COUNT(*) FROM dbo.Reports WHERE IsDeleted = 0) END;

    SELECT TOP 10
        P.ProjectId, P.ProjectCode, P.ProjectName, C.ClientName,
        ProjectStatusNameAr = PS.NameAr, P.City, P.LocationName, P.CreatedAt
    FROM dbo.Projects P
    LEFT JOIN dbo.Clients C ON C.ClientId = P.ClientId AND C.IsDeleted = 0
    LEFT JOIN dbo.LookupItems PS ON PS.LookupItemId = P.ProjectStatusId AND PS.IsDeleted = 0
    WHERE P.IsDeleted = 0
    ORDER BY P.CreatedAt DESC;

    SELECT ProjectStatusNameAr = ISNULL(PS.NameAr, N'غير محدد'), ProjectCount = COUNT(*)
    FROM dbo.Projects P
    LEFT JOIN dbo.LookupItems PS ON PS.LookupItemId = P.ProjectStatusId AND PS.IsDeleted = 0
    WHERE P.IsDeleted = 0
    GROUP BY ISNULL(PS.NameAr, N'غير محدد')
    ORDER BY ProjectCount DESC;
END
GO

PRINT N'Sprint 3 stored procedures created successfully.';
GO
