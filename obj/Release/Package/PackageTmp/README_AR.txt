GeoSite Pro - Sprint 2 Package
==============================

هذه النسخة مبنية على Sprint 1 السابق، وتم فيها تفعيل Sprint 2 عمليًا.

الوظائف الموجودة الآن:
1) Login / Dashboard.
2) Projects / ProjectDetails.
3) Boreholes: إضافة وتعديل وحذف منطقي للجسات.
4) Borehole Log: إدخال طبقات الجسة وعرض سجل الجسة.
5) Samples: تسجيل العينات وربطها بالمشروع والجسة.
6) SPT Tests: تسجيل ضربات N1/N2/N3 وحساب N-Value عند تركه فارغًا.
7) Groundwater: تسجيل قراءات المياه الجوفية.

ترتيب تشغيل قاعدة البيانات من الصفر:
1) شغّل ملفات Sprint 1 التي أرسلتها أنت بالترتيب:
   01_Create_Database(1).sql
   02_Create_Tables_Sprint1.sql
   03_Create_Lookups_Permissions.sql
   04_Create_StoredProcedures_Sprint1.sql
   05_Seed_Admin_User.sql

2) بعد ذلك شغّل ملفات Sprint 2 من داخل:
   Scripts/Sprint2/

   06_Create_Tables_Sprint2.sql
   07_Create_Lookups_Permissions_Sprint2.sql
   08_Create_StoredProcedures_Sprint2.sql

بيانات الدخول:
Username: admin
Password: Admin@123

ملاحظات مهمة:
- لا تشغّل GeoSitePro_Database.sql القديم إذا كنت ستعتمد ملفات Sprint 1 الخمسة التي أرسلتها؛ استخدمها فقط كمرجع قديم.
- Sprint 2 يركز على التحري الحقلي: Boreholes + Logs + Samples + SPT + Groundwater.
- Lab Results و Reports ستكون في Sprint 3 و Sprint 4.
- المشروع ASP.NET WebForms على .NET Framework 4.7.2 ويحتاج Visual Studio على Windows للبناء النهائي.

------------------------------------------------------------
Sprint 5 - الإدارة والصلاحيات وسجل التدقيق
------------------------------------------------------------
تم إضافة وتفعيل الصفحات التالية:
- Users.aspx لإدارة المستخدمين وتوزيع الأدوار.
- Roles.aspx لإدارة الأدوار.
- RolePermissions.aspx لإدارة صلاحيات كل دور.
- AuditLog.aspx لعرض سجل التدقيق.

شغّل سكربتات Sprint 5 بالترتيب التالي بعد Sprint 4:
Scripts/Sprint5/18_Schema_Compatibility_Sprint5.sql
Scripts/Sprint5/19_Create_Permissions_Sprint5.sql
Scripts/Sprint5/20_Create_StoredProcedures_Sprint5.sql
Scripts/Sprint5/21_Verify_Sprint5_DB.sql

ملاحظة: بعد تغيير صلاحيات أي دور، يجب تسجيل الخروج والدخول من جديد لتحميل الصلاحيات الجديدة في Session.

========================================
Sprint 6 + Sprint 7
========================================
تمت إضافة مرحلتي الجودة والتشغيل:

Sprint 6:
- Standards.aspx: مكتبة المعايير الفنية.
- ProjectQualityCheck.aspx: فحص جودة المشروع وقائمة تحقق QA/QC.
- EngineeringCalculations.aspx: حسابات جيوتقنية مساعدة مثل Moisture Content وPI وN60 وCu/Cc وDry Density.

Sprint 7:
- ProjectDocuments.aspx: رفع وحفظ مرفقات المشروع داخل App_Data/Uploads/ProjectDocuments.
- ExportCenter.aspx: إنشاء حزم تصدير للمشروع.
- ProductionReadiness.aspx: قائمة جاهزية الإنتاج قبل الاستخدام الرسمي.

ترتيب تشغيل SQL بعد Sprint 5:
Scripts/Sprint6/22_Create_Tables_Sprint6.sql
Scripts/Sprint6/23_Create_Lookups_Permissions_Sprint6.sql
Scripts/Sprint6/24_Create_StoredProcedures_Sprint6.sql
Scripts/Sprint6/25_Verify_Sprint6_DB.sql
Scripts/Sprint7/26_Create_Tables_Sprint7.sql
Scripts/Sprint7/27_Create_Lookups_Permissions_Sprint7.sql
Scripts/Sprint7/28_Create_StoredProcedures_Sprint7.sql
Scripts/Sprint7/29_Verify_Sprint7_DB.sql

ملاحظات مهمة:
- الحسابات المضافة مساعدة ولا تغني عن مراجعة مهندس جيوتقني.
- المرفقات تحتاج نسخًا احتياطيًا من مجلد App_Data/Uploads مع قاعدة البيانات.
- قبل الإنتاج الحقيقي يجب تشغيل Build فعلي في Visual Studio ومراجعة Web.config للأمان.

----------------------------------------
Sprint 8 - Project Type Investigation Templates
----------------------------------------
تمت إضافة قوالب تحري حسب نوع المشروع بحيث يبدأ النظام من توصيات مبدئية للجسات والعينات والاختبارات والمعايير، ثم يسمح للمهندس بتعديل خطة المشروع واعتمادها.

الصفحات:
- InvestigationTemplates.aspx: مكتبة القوالب حسب نوع المشروع.
- ProjectInvestigationPlan.aspx: توليد خطة تحري للمشروع وتعديل البنود واعتمادها.

ترتيب تشغيل SQL بعد Sprint 7:
1) Scripts/Sprint8/30_Create_Tables_Sprint8.sql
2) Scripts/Sprint8/31_Create_Lookups_Permissions_Templates_Sprint8.sql
3) Scripts/Sprint8/32_Create_StoredProcedures_Sprint8.sql
4) Scripts/Sprint8/33_Verify_Sprint8_DB.sql

مهم: القوالب إرشادية وقابلة للتعديل، وليست بديلًا عن حكم المهندس أو متطلبات الكود والجهة المالكة.

Sprint 9 - Site Map & Cross Sections
------------------------------------
تمت إضافة:
- SiteMap.aspx: خريطة مبسطة للجسات المخططة والفعلية باستخدام Easting/Northing.
- CrossSections.aspx: مقاطع جيوتقنية مبسطة تعتمد على الجسات وطبقات Borehole Log.

بعد Sprint 8 شغّل:
Scripts/Sprint9/34_Create_Tables_Sprint9.sql
Scripts/Sprint9/35_Create_Lookups_Permissions_Sprint9.sql
Scripts/Sprint9/36_Create_StoredProcedures_Sprint9.sql
Scripts/Sprint9/37_Verify_Sprint9_DB.sql

ملاحظة: الخرائط والمقاطع في Sprint 9 هي رسومات تخطيطية داخلية، وليست بديلًا عن CAD/GIS معتمد أو رفع مساحي رسمي.

----------------------------------------
Sprint 10 - Data Exchange + GIS/CAD Export
----------------------------------------
تمت إضافة:
- DataExchange.aspx لتصدير بيانات المشروع CSV.
- GisCadExport.aspx لتصدير نقاط الجسات وطبقات الجسات وبيانات المقاطع بصيغة CSV مناسبة للاستيراد أو التحويل في GIS/CAD.
- DataExportDownload.aspx لتوليد ملفات CSV فعليًا من قاعدة البيانات.

ترتيب تشغيل سكربتات Sprint 10:
1) Scripts/Sprint10/38_Create_Tables_Sprint10.sql
2) Scripts/Sprint10/39_Create_Permissions_Sprint10.sql
3) Scripts/Sprint10/40_Create_StoredProcedures_Sprint10.sql
4) Scripts/Sprint10/41_Verify_Sprint10_DB.sql

بعد تشغيل السكربتات:
- سجّل خروج ثم دخول مرة أخرى.
- افتح DataExchange.aspx أو GisCadExport.aspx من القائمة.

============================================================
Sprint 11 - Print & Submission Package
============================================================

تمت إضافة موديول الطباعة وحزمة التسليم:

الصفحات الجديدة:
- PrintableOutputs.aspx
- ProjectPrintPackage.aspx
- BoreholeLogPrint.aspx

الهدف:
- اختيار المشروع وعرض مركز مخرجات الطباعة.
- طباعة حزمة مشروع كاملة من المتصفح أو حفظها PDF.
- طباعة سجل جسة واحد أو كل سجلات الجسات في المشروع.

تشغيل قاعدة البيانات بعد Sprint 10:
1) Scripts/Sprint11/42_Create_Tables_Sprint11.sql
2) Scripts/Sprint11/43_Create_Permissions_Sprint11.sql
3) Scripts/Sprint11/44_Create_StoredProcedures_Sprint11.sql
4) Scripts/Sprint11/45_Verify_Sprint11_DB.sql

بعد تشغيل السكربتات، سجّل خروج ثم دخول مرة أخرى حتى يتم تحميل صلاحيات Sprint 11.

ملاحظة مهمة:
مخرجات Sprint 11 مناسبة للطباعة والمراجعة وحفظ PDF من المتصفح، لكنها لا تغني عن اعتماد التقرير النهائي من المهندس المختص أو عن قالب الشركة الرسمي في مرحلة الإنتاج.

========================================
Sprint 12 - Workflow & Approvals
========================================
تمت إضافة موديول سير العمل والاعتمادات الفنية.

الصفحات الجديدة:
- WorkflowInbox.aspx: صندوق طلبات المراجعة والاعتماد.
- ProjectApproval.aspx: إنشاء ومتابعة طلبات اعتماد المشروع.
- ApprovalMatrix.aspx: إدارة مراحل سير العمل حسب نوع الكيان.

ترتيب تشغيل قاعدة البيانات بعد Sprint 11:
Scripts/Sprint12/46_Create_Tables_Sprint12.sql
Scripts/Sprint12/47_Create_Permissions_Sprint12.sql
Scripts/Sprint12/48_Create_StoredProcedures_Sprint12.sql
Scripts/Sprint12/49_Verify_Sprint12_DB.sql

بعد تشغيل سكربتات Sprint 12:
سجل خروج ثم دخول مرة أخرى حتى تُحمّل صلاحيات Workflow الجديدة.


Sprint 13 - Notifications & Follow-up Center
- Notifications.aspx: مركز التنبيهات.
- FollowUpBoard.aspx: إنشاء وإغلاق بنود المتابعة للمشاريع.
- NotificationRules.aspx: إدارة قواعد التنبيهات.

ترتيب SQL بعد Sprint 12:
Scripts/Sprint13/50_Create_Tables_Sprint13.sql
Scripts/Sprint13/51_Create_Permissions_Seed_Sprint13.sql
Scripts/Sprint13/52_Create_StoredProcedures_Sprint13.sql
Scripts/Sprint13/53_Verify_Sprint13_DB.sql


Sprint 14 - Executive Dashboard, Quality KPIs & Risk Register
------------------------------------------------------------
الصفحات الجديدة:
- ExecutiveDashboard.aspx
- ProjectRiskRegister.aspx
- QualityKpiDashboard.aspx

ترتيب سكربتات Sprint 14 بعد Sprint 13:
1) Scripts/Sprint14/54_Create_Tables_Sprint14.sql
2) Scripts/Sprint14/55_Create_Permissions_Seed_Sprint14.sql
3) Scripts/Sprint14/56_Create_StoredProcedures_Sprint14.sql
4) Scripts/Sprint14/57_Verify_Sprint14_DB.sql

بعد التشغيل، سجل خروج ثم دخول لتظهر الصلاحيات الجديدة.


Sprint 15 - إدارة التشغيل والنسخ الاحتياطي
- SystemSettings.aspx: إعدادات النظام العامة.
- BackupCenter.aspx: تسجيل طلب النسخ الاحتياطي وتوليد أمر SQL.
- SystemHealth.aspx: فحص صحة النظام والجداول الأساسية.
- OperationLogs.aspx: سجل تشغيل إداري وتقني منفصل عن Audit Log.
تشغيل قاعدة البيانات: Scripts/Sprint15/58 ثم 59 ثم 60 ثم 61.

Sprint 16 - Security Hardening & Deployment Readiness
=====================================================
تمت إضافة:
- SecurityCenter.aspx: مركز أحداث الأمان.
- PasswordPolicy.aspx: سياسة كلمة المرور والجلسات.
- DeploymentChecklist.aspx: قائمة تحقق جاهزية النشر.

ملفات SQL:
Scripts/Sprint16/62_Create_Tables_Sprint16.sql
Scripts/Sprint16/63_Create_Permissions_Seed_Sprint16.sql
Scripts/Sprint16/64_Create_StoredProcedures_Sprint16.sql
Scripts/Sprint16/65_Verify_Sprint16_DB.sql

بعد تشغيل SQL، سجل خروج ثم دخول حتى يتم تحميل الصلاحيات الجديدة.
