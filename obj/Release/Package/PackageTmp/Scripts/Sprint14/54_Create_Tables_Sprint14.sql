USE GeoSitePro;
GO

IF OBJECT_ID(N'dbo.ProjectRiskRegister', N'U') IS NULL
BEGIN
CREATE TABLE dbo.ProjectRiskRegister
(
    RiskId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ProjectRiskRegister PRIMARY KEY,
    ProjectId BIGINT NOT NULL,
    RiskCode NVARCHAR(80) NULL,
    RiskCategory NVARCHAR(80) NOT NULL CONSTRAINT DF_ProjectRiskRegister_Category DEFAULT(N'Geotechnical'),
    RiskTitle NVARCHAR(300) NOT NULL,
    RiskDescription NVARCHAR(MAX) NULL,
    ProbabilityLevel INT NOT NULL CONSTRAINT DF_ProjectRiskRegister_Probability DEFAULT(3),
    ImpactLevel INT NOT NULL CONSTRAINT DF_ProjectRiskRegister_Impact DEFAULT(3),
    RiskScore AS (ProbabilityLevel * ImpactLevel) PERSISTED,
    RiskLevel AS (CASE WHEN ProbabilityLevel * ImpactLevel >= 20 THEN N'Critical' WHEN ProbabilityLevel * ImpactLevel >= 12 THEN N'High' WHEN ProbabilityLevel * ImpactLevel >= 6 THEN N'Medium' ELSE N'Low' END) PERSISTED,
    MitigationPlan NVARCHAR(MAX) NULL,
    OwnerUserId BIGINT NULL,
    DueDate DATE NULL,
    Status NVARCHAR(30) NOT NULL CONSTRAINT DF_ProjectRiskRegister_Status DEFAULT(N'Open'),
    ClosedAt DATETIME2 NULL,
    ClosedBy BIGINT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_ProjectRiskRegister_IsActive DEFAULT(1),
    IsDeleted BIT NOT NULL CONSTRAINT DF_ProjectRiskRegister_IsDeleted DEFAULT(0),
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectRiskRegister_CreatedAt DEFAULT(SYSDATETIME()),
    CreatedBy BIGINT NULL,
    UpdatedAt DATETIME2 NULL,
    UpdatedBy BIGINT NULL,
    DeletedAt DATETIME2 NULL,
    DeletedBy BIGINT NULL,
    CONSTRAINT FK_ProjectRiskRegister_Projects FOREIGN KEY(ProjectId) REFERENCES dbo.Projects(ProjectId),
    CONSTRAINT FK_ProjectRiskRegister_Users FOREIGN KEY(OwnerUserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT CK_ProjectRiskRegister_Probability CHECK(ProbabilityLevel BETWEEN 1 AND 5),
    CONSTRAINT CK_ProjectRiskRegister_Impact CHECK(ImpactLevel BETWEEN 1 AND 5)
);
CREATE INDEX IX_ProjectRiskRegister_Project ON dbo.ProjectRiskRegister(ProjectId, Status, IsDeleted);
CREATE INDEX IX_ProjectRiskRegister_Owner ON dbo.ProjectRiskRegister(OwnerUserId, Status) WHERE IsDeleted = 0;
END
GO

IF OBJECT_ID(N'dbo.ProjectKpiSnapshots', N'U') IS NULL
BEGIN
CREATE TABLE dbo.ProjectKpiSnapshots
(
    KpiSnapshotId BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ProjectKpiSnapshots PRIMARY KEY,
    ProjectId BIGINT NOT NULL,
    SnapshotDate DATE NOT NULL CONSTRAINT DF_ProjectKpiSnapshots_Date DEFAULT(CONVERT(DATE, GETDATE())),
    TotalBoreholes INT NOT NULL DEFAULT(0),
    BoreholesWithLogs INT NOT NULL DEFAULT(0),
    TotalSamples INT NOT NULL DEFAULT(0),
    SamplesWithLabResults INT NOT NULL DEFAULT(0),
    TotalLabResults INT NOT NULL DEFAULT(0),
    ApprovedLabResults INT NOT NULL DEFAULT(0),
    TotalReports INT NOT NULL DEFAULT(0),
    ApprovedReports INT NOT NULL DEFAULT(0),
    OpenFollowUps INT NOT NULL DEFAULT(0),
    OverdueFollowUps INT NOT NULL DEFAULT(0),
    PendingApprovals INT NOT NULL DEFAULT(0),
    HighRisks INT NOT NULL DEFAULT(0),
    QualityScore INT NOT NULL DEFAULT(100),
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ProjectKpiSnapshots_CreatedAt DEFAULT(SYSDATETIME()),
    CreatedBy BIGINT NULL,
    CONSTRAINT FK_ProjectKpiSnapshots_Projects FOREIGN KEY(ProjectId) REFERENCES dbo.Projects(ProjectId)
);
CREATE INDEX IX_ProjectKpiSnapshots_ProjectDate ON dbo.ProjectKpiSnapshots(ProjectId, SnapshotDate DESC);
END
GO

PRINT N'Sprint 14 tables created successfully.';
GO
