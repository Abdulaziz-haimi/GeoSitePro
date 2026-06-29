GeoSitePro - Sprint 9
=====================

موضوع Sprint 9:
خريطة الموقع والجسات Site Map + Borehole Layout + Cross Sections.

الترتيب الصحيح لتشغيل قاعدة البيانات بعد Sprint 8:
1) 34_Create_Tables_Sprint9.sql
2) 35_Create_Lookups_Permissions_Sprint9.sql
3) 36_Create_StoredProcedures_Sprint9.sql
4) 37_Verify_Sprint9_DB.sql

الصفحات الجديدة:
- SiteMap.aspx
- CrossSections.aspx

طريقة الاستخدام:
1) افتح SiteMap.aspx واختر المشروع.
2) احفظ نظام الإحداثيات أو اتركه كشبكة محلية.
3) أدخل Easting/Northing للجسات الفعلية من صفحة Boreholes، ثم اضغط "توليد من الجسات الفعلية".
4) إذا لم تبدأ الحفر بعد، يمكن توليد نقاط مبدئية من خطة التحري التي تم إنشاؤها في Sprint 8.
5) افتح CrossSections.aspx، أنشئ مقطعًا، ثم اضغط "ربط الجسات تلقائيًا".
6) سيعرض النظام مقطعًا مبسطًا من الجسات والطبقات المسجلة في Borehole Log.

ملاحظة هندسية:
الخريطة والمقاطع الحالية Schematics داخلية للمراجعة والتخطيط، وليست بديلًا عن مخطط CAD/GIS مساحي معتمد.
