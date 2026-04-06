#!/bin/bash
# BUILD_NOW.sh - شغّله مباشرة لبناء APK
set -e
PROJ="$(cd "$(dirname "$0")" && pwd)"
RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'; CYN='\033[0;36m'; GRY='\033[0;37m'; NC='\033[0m'

echo -e "${CYN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYN}║   📡 WiFi Manager — AI Build Agent               ║${NC}"
echo -e "${CYN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

step(){ echo -e "  ${YLW}[$1]${NC} $2"; }
ok()  { echo -e "      ${GRN}✓${NC} $1"; }
fail(){ echo -e "      ${RED}✗${NC} $1"; exit 1; }
info(){ echo -e "      ${GRY}→${NC} $1"; }

# 1: Flutter
step "1/5" "التحقق من Flutter"
if ! FLUTTER=$(command -v flutter 2>/dev/null); then
  for p in "$HOME/flutter/bin/flutter" "/opt/flutter/bin/flutter" "$HOME/snap/flutter/common/flutter/bin/flutter"; do
    [ -f "$p" ] && FLUTTER="$p" && break
  done
fi
[ -z "$FLUTTER" ] && fail "Flutter غير موجود!\nثبّته من: https://docs.flutter.dev/get-started/install"
ok "Flutter: $($FLUTTER --version 2>&1 | head -1)"

# 2: Android SDK
step "2/5" "التحقق من Android SDK"
for SDK in "$ANDROID_HOME" "$ANDROID_SDK_ROOT" "$HOME/Android/Sdk" "$HOME/Library/Android/sdk" "/opt/android-sdk"; do
  [ -d "$SDK/platform-tools" ] && { export ANDROID_HOME="$SDK"; ok "Android SDK: $SDK"; break; }
done
[ -z "$ANDROID_HOME" ] && fail "Android SDK غير موجود!\nثبّت Android Studio من: https://developer.android.com/studio"

# 3: pub get
step "3/5" "تثبيت مكتبات Dart"
cd "$PROJ"
info "flutter pub get..."
"$FLUTTER" pub get
ok "تم تثبيت جميع المكتبات"

# 4: بناء APK
step "4/5" "بناء APK (5-10 دقائق)..."
info "flutter build apk --release --split-per-abi"
if ! "$FLUTTER" build apk --release --split-per-abi 2>/dev/null; then
  info "split-per-abi فشل، محاولة universal..."
  "$FLUTTER" build apk --release || fail "فشل البناء"
fi
ok "اكتمل البناء"

# 5: تسليم
step "5/5" "تسليم ملف APK"
mkdir -p "$PROJ/output_apk"
find build/app/outputs/flutter-apk/ -name "*.apk" | while read f; do
  cp "$f" "$PROJ/output_apk/$(basename $f)"
  ok "$(basename $f) — $(du -sh $f | cut -f1)"
done
BEST=$(ls "$PROJ/output_apk/"*arm64*.apk 2>/dev/null | head -1 || ls "$PROJ/output_apk/"*.apk | head -1)
cp "$BEST" "$PROJ/output_apk/WiFiManager.apk"
ok "WiFiManager.apk جاهز في output_apk/"
echo ""
echo -e "  ${GRN}╔═══════════════════════════════════════╗${NC}"
echo -e "  ${GRN}║   ✅ APK جاهز في: output_apk/        ║${NC}"
echo -e "  ${GRN}╚═══════════════════════════════════════╝${NC}"
echo ""
echo -e "  للتثبيت: ${YLW}adb install $PROJ/output_apk/WiFiManager.apk${NC}"
