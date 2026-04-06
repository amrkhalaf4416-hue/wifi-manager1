#!/bin/bash
set -e

echo "╔══════════════════════════════════════╗"
echo "║     WiFi Manager — Build APK         ║"
echo "╚══════════════════════════════════════╝"

# التحقق من Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter غير مثبت. يرجى تثبيت Flutter SDK أولاً."
    exit 1
fi

echo ""
echo "1️⃣  تنظيف البناء السابق..."
flutter clean

echo ""
echo "2️⃣  تثبيت المتطلبات..."
flutter pub get

echo ""
echo "3️⃣  تشغيل الاختبارات..."
flutter test || echo "⚠️  بعض الاختبارات فشلت — تابع البناء"

echo ""
echo "4️⃣  بناء APK (منفصلة حسب المعالج)..."
flutter build apk --release --split-per-abi

echo ""
echo "✅ تم البناء بنجاح!"
echo ""
echo "📦 ملفات APK:"
find build/app/outputs/flutter-apk/ -name "*.apk" | while read f; do
    SIZE=$(du -sh "$f" | cut -f1)
    echo "   → $f ($SIZE)"
done

echo ""
echo "📲 للتثبيت على الجهاز:"
echo "   adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
