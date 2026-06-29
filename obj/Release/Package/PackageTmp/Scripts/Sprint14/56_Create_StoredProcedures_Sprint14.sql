USE GeoSitePro;
GO

-- Sequence for risk codes
IF OBJECT_ID(N'dbo.SeqRiskCode', N'SO') IS NULL
    EXEC('CREATE SEQUENCE dbo.SeqRiskCode AS BIGINT START WITH 1 INCREMENT BY 1');
GO

CREATE OR ALTER PROCEDURE dbo.sp_Projects_Lookup
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ProjectId, ProjectDisplay = ProjectCode + N' - ' + ProjectName
    FROM dbo.Projects
    WHERE IsDeleted = 0
    ORDER BY ProjectCode;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Users_Lookup
AS
BEGIN
    SET NOCOUNT ON;
    SELECT UserId, FullName
    FROM dbo.Users
    WHERE IsDeleted = 0 AND IsActive = 1
    ORDER BY FullName;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProjectRisks_Get
    @ProjectId BIGINT = NULL,
    @Status NVARCHAR(30) = NULL,
    @RiskLevel NVARCHAR(30) = NULL,
    @SearchText NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @SearchText = NULLIF(LTRIM(RTRIM(@SearchText)), N'');
    SELECT TOP 500
        R.RiskId, R.ProjectId, P.ProjectCode, P.ProjectName,
        R.RiskCode, R.RiskCategory, R.RiskTitle, R.RiskDescription,
        R.ProbabilityLevel, R.ImpactLevel, R.RiskScore, R.RiskLevel,
        R.MitigationPlan, R.OwnerUserId, U.FullName AS OwnerName,
        R.DueDate, R.Status, R.CreatedAt, R.UpdatedAt
    FROM dbo.ProjectRiskRegister R
    INNER JOIN dbo.Projects P ON P.ProjectId = R.ProjectId
    LEFT JOIN dbo.Users U ON U.UserId = R.OwnerUserId
    WHERE R.IsDeleted = 0
      AND (@ProjectId IS NULL OR R.ProjectId = @ProjectId)
      AND (@Status IS NULL OR (@Status = N'Open' AND R.Status IN (N'Open', N'Mitigating')) OR R.Status = @Status)
      AND (@RiskLevel IS NULL OR R.RiskLevel = @RiskLevel)
      AND (@SearchText IS NULL OR R.RiskTitle LIKE N'%' + @SearchText + N'%' OR R.RiskDescription LIKE N'%' + @SearchText + N'%' OR P.ProjectCode LIKE N'%' + @SearchText + N'%' OR P.ProjectName LIKE N'%' + @SearchText + N'%')
    ORDER BY CASE R.RiskLevel WHEN N'Critical' THEN 0 WHEN N'High' THEN 1 WHEN N'Medium' THEN 2 ELSE 3 END, R.DueDate, R.CreatedAt DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProjectRisk_GetById
    @RiskId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT RiskId, ProjectId, RiskCode, RiskCategory, RiskTitle, RiskDescription, ProbabilityLevel, ImpactLevel,
           RiskScore, RiskLevel, MitigationPlan, OwnerUserId, DueDate, Status
    FROM dbo.ProjectRiskRegister
    WHERE RiskId = @RiskId AND IsDeleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProjectRisk_Save
    @RiskId BIGINT = NULL,
    @ProjectId BIGINT,
    @RiskCode NVARCHAR(80) = NULL,
    @RiskCategory NVARCHAR(80),
    @RiskTitle NVARCHAR(300),
    @RiskDescription NVARCHAR(MAX) = NULL,
    @ProbabilityLevel INT = 3,
    @ImpactLevel INT = 3,
    @MitigationPlan NVARCHAR(MAX) = NULL,
    @OwnerUserId BIGINT = NULL,
    @DueDate DATE = NULL,
    @Status NVARCHAR(30) = N'Open',
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @ProbabilityLevel = CASE WHEN @ProbabilityLevel BETWEEN 1 AND 5 THEN @ProbabilityLevel ELSE 3 END;
    SET @ImpactLevel = CASE WHEN @ImpactLevel BETWEEN 1 AND 5 THEN @ImpactLevel ELSE 3 END;

    IF @RiskId IS NULL OR @RiskId = 0
    BEGIN
        IF NULLIF(@RiskCode, N'') IS NULL
            SET @RiskCode = N'RISK-' + CONVERT(NVARCHAR(20), NEXT VALUE FOR dbo.SeqRiskCode);
        INSERT INTO dbo.ProjectRiskRegister(ProjectId, RiskCode, RiskCategory, RiskTitle, RiskDescription, ProbabilityLevel, ImpactLevel, MitigationPlan, OwnerUserId, DueDate, Status, CreatedBy)
        VALUES(@ProjectId, @RiskCode, @RiskCategory, @RiskTitle, @RiskDescription, @ProbabilityLevel, @ImpactLevel, @MitigationPlan, @OwnerUserId, @DueDate, @Status, @UserId);
        SELECT SCOPE_IDENTITY() AS RiskId;
    END
    ELSE
    BEGIN
        UPDATE dbo.ProjectRiskRegister
        SET ProjectId=@ProjectId, RiskCode=@RiskCode, RiskCategory=@RiskCategory, RiskTitle=@RiskTitle, RiskDescription=@RiskDescription,
            ProbabilityLevel=@ProbabilityLevel, ImpactLevel=@ImpactLevel, MitigationPlan=@MitigationPlan, OwnerUserId=@OwnerUserId,
            DueDate=@DueDate, Status=@Status,
            ClosedAt = CASE WHEN @Status = N'Closed' AND ClosedAt IS NULL THEN SYSDATETIME() ELSE ClosedAt END,
            ClosedBy = CASE WHEN @Status = N'Closed' AND ClosedBy IS NULL THEN @UserId ELSE ClosedBy END,
            UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId
        WHERE RiskId=@RiskId AND IsDeleted=0;
        SELECT @RiskId AS RiskId;
    END
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProjectRisk_UpdateStatus
    @RiskId BIGINT,
    @Status NVARCHAR(30),
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProjectRiskRegister
    SET Status = @Status,
        ClosedAt = CASE WHEN @Status = N'Closed' THEN SYSDATETIME() ELSE ClosedAt END,
        ClosedBy = CASE WHEN @Status = N'Closed' THEN @UserId ELSE ClosedBy END,
        UpdatedAt = SYSDATETIME(), UpdatedBy = @UserId
    WHERE RiskId = @RiskId AND IsDeleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_QualityKpi_GenerateSnapshot
    @ProjectId BIGINT = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Today DATE = CONVERT(DATE, GETDATE());

    DELETE FROM dbo.ProjectKpiSnapshots WHERE SnapshotDate = @Today AND (@ProjectId IS NULL OR ProjectId = @ProjectId);

    INSERT INTO dbo.ProjectKpiSnapshots
    (
        ProjectId, SnapshotDate, TotalBoreholes, BoreholesWithLogs, TotalSamples, SamplesWithLabResults,
        TotalLabResults, ApprovedLabResults, TotalReports, ApprovedReports, OpenFollowUps, OverdueFollowUps,
        PendingApprovals, HighRisks, QualityScore, CreatedBy
    )
    SELECT
        P.ProjectId,
        @Today,
        ISNULL(BH.TotalBoreholes,0),
        ISNULL(BHL.BoreholesWithLogs,0),
        ISNULL(S.TotalSamples,0),
        ISNULL(SLR.SamplesWithLabResults,0),
        ISNULL(L.TotalLabResults,0),
        ISNULL(L.ApprovedLabResults,0),
        ISNULL(R.TotalReports,0),
        ISNULL(R.ApprovedReports,0),
        ISNULL(F.OpenFollowUps,0),
        ISNULL(F.OverdueFollowUps,0),
        ISNULL(A.PendingApprovals,0),
        ISNULL(PR.HighRisks,0),
        QualityScore = CASE
            WHEN (100 - ISNULL(F.OpenFollowUps,0)*3 - ISNULL(F.OverdueFollowUps,0)*5 - ISNULL(A.PendingApprovals,0)*2 - ISNULL(PR.HighRisks,0)*5) < 0 THEN 0
            ELSE (100 - ISNULL(F.OpenFollowUps,0)*3 - ISNULL(F.OverdueFollowUps,0)*5 - ISNULL(A.PendingApprovals,0)*2 - ISNULL(PR.HighRisks,0)*5)
        END,
        @UserId
    FROM dbo.Projects P
    OUTER APPLY (SELECT COUNT(1) TotalBoreholes FROM dbo.Boreholes X WHERE X.ProjectId=P.ProjectId AND X.IsDeleted=0) BH
    OUTER APPLY (SELECT COUNT(DISTINCT X.BoreholeId) BoreholesWithLogs FROM dbo.BoreholeLayers X INNER JOIN dbo.Boreholes B ON B.BoreholeId=X.BoreholeId WHERE B.ProjectId=P.ProjectId AND X.IsDeleted=0 AND B.IsDeleted=0) BHL
    OUTER APPLY (SELECT COUNT(1) TotalSamples FROM dbo.Samples X INNER JOIN dbo.Boreholes B ON B.BoreholeId=X.BoreholeId WHERE B.ProjectId=P.ProjectId AND X.IsDeleted=0 AND B.IsDeleted=0) S
    OUTER APPLY (SELECT COUNT(DISTINCT X.SampleId) SamplesWithLabResults FROM dbo.LabTestResults X WHERE X.ProjectId=P.ProjectId AND X.SampleId IS NOT NULL AND X.IsDeleted=0) SLR
    OUTER APPLY (SELECT COUNT(1) TotalLabResults, SUM(CASE WHEN ISNULL(IsApproved,0)=1 THEN 1 ELSE 0 END) ApprovedLabResults FROM dbo.LabTestResults X WHERE X.ProjectId=P.ProjectId AND X.IsDeleted=0) L
    OUTER APPLY (SELECT COUNT(1) TotalReports, SUM(CASE WHEN ApprovedAt IS NOT NULL OR IssuedAt IS NOT NULL THEN 1 ELSE 0 END) ApprovedReports FROM dbo.TechnicalReports X WHERE X.ProjectId=P.ProjectId AND X.IsDeleted=0) R
    OUTER APPLY (SELECT COUNT(1) OpenFollowUps, SUM(CASE WHEN DueDate < @Today THEN 1 ELSE 0 END) OverdueFollowUps FROM dbo.ProjectFollowUpItems X WHERE X.ProjectId=P.ProjectId AND X.IsDeleted=0 AND X.Status <> N'Closed') F
    OUTER APPLY (SELECT COUNT(1) PendingApprovals FROM dbo.ApprovalRequests X WHERE X.ProjectId=P.ProjectId AND X.IsDeleted=0 AND X.Status = N'Pending') A
    OUTER APPLY (SELECT COUNT(1) HighRisks FROM dbo.ProjectRiskRegister X WHERE X.ProjectId=P.ProjectId AND X.IsDeleted=0 AND X.Status <> N'Closed' AND X.RiskLevel IN (N'High',N'Critical')) PR
    WHERE P.IsDeleted=0 AND (@ProjectId IS NULL OR P.ProjectId=@ProjectId);
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_QualityKpi_Get
    @ProjectId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    ;WITH Latest AS
    (
        SELECT K.*, ROW_NUMBER() OVER(PARTITION BY K.ProjectId ORDER BY K.SnapshotDate DESC, K.KpiSnapshotId DESC) rn
        FROM dbo.ProjectKpiSnapshots K
        WHERE (@ProjectId IS NULL OR K.ProjectId=@ProjectId)
    )
    SELECT TOP 300
        L.SnapshotDate, L.ProjectId, P.ProjectCode, P.ProjectName,
        L.TotalBoreholes, L.BoreholesWithLogs, L.TotalSamples, L.SamplesWithLabResults,
        L.TotalLabResults, L.ApprovedLabResults, L.TotalReports, L.ApprovedReports,
        L.OpenFollowUps, L.OverdueFollowUps, L.PendingApprovals, L.HighRisks, L.QualityScore
    FROM Latest L
    INNER JOIN dbo.Projects P ON P.ProjectId=L.ProjectId
    WHERE L.rn=1 AND P.IsDeleted=0
    ORDER BY L.QualityScore ASC, P.ProjectCode;

    SELECT
        AvgScore = ISNULL(CONVERT(INT, AVG(CONVERT(DECIMAL(10,2), QualityScore))), 0),
        LowScoreCount = SUM(CASE WHEN QualityScore < 70 THEN 1 ELSE 0 END),
        OpenFollowUps = SUM(OpenFollowUps),
        HighRisks = SUM(HighRisks)
    FROM
    (
        SELECT L.*, ROW_NUMBER() OVER(PARTITION BY L.ProjectId ORDER BY L.SnapshotDate DESC, L.KpiSnapshotId DESC) rn
        FROM dbo.ProjectKpiSnapshots L
        WHERE (@ProjectId IS NULL OR L.ProjectId=@ProjectId)
    ) X
    WHERE rn=1;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ExecutiveDashboard_GetSummary
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        TotalProjects = (SELECT COUNT(1) FROM dbo.Projects WHERE IsDeleted=0),
        ActiveProjects = (SELECT COUNT(1) FROM dbo.Projects WHERE IsDeleted=0 AND IsActive=1),
        TotalBoreholes = (SELECT COUNT(1) FROM dbo.Boreholes WHERE IsDeleted=0),
        TotalSamples = (SELECT COUNT(1) FROM dbo.Samples WHERE IsDeleted=0),
        TotalLabResults = (SELECT COUNT(1) FROM dbo.LabTestResults WHERE IsDeleted=0),
        TotalReports = (SELECT COUNT(1) FROM dbo.TechnicalReports WHERE IsDeleted=0),
        PendingApprovals = (SELECT COUNT(1) FROM dbo.ApprovalRequests WHERE IsDeleted=0 AND Status=N'Pending'),
        OpenFollowUps = (SELECT COUNT(1) FROM dbo.ProjectFollowUpItems WHERE IsDeleted=0 AND Status<>N'Closed'),
        OverdueFollowUps = (SELECT COUNT(1) FROM dbo.ProjectFollowUpItems WHERE IsDeleted=0 AND Status<>N'Closed' AND DueDate < CONVERT(DATE,GETDATE())),
        HighRisks = (SELECT COUNT(1) FROM dbo.ProjectRiskRegister WHERE IsDeleted=0 AND Status<>N'Closed' AND RiskLevel IN (N'High',N'Critical')),
        AverageQualityScore = ISNULL((SELECT CONVERT(INT, AVG(CONVERT(DECIMAL(10,2), QualityScore))) FROM (SELECT K.*, ROW_NUMBER() OVER(PARTITION BY ProjectId ORDER BY SnapshotDate DESC, KpiSnapshotId DESC) rn FROM dbo.ProjectKpiSnapshots K) X WHERE rn=1), 0),
        CriticalNotifications = (SELECT COUNT(1) FROM dbo.UserNotifications WHERE IsDeleted=0 AND Status<>N'Archived' AND Severity=N'Critical');

    SELECT TOP 10 P.ProjectCode, P.ProjectName,
        OpenRisks = COUNT(1),
        HighRisks = SUM(CASE WHEN R.RiskLevel IN (N'High',N'Critical') THEN 1 ELSE 0 END),
        MaxRiskScore = MAX(R.RiskScore)
    FROM dbo.ProjectRiskRegister R
    INNER JOIN dbo.Projects P ON P.ProjectId=R.ProjectId
    WHERE R.IsDeleted=0 AND R.Status<>N'Closed' AND P.IsDeleted=0
    GROUP BY P.ProjectCode, P.ProjectName
    ORDER BY HighRisks DESC, MaxRiskScore DESC;

    SELECT TOP 10 P.ProjectCode, P.ProjectName, K.QualityScore, K.OpenFollowUps, K.PendingApprovals, K.HighRisks
    FROM
    (
        SELECT K.*, ROW_NUMBER() OVER(PARTITION BY K.ProjectId ORDER BY K.SnapshotDate DESC, K.KpiSnapshotId DESC) rn
        FROM dbo.ProjectKpiSnapshots K
    ) K
    INNER JOIN dbo.Projects P ON P.ProjectId=K.ProjectId
    WHERE K.rn=1 AND P.IsDeleted=0
    ORDER BY K.QualityScore ASC, P.ProjectCode;

    SELECT TOP 20 ItemType, ProjectCode, Title, Status, DueDate, Severity
    FROM
    (
        SELECT N'Risk' AS ItemType, P.ProjectCode, R.RiskTitle AS Title, R.Status, R.DueDate, R.RiskLevel AS Severity, R.CreatedAt
        FROM dbo.ProjectRiskRegister R INNER JOIN dbo.Projects P ON P.ProjectId=R.ProjectId
        WHERE R.IsDeleted=0 AND R.Status<>N'Closed' AND R.RiskLevel IN (N'High',N'Critical')
        UNION ALL
        SELECT N'FollowUp', P.ProjectCode, F.ItemTitle, F.Status, F.DueDate, F.Priority, F.CreatedAt
        FROM dbo.ProjectFollowUpItems F INNER JOIN dbo.Projects P ON P.ProjectId=F.ProjectId
        WHERE F.IsDeleted=0 AND F.Status<>N'Closed' AND (F.DueDate <= DATEADD(DAY,2,CONVERT(DATE,GETDATE())) OR F.Priority IN (N'High',N'Urgent'))
        UNION ALL
        SELECT N'Approval', P.ProjectCode, A.RequestTitle, A.Status, CAST(NULL AS DATE) AS DueDate, A.Priority, A.CreatedAt
        FROM dbo.ApprovalRequests A LEFT JOIN dbo.Projects P ON P.ProjectId=A.ProjectId
        WHERE A.IsDeleted=0 AND A.Status=N'Pending'
    ) X
    ORDER BY CASE WHEN Severity IN (N'Critical',N'Urgent') THEN 0 WHEN Severity IN (N'High') THEN 1 ELSE 2 END, DueDate, CreatedAt DESC;
END
GO

PRINT N'Sprint 14 stored procedures created successfully.';
GO
