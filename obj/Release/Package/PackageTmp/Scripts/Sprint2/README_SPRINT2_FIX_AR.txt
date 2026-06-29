تمت إضافة باتش إصلاح أخطاء قاعدة Sprint 2.

سبب الأخطاء:
قاعدة البيانات لديك كانت تحتوي جداول قديمة، لذلك لم يتم إنشاء الأعمدة الحديثة مثل IsDeleted وLookupCategoryId وItemCode وNewValues وClientId.

الترتيب الصحيح الآن عند وجود قاعدة قديمة:
1) 06A_Schema_Compatibility_Before_Sprint2.sql
2) 07_Create_Lookups_Permissions_Sprint2_FIXED.sql
3) 08_Create_StoredProcedures_Sprint2_FIXED.sql
4) 09_Verify_Sprint2_DB.sql

لا تستخدم ملف 07 القديم إذا كنت تعمل فوق قاعدة قديمة.
