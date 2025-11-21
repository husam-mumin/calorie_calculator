# مشروع حساب السعرات الحرارية (Calorie Calculator)

## فكرة المشروع

مشروع تطبيق متعدد المنصات (أندرويد، iOS، ويب، سطح المكتب) باستخدام Flutter يهدف إلى مساعدة المستخدم على إدارة تغذيته اليومية من خلال:

1. حساب السعرات الحرارية المستهلكة.
2. اقتراح احتياج السعرات اليومي بناءً على بيانات المستخدم (العمر، الجنس، الطول، الوزن، مستوى النشاط، الهدف: فقدان وزن / اكتساب / تثبيت).
3. تتبع العناصر الغذائية الكبرى (البروتين، الكربوهيدرات، الدهون) والفيتامينات الأساسية إن وُجدت.
4. بناء سجل يومي / أسبوعي / شهري للتقدم.
5. دعم لغات متعددة (وجود مجلد `l10n` يوحي بإمكانية الترجمة).

## كيف يعمل التطبيق

1. يقوم المستخدم بإدخال بياناته الأساسية لأول مرة (أو تعديلها لاحقاً).
2. يتم حساب معدل الأيض الأساسي (BMR) ثم السعرات اليومية الموصى بها عبر معادلات شائعة مثل Harris-Benedict أو Mifflin-St Jeor (يمكنك لاحقاً اختيار المعادلة الأنسب وتوثيقها هنا).
3. يضيف المستخدم وجباته خلال اليوم عبر البحث عن الأطعمة أو اختيارها من قائمة محلية (ملفات JSON في مجلد `assets`).
4. عند إضافة كل طعام يتم:
   - قراءة بياناته الغذائية من قاعدة البيانات المحلية / ملف البذور (seed).
   - حساب مجموع السعرات والعناصر الغذائية وتحديث ملخص اليوم.
5. يمكن للمستخدم رؤية مخطط بياني للتقدم (قد يتم تنفيذه لاحقاً باستخدام مكتبة رسوميات).
6. يتم تخزين السجلات محلياً (ربما باستخدام SQLite عبر حزمة مثل `sqflite` نظراً لوجود مجلد مرتبط بالحزمة في `build`).

## بنية المشروع (نظرة سريعة)

`lib/` يحتوي على الشيفرة المصدرية:

- الملف `main.dart` نقطة الدخول.
- مجلد `core/features` (يبدو مخصصاً لتجزئة الوظائف: حساب السعرات، إدارة المستخدم، إدارة قاعدة البيانات، آليات التخزين).
- مجلد `l10n` للترجمة (arb ملفات عادةً).

`assets/` يحتوي على:

- ملفي: `foods_seed.json` و `foods_seed_ar.json` وهما على الأرجح بذور بيانات للأطعمة (إنجليزي وعربي) تشمل: اسم الطعام، حجم الحصة، السعرات، البروتين، الكربوهيدرات، الدهون وربما ألياف وسكر.

## قاعدة البيانات

### النموذج المقترح (Entities)

1. مستخدم (User)
   - id
   - name
   - gender (male/female)
   - birthDate (أو العمر مباشرة)
   - heightCm
   - weightKg
   - activityLevel (sedentary, light, moderate, active, very_active)
   - goalType (lose, maintain, gain)
   - targetWeightKg (اختياري)
   - createdAt / updatedAt

2. طعام (Food)
   - id
   - localizedNameEn
   - localizedNameAr
   - portionSize (مثلاً جرام أو حصة)
   - calories
   - proteinGrams
   - carbsGrams
   - fatGrams
   - fiberGrams (اختياري)
   - sugarGrams (اختياري)

3. وجبة يومية (MealEntry)
   - id
   - userId
   - foodId
   - date (تاريخ اليوم)
   - quantity (عدد الحصص)
   - totalCalories (مشتقة)
   - totalProtein (مشتقة)
   - totalCarbs (مشتقة)
   - totalFat (مشتقة)
   - createdAt

4. ملخص يومي (DailySummary)
   - id
   - userId
   - date
   - totalCalories
   - totalProtein
   - totalCarbs
   - totalFat
   - calorieTarget (عند الحساب في ذلك اليوم)

يمكن تخزين الكيانات 3 و 4 كمخرجات محسوبة دون الحاجة أحياناً لكيان منفصل لـ DailySummary إذا أمكن اشتقاقه مباشرة من MealEntry، لكن وجوده يحسّن الأداء عند كثرة البيانات.

### الحقول على شكل جداول

يوضح الجدول التالي الحقول لكل كيان مع النوع والغرض المقترَح (SQLite):

#### User

| الحقل | النوع (SQLite) | الوصف |
|---|---|---|
| id | INTEGER PRIMARY KEY AUTOINCREMENT | معرف المستخدم |
| name | TEXT | اسم المستخدم |
| gender | TEXT CHECK(gender IN ('male','female')) | الجنس |
| birthDate | TEXT | تاريخ الميلاد بصيغة ISO8601 |
| heightCm | REAL | الطول بالسنتيمتر |
| weightKg | REAL | الوزن بالكيلوجرام |
| activityLevel | TEXT | مستوى النشاط |
| goalType | TEXT CHECK(goalType IN ('lose','maintain','gain')) | الهدف |
| targetWeightKg | REAL NULL | الوزن المستهدف (اختياري) |
| createdAt | TEXT | تاريخ الإنشاء |
| updatedAt | TEXT | تاريخ التحديث |

#### Food

| الحقل | النوع (SQLite) | الوصف |
|---|---|---|
| id | INTEGER PRIMARY KEY AUTOINCREMENT | معرف الطعام |
| localizedNameEn | TEXT | الاسم بالإنجليزية |
| localizedNameAr | TEXT | الاسم بالعربية |
| portionSize | REAL | حجم الحصة بالجرام/الوحدة |
| calories | REAL | سعرات لكل حصة |
| proteinGrams | REAL | بروتين لكل حصة |
| carbsGrams | REAL | كربوهيدرات لكل حصة |
| fatGrams | REAL | دهون لكل حصة |
| fiberGrams | REAL NULL | ألياف (اختياري) |
| sugarGrams | REAL NULL | سكر (اختياري) |

#### MealEntry

| الحقل | النوع (SQLite) | الوصف |
|---|---|---|
| id | INTEGER PRIMARY KEY AUTOINCREMENT | معرف السجل |
| userId | INTEGER | مرجع المستخدم |
| foodId | INTEGER | مرجع الطعام |
| date | TEXT | تاريخ اليوم (ISO8601 دون وقت) |
| quantity | REAL | عدد الحصص |
| totalCalories | REAL | السعرات الإجمالية |
| totalProtein | REAL | بروتين إجمالي |
| totalCarbs | REAL | كربوهيدرات إجمالي |
| totalFat | REAL | دهون إجمالية |
| createdAt | TEXT | تاريخ الإنشاء |

#### DailySummary

| الحقل | النوع (SQLite) | الوصف |
|---|---|---|
| id | INTEGER PRIMARY KEY AUTOINCREMENT | معرف السجل |
| userId | INTEGER | مرجع المستخدم |
| date | TEXT | تاريخ اليوم |
| totalCalories | REAL | مجموع السعرات |
| totalProtein | REAL | مجموع البروتين |
| totalCarbs | REAL | مجموع الكربوهيدرات |
| totalFat | REAL | مجموع الدهون |
| calorieTarget | REAL | الهدف من السعرات في ذلك اليوم |

ملاحظة: يُفضّل استخدام تواريخ بصيغة ISO8601 كنص مع فهارس (Indexes) على الحقول `date`, `userId` لتحسين الأداء.

### أوامر إنشاء الجداول (SQLite DDL)

```sql
CREATE TABLE IF NOT EXISTS User (
   id INTEGER PRIMARY KEY AUTOINCREMENT,
   name TEXT NOT NULL,
   gender TEXT CHECK(gender IN ('male','female')) NOT NULL,
   birthDate TEXT,
   heightCm REAL NOT NULL,
   weightKg REAL NOT NULL,
   activityLevel TEXT NOT NULL,
   goalType TEXT CHECK(goalType IN ('lose','maintain','gain')) NOT NULL,
   targetWeightKg REAL,
   createdAt TEXT NOT NULL,
   updatedAt TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS Food (
   id INTEGER PRIMARY KEY AUTOINCREMENT,
   localizedNameEn TEXT,
   localizedNameAr TEXT,
   portionSize REAL NOT NULL,
   calories REAL NOT NULL,
   proteinGrams REAL NOT NULL,
   carbsGrams REAL NOT NULL,
   fatGrams REAL NOT NULL,
   fiberGrams REAL,
   sugarGrams REAL
);

CREATE TABLE IF NOT EXISTS MealEntry (
   id INTEGER PRIMARY KEY AUTOINCREMENT,
   userId INTEGER NOT NULL,
   foodId INTEGER NOT NULL,
   date TEXT NOT NULL,
   quantity REAL NOT NULL,
   totalCalories REAL NOT NULL,
   totalProtein REAL NOT NULL,
   totalCarbs REAL NOT NULL,
   totalFat REAL NOT NULL,
   createdAt TEXT NOT NULL,
   FOREIGN KEY(userId) REFERENCES User(id) ON DELETE CASCADE,
   FOREIGN KEY(foodId) REFERENCES Food(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS DailySummary (
   id INTEGER PRIMARY KEY AUTOINCREMENT,
   userId INTEGER NOT NULL,
   date TEXT NOT NULL,
   totalCalories REAL NOT NULL,
   totalProtein REAL NOT NULL,
   totalCarbs REAL NOT NULL,
   totalFat REAL NOT NULL,
   calorieTarget REAL NOT NULL,
   UNIQUE(userId, date),
   FOREIGN KEY(userId) REFERENCES User(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_mealentry_user_date ON MealEntry(userId, date);
CREATE INDEX IF NOT EXISTS idx_dailysummary_user_date ON DailySummary(userId, date);
```

### اختيار محرك التخزين

بما أن المشروع Flutter متعدد المنصات وأبسط، فـ SQLite (حزمة `sqflite`) خيار مناسب. بديل آخر: استخدام `hive` للتخزين المفتاح-قيمة مع صناديق (Boxes) لكنه أقل كفاءة للاستعلامات المعقدة.

### تدفق البيانات

1. بيانات الأطعمة تُحمّل أول مرة من ملف البذور `foods_seed_ar.json` و `foods_seed.json` وتُدخل إلى جدول Food إذا كان فارغاً.
2. عند إضافة وجبة، يتم جلب Food ثم حساب القيم وضخها في MealEntry.
3. يتم تحديث / حساب DailySummary (إما بإعادة التجميع أو التحديث التراكمي).
4. واجهة المستخدم تستمع (Streams / ChangeNotifier / Bloc / Riverpod حسب ما ستستخدم) لتحديثات الملخص.

## حساب السعرات (مثال مبسط)

معادلة Mifflin-St Jeor:

ذكر: BMR = (10 × الوزن كجم) + (6.25 × الطول سم) − (5 × العمر) + 5  
أنثى: BMR = (10 × الوزن كجم) + (6.25 × الطول سم) − (5 × العمر) − 161

يتم ضرب الناتج بعامل النشاط (1.2 إلى 1.9). ثم تعديل الهدف:

- فقدان وزن: نقص 10% إلى 20% أو طرح 300 - 500 سعرة.
- زيادة وزن: زيادة 10% إلى 15% أو إضافة 300 - 400 سعرة.
- تثبيت: السعرات المحسوبة دون تعديل.

## واجهة المستخدم المتوقعة

شاشات رئيسية محتملة:

1. شاشة إدخال بيانات المستخدم أو الإعدادات.
2. شاشة اليوم الحالي (ملخص السعرات المتبقية، العناصر الغذائية، قائمة الوجبات المدخلة).
3. شاشة إضافة / بحث طعام.
4. شاشة السجل (أيام سابقة - مخطط بياني).
5. شاشة الإحصائيات (متوسط أسبوعي، تقدم الوزن).
6. شاشة اختيار اللغة.

## التدويل (i18n)

وجود مجلد `l10n` يوحي باستخدام Flutter localization. يمكن إضافة ملفات ARB مثل:

- app_en.arb
- app_ar.arb

وتحوي المفاتيح: appTitle, addMeal, remainingCalories, settings, etc.

## تشغيل المشروع محلياً

بعد تثبيت Flutter:

1. تثبيت الحزم:

```bash
flutter pub get
```

1. تشغيل على المحاكي أو الجهاز:

```bash
flutter run
```

## هيكلية برمجية مقترحة (ليست إلزامية)

اعتماد طبقات:

- data: مصادر البيانات (SQLite، ملفات JSON، خدمات خارجية)
- domain: نماذج + واجهات مخازن (Repositories) + منطق حساب السعرات
- application: إدارة الحالة (Bloc / Riverpod / Provider)
- presentation: الشاشات و الواجهات و الودجات

