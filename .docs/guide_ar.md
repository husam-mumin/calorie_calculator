# دليل مشروع حساب السعرات الحرارية

## مقدمة

هذا الدليل يشرح بالتفصيل فكرة مشروع "حساب السعرات الحرارية" المبني بإطار Flutter، ويغطي الأهداف، المكونات البرمجية، بنية قاعدة البيانات، منطق حساب السعرات، إدارة الحالة، التدويل، الاختبارات، والخارطة المستقبلية.

## الأهداف الرئيسية

1. تمكين المستخدم من معرفة احتياجه اليومي من السعرات الحرارية بناءً على بياناته.
2. تسهيل تسجيل الوجبات والأطعمة مع تفاصيل العناصر الغذائية الكبرى (Macronutrients).
3. عرض تقدم المستخدم (سعرات مستهلكة مقابل المستهدفة + مخططات يومية/أسبوعية/شهرية).
4. دعم لغات متعددة مع توفير واجهة عربية كاملة.
5. توفير بنية قابلة للتوسعة لإضافة ميزات مثل المزامنة السحابية وقراءة الباركود.

## الجمهور المستهدف

- الأفراد الراغبون في فقدان أو زيادة أو تثبيت الوزن.
- الرياضيون الهواة الذين يتابعون توزيع العناصر الغذائية.
- أي مستخدم يرغب في تتبع عادات الأكل اليومية بطريقة مبسطة.

## المتطلبات المسبقة

- تثبيت Flutter (نسخة مستقرة حديثة).
- محاكي Android أو iOS، أو جهاز فعلي.
- Dart SDK مضمن مع Flutter.

للتحقق من الإعداد:

```bash
flutter doctor
```

## تشغيل المشروع

```bash
flutter pub get
flutter run
```

يمكن تحديد المنصة:

```bash
flutter run -d chrome
flutter run -d windows
```

## بنية المجلدات المقترحة (منطق طبقات نظري)

```text
lib/
  core/
    features/
      user/
      food/
      meal/
      summary/
    services/
      database/
      localization/
  data/
    datasources/
    repositories/
  domain/
    models/
    usecases/
  application/
    state/
  presentation/
    widgets/
    screens/
  l10n/
```

- core: وظائف أساسية مشتركة (استثناءات، ثوابت، خدمات).
- data: مصادر البيانات الفعلية (SQLite، ملفات JSON، استدعاءات HTTP مستقبلاً).
- domain: نماذج الأعمال + واجهات المستودعات + حالات الاستخدام (Use Cases).
- application: إدارة الحالة (Bloc / Riverpod / Provider).
- presentation: واجهات المستخدم وودجات.
- l10n: ملفات الترجمة ARB.

## نماذج البيانات (Entities)

### User

- id
- name
- gender
- birthDate
- heightCm
- weightKg
- activityLevel
- goalType
- targetWeightKg
- createdAt / updatedAt

### Food

- id
- localizedNameEn / localizedNameAr
- portionSize
- calories
- proteinGrams
- carbsGrams
- fatGrams
- fiberGrams (اختياري)
- sugarGrams (اختياري)

### MealEntry

- id
- userId
- foodId
- date
- quantity
- totalCalories / totalProtein / totalCarbs / totalFat
- createdAt

### DailySummary

- id
- userId
- date
- totalCalories / totalProtein / totalCarbs / totalFat
- calorieTarget

## تصميم قاعدة البيانات (جداول + فهارس)

انظر `README` لنسخة SQL، ويمكن اعتماد نفس الأوامر. ملاحظات إضافية:

1. تأكد من إضافة فهرس على (userId, date) في الجداول التي تعتمد الاستعلام اليومي.
2. استخدم تنسيق ISO8601 للتواريخ (YYYY-MM-DD أو التاريخ الكامل مع الوقت عند الحاجة).
3. يمكن حذف جدول DailySummary والاكتفاء بحساب تجميعي عند الطلب، ولكن وجوده يسهّل الأداء على الأجهزة الضعيفة.

## منطق حساب السعرات

### معادلة Mifflin-St Jeor

ذكر:

```text
BMR = (10 × الوزن كجم) + (6.25 × الطول سم) − (5 × العمر) + 5
```

أنثى:

```text
BMR = (10 × الوزن كجم) + (6.25 × الطول سم) − (5 × العمر) − 161
```

### مستويات النشاط المقترحة

| المستوى | العامل |
|---------|--------|
| خامل (Sedentary) | 1.2 |
| خفيف (Light) | 1.375 |
| متوسط (Moderate) | 1.55 |
| نشط (Active) | 1.725 |
| نشط جداً (Very Active) | 1.9 |

### تعديل الهدف

- فقدان: طرح 300–500 سعرة أو خفض 10–20%.
- زيادة: إضافة 300–400 سعرة أو رفع 10–15%.
- تثبيت: الناتج كما هو.

يمكن لاحقاً دعم خوارزميات متقدمة تدمج معدل الحرق الفعلي عبر أجهزة تتبع النشاط.

## توزيع الماكروز (مثال)

| الهدف | بروتين | كربوهيدرات | دهون |
|-------|--------|------------|------|
| فقدان وزن | 30–35% | 35–40% | 25–30% |
| تثبيت | 25–30% | 40–50% | 20–30% |
| زيادة | 20–25% | 45–55% | 25–30% |

احسب الغرامات:

```text
proteinGrams = (calories * protein%) / 4
carbsGrams   = (calories * carbs%) / 4
fatGrams     = (calories * fat%) / 9
```

## إدارة الحالة (مثال باستخدام Riverpod)

خطوات عامة:

1. مزود (Provider) لحالة المستخدم UserProfile.
2. مزود للأطعمة FoodRepository (قراءة من SQLite + Seed).
3. مزود للوجبات MealEntryRepository.
4. مزود ملخص اليوم DailySummaryService.
5. مزود حساب السعرات CalorieCalculator.

## التدويل (Localization)

أمثلة مفاتيح في `l10n/app_ar.arb`:

```json
{
  "appTitle": "حساب السعرات",
  "addMeal": "إضافة وجبة",
  "remainingCalories": "السعرات المتبقية",
  "totalCalories": "إجمالي السعرات",
  "settings": "الإعدادات",
  "language": "اللغة",
  "profile": "الملف الشخصي"
}
```

## خارطة طريق (Roadmap)

| المرحلة | الوصف | الحالة |
|---------|-------|--------|
| MVP | إدخال المستخدم + حساب BMR + إضافة وجبات + عرض ملخص | قيد التنفيذ |
| i18n | دعم الإنجليزية والعربية | مخطط |

## شرح الملفات والمجلدات الرئيسية في المشروع

فيما يلي توضيح لوظيفة كل ملف/مجلد مهم موجود في هيكل المشروع الحالي (أو متوقع إضافته):

### الجذر (Root)

- `pubspec.yaml`: ملف تعريف المشروع في Flutter/Dart. يحدد الاسم، الوصف، الإصدارات، وإدارة الحزم (dependencies/dev_dependencies) والأصول (assets) والخطوط (fonts) والتحويلات (flutter). أي إضافة مكتبة خارجية يجب أن تمر عبره.
- `analysis_options.yaml`: إعدادات محلل Dart (Linter) لضمان جودة الشيفرة، مثل القواعد الصارمة حول الأنماط والتحذيرات.
- `devtools_options.yaml`: تهيئة أدوات التطوير (قد يضبط سلوك DevTools للبرمجيات أو التحليل).
- `readme.md`: ملف تعريف مختصر عام للمشروع باللغة العربية حالياً.
- مجلد `.docs/`: يحتوي وثائق تفصيلية مثل هذا الدليل.

### مجلد `lib/`

المكان الذي توجد فيه الشيفرة التنفيذية لتطبيق Flutter.

- `main.dart`: نقطة الدخول (entry point)؛ تنشئ `runApp()` وتحمل الشجرة الجذرية (MaterialApp/CupertinoApp) وإعدادات الترجمة والثيم.
- `core/`: مساحة مشتركة لعناصر أساسية لا تتبع ميزة محددة؛ قد يشمل:
  - `features/`: كل ميزة فرعية داخل مجلد خاص بها (user، food، meal، summary) وتحتها:
    - models: نماذج البيانات (Plain Dart classes / freezed).
    - repository: واجهات ومستودعات لتنفيذ منطق التخزين.
    - controllers / notifiers / blocs: إدارة حالة خاصة بالميزة.
    - widgets: ودجات مخصصة قابلة لإعادة الاستخدام.
  - `services/`: خدمات عامة (مثل `database/` للتهيئة والوصول إلى SQLite، و `localization/` لإدارة الترجمة، و ربما `prefs/` لتخزين تفضيلات المستخدم).
- `data/`: (إذا تم اعتماد طبقات نظيفة) مصادر فعلية (datasources) تتعامل مع SQLite، ملفات JSON، HTTP؛ و `repositories/` التي تربط البيانات بالطبقة الأعلى.
- `domain/`: نماذج نطاق الأعمال (Entities)، واجهات المستودعات، حالات الاستخدام (UseCases) لعزل المنطق.
- `application/`: إدارة الحالة العامة (مثلاً Riverpod providers، Bloc، أو إدارة أحداث).
- `presentation/`: الشاشات والودجات النهائية، تقسم عادةً حسب المجال (screens/ + widgets/ + components/ + theming/).
- `l10n/`: ملفات ARB للترجمة (مثل `app_en.arb`، `app_ar.arb`) ويُولِّد منها Flutter كود دعم (شارح مفاتيح الترجمة).

### مجلد `assets/`

- `foods_seed.json` / `foods_seed_ar.json`: بيانات أولية (Seed) للأطعمة باللغتين، تُستخدم لتهيئة قاعدة البيانات لأول مرة.
- صور أو أيقونات أو خطوط إضافية (إن وُجدت لاحقاً). تُعرّف في `pubspec.yaml` تحت قسم assets.

### مجلدات المنصات (`android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`)

- تحتوي على الشيفرة/الإعدادات الخاصة بكل منصة.
- `android/app/build.gradle.kts`: إعدادات البناء (Gradle Kotlin DSL) وإدراج الحزم الأصلية.
- `android/gradle.properties`: خصائص عامة (مثل تمكين R8، إصدارات JVM).
- `ios/Runner/AppDelegate.swift`: نقطة الدخول لـ iOS وإعدادات الجسر مع Flutter.
- `web/index.html`: الصفحة الرئيسية عند تشغيل التطبيق كويب (Bootstrap لملفات Flutter js/wasm).
- منصات سطح المكتب (linux/macos/windows): شيفرة تهيئة لإطار النافذة والمشروع.

### مجلد `build/`

مخرجات البناء المؤقتة (Generated artifacts)، لا يُعدّل يدوياً. يمكن حذفه وسيُعاد توليده. يشمل ملفات:

- `flutter_assets/`: نسخ الأصول المجمعة للتشغيل.
- مجلدات الحزم (مثل `sqflite_android/`، `shared_preferences_android/`) ناتجة عن دمج Plugins.

## كيفية التوسع المنظم

1. عند إضافة ميزة جديدة (مثلاً: تتبع الماء) أنشئ مجلد `water/` تحت `core/features/` أو اتبع نمط الطبقات النظيفة (domain/data/presentation).
2. ضع نموذج `WaterIntake` في `domain/models/`، ومصدر بيانات في `data/datasources/`، ومستودع في `data/repositories/`، واستخدم حالة في `application/`.
3. أضف شاشة/ودجت لعرض وإدخال البيانات داخل `presentation/screens/`.
4. أضف المفاتيح اللغوية في ملفات ARB لتظهر في الواجهة بالعربية والإنجليزية.

## خريطة ربط سريعة (Flow)

User actions → Presentation Widgets/Screen → State (Riverpod/Bloc) → UseCase (Domain) → Repository → DataSource (SQLite/JSON/API) → رجوع بالنتيجة → تحديث الحالة → إعادة بناء الودجات.

هذا التقسيم يساعد على العزل: أي تغيير في التخزين لا يؤثر على العرض مباشرةً.
