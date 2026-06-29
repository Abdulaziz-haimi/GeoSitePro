Sprint 5 - Administration and Security

الترتيب الصحيح للتنفيذ بعد Sprint 4:

18_Schema_Compatibility_Sprint5.sql
19_Create_Permissions_Sprint5.sql
20_Create_StoredProcedures_Sprint5.sql
21_Verify_Sprint5_DB.sql

الوظائف المضافة:
- إدارة المستخدمين Users.
- إنشاء وتعديل وحذف المستخدمين منطقيًا.
- إعادة تعيين كلمة المرور إلى Admin@123 من شاشة المستخدمين.
- توزيع الأدوار على المستخدم.
- إدارة الأدوار Roles.
- إدارة صلاحيات كل دور Role Permissions.
- عرض سجل التدقيق Audit Log مع فلاتر.

ملاحظة:
بعد تعديل صلاحيات دور، يجب تسجيل خروج المستخدم ثم تسجيل الدخول مرة أخرى حتى يتم تحميل الصلاحيات الجديدة داخل Session.
