# BUILD_NOW.ps1 - شغّله مباشرة لبناء APK
# الاستخدام: powershell -ExecutionPolicy Bypass -File BUILD_NOW.ps1

$HOST_OS = if ($IsWindows -or $env:OS -eq "Windows_NT") {"win"} elseif ($IsMacOS) {"mac"} else {"linux"}
$FLUTTER_MIN = "3.19.0"
$PROJECT = $PSScriptRoot

function Header {
    Clear-Host
    Write-Host "╔═══════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   📡 WiFi Manager — AI Build Agent               ║" -ForegroundColor Cyan  
    Write-Host "║   يبني APK تلقائياً جاهز للتثبيت               ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Step($n, $msg) {
    Write-Host "  [$n] " -ForegroundColor Yellow -NoNewline
    Write-Host $msg -ForegroundColor White
}
function OK($m)   { Write-Host "      ✓ $m" -ForegroundColor Green }
function FAIL($m) { Write-Host "      ✗ $m" -ForegroundColor Red; Read-Host "اضغط Enter للخروج"; exit 1 }
function INFO($m) { Write-Host "      → $m" -ForegroundColor Gray }

Header

# ── 1: Flutter ──
Step "1/5" "التحقق من Flutter SDK"
$flutter = $null
foreach ($p in @("flutter", "$env:USERPROFILE\flutter\bin\flutter.bat", "C:\flutter\bin\flutter.bat", "$env:LOCALAPPDATA\flutter\bin\flutter.bat")) {
    try { 
        $v = & $p --version 2>&1 | Select-String "Flutter"
        if ($v) { $flutter = $p; OK "Flutter: $v"; break }
    } catch {}
}
if (-not $flutter) {
    Write-Host ""
    Write-Host "  Flutter غير موجود! ثبّته أولاً:" -ForegroundColor Red
    Write-Host "  https://docs.flutter.dev/get-started/install" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  بعد التثبيت، شغّل هذا السكريبت مرة أخرى." -ForegroundColor White
    Read-Host "اضغط Enter للخروج"
    exit 1
}

# ── 2: Android SDK ──
Step "2/5" "التحقق من Android SDK"
$androidHome = $env:ANDROID_HOME ?? $env:ANDROID_SDK_ROOT ?? "$env:LOCALAPPDATA\Android\Sdk"
if (Test-Path "$androidHome\platform-tools\adb.exe") {
    OK "Android SDK: $androidHome"
    $env:ANDROID_HOME = $androidHome
} else {
    FAIL "Android SDK غير موجود في $androidHome`nثبّت Android Studio: https://developer.android.com/studio"
}

# ── 3: pub get ──
Step "3/5" "تثبيت مكتبات Dart"
Set-Location $PROJECT
INFO "flutter pub get..."
& $flutter pub get
if ($LASTEXITCODE -ne 0) { FAIL "فشل flutter pub get" }
OK "تم تثبيت جميع المكتبات"

# ── 4: بناء APK ──
Step "4/5" "بناء APK (5-10 دقائق)"
INFO "flutter build apk --release --split-per-abi"
& $flutter build apk --release --split-per-abi
if ($LASTEXITCODE -ne 0) {
    INFO "split-per-abi فشل، محاولة universal..."
    & $flutter build apk --release
    if ($LASTEXITCODE -ne 0) { FAIL "فشل البناء" }
}
OK "اكتمل البناء"

# ── 5: تسليم APK ──
Step "5/5" "تسليم ملف APK"
$outDir = "$PROJECT\output_apk"
New-Item -Force -ItemType Directory $outDir | Out-Null
$apks = Get-ChildItem "build\app\outputs\flutter-apk\*.apk"
$apks | ForEach-Object {
    Copy-Item $_ "$outDir\$($_.Name)"
    OK "$($_.Name) — $([math]::Round($_.Length/1MB,1)) MB"
}
$best = ($apks | Where-Object {$_.Name -like "*arm64*"} | Select-Object -First 1) ?? ($apks | Select-Object -First 1)
Copy-Item $best "$env:USERPROFILE\Desktop\WiFiManager.apk" -Force
OK "نُسخ للسطح المكتب: WiFiManager.apk"

Write-Host ""
Write-Host "  ╔═══════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║   ✅ APK جاهز على سطح المكتب!       ║" -ForegroundColor Green
Write-Host "  ╚═══════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  للتثبيت عبر USB:" -ForegroundColor White
Write-Host "  adb install `"$env:USERPROFILE\Desktop\WiFiManager.apk`"" -ForegroundColor Yellow
Write-Host ""
explorer $outDir
Read-Host "اضغط Enter للإنهاء"
