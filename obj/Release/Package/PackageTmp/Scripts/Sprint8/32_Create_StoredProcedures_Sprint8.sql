USE GeoSitePro;
GO

IF OBJECT_ID(N'dbo.sp_ProjectTypes_Get', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectTypes_Get;
GO
CREATE PROCEDURE dbo.sp_ProjectTypes_Get
AS
BEGIN
    SET NOCOUNT ON;
    SELECT I.LookupItemId, I.ItemCode, I.NameAr, I.NameEn, I.SortOrder
    FROM dbo.LookupItems I
    INNER JOIN dbo.LookupCategories C ON C.LookupCategoryId=I.LookupCategoryId
    WHERE C.CategoryCode=N'ProjectType' AND C.IsDeleted=0 AND I.IsDeleted=0 AND I.IsActive=1
    ORDER BY I.SortOrder, I.NameAr;
END
GO

IF OBJECT_ID(N'dbo.sp_InvestigationTemplates_Get', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_InvestigationTemplates_Get;
GO
CREATE PROCEDURE dbo.sp_InvestigationTemplates_Get
    @ProjectTypeId BIGINT = NULL,
    @SearchText NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT T.TemplateId, T.TemplateCode, T.TemplateNameAr, T.TemplateNameEn, T.ApplicabilitySummary,
           T.MinSiteAreaM2, T.MaxSiteAreaM2, T.MinFloors, T.MaxFloors,
           T.DefaultBoreholeCount, T.DefaultMinDepthM, T.DefaultSPTIntervalM,
           T.IsDefault, T.IsActive,
           PT.NameAr AS ProjectTypeNameAr, PT.NameEn AS ProjectTypeNameEn,
           ST.NameAr AS InvestigationStageNameAr,
           RL.NameAr AS RiskLevelNameAr,
           ItemCount=(SELECT COUNT(1) FROM dbo.InvestigationTemplateItems I WHERE I.TemplateId=T.TemplateId AND I.IsDeleted=0)
    FROM dbo.InvestigationTemplates T
    LEFT JOIN dbo.LookupItems PT ON PT.LookupItemId=T.ProjectTypeId
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId=T.InvestigationStageId
    LEFT JOIN dbo.LookupItems RL ON RL.LookupItemId=T.RiskLevelId
    WHERE T.IsDeleted=0
      AND (@ProjectTypeId IS NULL OR T.ProjectTypeId=@ProjectTypeId)
      AND (@SearchText IS NULL OR @SearchText=N'' OR T.TemplateCode LIKE N'%' + @SearchText + N'%' OR T.TemplateNameAr LIKE N'%' + @SearchText + N'%' OR T.TemplateNameEn LIKE N'%' + @SearchText + N'%')
    ORDER BY PT.SortOrder, T.IsDefault DESC, T.TemplateCode;
END
GO

IF OBJECT_ID(N'dbo.sp_InvestigationTemplate_GetDetails', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_InvestigationTemplate_GetDetails;
GO
CREATE PROCEDURE dbo.sp_InvestigationTemplate_GetDetails
    @TemplateId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT T.*, PT.NameAr AS ProjectTypeNameAr, ST.NameAr AS InvestigationStageNameAr, RL.NameAr AS RiskLevelNameAr
    FROM dbo.InvestigationTemplates T
    LEFT JOIN dbo.LookupItems PT ON PT.LookupItemId=T.ProjectTypeId
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId=T.InvestigationStageId
    LEFT JOIN dbo.LookupItems RL ON RL.LookupItemId=T.RiskLevelId
    WHERE T.TemplateId=@TemplateId AND T.IsDeleted=0;

    SELECT I.TemplateItemId, I.TemplateId, I.ItemCode, I.ItemTitleAr, I.ItemTitleEn, I.RecommendationText,
           I.MinQuantity, I.SpacingMeters, I.MinDepthM, I.MaxDepthM, I.FrequencyRule, I.DepthRule,
           I.StandardReference, I.IsMandatory, I.SortOrder, C.NameAr AS ItemCategoryNameAr
    FROM dbo.InvestigationTemplateItems I
    LEFT JOIN dbo.LookupItems C ON C.LookupItemId=I.ItemCategoryId
    WHERE I.TemplateId=@TemplateId AND I.IsDeleted=0 AND I.IsActive=1
    ORDER BY I.SortOrder, I.TemplateItemId;
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectInvestigationTemplates_Suggest', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectInvestigationTemplates_Suggest;
GO
CREATE PROCEDURE dbo.sp_ProjectInvestigationTemplates_Suggest
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProjectTypeId BIGINT, @StageId BIGINT, @Area DECIMAL(18,2), @Floors INT;
    SELECT @ProjectTypeId=ProjectTypeId, @StageId=InvestigationStageId, @Area=SiteAreaM2, @Floors=NumberOfFloors
    FROM dbo.Projects WHERE ProjectId=@ProjectId AND IsDeleted=0;

    SELECT TOP 20 T.TemplateId, T.TemplateCode, T.TemplateNameAr, T.TemplateNameEn, T.ApplicabilitySummary,
           T.DefaultBoreholeCount, T.DefaultMinDepthM, T.DefaultSPTIntervalM,
           PT.NameAr AS ProjectTypeNameAr, ST.NameAr AS InvestigationStageNameAr, RL.NameAr AS RiskLevelNameAr,
           MatchScore =
             (CASE WHEN T.ProjectTypeId=@ProjectTypeId THEN 100 ELSE 0 END) +
             (CASE WHEN T.InvestigationStageId=@StageId THEN 20 ELSE 0 END) +
             (CASE WHEN (T.MinSiteAreaM2 IS NULL OR @Area IS NULL OR @Area>=T.MinSiteAreaM2) AND (T.MaxSiteAreaM2 IS NULL OR @Area IS NULL OR @Area<=T.MaxSiteAreaM2) THEN 10 ELSE 0 END) +
             (CASE WHEN (T.MinFloors IS NULL OR @Floors IS NULL OR @Floors>=T.MinFloors) AND (T.MaxFloors IS NULL OR @Floors IS NULL OR @Floors<=T.MaxFloors) THEN 10 ELSE 0 END) +
             (CASE WHEN T.IsDefault=1 THEN 5 ELSE 0 END)
    FROM dbo.InvestigationTemplates T
    LEFT JOIN dbo.LookupItems PT ON PT.LookupItemId=T.ProjectTypeId
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId=T.InvestigationStageId
    LEFT JOIN dbo.LookupItems RL ON RL.LookupItemId=T.RiskLevelId
    WHERE T.IsDeleted=0 AND T.IsActive=1
      AND (T.ProjectTypeId=@ProjectTypeId OR @ProjectTypeId IS NULL)
    ORDER BY MatchScore DESC, T.IsDefault DESC, T.TemplateCode;
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectInvestigationPlan_Generate', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectInvestigationPlan_Generate;
GO
CREATE PROCEDURE dbo.sp_ProjectInvestigationPlan_Generate
    @ProjectId BIGINT,
    @TemplateId BIGINT = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProjectTypeId BIGINT, @StageId BIGINT, @Area DECIMAL(18,2), @Floors INT, @ProjectName NVARCHAR(300);
    SELECT @ProjectTypeId=ProjectTypeId, @StageId=InvestigationStageId, @Area=SiteAreaM2, @Floors=NumberOfFloors, @ProjectName=ProjectName
    FROM dbo.Projects WHERE ProjectId=@ProjectId AND IsDeleted=0;

    IF @ProjectTypeId IS NULL
    BEGIN
        RAISERROR(N'لا يمكن توليد خطة التحري لأن نوع المشروع غير محدد.', 16, 1);
        RETURN;
    END

    IF @TemplateId IS NULL OR @TemplateId <= 0
    BEGIN
        SELECT TOP 1 @TemplateId=T.TemplateId
        FROM dbo.InvestigationTemplates T
        WHERE T.ProjectTypeId=@ProjectTypeId AND T.IsDeleted=0 AND T.IsActive=1
        ORDER BY
          (CASE WHEN T.InvestigationStageId=@StageId THEN 1 ELSE 0 END) DESC,
          (CASE WHEN (T.MinSiteAreaM2 IS NULL OR @Area IS NULL OR @Area>=T.MinSiteAreaM2) AND (T.MaxSiteAreaM2 IS NULL OR @Area IS NULL OR @Area<=T.MaxSiteAreaM2) THEN 1 ELSE 0 END) DESC,
          (CASE WHEN (T.MinFloors IS NULL OR @Floors IS NULL OR @Floors>=T.MinFloors) AND (T.MaxFloors IS NULL OR @Floors IS NULL OR @Floors<=T.MaxFloors) THEN 1 ELSE 0 END) DESC,
          T.IsDefault DESC, T.TemplateId;
    END

    IF @TemplateId IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.InvestigationTemplates WHERE TemplateId=@TemplateId AND IsDeleted=0 AND IsActive=1)
    BEGIN
        RAISERROR(N'لا يوجد قالب تحري مناسب لنوع هذا المشروع.', 16, 1);
        RETURN;
    END

    DECLARE @DraftStatusId BIGINT = (
        SELECT TOP 1 I.LookupItemId FROM dbo.LookupItems I INNER JOIN dbo.LookupCategories C ON C.LookupCategoryId=I.LookupCategoryId
        WHERE C.CategoryCode=N'InvestigationPlanStatus' AND I.ItemCode=N'DRAFT' AND C.IsDeleted=0 AND I.IsDeleted=0
    );
    DECLARE @PlannedItemStatusId BIGINT = (
        SELECT TOP 1 I.LookupItemId FROM dbo.LookupItems I INNER JOIN dbo.LookupCategories C ON C.LookupCategoryId=I.LookupCategoryId
        WHERE C.CategoryCode=N'InvestigationPlanItemStatus' AND I.ItemCode=N'PLANNED' AND C.IsDeleted=0 AND I.IsDeleted=0
    );

    DECLARE @OldPlanId BIGINT = (SELECT TOP 1 PlanId FROM dbo.ProjectInvestigationPlans WHERE ProjectId=@ProjectId AND IsDeleted=0 AND IsActive=1 ORDER BY RevisionNo DESC, PlanId DESC);
    DECLARE @RevisionNo INT = ISNULL((SELECT MAX(RevisionNo) FROM dbo.ProjectInvestigationPlans WHERE ProjectId=@ProjectId AND IsDeleted=0),0) + 1;
    IF @OldPlanId IS NOT NULL
    BEGIN
        UPDATE dbo.ProjectInvestigationPlans SET IsActive=0, UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId WHERE PlanId=@OldPlanId;
    END

    DECLARE @TemplateName NVARCHAR(300)=(SELECT TemplateNameAr FROM dbo.InvestigationTemplates WHERE TemplateId=@TemplateId);
    INSERT INTO dbo.ProjectInvestigationPlans(ProjectId, TemplateId, PlanTitle, PlanStatusId, GeneratedAt, GeneratedBy, RevisionNo, Notes, IsActive, CreatedBy)
    VALUES(@ProjectId, @TemplateId, ISNULL(@ProjectName,N'') + N' - خطة تحري - ' + ISNULL(@TemplateName,N''), @DraftStatusId, SYSDATETIME(), @UserId, @RevisionNo, N'خطة مولدة من قالب نوع المشروع؛ يجب مراجعتها وتعديلها حسب ظروف الموقع.', 1, @UserId);

    DECLARE @PlanId BIGINT = SCOPE_IDENTITY();

    INSERT INTO dbo.ProjectInvestigationPlanItems(PlanId, TemplateItemId, ItemCategoryId, ItemCode, ItemTitleAr, RecommendationText,
        PlannedQuantity, PlannedSpacingM, PlannedDepthM, FrequencyRule, DepthRule, StandardReference, IsMandatory, IsAccepted, ItemStatusId, SortOrder, CreatedBy)
    SELECT @PlanId, I.TemplateItemId, I.ItemCategoryId, I.ItemCode, I.ItemTitleAr, I.RecommendationText,
           CASE
             WHEN I.ItemCode IN (N'BH_COUNT', N'LARGE_FOOTPRINT_GRID') AND @Area IS NOT NULL AND @Area > 0 THEN
                CASE WHEN CEILING(@Area / 500.0) > ISNULL(I.MinQuantity,0) THEN CEILING(@Area / 500.0) ELSE I.MinQuantity END
             WHEN I.ItemCode=N'BH_DEEP_GRID' AND @Floors IS NOT NULL AND @Floors >= 15 THEN
                CASE WHEN ISNULL(I.MinQuantity,0) < 8 THEN 8 ELSE I.MinQuantity END
             ELSE I.MinQuantity END,
           I.SpacingMeters,
           CASE
             WHEN I.ItemCode=N'BH_COUNT' AND @Floors IS NOT NULL AND @Floors > 10 THEN ISNULL(I.MinDepthM,15) + ((@Floors-10) * 1.0)
             ELSE I.MinDepthM END,
           I.FrequencyRule, I.DepthRule, I.StandardReference, I.IsMandatory, 1, @PlannedItemStatusId, I.SortOrder, @UserId
    FROM dbo.InvestigationTemplateItems I
    WHERE I.TemplateId=@TemplateId AND I.IsDeleted=0 AND I.IsActive=1
    ORDER BY I.SortOrder;

    IF OBJECT_ID(N'dbo.AuditLogs', N'U') IS NOT NULL
    BEGIN
        INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription, NewValues)
        SELECT @UserId, U.Username, N'Generate', N'ProjectInvestigationPlan', CONVERT(NVARCHAR(100),@PlanId), N'تم توليد خطة تحري من قالب نوع المشروع.', N'ProjectId=' + CONVERT(NVARCHAR(50),@ProjectId) + N'; TemplateId=' + CONVERT(NVARCHAR(50),@TemplateId)
        FROM dbo.Users U WHERE U.UserId=@UserId;
    END

    SELECT @PlanId AS PlanId;
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectInvestigationPlans_Get', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectInvestigationPlans_Get;
GO
CREATE PROCEDURE dbo.sp_ProjectInvestigationPlans_Get
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT P.PlanId, P.ProjectId, P.TemplateId, P.PlanTitle, P.RevisionNo, P.GeneratedAt, P.IsApproved, P.IsActive,
           P.Notes, P.ApprovalNotes, T.TemplateCode, T.TemplateNameAr,
           S.NameAr AS PlanStatusNameAr,
           ItemCount=(SELECT COUNT(1) FROM dbo.ProjectInvestigationPlanItems I WHERE I.PlanId=P.PlanId AND I.IsDeleted=0),
           AcceptedCount=(SELECT COUNT(1) FROM dbo.ProjectInvestigationPlanItems I WHERE I.PlanId=P.PlanId AND I.IsDeleted=0 AND I.IsAccepted=1)
    FROM dbo.ProjectInvestigationPlans P
    LEFT JOIN dbo.InvestigationTemplates T ON T.TemplateId=P.TemplateId
    LEFT JOIN dbo.LookupItems S ON S.LookupItemId=P.PlanStatusId
    WHERE P.ProjectId=@ProjectId AND P.IsDeleted=0
    ORDER BY P.IsActive DESC, P.RevisionNo DESC, P.PlanId DESC;
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectInvestigationPlan_GetById', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectInvestigationPlan_GetById;
GO
CREATE PROCEDURE dbo.sp_ProjectInvestigationPlan_GetById
    @PlanId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT P.*, T.TemplateCode, T.TemplateNameAr, S.NameAr AS PlanStatusNameAr,
           PR.ProjectCode, PR.ProjectName, PT.NameAr AS ProjectTypeNameAr
    FROM dbo.ProjectInvestigationPlans P
    INNER JOIN dbo.Projects PR ON PR.ProjectId=P.ProjectId
    LEFT JOIN dbo.InvestigationTemplates T ON T.TemplateId=P.TemplateId
    LEFT JOIN dbo.LookupItems S ON S.LookupItemId=P.PlanStatusId
    LEFT JOIN dbo.LookupItems PT ON PT.LookupItemId=PR.ProjectTypeId
    WHERE P.PlanId=@PlanId AND P.IsDeleted=0;
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectInvestigationPlanItems_Get', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectInvestigationPlanItems_Get;
GO
CREATE PROCEDURE dbo.sp_ProjectInvestigationPlanItems_Get
    @PlanId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT I.PlanItemId, I.PlanId, I.TemplateItemId, I.ItemCode, I.ItemTitleAr, I.RecommendationText,
           I.PlannedQuantity, I.PlannedSpacingM, I.PlannedDepthM, I.FrequencyRule, I.DepthRule,
           I.StandardReference, I.IsMandatory, I.IsAccepted, I.EngineerNotes, I.SortOrder,
           C.NameAr AS ItemCategoryNameAr, S.NameAr AS ItemStatusNameAr
    FROM dbo.ProjectInvestigationPlanItems I
    LEFT JOIN dbo.LookupItems C ON C.LookupItemId=I.ItemCategoryId
    LEFT JOIN dbo.LookupItems S ON S.LookupItemId=I.ItemStatusId
    WHERE I.PlanId=@PlanId AND I.IsDeleted=0
    ORDER BY I.SortOrder, I.PlanItemId;
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectInvestigationPlanItem_Save', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectInvestigationPlanItem_Save;
GO
CREATE PROCEDURE dbo.sp_ProjectInvestigationPlanItem_Save
    @PlanItemId BIGINT,
    @PlannedQuantity DECIMAL(18,2) = NULL,
    @PlannedSpacingM DECIMAL(18,2) = NULL,
    @PlannedDepthM DECIMAL(18,2) = NULL,
    @IsAccepted BIT = 1,
    @EngineerNotes NVARCHAR(MAX) = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ModifiedStatusId BIGINT = (
        SELECT TOP 1 I.LookupItemId FROM dbo.LookupItems I INNER JOIN dbo.LookupCategories C ON C.LookupCategoryId=I.LookupCategoryId
        WHERE C.CategoryCode=N'InvestigationPlanItemStatus' AND I.ItemCode=N'MODIFIED' AND C.IsDeleted=0 AND I.IsDeleted=0
    );
    UPDATE dbo.ProjectInvestigationPlanItems
    SET PlannedQuantity=@PlannedQuantity,
        PlannedSpacingM=@PlannedSpacingM,
        PlannedDepthM=@PlannedDepthM,
        IsAccepted=ISNULL(@IsAccepted,1),
        EngineerNotes=@EngineerNotes,
        ItemStatusId=@ModifiedStatusId,
        UpdatedAt=SYSDATETIME(),
        UpdatedBy=@UserId
    WHERE PlanItemId=@PlanItemId AND IsDeleted=0;
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectInvestigationPlan_Approve', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectInvestigationPlan_Approve;
GO
CREATE PROCEDURE dbo.sp_ProjectInvestigationPlan_Approve
    @PlanId BIGINT,
    @ApprovalNotes NVARCHAR(MAX) = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ApprovedStatusId BIGINT = (
        SELECT TOP 1 I.LookupItemId FROM dbo.LookupItems I INNER JOIN dbo.LookupCategories C ON C.LookupCategoryId=I.LookupCategoryId
        WHERE C.CategoryCode=N'InvestigationPlanStatus' AND I.ItemCode=N'APPROVED' AND C.IsDeleted=0 AND I.IsDeleted=0
    );
    UPDATE dbo.ProjectInvestigationPlans
    SET IsApproved=1, ApprovedAt=SYSDATETIME(), ApprovedBy=@UserId, ApprovalNotes=@ApprovalNotes,
        PlanStatusId=@ApprovedStatusId, UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId
    WHERE PlanId=@PlanId AND IsDeleted=0;
END
GO

PRINT N'Sprint 8 stored procedures created successfully.';
GO
