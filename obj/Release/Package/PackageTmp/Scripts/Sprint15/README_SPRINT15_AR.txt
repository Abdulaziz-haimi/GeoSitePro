Sprint 15 - System Administration, Backup & Operations

ترتيب التشغيل بعد Sprint 14:
1) 58_Create_Tables_Sprint15.sql
2) 59_Create_Permissions_Seed_Sprint15.sql
3) 60_Create_StoredProcedures_Sprint15.sql
4) 61_Verify_Sprint15_DB.sql

بعد التشغيل:
- سجل خروج ثم دخول حتى يتم تحميل الصلاحيات الجديدة.
- افتح إعدادات النظام من القائمة.
- افتح مركز النسخ الاحتياطي وأنشئ طلب نسخة احتياطية.
- نفذ أمر BACKUP DATABASE الناتج من SQL Server Management Studio بواسطة مسؤول قاعدة البيانات.
- راجع System Health قبل تسليم النظام للتجربة.

ملاحظة: النظام لا ينفذ النسخ الاحتياطي فعليًا من صفحة الويب لأسباب أمنية وصلاحيات SQL Server، بل يولد أمر SQL قابل للمراجعة والتنفيذ.
