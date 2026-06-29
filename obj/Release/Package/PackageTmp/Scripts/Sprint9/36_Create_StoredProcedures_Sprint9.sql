USE GeoSitePro;
GO

IF OBJECT_ID(N'dbo.sp_LookupItems_GetByCategory', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_LookupItems_GetByCategory;
GO
CREATE PROCEDURE dbo.sp_LookupItems_GetByCategory
    @CategoryCode NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT I.LookupItemId, I.ItemCode, I.NameAr, I.NameEn, I.Description, I.SortOrder, I.IsDefault
    FROM dbo.LookupItems I
    INNER JOIN dbo.LookupCategories C ON C.LookupCategoryId=I.LookupCategoryId
    WHERE C.CategoryCode=@CategoryCode AND C.IsDeleted=0 AND I.IsDeleted=0 AND I.IsActive=1
    ORDER BY I.SortOrder, I.NameAr;
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectMap_Get', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectMap_Get;
GO
CREATE PROCEDURE dbo.sp_ProjectMap_Get
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT P.ProjectId, P.ProjectCode, P.ProjectName, P.City, P.LocationName, P.SiteAreaM2, P.NumberOfFloors, P.BasementCount,
           PT.NameAr AS ProjectTypeNameAr, ST.NameAr AS StructureTypeNameAr
    FROM dbo.Projects P
    LEFT JOIN dbo.LookupItems PT ON PT.LookupItemId=P.ProjectTypeId
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId=P.StructureTypeId
    WHERE P.ProjectId=@ProjectId AND P.IsDeleted=0;

    SELECT TOP 1 * FROM dbo.ProjectMapSettings WHERE ProjectId=@ProjectId AND IsDeleted=0 ORDER BY MapSettingId DESC;

    SELECT B.BoreholeId, B.BoreholeCode, B.Easting, B.Northing, B.ElevationM, B.PlannedDepthM, B.ActualDepthM, B.GroundwaterDepthM, B.LocationDescription
    FROM dbo.Boreholes B
    WHERE B.ProjectId=@ProjectId AND B.IsDeleted=0
    ORDER BY B.BoreholeCode;

    SELECT LP.LayoutPointId, LP.ProjectId, LP.BoreholeId, LP.PlanId, LP.SourceTypeId, LP.BoreholeCode,
           LP.Easting, LP.Northing, LP.ElevationM, LP.PlannedDepthM, LP.ActualDepthM, LP.SortOrder, LP.Notes,
           SRC.ItemCode AS SourceTypeCode, SRC.NameAr AS SourceTypeNameAr, SRC.NameEn AS SourceTypeNameEn
    FROM dbo.ProjectBoreholeLayoutPoints LP
    LEFT JOIN dbo.LookupItems SRC ON SRC.LookupItemId=LP.SourceTypeId
    WHERE LP.ProjectId=@ProjectId AND LP.IsDeleted=0
    ORDER BY LP.SortOrder, LP.BoreholeCode, LP.LayoutPointId;

    SELECT ActualBoreholeCount = (SELECT COUNT(1) FROM dbo.Boreholes WHERE ProjectId=@ProjectId AND IsDeleted=0),
           LayoutPointCount = (SELECT COUNT(1) FROM dbo.ProjectBoreholeLayoutPoints WHERE ProjectId=@ProjectId AND IsDeleted=0),
           MissingCoordinateCount = (SELECT COUNT(1) FROM dbo.ProjectBoreholeLayoutPoints WHERE ProjectId=@ProjectId AND IsDeleted=0 AND (Easting IS NULL OR Northing IS NULL));
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectMapSettings_Save', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectMapSettings_Save;
GO
CREATE PROCEDURE dbo.sp_ProjectMapSettings_Save
    @ProjectId BIGINT,
    @CoordinateSystem NVARCHAR(200) = NULL,
    @EPSGCode NVARCHAR(50) = NULL,
    @OriginEasting DECIMAL(18,3) = NULL,
    @OriginNorthing DECIMAL(18,3) = NULL,
    @ScaleDenominator DECIMAL(18,2) = NULL,
    @NorthAngleDeg DECIMAL(10,3) = NULL,
    @SiteBoundaryText NVARCHAR(MAX) = NULL,
    @Notes NVARCHAR(MAX) = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT 1 FROM dbo.ProjectMapSettings WHERE ProjectId=@ProjectId AND IsDeleted=0)
    BEGIN
        UPDATE dbo.ProjectMapSettings
        SET CoordinateSystem=NULLIF(LTRIM(RTRIM(@CoordinateSystem)),N''), EPSGCode=NULLIF(LTRIM(RTRIM(@EPSGCode)),N''),
            OriginEasting=@OriginEasting, OriginNorthing=@OriginNorthing, ScaleDenominator=@ScaleDenominator, NorthAngleDeg=@NorthAngleDeg,
            SiteBoundaryText=@SiteBoundaryText, Notes=@Notes, UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId
        WHERE ProjectId=@ProjectId AND IsDeleted=0;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.ProjectMapSettings(ProjectId, CoordinateSystem, EPSGCode, OriginEasting, OriginNorthing, ScaleDenominator, NorthAngleDeg, SiteBoundaryText, Notes, CreatedBy)
        VALUES(@ProjectId, NULLIF(LTRIM(RTRIM(@CoordinateSystem)),N''), NULLIF(LTRIM(RTRIM(@EPSGCode)),N''), @OriginEasting, @OriginNorthing, @ScaleDenominator, @NorthAngleDeg, @SiteBoundaryText, @Notes, @UserId);
    END

    INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription)
    VALUES(@UserId, (SELECT Username FROM dbo.Users WHERE UserId=@UserId), N'Save', N'ProjectMapSettings', CONVERT(NVARCHAR(100), @ProjectId), N'تم حفظ إعدادات خريطة المشروع.');
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectBoreholeLayoutPoints_Get', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectBoreholeLayoutPoints_Get;
GO
CREATE PROCEDURE dbo.sp_ProjectBoreholeLayoutPoints_Get
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT LP.LayoutPointId, LP.ProjectId, LP.BoreholeId, LP.PlanId, LP.SourceTypeId, LP.BoreholeCode,
           LP.Easting, LP.Northing, LP.ElevationM, LP.PlannedDepthM, LP.ActualDepthM, LP.SortOrder, LP.Notes,
           SRC.ItemCode AS SourceTypeCode, SRC.NameAr AS SourceTypeNameAr
    FROM dbo.ProjectBoreholeLayoutPoints LP
    LEFT JOIN dbo.LookupItems SRC ON SRC.LookupItemId=LP.SourceTypeId
    WHERE LP.ProjectId=@ProjectId AND LP.IsDeleted=0
    ORDER BY LP.SortOrder, LP.BoreholeCode, LP.LayoutPointId;
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectBoreholeLayoutPoint_GetById', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectBoreholeLayoutPoint_GetById;
GO
CREATE PROCEDURE dbo.sp_ProjectBoreholeLayoutPoint_GetById
    @LayoutPointId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.ProjectBoreholeLayoutPoints WHERE LayoutPointId=@LayoutPointId AND IsDeleted=0;
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectBoreholeLayoutPoint_Save', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectBoreholeLayoutPoint_Save;
GO
CREATE PROCEDURE dbo.sp_ProjectBoreholeLayoutPoint_Save
    @LayoutPointId BIGINT = NULL,
    @ProjectId BIGINT,
    @SourceTypeId BIGINT = NULL,
    @BoreholeCode NVARCHAR(80),
    @Easting DECIMAL(18,3) = NULL,
    @Northing DECIMAL(18,3) = NULL,
    @ElevationM DECIMAL(10,3) = NULL,
    @PlannedDepthM DECIMAL(10,2) = NULL,
    @Notes NVARCHAR(MAX) = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @SourceTypeId IS NULL
        SELECT TOP 1 @SourceTypeId=I.LookupItemId FROM dbo.LookupItems I INNER JOIN dbo.LookupCategories C ON C.LookupCategoryId=I.LookupCategoryId WHERE C.CategoryCode=N'MapPointSource' AND I.ItemCode=N'MANUAL' AND I.IsDeleted=0;

    IF @LayoutPointId IS NULL OR @LayoutPointId <= 0
    BEGIN
        IF @BoreholeCode IS NULL OR LTRIM(RTRIM(@BoreholeCode))=N''
            SET @BoreholeCode = N'BH-P' + RIGHT(N'000' + CONVERT(NVARCHAR(20), ISNULL((SELECT COUNT(1)+1 FROM dbo.ProjectBoreholeLayoutPoints WHERE ProjectId=@ProjectId),1)),3);
        INSERT INTO dbo.ProjectBoreholeLayoutPoints(ProjectId, SourceTypeId, BoreholeCode, Easting, Northing, ElevationM, PlannedDepthM, Notes, CreatedBy)
        VALUES(@ProjectId, @SourceTypeId, @BoreholeCode, @Easting, @Northing, @ElevationM, @PlannedDepthM, @Notes, @UserId);
        SELECT SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.ProjectBoreholeLayoutPoints
        SET SourceTypeId=@SourceTypeId, BoreholeCode=NULLIF(LTRIM(RTRIM(@BoreholeCode)),N''), Easting=@Easting, Northing=@Northing,
            ElevationM=@ElevationM, PlannedDepthM=@PlannedDepthM, Notes=@Notes, UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId
        WHERE LayoutPointId=@LayoutPointId AND IsDeleted=0;
        SELECT @LayoutPointId;
    END
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectBoreholeLayoutPoint_Delete', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectBoreholeLayoutPoint_Delete;
GO
CREATE PROCEDURE dbo.sp_ProjectBoreholeLayoutPoint_Delete
    @LayoutPointId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProjectBoreholeLayoutPoints SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE LayoutPointId=@LayoutPointId;
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectBoreholeLayout_GenerateFromActual', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectBoreholeLayout_GenerateFromActual;
GO
CREATE PROCEDURE dbo.sp_ProjectBoreholeLayout_GenerateFromActual
    @ProjectId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SourceTypeId BIGINT;
    SELECT TOP 1 @SourceTypeId=I.LookupItemId FROM dbo.LookupItems I INNER JOIN dbo.LookupCategories C ON C.LookupCategoryId=I.LookupCategoryId WHERE C.CategoryCode=N'MapPointSource' AND I.ItemCode=N'ACTUAL' AND I.IsDeleted=0;

    INSERT INTO dbo.ProjectBoreholeLayoutPoints(ProjectId, BoreholeId, SourceTypeId, BoreholeCode, Easting, Northing, ElevationM, PlannedDepthM, ActualDepthM, SortOrder, Notes, CreatedBy)
    SELECT B.ProjectId, B.BoreholeId, @SourceTypeId, B.BoreholeCode, B.Easting, B.Northing, B.ElevationM, B.PlannedDepthM, B.ActualDepthM,
           ROW_NUMBER() OVER(ORDER BY B.BoreholeCode)*10, N'Generated from actual borehole record.', @UserId
    FROM dbo.Boreholes B
    WHERE B.ProjectId=@ProjectId AND B.IsDeleted=0
      AND NOT EXISTS(SELECT 1 FROM dbo.ProjectBoreholeLayoutPoints LP WHERE LP.ProjectId=@ProjectId AND LP.IsDeleted=0 AND (LP.BoreholeId=B.BoreholeId OR LP.BoreholeCode=B.BoreholeCode));

    INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription)
    VALUES(@UserId, (SELECT Username FROM dbo.Users WHERE UserId=@UserId), N'Generate', N'ProjectBoreholeLayoutPoints', CONVERT(NVARCHAR(100), @ProjectId), N'تم توليد نقاط خريطة الجسات من الجسات الفعلية.');
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectBoreholeLayout_GenerateFromApprovedPlan', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectBoreholeLayout_GenerateFromApprovedPlan;
GO
CREATE PROCEDURE dbo.sp_ProjectBoreholeLayout_GenerateFromApprovedPlan
    @ProjectId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @PlanId BIGINT, @Qty INT, @Depth DECIMAL(10,2), @Spacing DECIMAL(18,3), @OriginE DECIMAL(18,3), @OriginN DECIMAL(18,3), @SourceTypeId BIGINT;

    SELECT TOP 1 @PlanId=PlanId FROM dbo.ProjectInvestigationPlans
    WHERE ProjectId=@ProjectId AND IsDeleted=0
    ORDER BY IsApproved DESC, RevisionNo DESC, PlanId DESC;

    IF @PlanId IS NULL
    BEGIN
        RAISERROR(N'لا توجد خطة تحري لهذا المشروع. ولّد خطة التحري أولًا من Sprint 8.', 16, 1);
        RETURN;
    END

    SELECT @Qty = CONVERT(INT, ISNULL(MAX(NULLIF(PlannedQuantity,0)),4)),
           @Depth = ISNULL(MAX(PlannedDepthM), 15),
           @Spacing = ISNULL(MAX(PlannedSpacingM), 20)
    FROM dbo.ProjectInvestigationPlanItems PI
    LEFT JOIN dbo.LookupItems LI ON LI.LookupItemId=PI.ItemCategoryId
    WHERE PI.PlanId=@PlanId AND PI.IsDeleted=0 AND PI.IsAccepted=1 AND (LI.ItemCode=N'BOREHOLE' OR PI.ItemCode LIKE N'%BH%' OR PI.ItemTitleAr LIKE N'%جس%');

    IF @Qty IS NULL OR @Qty < 1 SET @Qty = 4;
    IF @Qty > 50 SET @Qty = 50;
    IF @Spacing IS NULL OR @Spacing <= 0 SET @Spacing = 20;
    IF @Depth IS NULL OR @Depth <= 0 SET @Depth = 15;

    SELECT TOP 1 @OriginE=OriginEasting, @OriginN=OriginNorthing FROM dbo.ProjectMapSettings WHERE ProjectId=@ProjectId AND IsDeleted=0;
    IF @OriginE IS NULL SET @OriginE = 0;
    IF @OriginN IS NULL SET @OriginN = 0;
    SELECT TOP 1 @SourceTypeId=I.LookupItemId FROM dbo.LookupItems I INNER JOIN dbo.LookupCategories C ON C.LookupCategoryId=I.LookupCategoryId WHERE C.CategoryCode=N'MapPointSource' AND I.ItemCode=N'PLANNED' AND I.IsDeleted=0;

    DECLARE @i INT = 1, @cols INT = CEILING(SQRT(CONVERT(FLOAT,@Qty))), @code NVARCHAR(80), @row INT, @col INT;
    WHILE @i <= @Qty
    BEGIN
        SET @code = N'BH-P' + RIGHT(N'000' + CONVERT(NVARCHAR(20), @i), 3);
        SET @col = (@i - 1) % @cols;
        SET @row = (@i - 1) / @cols;
        IF NOT EXISTS(SELECT 1 FROM dbo.ProjectBoreholeLayoutPoints WHERE ProjectId=@ProjectId AND BoreholeCode=@code AND IsDeleted=0)
        BEGIN
            INSERT INTO dbo.ProjectBoreholeLayoutPoints(ProjectId, PlanId, SourceTypeId, BoreholeCode, Easting, Northing, PlannedDepthM, SortOrder, Notes, CreatedBy)
            VALUES(@ProjectId, @PlanId, @SourceTypeId, @code, @OriginE + (@col * @Spacing), @OriginN + (@row * @Spacing), @Depth, @i*10, N'Generated from project investigation plan. Move coordinates after reviewing architectural/site plan.', @UserId);
        END
        SET @i += 1;
    END
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectCrossSections_Get', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectCrossSections_Get;
GO
CREATE PROCEDURE dbo.sp_ProjectCrossSections_Get
    @ProjectId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CS.CrossSectionId, CS.ProjectId, CS.SectionCode, CS.SectionName, CS.BaselineType, CS.HorizontalScale, CS.VerticalScale,
           CS.SectionStatusId, ST.NameAr AS SectionStatusNameAr, CS.CreatedAt,
           BoreholeCount=(SELECT COUNT(1) FROM dbo.ProjectCrossSectionBoreholes CB WHERE CB.CrossSectionId=CS.CrossSectionId AND CB.IsDeleted=0)
    FROM dbo.ProjectCrossSections CS
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId=CS.SectionStatusId
    WHERE CS.ProjectId=@ProjectId AND CS.IsDeleted=0
    ORDER BY CS.SectionCode, CS.CrossSectionId;
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectCrossSection_GetById', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectCrossSection_GetById;
GO
CREATE PROCEDURE dbo.sp_ProjectCrossSection_GetById
    @CrossSectionId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.ProjectCrossSections WHERE CrossSectionId=@CrossSectionId AND IsDeleted=0;
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectCrossSection_Save', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectCrossSection_Save;
GO
CREATE PROCEDURE dbo.sp_ProjectCrossSection_Save
    @CrossSectionId BIGINT = NULL,
    @ProjectId BIGINT,
    @SectionCode NVARCHAR(80) = NULL,
    @SectionName NVARCHAR(250) = NULL,
    @BaselineType NVARCHAR(50) = N'EASTING',
    @SectionStatusId BIGINT = NULL,
    @HorizontalScale DECIMAL(18,2) = NULL,
    @VerticalScale DECIMAL(18,2) = NULL,
    @StartEasting DECIMAL(18,3) = NULL,
    @StartNorthing DECIMAL(18,3) = NULL,
    @EndEasting DECIMAL(18,3) = NULL,
    @EndNorthing DECIMAL(18,3) = NULL,
    @Notes NVARCHAR(MAX) = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @SectionStatusId IS NULL
        SELECT TOP 1 @SectionStatusId=I.LookupItemId FROM dbo.LookupItems I INNER JOIN dbo.LookupCategories C ON C.LookupCategoryId=I.LookupCategoryId WHERE C.CategoryCode=N'CrossSectionStatus' AND I.ItemCode=N'DRAFT' AND I.IsDeleted=0;
    IF @SectionCode IS NULL OR LTRIM(RTRIM(@SectionCode))=N''
        SET @SectionCode = N'SEC-' + RIGHT(N'000' + CONVERT(NVARCHAR(20), ISNULL((SELECT COUNT(1)+1 FROM dbo.ProjectCrossSections WHERE ProjectId=@ProjectId),1)),3);

    IF @CrossSectionId IS NULL OR @CrossSectionId <= 0
    BEGIN
        INSERT INTO dbo.ProjectCrossSections(ProjectId, SectionCode, SectionName, BaselineType, SectionStatusId, StartEasting, StartNorthing, EndEasting, EndNorthing, HorizontalScale, VerticalScale, Notes, CreatedBy)
        VALUES(@ProjectId, @SectionCode, NULLIF(LTRIM(RTRIM(@SectionName)),N''), ISNULL(NULLIF(@BaselineType,N''),N'EASTING'), @SectionStatusId, @StartEasting, @StartNorthing, @EndEasting, @EndNorthing, @HorizontalScale, @VerticalScale, @Notes, @UserId);
        SELECT SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.ProjectCrossSections
        SET SectionCode=@SectionCode, SectionName=NULLIF(LTRIM(RTRIM(@SectionName)),N''), BaselineType=ISNULL(NULLIF(@BaselineType,N''),N'EASTING'), SectionStatusId=@SectionStatusId,
            StartEasting=@StartEasting, StartNorthing=@StartNorthing, EndEasting=@EndEasting, EndNorthing=@EndNorthing, HorizontalScale=@HorizontalScale, VerticalScale=@VerticalScale,
            Notes=@Notes, UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId
        WHERE CrossSectionId=@CrossSectionId AND IsDeleted=0;
        SELECT @CrossSectionId;
    END
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectCrossSection_GenerateBoreholes', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectCrossSection_GenerateBoreholes;
GO
CREATE PROCEDURE dbo.sp_ProjectCrossSection_GenerateBoreholes
    @CrossSectionId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProjectId BIGINT, @BaselineType NVARCHAR(50), @MinE DECIMAL(18,3), @MinN DECIMAL(18,3);
    SELECT @ProjectId=ProjectId, @BaselineType=BaselineType FROM dbo.ProjectCrossSections WHERE CrossSectionId=@CrossSectionId AND IsDeleted=0;
    IF @ProjectId IS NULL BEGIN RAISERROR(N'المقطع غير موجود.',16,1); RETURN; END

    SELECT @MinE=MIN(Easting), @MinN=MIN(Northing) FROM dbo.Boreholes WHERE ProjectId=@ProjectId AND IsDeleted=0;
    IF @MinE IS NULL SET @MinE = 0;
    IF @MinN IS NULL SET @MinN = 0;

    UPDATE dbo.ProjectCrossSectionBoreholes SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE CrossSectionId=@CrossSectionId AND IsDeleted=0;

    ;WITH B AS (
        SELECT B.BoreholeId, B.BoreholeCode, B.Easting, B.Northing,
               ChainageM = CASE WHEN @BaselineType=N'NORTHING' THEN ISNULL(B.Northing-@MinN, ROW_NUMBER() OVER(ORDER BY B.BoreholeCode)*10)
                                WHEN @BaselineType=N'EASTING' THEN ISNULL(B.Easting-@MinE, ROW_NUMBER() OVER(ORDER BY B.BoreholeCode)*10)
                                ELSE ROW_NUMBER() OVER(ORDER BY B.BoreholeCode)*10 END,
               OffsetM = CASE WHEN @BaselineType=N'NORTHING' THEN ISNULL(B.Easting-@MinE,0)
                              WHEN @BaselineType=N'EASTING' THEN ISNULL(B.Northing-@MinN,0)
                              ELSE 0 END,
               SortOrder = ROW_NUMBER() OVER(ORDER BY CASE WHEN @BaselineType=N'NORTHING' THEN ISNULL(B.Northing,0) ELSE ISNULL(B.Easting,0) END, B.BoreholeCode)
        FROM dbo.Boreholes B
        WHERE B.ProjectId=@ProjectId AND B.IsDeleted=0
    )
    INSERT INTO dbo.ProjectCrossSectionBoreholes(CrossSectionId, BoreholeId, ChainageM, OffsetM, SortOrder, CreatedBy)
    SELECT @CrossSectionId, BoreholeId, ChainageM, OffsetM, SortOrder*10, @UserId FROM B;
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectCrossSectionData_Get', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectCrossSectionData_Get;
GO
CREATE PROCEDURE dbo.sp_ProjectCrossSectionData_Get
    @CrossSectionId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CS.*, ST.NameAr AS SectionStatusNameAr
    FROM dbo.ProjectCrossSections CS
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId=CS.SectionStatusId
    WHERE CS.CrossSectionId=@CrossSectionId AND CS.IsDeleted=0;

    SELECT CB.CrossSectionBoreholeId, CB.CrossSectionId, CB.BoreholeId, CB.ChainageM, CB.OffsetM, CB.SortOrder,
           B.BoreholeCode, B.Easting, B.Northing, B.ElevationM, B.PlannedDepthM, B.ActualDepthM, B.GroundwaterDepthM
    FROM dbo.ProjectCrossSectionBoreholes CB
    INNER JOIN dbo.Boreholes B ON B.BoreholeId=CB.BoreholeId AND B.IsDeleted=0
    WHERE CB.CrossSectionId=@CrossSectionId AND CB.IsDeleted=0
    ORDER BY CB.SortOrder, CB.ChainageM, B.BoreholeCode;

    SELECT B.BoreholeId, B.BoreholeCode, L.LayerId,
           L.FromDepthM AS DepthFromM, L.ToDepthM AS DepthToM,
           ISNULL(NULLIF(L.Description,N''), ISNULL(SR.NameAr,N'Layer')) AS LayerDescription,
           L.USCS, L.Color, L.ConsistencyDensity, L.MoistureCondition, L.RecoveryPercent, L.RQDPercent,
           CB.SortOrder
    FROM dbo.ProjectCrossSectionBoreholes CB
    INNER JOIN dbo.Boreholes B ON B.BoreholeId=CB.BoreholeId AND B.IsDeleted=0
    INNER JOIN dbo.BoreholeLayers L ON L.BoreholeId=B.BoreholeId AND L.IsDeleted=0
    LEFT JOIN dbo.LookupItems SR ON SR.LookupItemId=L.SoilRockTypeId
    WHERE CB.CrossSectionId=@CrossSectionId AND CB.IsDeleted=0
    ORDER BY CB.SortOrder, L.FromDepthM, L.ToDepthM;
END
GO

IF OBJECT_ID(N'dbo.sp_ProjectCrossSection_Delete', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProjectCrossSection_Delete;
GO
CREATE PROCEDURE dbo.sp_ProjectCrossSection_Delete
    @CrossSectionId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProjectCrossSections SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE CrossSectionId=@CrossSectionId;
    UPDATE dbo.ProjectCrossSectionBoreholes SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE CrossSectionId=@CrossSectionId AND IsDeleted=0;
END
GO

PRINT N'Sprint 9 stored procedures created successfully.';
GO
