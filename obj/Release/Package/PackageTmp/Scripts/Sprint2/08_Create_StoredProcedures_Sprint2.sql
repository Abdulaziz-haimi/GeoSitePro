USE GeoSitePro;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Boreholes_Get
    @ProjectId BIGINT = NULL,
    @SearchText NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @SearchText = NULLIF(LTRIM(RTRIM(@SearchText)), N'');

    SELECT
        B.BoreholeId, B.ProjectId, B.BoreholeCode, B.PlannedDepthM, B.ActualDepthM, B.Easting, B.Northing, B.ElevationM,
        B.DrillingMethodId, DM.NameAr AS DrillingMethodNameAr,
        B.BoreholeStatusId, BS.NameAr AS BoreholeStatusNameAr,
        B.StartDate, B.EndDate, B.GroundwaterDepthM, B.LocationDescription, B.FieldEngineer, B.TerminationReason, B.Notes,
        B.IsActive, P.ProjectCode, P.ProjectName
    FROM dbo.Boreholes B
    INNER JOIN dbo.Projects P ON P.ProjectId = B.ProjectId AND P.IsDeleted = 0
    LEFT JOIN dbo.LookupItems DM ON DM.LookupItemId = B.DrillingMethodId AND DM.IsDeleted = 0
    LEFT JOIN dbo.LookupItems BS ON BS.LookupItemId = B.BoreholeStatusId AND BS.IsDeleted = 0
    WHERE B.IsDeleted = 0
      AND (@ProjectId IS NULL OR B.ProjectId = @ProjectId)
      AND (@SearchText IS NULL OR B.BoreholeCode LIKE N'%' + @SearchText + N'%' OR P.ProjectCode LIKE N'%' + @SearchText + N'%' OR P.ProjectName LIKE N'%' + @SearchText + N'%' OR B.FieldEngineer LIKE N'%' + @SearchText + N'%')
    ORDER BY P.ProjectCode, B.BoreholeCode;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Borehole_GetById
    @BoreholeId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT B.*, P.ProjectCode, P.ProjectName, DM.NameAr AS DrillingMethodNameAr, BS.NameAr AS BoreholeStatusNameAr
    FROM dbo.Boreholes B
    INNER JOIN dbo.Projects P ON P.ProjectId = B.ProjectId AND P.IsDeleted = 0
    LEFT JOIN dbo.LookupItems DM ON DM.LookupItemId = B.DrillingMethodId AND DM.IsDeleted = 0
    LEFT JOIN dbo.LookupItems BS ON BS.LookupItemId = B.BoreholeStatusId AND BS.IsDeleted = 0
    WHERE B.BoreholeId = @BoreholeId AND B.IsDeleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Borehole_Save
    @BoreholeId BIGINT = NULL,
    @ProjectId BIGINT,
    @BoreholeCode NVARCHAR(80),
    @PlannedDepthM DECIMAL(10,2) = NULL,
    @ActualDepthM DECIMAL(10,2),
    @Easting DECIMAL(18,3) = NULL,
    @Northing DECIMAL(18,3) = NULL,
    @ElevationM DECIMAL(10,3) = NULL,
    @DrillingMethodId BIGINT = NULL,
    @BoreholeStatusId BIGINT = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @GroundwaterDepthM DECIMAL(10,2) = NULL,
    @LocationDescription NVARCHAR(500) = NULL,
    @FieldEngineer NVARCHAR(200) = NULL,
    @TerminationReason NVARCHAR(500) = NULL,
    @Notes NVARCHAR(MAX) = NULL,
    @IsActive BIT = 1,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @BoreholeCode = LTRIM(RTRIM(@BoreholeCode));
    IF @ProjectId IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.Projects WHERE ProjectId=@ProjectId AND IsDeleted=0) BEGIN RAISERROR(N'المشروع غير موجود.',16,1); RETURN; END
    IF @BoreholeCode IS NULL OR @BoreholeCode = N'' BEGIN RAISERROR(N'كود الجسة مطلوب.',16,1); RETURN; END
    IF @ActualDepthM IS NULL OR @ActualDepthM <= 0 BEGIN RAISERROR(N'العمق الفعلي يجب أن يكون أكبر من صفر.',16,1); RETURN; END
    IF @EndDate IS NOT NULL AND @StartDate IS NOT NULL AND @EndDate < @StartDate BEGIN RAISERROR(N'تاريخ نهاية الحفر لا يمكن أن يكون قبل تاريخ البداية.',16,1); RETURN; END
    IF EXISTS(SELECT 1 FROM dbo.Boreholes WHERE ProjectId=@ProjectId AND BoreholeCode=@BoreholeCode AND IsDeleted=0 AND (@BoreholeId IS NULL OR BoreholeId<>@BoreholeId)) BEGIN RAISERROR(N'كود الجسة مستخدم مسبقًا داخل نفس المشروع.',16,1); RETURN; END

    IF @BoreholeId IS NULL OR @BoreholeId <= 0
    BEGIN
        INSERT INTO dbo.Boreholes(ProjectId, BoreholeCode, PlannedDepthM, ActualDepthM, Easting, Northing, ElevationM, DrillingMethodId, BoreholeStatusId, StartDate, EndDate, GroundwaterDepthM, LocationDescription, FieldEngineer, TerminationReason, Notes, IsActive, CreatedBy)
        VALUES(@ProjectId, @BoreholeCode, @PlannedDepthM, @ActualDepthM, @Easting, @Northing, @ElevationM, @DrillingMethodId, @BoreholeStatusId, @StartDate, @EndDate, @GroundwaterDepthM, NULLIF(LTRIM(RTRIM(@LocationDescription)),N''), NULLIF(LTRIM(RTRIM(@FieldEngineer)),N''), NULLIF(LTRIM(RTRIM(@TerminationReason)),N''), @Notes, @IsActive, @UserId);
        SET @BoreholeId = SCOPE_IDENTITY();
        INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription, NewValues)
        VALUES(@UserId, (SELECT Username FROM dbo.Users WHERE UserId=@UserId), N'Insert', N'Boreholes', CONVERT(NVARCHAR(100),@BoreholeId), N'تم إنشاء جسة جديدة.', N'BoreholeCode=' + @BoreholeCode);
    END
    ELSE
    BEGIN
        IF NOT EXISTS(SELECT 1 FROM dbo.Boreholes WHERE BoreholeId=@BoreholeId AND IsDeleted=0) BEGIN RAISERROR(N'الجسة غير موجودة.',16,1); RETURN; END
        UPDATE dbo.Boreholes SET ProjectId=@ProjectId, BoreholeCode=@BoreholeCode, PlannedDepthM=@PlannedDepthM, ActualDepthM=@ActualDepthM, Easting=@Easting, Northing=@Northing, ElevationM=@ElevationM, DrillingMethodId=@DrillingMethodId, BoreholeStatusId=@BoreholeStatusId, StartDate=@StartDate, EndDate=@EndDate, GroundwaterDepthM=@GroundwaterDepthM, LocationDescription=NULLIF(LTRIM(RTRIM(@LocationDescription)),N''), FieldEngineer=NULLIF(LTRIM(RTRIM(@FieldEngineer)),N''), TerminationReason=NULLIF(LTRIM(RTRIM(@TerminationReason)),N''), Notes=@Notes, IsActive=@IsActive, UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId
        WHERE BoreholeId=@BoreholeId;
        INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription, NewValues)
        VALUES(@UserId, (SELECT Username FROM dbo.Users WHERE UserId=@UserId), N'Update', N'Boreholes', CONVERT(NVARCHAR(100),@BoreholeId), N'تم تعديل بيانات الجسة.', N'BoreholeCode=' + @BoreholeCode);
    END
    SELECT @BoreholeId AS BoreholeId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Borehole_Delete
    @BoreholeId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS(SELECT 1 FROM dbo.Boreholes WHERE BoreholeId=@BoreholeId AND IsDeleted=0) BEGIN RAISERROR(N'الجسة غير موجودة.',16,1); RETURN; END
    UPDATE dbo.Boreholes SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE BoreholeId=@BoreholeId;
    UPDATE dbo.BoreholeLayers SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE BoreholeId=@BoreholeId AND IsDeleted=0;
    UPDATE dbo.Samples SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE BoreholeId=@BoreholeId AND IsDeleted=0;
    UPDATE dbo.SPTTests SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE BoreholeId=@BoreholeId AND IsDeleted=0;
    UPDATE dbo.GroundwaterObservations SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE BoreholeId=@BoreholeId AND IsDeleted=0;
    INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription)
    VALUES(@UserId, (SELECT Username FROM dbo.Users WHERE UserId=@UserId), N'Delete', N'Boreholes', CONVERT(NVARCHAR(100),@BoreholeId), N'تم حذف الجسة منطقيًا مع بياناتها التابعة.');
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_BoreholeLayers_Get
    @BoreholeId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT L.*, SR.NameAr AS SoilRockTypeNameAr
    FROM dbo.BoreholeLayers L
    LEFT JOIN dbo.LookupItems SR ON SR.LookupItemId = L.SoilRockTypeId AND SR.IsDeleted = 0
    WHERE L.BoreholeId = @BoreholeId AND L.IsDeleted = 0
    ORDER BY L.FromDepthM, L.ToDepthM;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_BoreholeLayer_GetById
    @LayerId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.BoreholeLayers WHERE LayerId=@LayerId AND IsDeleted=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_BoreholeLayer_Save
    @LayerId BIGINT = NULL,
    @BoreholeId BIGINT,
    @FromDepthM DECIMAL(10,2),
    @ToDepthM DECIMAL(10,2),
    @SoilRockTypeId BIGINT = NULL,
    @USCS NVARCHAR(50) = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @Color NVARCHAR(100) = NULL,
    @ConsistencyDensity NVARCHAR(150) = NULL,
    @MoistureCondition NVARCHAR(150) = NULL,
    @RecoveryPercent DECIMAL(5,2) = NULL,
    @RQDPercent DECIMAL(5,2) = NULL,
    @Notes NVARCHAR(MAX) = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS(SELECT 1 FROM dbo.Boreholes WHERE BoreholeId=@BoreholeId AND IsDeleted=0) BEGIN RAISERROR(N'الجسة غير موجودة.',16,1); RETURN; END
    IF @FromDepthM IS NULL OR @FromDepthM < 0 OR @ToDepthM IS NULL OR @ToDepthM <= @FromDepthM BEGIN RAISERROR(N'أعماق الطبقة غير صحيحة.',16,1); RETURN; END
    IF @RecoveryPercent IS NOT NULL AND (@RecoveryPercent < 0 OR @RecoveryPercent > 100) BEGIN RAISERROR(N'Recovery يجب أن يكون بين 0 و 100.',16,1); RETURN; END
    IF @RQDPercent IS NOT NULL AND (@RQDPercent < 0 OR @RQDPercent > 100) BEGIN RAISERROR(N'RQD يجب أن يكون بين 0 و 100.',16,1); RETURN; END

    IF @LayerId IS NULL OR @LayerId <= 0
    BEGIN
        INSERT INTO dbo.BoreholeLayers(BoreholeId, FromDepthM, ToDepthM, SoilRockTypeId, USCS, Description, Color, ConsistencyDensity, MoistureCondition, RecoveryPercent, RQDPercent, Notes, CreatedBy)
        VALUES(@BoreholeId, @FromDepthM, @ToDepthM, @SoilRockTypeId, NULLIF(LTRIM(RTRIM(@USCS)),N''), @Description, NULLIF(LTRIM(RTRIM(@Color)),N''), NULLIF(LTRIM(RTRIM(@ConsistencyDensity)),N''), NULLIF(LTRIM(RTRIM(@MoistureCondition)),N''), @RecoveryPercent, @RQDPercent, @Notes, @UserId);
        SET @LayerId = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.BoreholeLayers SET FromDepthM=@FromDepthM, ToDepthM=@ToDepthM, SoilRockTypeId=@SoilRockTypeId, USCS=NULLIF(LTRIM(RTRIM(@USCS)),N''), Description=@Description, Color=NULLIF(LTRIM(RTRIM(@Color)),N''), ConsistencyDensity=NULLIF(LTRIM(RTRIM(@ConsistencyDensity)),N''), MoistureCondition=NULLIF(LTRIM(RTRIM(@MoistureCondition)),N''), RecoveryPercent=@RecoveryPercent, RQDPercent=@RQDPercent, Notes=@Notes, UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId
        WHERE LayerId=@LayerId AND BoreholeId=@BoreholeId AND IsDeleted=0;
    END
    SELECT @LayerId AS LayerId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_BoreholeLayer_Delete
    @LayerId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.BoreholeLayers SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE LayerId=@LayerId AND IsDeleted=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Samples_Get
    @ProjectId BIGINT = NULL,
    @BoreholeId BIGINT = NULL,
    @SearchText NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @SearchText = NULLIF(LTRIM(RTRIM(@SearchText)), N'');
    SELECT S.*, B.BoreholeCode, P.ProjectCode, P.ProjectName, ST.NameAr AS SampleTypeNameAr, SQ.NameAr AS SampleQualityNameAr
    FROM dbo.Samples S
    INNER JOIN dbo.Boreholes B ON B.BoreholeId = S.BoreholeId AND B.IsDeleted = 0
    INNER JOIN dbo.Projects P ON P.ProjectId = S.ProjectId AND P.IsDeleted = 0
    LEFT JOIN dbo.LookupItems ST ON ST.LookupItemId = S.SampleTypeId AND ST.IsDeleted = 0
    LEFT JOIN dbo.LookupItems SQ ON SQ.LookupItemId = S.SampleQualityId AND SQ.IsDeleted = 0
    WHERE S.IsDeleted = 0
      AND (@ProjectId IS NULL OR S.ProjectId = @ProjectId)
      AND (@BoreholeId IS NULL OR S.BoreholeId = @BoreholeId)
      AND (@SearchText IS NULL OR S.SampleCode LIKE N'%' + @SearchText + N'%' OR S.Description LIKE N'%' + @SearchText + N'%' OR S.RequiredTests LIKE N'%' + @SearchText + N'%')
    ORDER BY P.ProjectCode, B.BoreholeCode, S.FromDepthM;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Sample_GetById
    @SampleId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Samples WHERE SampleId=@SampleId AND IsDeleted=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Sample_Save
    @SampleId BIGINT = NULL,
    @ProjectId BIGINT,
    @BoreholeId BIGINT,
    @SampleCode NVARCHAR(100),
    @FromDepthM DECIMAL(10,2),
    @ToDepthM DECIMAL(10,2),
    @SampleTypeId BIGINT = NULL,
    @SampleQualityId BIGINT = NULL,
    @RecoveryLengthM DECIMAL(10,2) = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @TakenDate DATE = NULL,
    @RequiredTests NVARCHAR(500) = NULL,
    @StorageLocation NVARCHAR(250) = NULL,
    @Notes NVARCHAR(MAX) = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @SampleCode = LTRIM(RTRIM(@SampleCode));
    IF @SampleCode IS NULL OR @SampleCode=N'' BEGIN RAISERROR(N'كود العينة مطلوب.',16,1); RETURN; END
    IF NOT EXISTS(SELECT 1 FROM dbo.Boreholes WHERE BoreholeId=@BoreholeId AND ProjectId=@ProjectId AND IsDeleted=0) BEGIN RAISERROR(N'الجسة لا تتبع المشروع المحدد.',16,1); RETURN; END
    IF @FromDepthM IS NULL OR @FromDepthM < 0 OR @ToDepthM IS NULL OR @ToDepthM <= @FromDepthM BEGIN RAISERROR(N'أعماق العينة غير صحيحة.',16,1); RETURN; END
    IF EXISTS(SELECT 1 FROM dbo.Samples WHERE ProjectId=@ProjectId AND SampleCode=@SampleCode AND IsDeleted=0 AND (@SampleId IS NULL OR SampleId<>@SampleId)) BEGIN RAISERROR(N'كود العينة مستخدم مسبقًا داخل المشروع.',16,1); RETURN; END

    IF @SampleId IS NULL OR @SampleId <= 0
    BEGIN
        INSERT INTO dbo.Samples(ProjectId, BoreholeId, SampleCode, FromDepthM, ToDepthM, SampleTypeId, SampleQualityId, RecoveryLengthM, Description, TakenDate, RequiredTests, StorageLocation, Notes, CreatedBy)
        VALUES(@ProjectId, @BoreholeId, @SampleCode, @FromDepthM, @ToDepthM, @SampleTypeId, @SampleQualityId, @RecoveryLengthM, @Description, @TakenDate, NULLIF(LTRIM(RTRIM(@RequiredTests)),N''), NULLIF(LTRIM(RTRIM(@StorageLocation)),N''), @Notes, @UserId);
        SET @SampleId = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.Samples SET ProjectId=@ProjectId, BoreholeId=@BoreholeId, SampleCode=@SampleCode, FromDepthM=@FromDepthM, ToDepthM=@ToDepthM, SampleTypeId=@SampleTypeId, SampleQualityId=@SampleQualityId, RecoveryLengthM=@RecoveryLengthM, Description=@Description, TakenDate=@TakenDate, RequiredTests=NULLIF(LTRIM(RTRIM(@RequiredTests)),N''), StorageLocation=NULLIF(LTRIM(RTRIM(@StorageLocation)),N''), Notes=@Notes, UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId
        WHERE SampleId=@SampleId AND IsDeleted=0;
    END
    SELECT @SampleId AS SampleId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Sample_Delete
    @SampleId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Samples SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE SampleId=@SampleId AND IsDeleted=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_SPTTests_Get
    @ProjectId BIGINT = NULL,
    @BoreholeId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT T.*, B.BoreholeCode, P.ProjectCode, P.ProjectName
    FROM dbo.SPTTests T
    INNER JOIN dbo.Boreholes B ON B.BoreholeId = T.BoreholeId AND B.IsDeleted = 0
    INNER JOIN dbo.Projects P ON P.ProjectId = T.ProjectId AND P.IsDeleted = 0
    WHERE T.IsDeleted = 0
      AND (@ProjectId IS NULL OR T.ProjectId = @ProjectId)
      AND (@BoreholeId IS NULL OR T.BoreholeId = @BoreholeId)
    ORDER BY P.ProjectCode, B.BoreholeCode, T.TestDepthM;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_SPTTest_GetById
    @SPTTestId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.SPTTests WHERE SPTTestId=@SPTTestId AND IsDeleted=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_SPTTest_Save
    @SPTTestId BIGINT = NULL,
    @ProjectId BIGINT,
    @BoreholeId BIGINT,
    @TestDepthM DECIMAL(10,2),
    @BlowCount1 INT = NULL,
    @BlowCount2 INT = NULL,
    @BlowCount3 INT = NULL,
    @NValue INT = NULL,
    @HammerEnergyRatio DECIMAL(6,2) = NULL,
    @CorrectedN DECIMAL(10,2) = NULL,
    @RecoveryLengthM DECIMAL(10,2) = NULL,
    @TestDate DATE = NULL,
    @Notes NVARCHAR(MAX) = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS(SELECT 1 FROM dbo.Boreholes WHERE BoreholeId=@BoreholeId AND ProjectId=@ProjectId AND IsDeleted=0) BEGIN RAISERROR(N'الجسة لا تتبع المشروع المحدد.',16,1); RETURN; END
    IF @TestDepthM IS NULL OR @TestDepthM < 0 BEGIN RAISERROR(N'عمق اختبار SPT غير صحيح.',16,1); RETURN; END
    SET @NValue = CASE WHEN @NValue IS NOT NULL THEN @NValue WHEN @BlowCount2 IS NOT NULL OR @BlowCount3 IS NOT NULL THEN ISNULL(@BlowCount2,0)+ISNULL(@BlowCount3,0) ELSE NULL END;

    IF @SPTTestId IS NULL OR @SPTTestId <= 0
    BEGIN
        INSERT INTO dbo.SPTTests(ProjectId, BoreholeId, TestDepthM, BlowCount1, BlowCount2, BlowCount3, NValue, HammerEnergyRatio, CorrectedN, RecoveryLengthM, TestDate, Notes, CreatedBy)
        VALUES(@ProjectId, @BoreholeId, @TestDepthM, @BlowCount1, @BlowCount2, @BlowCount3, @NValue, @HammerEnergyRatio, @CorrectedN, @RecoveryLengthM, @TestDate, @Notes, @UserId);
        SET @SPTTestId = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.SPTTests SET ProjectId=@ProjectId, BoreholeId=@BoreholeId, TestDepthM=@TestDepthM, BlowCount1=@BlowCount1, BlowCount2=@BlowCount2, BlowCount3=@BlowCount3, NValue=@NValue, HammerEnergyRatio=@HammerEnergyRatio, CorrectedN=@CorrectedN, RecoveryLengthM=@RecoveryLengthM, TestDate=@TestDate, Notes=@Notes, UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId
        WHERE SPTTestId=@SPTTestId AND IsDeleted=0;
    END
    SELECT @SPTTestId AS SPTTestId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_SPTTest_Delete
    @SPTTestId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.SPTTests SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE SPTTestId=@SPTTestId AND IsDeleted=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GroundwaterObservations_Get
    @ProjectId BIGINT = NULL,
    @BoreholeId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT G.*, B.BoreholeCode, P.ProjectCode, P.ProjectName, GT.NameAr AS ObservationTypeNameAr
    FROM dbo.GroundwaterObservations G
    INNER JOIN dbo.Boreholes B ON B.BoreholeId = G.BoreholeId AND B.IsDeleted = 0
    INNER JOIN dbo.Projects P ON P.ProjectId = G.ProjectId AND P.IsDeleted = 0
    LEFT JOIN dbo.LookupItems GT ON GT.LookupItemId = G.ObservationTypeId AND GT.IsDeleted = 0
    WHERE G.IsDeleted = 0
      AND (@ProjectId IS NULL OR G.ProjectId = @ProjectId)
      AND (@BoreholeId IS NULL OR G.BoreholeId = @BoreholeId)
    ORDER BY P.ProjectCode, B.BoreholeCode, G.ObservationDate;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GroundwaterObservation_GetById
    @GroundwaterObservationId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.GroundwaterObservations WHERE GroundwaterObservationId=@GroundwaterObservationId AND IsDeleted=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GroundwaterObservation_Save
    @GroundwaterObservationId BIGINT = NULL,
    @ProjectId BIGINT,
    @BoreholeId BIGINT,
    @ObservationDate DATE = NULL,
    @DepthToWaterM DECIMAL(10,2),
    @ObservationTypeId BIGINT = NULL,
    @CasingDepthM DECIMAL(10,2) = NULL,
    @StabilizedAfterHours DECIMAL(10,2) = NULL,
    @Notes NVARCHAR(MAX) = NULL,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS(SELECT 1 FROM dbo.Boreholes WHERE BoreholeId=@BoreholeId AND ProjectId=@ProjectId AND IsDeleted=0) BEGIN RAISERROR(N'الجسة لا تتبع المشروع المحدد.',16,1); RETURN; END
    IF @DepthToWaterM IS NULL OR @DepthToWaterM < 0 BEGIN RAISERROR(N'عمق المياه غير صحيح.',16,1); RETURN; END

    IF @GroundwaterObservationId IS NULL OR @GroundwaterObservationId <= 0
    BEGIN
        INSERT INTO dbo.GroundwaterObservations(ProjectId, BoreholeId, ObservationDate, DepthToWaterM, ObservationTypeId, CasingDepthM, StabilizedAfterHours, Notes, CreatedBy)
        VALUES(@ProjectId, @BoreholeId, @ObservationDate, @DepthToWaterM, @ObservationTypeId, @CasingDepthM, @StabilizedAfterHours, @Notes, @UserId);
        SET @GroundwaterObservationId = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.GroundwaterObservations SET ProjectId=@ProjectId, BoreholeId=@BoreholeId, ObservationDate=@ObservationDate, DepthToWaterM=@DepthToWaterM, ObservationTypeId=@ObservationTypeId, CasingDepthM=@CasingDepthM, StabilizedAfterHours=@StabilizedAfterHours, Notes=@Notes, UpdatedAt=SYSDATETIME(), UpdatedBy=@UserId
        WHERE GroundwaterObservationId=@GroundwaterObservationId AND IsDeleted=0;
    END
    SELECT @GroundwaterObservationId AS GroundwaterObservationId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GroundwaterObservation_Delete
    @GroundwaterObservationId BIGINT,
    @UserId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.GroundwaterObservations SET IsDeleted=1, DeletedAt=SYSDATETIME(), DeletedBy=@UserId WHERE GroundwaterObservationId=@GroundwaterObservationId AND IsDeleted=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_BoreholeLog_Get
    @BoreholeId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.sp_Borehole_GetById @BoreholeId = @BoreholeId;
    EXEC dbo.sp_BoreholeLayers_Get @BoreholeId = @BoreholeId;
    EXEC dbo.sp_Samples_Get @ProjectId = NULL, @BoreholeId = @BoreholeId, @SearchText = NULL;
    EXEC dbo.sp_SPTTests_Get @ProjectId = NULL, @BoreholeId = @BoreholeId;
    EXEC dbo.sp_GroundwaterObservations_Get @ProjectId = NULL, @BoreholeId = @BoreholeId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Dashboard_GetSummary
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        (SELECT COUNT(*) FROM dbo.Projects WHERE IsDeleted = 0) AS TotalProjects,
        (SELECT COUNT(*) FROM dbo.Projects WHERE IsDeleted = 0 AND IsActive = 1) AS ActiveProjects,
        (SELECT COUNT(*) FROM dbo.Boreholes WHERE IsDeleted = 0) AS TotalBoreholes,
        CASE WHEN OBJECT_ID(N'dbo.Reports', N'U') IS NULL THEN 0 ELSE (SELECT COUNT(*) FROM dbo.Reports WHERE IsDeleted = 0) END AS TotalReports;

    SELECT TOP(10)
        P.ProjectId, P.ProjectCode, P.ProjectName, C.ClientName, ISNULL(PS.NameAr, N'غير محدد') AS ProjectStatusNameAr
    FROM dbo.Projects P
    LEFT JOIN dbo.Clients C ON C.ClientId = P.ClientId AND C.IsDeleted = 0
    LEFT JOIN dbo.LookupItems PS ON P.ProjectStatusId = PS.LookupItemId AND PS.IsDeleted = 0
    WHERE P.IsDeleted = 0
    ORDER BY P.CreatedAt DESC, P.ProjectId DESC;

    SELECT ISNULL(PS.NameAr, N'غير محدد') AS ProjectStatusNameAr, COUNT(*) AS ProjectCount
    FROM dbo.Projects P
    LEFT JOIN dbo.LookupItems PS ON P.ProjectStatusId = PS.LookupItemId AND PS.IsDeleted = 0
    WHERE P.IsDeleted = 0
    GROUP BY ISNULL(PS.NameAr, N'غير محدد')
    ORDER BY ProjectCount DESC;
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
        LabTestCount = 0,
        ReportCount = CASE WHEN OBJECT_ID(N'dbo.Reports', N'U') IS NULL THEN 0 ELSE (SELECT COUNT(*) FROM dbo.Reports WHERE ProjectId = @ProjectId AND IsDeleted = 0) END,
        DocumentCount = 0;
END
GO

PRINT N'Sprint 2 stored procedures created successfully.';
GO
