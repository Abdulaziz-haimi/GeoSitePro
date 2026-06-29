USE GeoSitePro;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Standards_Get
    @CategoryId BIGINT = NULL,
    @SearchText NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT S.StandardId, S.StandardCode, S.StandardTitle, S.Organization, S.CategoryId, LI.NameAr AS CategoryNameAr,
           S.VersionYear, S.StandardType, S.ScopeSummary, S.Remarks, S.IsActive, S.CreatedAt
    FROM dbo.Standards S
    LEFT JOIN dbo.LookupItems LI ON LI.LookupItemId=S.CategoryId
    WHERE S.IsDeleted=0
      AND (@CategoryId IS NULL OR S.CategoryId=@CategoryId)
      AND (@SearchText IS NULL OR S.StandardCode LIKE N'%'+@SearchText+N'%' OR S.StandardTitle LIKE N'%'+@SearchText+N'%' OR S.Organization LIKE N'%'+@SearchText+N'%' OR S.StandardType LIKE N'%'+@SearchText+N'%')
    ORDER BY S.Organization, S.StandardCode;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Standard_GetById @StandardId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Standards WHERE StandardId=@StandardId AND IsDeleted=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Standard_Save
    @StandardId BIGINT = NULL,
    @StandardCode NVARCHAR(100),
    @StandardTitle NVARCHAR(500),
    @Organization NVARCHAR(100) = NULL,
    @CategoryId BIGINT = NULL,
    @VersionYear INT = NULL,
    @StandardType NVARCHAR(100) = NULL,
    @ScopeSummary NVARCHAR(MAX) = NULL,
    @Remarks NVARCHAR(MAX) = NULL,
    @IsActive BIT = 1,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @StandardId IS NULL OR @StandardId=0
    BEGIN
        INSERT INTO dbo.Standards(StandardCode, StandardTitle, Organization, CategoryId, VersionYear, StandardType, ScopeSummary, Remarks, IsActive, CreatedBy)
        VALUES(@StandardCode, @StandardTitle, @Organization, @CategoryId, @VersionYear, @StandardType, @ScopeSummary, @Remarks, @IsActive, @UserId);
        SET @StandardId=SCOPE_IDENTITY();
        INSERT INTO dbo.AuditLogs(UserId, ActionType, EntityName, EntityId, ActionDescription, NewValues)
        VALUES(@UserId, N'Create', N'Standards', CONVERT(NVARCHAR(100),@StandardId), N'تم إنشاء معيار فني.', @StandardCode);
    END
    ELSE
    BEGIN
        UPDATE dbo.Standards SET StandardCode=@StandardCode, StandardTitle=@StandardTitle, Organization=@Organization, CategoryId=@CategoryId, VersionYear=@VersionYear, StandardType=@StandardType, ScopeSummary=@ScopeSummary, Remarks=@Remarks, IsActive=@IsActive, UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId WHERE StandardId=@StandardId;
        INSERT INTO dbo.AuditLogs(UserId, ActionType, EntityName, EntityId, ActionDescription, NewValues)
        VALUES(@UserId, N'Update', N'Standards', CONVERT(NVARCHAR(100),@StandardId), N'تم تعديل معيار فني.', @StandardCode);
    END
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Standard_Delete @StandardId BIGINT, @UserId BIGINT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Standards SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE StandardId=@StandardId;
    INSERT INTO dbo.AuditLogs(UserId, ActionType, EntityName, EntityId, ActionDescription)
    VALUES(@UserId, N'Delete', N'Standards', CONVERT(NVARCHAR(100),@StandardId), N'تم حذف معيار فني.');
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProjectQualityChecks_Get
    @ProjectId BIGINT = NULL,
    @StatusId BIGINT = NULL,
    @SearchText NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Q.QualityCheckId, Q.ProjectId, P.ProjectCode, P.ProjectName,
           Q.CheckAreaId, Area.NameAr AS CheckAreaNameAr,
           Q.ChecklistItem, Q.RequirementReference, Q.SeverityId, Sev.NameAr AS SeverityNameAr,
           Q.StatusId, St.NameAr AS StatusNameAr, Q.ResponsiblePerson, Q.DueDate, Q.ClosedDate,
           Q.EvidenceText, Q.CorrectiveAction, Q.IsApproved, Q.CreatedAt
    FROM dbo.ProjectQualityChecks Q
    LEFT JOIN dbo.Projects P ON P.ProjectId=Q.ProjectId
    LEFT JOIN dbo.LookupItems Area ON Area.LookupItemId=Q.CheckAreaId
    LEFT JOIN dbo.LookupItems Sev ON Sev.LookupItemId=Q.SeverityId
    LEFT JOIN dbo.LookupItems St ON St.LookupItemId=Q.StatusId
    WHERE Q.IsDeleted=0
      AND (@ProjectId IS NULL OR Q.ProjectId=@ProjectId)
      AND (@StatusId IS NULL OR Q.StatusId=@StatusId)
      AND (@SearchText IS NULL OR Q.ChecklistItem LIKE N'%'+@SearchText+N'%' OR Q.RequirementReference LIKE N'%'+@SearchText+N'%' OR Q.ResponsiblePerson LIKE N'%'+@SearchText+N'%')
    ORDER BY Q.IsApproved, Q.DueDate, Q.CreatedAt DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProjectQualityCheck_GetById @QualityCheckId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.ProjectQualityChecks WHERE QualityCheckId=@QualityCheckId AND IsDeleted=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProjectQualityCheck_Save
    @QualityCheckId BIGINT = NULL,
    @ProjectId BIGINT,
    @CheckAreaId BIGINT = NULL,
    @ChecklistItem NVARCHAR(1000),
    @RequirementReference NVARCHAR(300) = NULL,
    @SeverityId BIGINT = NULL,
    @StatusId BIGINT = NULL,
    @ResponsiblePerson NVARCHAR(200) = NULL,
    @DueDate DATE = NULL,
    @ClosedDate DATE = NULL,
    @EvidenceText NVARCHAR(MAX) = NULL,
    @CorrectiveAction NVARCHAR(MAX) = NULL,
    @Remarks NVARCHAR(MAX) = NULL,
    @IsApproved BIT = 0,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @QualityCheckId IS NULL OR @QualityCheckId=0
    BEGIN
        INSERT INTO dbo.ProjectQualityChecks(ProjectId, CheckAreaId, ChecklistItem, RequirementReference, SeverityId, StatusId, ResponsiblePerson, DueDate, ClosedDate, EvidenceText, CorrectiveAction, Remarks, IsApproved, ApprovedAt, ApprovedBy, CreatedBy)
        VALUES(@ProjectId, @CheckAreaId, @ChecklistItem, @RequirementReference, @SeverityId, @StatusId, @ResponsiblePerson, @DueDate, @ClosedDate, @EvidenceText, @CorrectiveAction, @Remarks, @IsApproved, CASE WHEN @IsApproved=1 THEN SYSDATETIME() END, CASE WHEN @IsApproved=1 THEN @UserId END, @UserId);
        SET @QualityCheckId=SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.ProjectQualityChecks SET ProjectId=@ProjectId, CheckAreaId=@CheckAreaId, ChecklistItem=@ChecklistItem, RequirementReference=@RequirementReference, SeverityId=@SeverityId, StatusId=@StatusId, ResponsiblePerson=@ResponsiblePerson, DueDate=@DueDate, ClosedDate=@ClosedDate, EvidenceText=@EvidenceText, CorrectiveAction=@CorrectiveAction, Remarks=@Remarks, IsApproved=@IsApproved, ApprovedAt=CASE WHEN @IsApproved=1 THEN ISNULL(ApprovedAt,SYSDATETIME()) ELSE NULL END, ApprovedBy=CASE WHEN @IsApproved=1 THEN ISNULL(ApprovedBy,@UserId) ELSE NULL END, UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId WHERE QualityCheckId=@QualityCheckId;
    END
    INSERT INTO dbo.AuditLogs(UserId, ActionType, EntityName, EntityId, ActionDescription)
    VALUES(@UserId, N'Save', N'ProjectQualityChecks', CONVERT(NVARCHAR(100),@QualityCheckId), N'تم حفظ بند فحص جودة.');
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProjectQualityCheck_Approve @QualityCheckId BIGINT, @UserId BIGINT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProjectQualityChecks SET IsApproved=1, ApprovedAt=SYSDATETIME(), ApprovedBy=@UserId, UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId WHERE QualityCheckId=@QualityCheckId;
    INSERT INTO dbo.AuditLogs(UserId, ActionType, EntityName, EntityId, ActionDescription)
    VALUES(@UserId, N'Approve', N'ProjectQualityChecks', CONVERT(NVARCHAR(100),@QualityCheckId), N'تم اعتماد بند فحص جودة.');
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProjectQualityCheck_Delete @QualityCheckId BIGINT, @UserId BIGINT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProjectQualityChecks SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE QualityCheckId=@QualityCheckId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_EngineeringCalculations_Get
    @ProjectId BIGINT = NULL,
    @CalculationTypeId BIGINT = NULL,
    @SearchText NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT C.CalculationId, C.ProjectId, P.ProjectCode, P.ProjectName, C.CalculationTypeId, LI.NameAr AS CalculationTypeNameAr,
           C.CalculationDate, C.CalculationTitle, C.Result1, C.Result2, C.Result3, C.Unit, C.ResultSummary, C.CalculatedBy, C.CheckedBy, C.IsApproved, C.CreatedAt
    FROM dbo.EngineeringCalculations C
    LEFT JOIN dbo.Projects P ON P.ProjectId=C.ProjectId
    LEFT JOIN dbo.LookupItems LI ON LI.LookupItemId=C.CalculationTypeId
    WHERE C.IsDeleted=0
      AND (@ProjectId IS NULL OR C.ProjectId=@ProjectId)
      AND (@CalculationTypeId IS NULL OR C.CalculationTypeId=@CalculationTypeId)
      AND (@SearchText IS NULL OR C.CalculationTitle LIKE N'%'+@SearchText+N'%' OR C.ResultSummary LIKE N'%'+@SearchText+N'%' OR C.CalculatedBy LIKE N'%'+@SearchText+N'%')
    ORDER BY C.CreatedAt DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_EngineeringCalculation_GetById @CalculationId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.EngineeringCalculations WHERE CalculationId=@CalculationId AND IsDeleted=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_EngineeringCalculation_Save
    @CalculationId BIGINT = NULL,
    @ProjectId BIGINT,
    @CalculationTypeId BIGINT,
    @CalculationDate DATE = NULL,
    @CalculationTitle NVARCHAR(300) = NULL,
    @Input1 DECIMAL(18,6) = NULL,
    @Input2 DECIMAL(18,6) = NULL,
    @Input3 DECIMAL(18,6) = NULL,
    @Input4 DECIMAL(18,6) = NULL,
    @Input5 DECIMAL(18,6) = NULL,
    @Input6 DECIMAL(18,6) = NULL,
    @Result1 DECIMAL(18,6) = NULL,
    @Result2 DECIMAL(18,6) = NULL,
    @Result3 DECIMAL(18,6) = NULL,
    @Unit NVARCHAR(50) = NULL,
    @ResultSummary NVARCHAR(MAX) = NULL,
    @CalculatedBy NVARCHAR(200) = NULL,
    @CheckedBy NVARCHAR(200) = NULL,
    @IsApproved BIT = 0,
    @Notes NVARCHAR(MAX) = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @CalculationId IS NULL OR @CalculationId=0
    BEGIN
        INSERT INTO dbo.EngineeringCalculations(ProjectId, CalculationTypeId, CalculationDate, CalculationTitle, Input1, Input2, Input3, Input4, Input5, Input6, Result1, Result2, Result3, Unit, ResultSummary, CalculatedBy, CheckedBy, IsApproved, ApprovedAt, ApprovedBy, Notes, CreatedBy)
        VALUES(@ProjectId, @CalculationTypeId, @CalculationDate, @CalculationTitle, @Input1, @Input2, @Input3, @Input4, @Input5, @Input6, @Result1, @Result2, @Result3, @Unit, @ResultSummary, @CalculatedBy, @CheckedBy, @IsApproved, CASE WHEN @IsApproved=1 THEN SYSDATETIME() END, CASE WHEN @IsApproved=1 THEN @UserId END, @Notes, @UserId);
        SET @CalculationId=SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.EngineeringCalculations SET ProjectId=@ProjectId, CalculationTypeId=@CalculationTypeId, CalculationDate=@CalculationDate, CalculationTitle=@CalculationTitle, Input1=@Input1, Input2=@Input2, Input3=@Input3, Input4=@Input4, Input5=@Input5, Input6=@Input6, Result1=@Result1, Result2=@Result2, Result3=@Result3, Unit=@Unit, ResultSummary=@ResultSummary, CalculatedBy=@CalculatedBy, CheckedBy=@CheckedBy, IsApproved=@IsApproved, ApprovedAt=CASE WHEN @IsApproved=1 THEN ISNULL(ApprovedAt,SYSDATETIME()) ELSE NULL END, ApprovedBy=CASE WHEN @IsApproved=1 THEN ISNULL(ApprovedBy,@UserId) ELSE NULL END, Notes=@Notes, UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId WHERE CalculationId=@CalculationId;
    END
    INSERT INTO dbo.AuditLogs(UserId, ActionType, EntityName, EntityId, ActionDescription)
    VALUES(@UserId, N'Save', N'EngineeringCalculations', CONVERT(NVARCHAR(100),@CalculationId), N'تم حفظ حساب جيوتقني.');
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_EngineeringCalculation_Approve @CalculationId BIGINT, @UserId BIGINT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.EngineeringCalculations SET IsApproved=1, ApprovedAt=SYSDATETIME(), ApprovedBy=@UserId, UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId WHERE CalculationId=@CalculationId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_EngineeringCalculation_Delete @CalculationId BIGINT, @UserId BIGINT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.EngineeringCalculations SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE CalculationId=@CalculationId;
END
GO

PRINT N'Sprint 6 stored procedures created successfully.';
GO
