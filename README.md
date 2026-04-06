# 📡 WiFi Manager — Huawei HG531 V1

تطبيق Flutter لإدارة راوتر Huawei HG531 V1 مباشرة من هاتف Android.

## ✨ الميزات

| الميزة | الوصف |
|--------|-------|
| 📋 عرض الأجهزة | قائمة بكل الأجهزة المتصلة مع IP ،MAC، الشركة المصنعة |
| 🚫 الحظر | حظر/إلغاء حظر أي جهاز عبر MAC Filter |
| ⚡ السرعة | تحديد سرعة التنزيل والرفع لكل جهاز |
| 🏷️ التسمية | تغيير اسم أي جهاز |
| 🔍 البحث | بحث سريع بالاسم أو MAC أو IP |
| 🌙 الثيم | وضع داكن وفاتح |
| 🌐 اللغة | عربي/إنجليزي مع دعم RTL |
| 📱 WebView | إعداد يدوي عبر صفحة الراوتر |

## 🏗️ المعمارية

```
lib/
├── core/
│   ├── constants/     # الثوابت (IPs، Endpoints)
│   ├── di/            # Dependency Injection (GetIt)
│   ├── network/       # DioClient (Cookie، Retry، IP Validation)
│   ├── theme/         # Light/Dark themes
│   └── utils/         # Extensions
├── data/
│   ├── datasources/
│   │   ├── local/     # SharedPreferences + Hive
│   │   └── remote/    # Router HTTP API
│   ├── models/        # DeviceModel، RouterSettingsModel
│   └── repositories/  # تنفيذ الـ repositories
├── domain/
│   ├── entities/      # DeviceEntity (business logic)
│   └── repositories/  # Abstract interfaces
└── presentation/
    ├── blocs/         # BLoC/Cubit state management
    ├── pages/         # Screens
    └── widgets/       # Reusable components
```

## 🚀 التشغيل

### المتطلبات
- Flutter SDK >= 3.0.0
- Android SDK (minSdk 21)
- Java JDK 11+

### خطوات البناء

```bash
# 1. تثبيت المتطلبات
flutter pub get

# 2. تشغيل الاختبارات
flutter test

# 3. بناء APK
flutter build apk --release --split-per-abi

# APK في: build/app/outputs/flutter-apk/
```

### بناء APK واحد (universal)
```bash
flutter build apk --release
```

## 🔌 نقاط الراوتر

| الغرض | Endpoint |
|-------|----------|
| تسجيل الدخول | `POST /login.cgi` |
| قائمة الأجهزة | `GET /wlstationlist.cmd` |
| MAC Filter | `POST /wlmacflt.cmd` |
| تحديد السرعة | `POST /qos.cgi` |
| بديل السرعة | `POST /bandwidthctrl.cgi` |
| معلومات الراوتر | `GET /routerinfo.cmd` |

## 🔒 الأمان

- IP Validation: يرفض أي IP خارج الشبكة المحلية
- No External Requests: التطبيق يتواصل مع الراوتر فقط
- Session Management: انتهاء الجلسة بعد 30 دقيقة
- Retry Logic: إعادة المحاولة تلقائياً عند فشل الاتصال

## 🧪 الاختبارات

```bash
# جميع الاختبارات
flutter test

# اختبارات محددة
flutter test test/unit/extensions_test.dart
flutter test test/unit/devices_cubit_test.dart
flutter test test/unit/router_settings_test.dart
flutter test test/unit/device_entity_test.dart
flutter test test/integration/router_login_test.dart
```

## 📱 الأذونات المطلوبة

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
```

## 🐛 استكشاف الأخطاء

| المشكلة | الحل |
|---------|------|
| الراوتر لا يستجيب | تأكد من الاتصال بنفس الشبكة |
| فشل تسجيل الدخول | تحقق من كلمة المرور (افتراضي: admin) |
| IP خاطئ | افتح إعدادات → راوتر وعدّل IP |
| أجهزة لا تظهر | استخدم زر التحديث أو افتح صفحة الراوتر يدوياً |
