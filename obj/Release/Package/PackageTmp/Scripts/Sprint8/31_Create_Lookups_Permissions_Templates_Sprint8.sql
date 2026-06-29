USE GeoSitePro;
GO

/* Sprint 8: seed lookups, permissions, and professional editable templates by project type. */

DECLARE @Categories TABLE(CategoryCode NVARCHAR(100), CategoryNameAr NVARCHAR(200), CategoryNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Categories VALUES
(N'TemplateItemCategory', N'تصنيف بند خطة التحري', N'Investigation Template Item Category', 800),
(N'InvestigationRiskLevel', N'مستوى خطورة التحري', N'Investigation Risk Level', 810),
(N'InvestigationPlanStatus', N'حالة خطة التحري', N'Investigation Plan Status', 820),
(N'InvestigationPlanItemStatus', N'حالة بند خطة التحري', N'Investigation Plan Item Status', 830);

UPDATE T
SET T.CategoryNameAr=S.CategoryNameAr, T.CategoryNameEn=S.CategoryNameEn, T.SortOrder=S.SortOrder, T.IsActive=1, T.IsDeleted=0
FROM dbo.LookupCategories T INNER JOIN @Categories S ON S.CategoryCode=T.CategoryCode;
INSERT INTO dbo.LookupCategories(CategoryCode, CategoryNameAr, CategoryNameEn, SortOrder, IsActive, IsDeleted)
SELECT S.CategoryCode, S.CategoryNameAr, S.CategoryNameEn, S.SortOrder, 1, 0
FROM @Categories S WHERE NOT EXISTS(SELECT 1 FROM dbo.LookupCategories C WHERE C.CategoryCode=S.CategoryCode);
GO

/* Extend project types beyond Sprint 1 basic set. */
DECLARE @Items TABLE(CategoryCode NVARCHAR(100), ItemCode NVARCHAR(100), NameAr NVARCHAR(200), NameEn NVARCHAR(200), Description NVARCHAR(500), SortOrder INT, IsDefault BIT);
INSERT INTO @Items VALUES
(N'ProjectType', N'BUILDING', N'مبنى', N'Building', N'Low to mid-rise building investigation template.', 10, 1),
(N'ProjectType', N'TOWER', N'برج / مبنى عالٍ', N'Tower / High-Rise', N'High-rise and high load structures.', 20, 0),
(N'ProjectType', N'ROAD', N'طريق', N'Road', N'Linear road alignment and pavement investigation.', 30, 0),
(N'ProjectType', N'BRIDGE', N'جسر', N'Bridge', N'Bridge foundations and abutment/pier investigations.', 40, 0),
(N'ProjectType', N'DAM', N'سد', N'Dam', N'Dam foundation, abutments, reservoir, borrow materials.', 50, 0),
(N'ProjectType', N'TUNNEL', N'نفق', N'Tunnel', N'Tunnel alignment and underground works.', 60, 0),
(N'ProjectType', N'RAILWAY', N'سكة حديد', N'Railway', N'Railway alignment and embankment/subgrade works.', 70, 0),
(N'ProjectType', N'AIRPORT', N'مطار', N'Airport', N'Runways, taxiways and airport platforms.', 80, 0),
(N'ProjectType', N'PORT', N'ميناء / أعمال بحرية', N'Port / Marine Works', N'Marine, quay wall, reclamation and coastal works.', 90, 0),
(N'ProjectType', N'STADIUM', N'استاد / منشأة رياضية', N'Stadium', N'Stadium and large public assembly structures.', 100, 0),
(N'ProjectType', N'SLOPE', N'منحدر / قطع صخري', N'Slope / Rock Cut', N'Slope stability, landslide and rock cut investigations.', 110, 0),
(N'TemplateItemCategory', N'BOREHOLE', N'جسات', N'Boreholes', N'Borehole number, location and depth recommendations.', 10, 1),
(N'TemplateItemCategory', N'SAMPLING', N'عينات', N'Sampling', N'Disturbed, undisturbed, rock core and groundwater sampling.', 20, 0),
(N'TemplateItemCategory', N'FIELD_TEST', N'اختبارات حقلية', N'Field Tests', N'SPT, permeability, plate load, geophysics and in-situ tests.', 30, 0),
(N'TemplateItemCategory', N'LAB_TEST', N'اختبارات معملية', N'Laboratory Tests', N'Soil and rock laboratory testing matrix.', 40, 0),
(N'TemplateItemCategory', N'GROUNDWATER', N'مياه جوفية', N'Groundwater', N'Groundwater monitoring and measurement.', 50, 0),
(N'TemplateItemCategory', N'REPORTING', N'تقارير ومخرجات', N'Reporting', N'Report deliverables and appendices.', 60, 0),
(N'InvestigationRiskLevel', N'LOW', N'منخفض', N'Low', N'Low geotechnical complexity.', 10, 1),
(N'InvestigationRiskLevel', N'MEDIUM', N'متوسط', N'Medium', N'Moderate geotechnical complexity.', 20, 0),
(N'InvestigationRiskLevel', N'HIGH', N'عالٍ', N'High', N'High loads, high consequence or complex ground.', 30, 0),
(N'InvestigationRiskLevel', N'CRITICAL', N'حرج', N'Critical', N'Critical infrastructure or very high consequence project.', 40, 0),
(N'InvestigationPlanStatus', N'DRAFT', N'مسودة', N'Draft', N'Generated and editable.', 10, 1),
(N'InvestigationPlanStatus', N'IN_REVIEW', N'قيد المراجعة', N'In Review', N'Under technical review.', 20, 0),
(N'InvestigationPlanStatus', N'APPROVED', N'معتمدة', N'Approved', N'Approved for execution.', 30, 0),
(N'InvestigationPlanStatus', N'SUPERSEDED', N'مستبدلة', N'Superseded', N'Superseded by newer revision.', 40, 0),
(N'InvestigationPlanItemStatus', N'PLANNED', N'مخطط', N'Planned', N'Planned item.', 10, 1),
(N'InvestigationPlanItemStatus', N'ACCEPTED', N'مقبول', N'Accepted', N'Accepted by engineer.', 20, 0),
(N'InvestigationPlanItemStatus', N'MODIFIED', N'معدل', N'Modified', N'Modified from template.', 30, 0),
(N'InvestigationPlanItemStatus', N'REJECTED', N'مستبعد', N'Rejected', N'Rejected after review.', 40, 0),
(N'InvestigationPlanItemStatus', N'COMPLETED', N'منفذ', N'Completed', N'Completed during execution.', 50, 0);

UPDATE T
SET T.NameAr=S.NameAr, T.NameEn=S.NameEn, T.Description=S.Description, T.SortOrder=S.SortOrder, T.IsDefault=S.IsDefault, T.IsActive=1, T.IsDeleted=0
FROM dbo.LookupItems T
INNER JOIN dbo.LookupCategories C ON C.LookupCategoryId=T.LookupCategoryId
INNER JOIN @Items S ON S.CategoryCode=C.CategoryCode AND S.ItemCode=T.ItemCode;

INSERT INTO dbo.LookupItems(LookupCategoryId, ItemCode, NameAr, NameEn, Description, SortOrder, IsDefault, IsActive, IsDeleted)
SELECT C.LookupCategoryId, S.ItemCode, S.NameAr, S.NameEn, S.Description, S.SortOrder, S.IsDefault, 1, 0
FROM @Items S INNER JOIN dbo.LookupCategories C ON C.CategoryCode=S.CategoryCode AND C.IsDeleted=0
WHERE NOT EXISTS(SELECT 1 FROM dbo.LookupItems I WHERE I.LookupCategoryId=C.LookupCategoryId AND I.ItemCode=S.ItemCode);
GO

DECLARE @Permissions TABLE(ModuleName NVARCHAR(100), PermissionCode NVARCHAR(150), PermissionNameAr NVARCHAR(200), PermissionNameEn NVARCHAR(200), SortOrder INT);
INSERT INTO @Permissions VALUES
(N'InvestigationTemplates', N'InvestigationTemplates.View', N'عرض قوالب التحري حسب نوع المشروع', N'View Investigation Templates', 10),
(N'InvestigationTemplates', N'InvestigationTemplates.Create', N'إضافة قالب تحري', N'Create Investigation Template', 20),
(N'InvestigationTemplates', N'InvestigationTemplates.Edit', N'تعديل قالب تحري', N'Edit Investigation Template', 30),
(N'InvestigationTemplates', N'InvestigationTemplates.Delete', N'حذف قالب تحري', N'Delete Investigation Template', 40),
(N'ProjectInvestigationPlan', N'ProjectInvestigationPlan.View', N'عرض خطة تحري المشروع', N'View Project Investigation Plan', 10),
(N'ProjectInvestigationPlan', N'ProjectInvestigationPlan.Generate', N'توليد خطة تحري من قالب', N'Generate Investigation Plan', 20),
(N'ProjectInvestigationPlan', N'ProjectInvestigationPlan.Edit', N'تعديل بنود خطة التحري', N'Edit Investigation Plan Items', 30),
(N'ProjectInvestigationPlan', N'ProjectInvestigationPlan.Approve', N'اعتماد خطة التحري', N'Approve Investigation Plan', 40);

UPDATE T
SET T.ModuleName=S.ModuleName, T.PermissionNameAr=S.PermissionNameAr, T.PermissionNameEn=S.PermissionNameEn, T.SortOrder=S.SortOrder, T.IsActive=1, T.IsDeleted=0
FROM dbo.Permissions T INNER JOIN @Permissions S ON S.PermissionCode=T.PermissionCode;
INSERT INTO dbo.Permissions(ModuleName, PermissionCode, PermissionNameAr, PermissionNameEn, SortOrder, IsActive, IsDeleted)
SELECT S.ModuleName, S.PermissionCode, S.PermissionNameAr, S.PermissionNameEn, S.SortOrder, 1, 0
FROM @Permissions S WHERE NOT EXISTS(SELECT 1 FROM dbo.Permissions P WHERE P.PermissionCode=S.PermissionCode);
GO

/* Grant all new permissions to admin role. */
DECLARE @AdminUserId BIGINT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Username=N'admin' AND IsDeleted=0 ORDER BY UserId);
DECLARE @AdminRoleId BIGINT = (SELECT TOP 1 RoleId FROM dbo.Roles WHERE RoleName IN (N'System Admin', N'Admin', N'Administrator') AND IsDeleted=0 ORDER BY RoleId);
IF @AdminRoleId IS NULL
BEGIN
    INSERT INTO dbo.Roles(RoleName, Description, IsActive, CreatedBy) VALUES(N'System Admin', N'Full system administrator role.', 1, @AdminUserId);
    SET @AdminRoleId = SCOPE_IDENTITY();
END
INSERT INTO dbo.RolePermissions(RoleId, PermissionId, GrantedBy)
SELECT @AdminRoleId, P.PermissionId, @AdminUserId
FROM dbo.Permissions P
WHERE P.IsActive=1 AND P.IsDeleted=0
  AND NOT EXISTS(SELECT 1 FROM dbo.RolePermissions RP WHERE RP.RoleId=@AdminRoleId AND RP.PermissionId=P.PermissionId);
GO

/* Seed editable templates. Values are guidance templates, not immutable engineering rules. */
DECLARE @Templates TABLE(ProjectTypeCode NVARCHAR(100), StageCode NVARCHAR(100), RiskCode NVARCHAR(100), TemplateCode NVARCHAR(100), TemplateNameAr NVARCHAR(300), TemplateNameEn NVARCHAR(300), Summary NVARCHAR(MAX), MinArea DECIMAL(18,2), MaxArea DECIMAL(18,2), MinFloors INT, MaxFloors INT, DefaultBH INT, DefaultDepth DECIMAL(18,2), SPTInterval DECIMAL(18,2), IsDefault BIT);
INSERT INTO @Templates VALUES
(N'BUILDING', N'DETAILED', N'MEDIUM', N'TPL-BUILDING-STD', N'قالب تحري مبنى تقليدي', N'Standard Building Investigation Template', N'قالب إرشادي للمباني السكنية/التجارية الصغيرة والمتوسطة. يراجع حسب الأحمال والجيولوجيا والمياه الجوفية.', 0, 5000, 1, 10, 4, 15, 1.5, 1),
(N'TOWER', N'DETAILED', N'HIGH', N'TPL-TOWER-HIGHRISE', N'قالب تحري برج أو مبنى عالٍ', N'High-Rise Tower Investigation Template', N'قالب للأبراج والمنشآت عالية الأحمال مع تركيز على العمق، الهبوط، الانضغاطية، والقوة القصية.', 0, NULL, 8, NULL, 6, 30, 1.5, 1),
(N'ROAD', N'DETAILED', N'MEDIUM', N'TPL-ROAD-CORRIDOR', N'قالب تحري طريق / مسار خطي', N'Road Corridor Investigation Template', N'قالب للطرق يشمل حفر اختبارية/جسات على المسار وتقييم subgrade والردميات والمواد.', 0, NULL, NULL, NULL, 1, 3, NULL, 1),
(N'BRIDGE', N'DETAILED', N'HIGH', N'TPL-BRIDGE-FOUNDATION', N'قالب تحري جسر', N'Bridge Foundation Investigation Template', N'قالب للجسور يركز على الدعامات والركائز والخواص العميقة للصخور/التربة.', 0, NULL, NULL, NULL, 2, 35, 1.5, 1),
(N'DAM', N'DETAILED', N'CRITICAL', N'TPL-DAM-CRITICAL', N'قالب تحري سد', N'Dam Investigation Template', N'قالب حرج للسدود يشمل أساس السد، الكتفين، النفاذية، مواد الردم، والمياه الجوفية.', 0, NULL, NULL, NULL, 10, 50, NULL, 1),
(N'TUNNEL', N'DETAILED', N'CRITICAL', N'TPL-TUNNEL-ALIGNMENT', N'قالب تحري نفق', N'Tunnel Alignment Investigation Template', N'قالب للأنفاق يجمع بين الجسات، المسح الجيولوجي، الجيوفيزياء، الصخور، والمياه الجوفية.', 0, NULL, NULL, NULL, 6, 60, NULL, 1),
(N'RAILWAY', N'DETAILED', N'HIGH', N'TPL-RAILWAY-CORRIDOR', N'قالب تحري سكة حديد', N'Railway Corridor Investigation Template', N'قالب للمسارات الطويلة والردميات والقطوع والمنشآت الصغيرة على الخط.', 0, NULL, NULL, NULL, 1, 5, NULL, 1),
(N'AIRPORT', N'DETAILED', N'HIGH', N'TPL-AIRPORT-PAVEMENT', N'قالب تحري مطار ومدارج', N'Airport Pavement Investigation Template', N'قالب للمدارج والساحات مع تركيز على طبقات الرصف، CBR، الدمك، المياه، والتجانس.', 0, NULL, NULL, NULL, 8, 8, NULL, 1),
(N'PORT', N'DETAILED', N'CRITICAL', N'TPL-PORT-MARINE', N'قالب تحري ميناء وأعمال بحرية', N'Port and Marine Investigation Template', N'قالب للأعمال البحرية يشمل جسات برية/بحرية، تربة رخوة، مياه، أملاح، وردميات.', 0, NULL, NULL, NULL, 8, 50, 1.5, 1),
(N'STADIUM', N'DETAILED', N'HIGH', N'TPL-STADIUM-LARGE', N'قالب تحري استاد أو منشأة رياضية كبيرة', N'Stadium Investigation Template', N'قالب للمنشآت ذات المساحة الكبيرة والأحمال المتغيرة مع فحص الهبوط والتجانس.', 0, NULL, NULL, NULL, 6, 25, 1.5, 1),
(N'SLOPE', N'DETAILED', N'HIGH', N'TPL-SLOPE-STABILITY', N'قالب تحري منحدر أو قطع صخري', N'Slope Stability Investigation Template', N'قالب للمنحدرات والانزلاقات والقطوع الصخرية ويشمل البنية الجيولوجية والمياه والقص.', 0, NULL, NULL, NULL, 3, 20, NULL, 1);

;WITH S AS (
    SELECT PT.LookupItemId ProjectTypeId, ST.LookupItemId InvestigationStageId, RL.LookupItemId RiskLevelId, T.*
    FROM @Templates T
    LEFT JOIN dbo.LookupCategories CPT ON CPT.CategoryCode=N'ProjectType' AND CPT.IsDeleted=0
    LEFT JOIN dbo.LookupItems PT ON PT.LookupCategoryId=CPT.LookupCategoryId AND PT.ItemCode=T.ProjectTypeCode AND PT.IsDeleted=0
    LEFT JOIN dbo.LookupCategories CST ON CST.CategoryCode=N'InvestigationStage' AND CST.IsDeleted=0
    LEFT JOIN dbo.LookupItems ST ON ST.LookupCategoryId=CST.LookupCategoryId AND ST.ItemCode=T.StageCode AND ST.IsDeleted=0
    LEFT JOIN dbo.LookupCategories CRL ON CRL.CategoryCode=N'InvestigationRiskLevel' AND CRL.IsDeleted=0
    LEFT JOIN dbo.LookupItems RL ON RL.LookupCategoryId=CRL.LookupCategoryId AND RL.ItemCode=T.RiskCode AND RL.IsDeleted=0
)
UPDATE IT
SET IT.ProjectTypeId=S.ProjectTypeId, IT.InvestigationStageId=S.InvestigationStageId, IT.RiskLevelId=S.RiskLevelId,
    IT.TemplateNameAr=S.TemplateNameAr, IT.TemplateNameEn=S.TemplateNameEn, IT.ApplicabilitySummary=S.Summary,
    IT.MinSiteAreaM2=S.MinArea, IT.MaxSiteAreaM2=S.MaxArea, IT.MinFloors=S.MinFloors, IT.MaxFloors=S.MaxFloors,
    IT.DefaultBoreholeCount=S.DefaultBH, IT.DefaultMinDepthM=S.DefaultDepth, IT.DefaultSPTIntervalM=S.SPTInterval, IT.IsDefault=S.IsDefault,
    IT.IsActive=1, IT.IsDeleted=0, IT.UpdatedAt=SYSDATETIME()
FROM dbo.InvestigationTemplates IT INNER JOIN S ON S.TemplateCode=IT.TemplateCode;

;WITH S AS (
    SELECT PT.LookupItemId ProjectTypeId, ST.LookupItemId InvestigationStageId, RL.LookupItemId RiskLevelId, T.*
    FROM @Templates T
    LEFT JOIN dbo.LookupCategories CPT ON CPT.CategoryCode=N'ProjectType' AND CPT.IsDeleted=0
    LEFT JOIN dbo.LookupItems PT ON PT.LookupCategoryId=CPT.LookupCategoryId AND PT.ItemCode=T.ProjectTypeCode AND PT.IsDeleted=0
    LEFT JOIN dbo.LookupCategories CST ON CST.CategoryCode=N'InvestigationStage' AND CST.IsDeleted=0
    LEFT JOIN dbo.LookupItems ST ON ST.LookupCategoryId=CST.LookupCategoryId AND ST.ItemCode=T.StageCode AND ST.IsDeleted=0
    LEFT JOIN dbo.LookupCategories CRL ON CRL.CategoryCode=N'InvestigationRiskLevel' AND CRL.IsDeleted=0
    LEFT JOIN dbo.LookupItems RL ON RL.LookupCategoryId=CRL.LookupCategoryId AND RL.ItemCode=T.RiskCode AND RL.IsDeleted=0
)
INSERT INTO dbo.InvestigationTemplates(ProjectTypeId, InvestigationStageId, RiskLevelId, TemplateCode, TemplateNameAr, TemplateNameEn, ApplicabilitySummary, MinSiteAreaM2, MaxSiteAreaM2, MinFloors, MaxFloors, DefaultBoreholeCount, DefaultMinDepthM, DefaultSPTIntervalM, IsDefault, IsActive)
SELECT S.ProjectTypeId, S.InvestigationStageId, S.RiskLevelId, S.TemplateCode, S.TemplateNameAr, S.TemplateNameEn, S.Summary, S.MinArea, S.MaxArea, S.MinFloors, S.MaxFloors, S.DefaultBH, S.DefaultDepth, S.SPTInterval, S.IsDefault, 1
FROM S WHERE NOT EXISTS(SELECT 1 FROM dbo.InvestigationTemplates IT WHERE IT.TemplateCode=S.TemplateCode AND IT.IsDeleted=0);
GO

DECLARE @Items TABLE(TemplateCode NVARCHAR(100), CategoryCode NVARCHAR(100), ItemCode NVARCHAR(100), TitleAr NVARCHAR(300), TitleEn NVARCHAR(300), Rec NVARCHAR(MAX), Qty DECIMAL(18,2), Spacing DECIMAL(18,2), MinDepth DECIMAL(18,2), MaxDepth DECIMAL(18,2), Freq NVARCHAR(500), DepthRule NVARCHAR(500), Std NVARCHAR(300), Mandatory BIT, SortOrder INT);
INSERT INTO @Items VALUES
-- Building
(N'TPL-BUILDING-STD', N'BOREHOLE', N'BH_COUNT', N'عدد الجسات المقترح', N'Recommended borehole count', N'ابدأ بأربع جسات موزعة على حدود الموقع ومناطق الأحمال، وتزداد حسب المساحة وعدم تجانس الموقع.', 4, NULL, 15, NULL, N'تراجع حسب مساحة الموقع ومواقع الأعمدة واللب.', N'حتى أسفل منطقة التأثير أو الوصول إلى طبقة مناسبة.', N'BS 5930 / EN 1997-2', 1, 10),
(N'TPL-BUILDING-STD', N'SAMPLING', N'DIST_UD_SAMPLES', N'عينات مقلقلة وغير مقلقلة', N'Disturbed and undisturbed samples', N'عينات مقلقلة لكل طبقة مهمة، وعينات Shelby/undisturbed من الطبقات الطينية القابلة للانضغاط.', 1, NULL, NULL, NULL, N'لكل طبقة هندسية مهمة.', N'حسب تغير الطبقات.', N'ISO 22475-1 / ASTM D1587', 1, 20),
(N'TPL-BUILDING-STD', N'FIELD_TEST', N'SPT', N'اختبار SPT', N'Standard Penetration Test', N'تنفيذ SPT داخل الجسات في التربة المناسبة، مع تسجيل N و N60 عند توفر معاملات التصحيح.', 1, NULL, NULL, NULL, N'كل 1.5 م تقريبًا أو عند تغير الطبقات.', N'طول الجسة الكامل في التربة.', N'ASTM D1586 / ISO 22476-3', 1, 30),
(N'TPL-BUILDING-STD', N'LAB_TEST', N'BASIC_LAB', N'اختبارات تصنيف وخواص أساسية', N'Basic classification and index tests', N'رطوبة، حدود أتربرج، تدرج حبيبي، كثافة، واختبارات قص/انضغاطية عند الحاجة.', 1, NULL, NULL, NULL, N'حسب نوع العينات والطبقات.', NULL, N'ASTM D2216 / D4318 / D6913', 1, 40),
(N'TPL-BUILDING-STD', N'GROUNDWATER', N'GWT_OBS', N'رصد المياه الجوفية', N'Groundwater observations', N'تسجيل منسوب المياه أثناء وبعد الحفر مع إعادة القياس إذا كانت المياه مؤثرة على الأساسات.', 1, NULL, NULL, NULL, N'في كل جسة إن وجدت مياه.', NULL, N'ISO 22475-1', 1, 50),
-- Tower
(N'TPL-TOWER-HIGHRISE', N'BOREHOLE', N'BH_DEEP_GRID', N'جسات عميقة مركزة', N'Deep focused boreholes', N'توزيع الجسات حول اللب ومناطق الأحمال العالية، مع عمق كافٍ لتقييم الهبوط الطويل الأمد والأساسات العميقة.', 6, NULL, 30, NULL, N'حول اللب والزوايا ومناطق الأحمال.', N'حتى أسفل تأثير الأحمال أو الصخر/طبقة شديدة الكثافة.', N'BS 5930 / EN 1997-2', 1, 10),
(N'TPL-TOWER-HIGHRISE', N'FIELD_TEST', N'SPT_N60', N'SPT مع تصحيحات N60', N'SPT with N60 corrections', N'تسجيل معاملات الطاقة والقضبان والقطر ونوع العينة لإنتاج N60.', 1, NULL, NULL, NULL, N'كل 1.5 م أو حسب الطبقات.', NULL, N'ASTM D1586 / ISO 22476-3', 1, 20),
(N'TPL-TOWER-HIGHRISE', N'LAB_TEST', N'SETTLEMENT_STRENGTH', N'انضغاطية وقوة قص', N'Settlement and strength testing', N'Consolidation وTriaxial/Direct Shear للطبقات الطينية أو الضعيفة المؤثرة على الهبوط.', 1, NULL, NULL, NULL, N'حسب العينات غير المقلقلة والطبقات الحرجة.', NULL, N'ASTM D2435 / D4767 / D3080', 1, 30),
(N'TPL-TOWER-HIGHRISE', N'LAB_TEST', N'ROCK_TESTS', N'اختبارات الصخر عند وجوده', N'Rock testing when encountered', N'UCS/Point Load/RQD عند الوصول للصخر أو الاعتماد عليه كأساس.', 1, NULL, NULL, NULL, N'حسب runs الصخرية.', NULL, N'ASTM D7012 / D5731', 0, 40),
-- Road
(N'TPL-ROAD-CORRIDOR', N'BOREHOLE', N'TP_BH_INTERVAL', N'حفر اختبارية/جسات على المسار', N'Trial pits/boreholes along alignment', N'توزيع حفر اختبارية أو جسات ضحلة على امتداد المسار مع تكثيفها في مناطق الردم العالي، القطوع، الأودية، والتربة الضعيفة.', 1, 250, 3, 10, N'تباعد إرشادي 250-500 م ويعدل حسب تغيرات المسار.', N'حتى أسفل طبقة subgrade/الردميات أو الطبقة الضعيفة.', N'BS 5930 / AASHTO guidance', 1, 10),
(N'TPL-ROAD-CORRIDOR', N'SAMPLING', N'SUBGRADE_SAMPLES', N'عينات Subgrade ومواد', N'Subgrade and material samples', N'عينات من التربة الطبيعية، borrow areas، ومواد الردم المحتملة.', 1, NULL, NULL, NULL, N'حسب تغير نوع التربة على المسار.', NULL, N'ISO 22475-1', 1, 20),
(N'TPL-ROAD-CORRIDOR', N'LAB_TEST', N'PAVEMENT_TESTS', N'CBR وProctor وتصنيف', N'CBR, Proctor and classification', N'CBR، Proctor، تدرج، Atterberg، ورطوبة لتقييم طبقة التأسيس والمواد.', 1, NULL, NULL, NULL, N'لكل مادة أو تغير واضح.', NULL, N'AASHTO / ASTM D698 / D1883', 1, 30),
-- Bridge
(N'TPL-BRIDGE-FOUNDATION', N'BOREHOLE', N'PIER_ABUTMENT_BH', N'جسات عند الدعامات والركائز', N'Boreholes at piers and abutments', N'جسة أو أكثر عند كل دعامة/كتف حسب حجم الجسر وتعقيد التربة.', 2, NULL, 35, NULL, N'عند كل pier/abutment أو مجموعة دعامات.', N'حتى طبقة تأسيس مناسبة للأساسات العميقة أو الصخر.', N'BS 5930 / EN 1997-2', 1, 10),
(N'TPL-BRIDGE-FOUNDATION', N'FIELD_TEST', N'SPT_ROCK_CORE', N'SPT وRock Coring', N'SPT and rock coring', N'SPT في التربة وأخذ core للصخر مع recovery وRQD عند وجود صخر.', 1, NULL, NULL, NULL, N'حسب الطبقات.', NULL, N'ASTM D1586 / ASTM D2113', 1, 20),
(N'TPL-BRIDGE-FOUNDATION', N'LAB_TEST', N'PILE_PARAMS', N'اختبارات معاملات تصميم الركائز', N'Pile design parameter tests', N'اختبارات قوة وقص وتصنيف وربما كيميائية للخرسانة والحديد حسب الموقع.', 1, NULL, NULL, NULL, N'حسب الطبقات المؤثرة.', NULL, N'ASTM / BS / EN', 1, 30),
-- Dam
(N'TPL-DAM-CRITICAL', N'FIELD_TEST', N'PERMEABILITY', N'اختبارات النفاذية', N'Permeability testing', N'اختبارات نفاذية حقلية/معملية للركيزة والكتفين ومواد الردم المحتملة.', 1, NULL, NULL, NULL, N'في مناطق الأساس والكتفين ومناطق التسرب المحتملة.', NULL, N'BS 5930 / ISO geotechnical practice', 1, 10),
(N'TPL-DAM-CRITICAL', N'BOREHOLE', N'FOUNDATION_ABUTMENTS', N'جسات الأساس والكتفين', N'Foundation and abutment boreholes', N'شبكة جسات ومقاطع على محور السد والكتفين ومناطق borrow، وتدعم بمسح جيولوجي.', 10, NULL, 50, NULL, N'حسب طول محور السد وتعقيد الجيولوجيا.', N'حتى فهم كامل لركيزة السد ومسارات التسرب.', N'BS 5930 / EN 1997-2', 1, 20),
(N'TPL-DAM-CRITICAL', N'LAB_TEST', N'EMBANKMENT_MATERIALS', N'اختبارات مواد السد', N'Dam material testing', N'تصنيف، دمك، قص، نفاذية، تشتت/كيمياء حسب نوع السد والمواد.', 1, NULL, NULL, NULL, N'لكل مصدر مادة وكل طبقة حرجة.', NULL, N'ASTM / BS / AASHTO', 1, 30),
-- Tunnel
(N'TPL-TUNNEL-ALIGNMENT', N'BOREHOLE', N'ALIGNMENT_BH', N'جسات على محور النفق', N'Boreholes along tunnel alignment', N'جسات مختارة على المحور والمداخل والمناطق الجيولوجية الحساسة، وتدمج مع mapping وgeophysics.', 6, NULL, 60, NULL, N'حسب طول النفق والتراكيب الجيولوجية.', N'إلى أسفل منسوب النفق ومنطقة التأثير.', N'BS 5930 / EN 1997-2', 1, 10),
(N'TPL-TUNNEL-ALIGNMENT', N'LAB_TEST', N'ROCK_MASS_TESTS', N'اختبارات كتلة الصخر', N'Rock mass and intact rock tests', N'UCS, Point Load, discontinuities, weathering, RQD/RMR/Q input data.', 1, NULL, NULL, NULL, N'لكل وحدة صخرية مهمة.', NULL, N'ASTM D7012 / ISRM guidance', 1, 20),
(N'TPL-TUNNEL-ALIGNMENT', N'GROUNDWATER', N'WATER_INGRESS', N'مخاطر تدفق المياه', N'Groundwater inflow risk', N'رصد المياه ومناطق التسرب المحتملة والضغط المائي على طول المسار.', 1, NULL, NULL, NULL, N'عند التقاطعات والكسور والوديان.', NULL, N'ISO 22475-1', 1, 30),
-- Railway/Airport/Port/Stadium/Slope shared enough
(N'TPL-RAILWAY-CORRIDOR', N'LAB_TEST', N'SUBGRADE_BALLAST', N'اختبارات Subgrade وBallast', N'Subgrade and ballast tests', N'CBR، Proctor، تدرج، Atterberg، واختبارات مواد طبقات السكة حسب المتطلبات.', 1, NULL, NULL, NULL, N'على امتداد المسار وعند تغير المواد.', NULL, N'AASHTO / ASTM / EN', 1, 10),
(N'TPL-AIRPORT-PAVEMENT', N'LAB_TEST', N'AIRFIELD_PAVEMENT', N'اختبارات رصف المطارات', N'Airfield pavement tests', N'CBR/Plate Load/Compaction/Gradation/Atterberg مع تكثيف العينات لتجانس الساحات والمدارج.', 1, NULL, NULL, NULL, N'شبكة على المدرج والساحات.', NULL, N'ASTM / AASHTO', 1, 10),
(N'TPL-PORT-MARINE', N'GROUNDWATER', N'MARINE_WATER_CHEM', N'مياه وأملاح وبيئة بحرية', N'Marine groundwater and chemistry', N'قياس المياه والأملاح والكبريتات/الكلوريدات وتأثيرها على الخرسانة والحديد.', 1, NULL, NULL, NULL, N'في الجسات البحرية والبرية القريبة.', NULL, N'BS / ASTM chemical testing', 1, 10),
(N'TPL-STADIUM-LARGE', N'BOREHOLE', N'LARGE_FOOTPRINT_GRID', N'شبكة جسات للمساحات الكبيرة', N'Large footprint borehole grid', N'شبكة جسات تغطي المدرجات والمنشآت الثقيلة والمناطق الواسعة مع فحص التجانس والهبوط.', 6, NULL, 25, NULL, N'توزيع شبكي قابل للتعديل حسب المخطط.', NULL, N'BS 5930 / EN 1997-2', 1, 10),
(N'TPL-SLOPE-STABILITY', N'FIELD_TEST', N'SLOPE_MAPPING', N'مسح جيولوجي للمنحدر', N'Slope geological mapping', N'تسجيل الفواصل، الميل، اتجاه الطبقات، مناطق الرشح، شواهد الانزلاق، وخصائص مواد المنحدر.', 1, NULL, NULL, NULL, N'على كامل منطقة المنحدر ومناطق الخطر.', NULL, N'BS 5930 / ISRM guidance', 1, 10),
(N'TPL-SLOPE-STABILITY', N'LAB_TEST', N'SHEAR_STRENGTH', N'اختبارات مقاومة القص', N'Shear strength tests', N'Direct shear/triaxial/residual shear حسب نوع التربة أو مستوى الانزلاق المحتمل.', 1, NULL, NULL, NULL, N'من طبقة الانزلاق والمواد الضعيفة.', NULL, N'ASTM D3080 / D4767', 1, 20);

;WITH S AS (
    SELECT T.TemplateId, C.LookupItemId ItemCategoryId, I.*
    FROM @Items I
    INNER JOIN dbo.InvestigationTemplates T ON T.TemplateCode=I.TemplateCode AND T.IsDeleted=0
    LEFT JOIN dbo.LookupCategories LC ON LC.CategoryCode=N'TemplateItemCategory' AND LC.IsDeleted=0
    LEFT JOIN dbo.LookupItems C ON C.LookupCategoryId=LC.LookupCategoryId AND C.ItemCode=I.CategoryCode AND C.IsDeleted=0
)
UPDATE TI
SET TI.ItemCategoryId=S.ItemCategoryId, TI.ItemTitleAr=S.TitleAr, TI.ItemTitleEn=S.TitleEn, TI.RecommendationText=S.Rec,
    TI.MinQuantity=S.Qty, TI.SpacingMeters=S.Spacing, TI.MinDepthM=S.MinDepth, TI.MaxDepthM=S.MaxDepth,
    TI.FrequencyRule=S.Freq, TI.DepthRule=S.DepthRule, TI.StandardReference=S.Std, TI.IsMandatory=S.Mandatory,
    TI.SortOrder=S.SortOrder, TI.IsActive=1, TI.IsDeleted=0, TI.UpdatedAt=SYSDATETIME()
FROM dbo.InvestigationTemplateItems TI INNER JOIN S ON S.TemplateId=TI.TemplateId AND S.ItemCode=TI.ItemCode;

;WITH S AS (
    SELECT T.TemplateId, C.LookupItemId ItemCategoryId, I.*
    FROM @Items I
    INNER JOIN dbo.InvestigationTemplates T ON T.TemplateCode=I.TemplateCode AND T.IsDeleted=0
    LEFT JOIN dbo.LookupCategories LC ON LC.CategoryCode=N'TemplateItemCategory' AND LC.IsDeleted=0
    LEFT JOIN dbo.LookupItems C ON C.LookupCategoryId=LC.LookupCategoryId AND C.ItemCode=I.CategoryCode AND C.IsDeleted=0
)
INSERT INTO dbo.InvestigationTemplateItems(TemplateId, ItemCategoryId, ItemCode, ItemTitleAr, ItemTitleEn, RecommendationText, MinQuantity, SpacingMeters, MinDepthM, MaxDepthM, FrequencyRule, DepthRule, StandardReference, IsMandatory, SortOrder, IsActive)
SELECT S.TemplateId, S.ItemCategoryId, S.ItemCode, S.TitleAr, S.TitleEn, S.Rec, S.Qty, S.Spacing, S.MinDepth, S.MaxDepth, S.Freq, S.DepthRule, S.Std, S.Mandatory, S.SortOrder, 1
FROM S WHERE NOT EXISTS(SELECT 1 FROM dbo.InvestigationTemplateItems TI WHERE TI.TemplateId=S.TemplateId AND TI.ItemCode=S.ItemCode AND TI.IsDeleted=0);
GO

PRINT N'Sprint 8 lookups, permissions, and templates created successfully.';
GO
