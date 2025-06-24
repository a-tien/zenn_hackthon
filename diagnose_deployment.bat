@echo off
echo 🔍 診斷 GitHub Pages 部署問題...
echo.

echo ==========================================
echo 📋 1. 檢查工作流程檔案是否存在
echo ==========================================
if exist ".github\workflows\deploy.yml" (
    echo ✅ deploy.yml 存在
    echo 📄 檔案內容：
    type .github\workflows\deploy.yml
) else (
    echo ❌ deploy.yml 不存在！
)
echo.

echo ==========================================
echo 📋 2. 檢查 Git 狀態
echo ==========================================
echo 🌳 當前分支：
git branch --show-current
echo.
echo 📝 最新提交：
git log --oneline -3
echo.
echo 📤 遠端分支：
git branch -r
echo.

echo ==========================================
echo 📋 3. 檢查 pubspec.yaml 依賴版本
echo ==========================================
echo 🔧 SDK 版本設定：
findstr "sdk:" pubspec.yaml
echo.
echo 🔧 flutter_lints 版本：
findstr "flutter_lints:" pubspec.yaml
echo.
echo 🚀 測試依賴解析：
flutter pub deps --no-dev
echo.

echo ==========================================
echo 📋 4. 測試 Flutter Web 建置
echo ==========================================
echo 🚀 嘗試建置 Flutter Web...
flutter clean
flutter pub get
flutter build web --release --web-renderer html --base-href "/zenn_hackthon/"

if %ERRORLEVEL% EQU 0 (
    echo ✅ Flutter Web 建置成功
    echo 📂 檢查建置輸出：
    if exist "build\web\index.html" (
        echo ✅ index.html 存在
    ) else (
        echo ❌ index.html 不存在
    )
    if exist "build\web\main.dart.js" (
        echo ✅ main.dart.js 存在
    ) else (
        echo ❌ main.dart.js 不存在
    )
) else (
    echo ❌ Flutter Web 建置失敗
)
echo.

echo ==========================================
echo 📋 5. 檢查重要檔案
echo ==========================================
echo 🔍 檢查關鍵檔案是否存在：
if exist "web\index.html" (
    echo ✅ web\index.html 存在
) else (
    echo ❌ web\index.html 不存在
)

if exist "pubspec.yaml" (
    echo ✅ pubspec.yaml 存在
) else (
    echo ❌ pubspec.yaml 不存在
)

if exist "lib\main.dart" (
    echo ✅ lib\main.dart 存在
) else (
    echo ❌ lib\main.dart 不存在
)
echo.

echo ==========================================
echo 📋 診斷完成
echo ==========================================
echo 💡 如果所有檢查都通過，問題可能是：
echo 1. GitHub Actions 權限設定
echo 2. GitHub Pages 設定未正確配置
echo 3. 工作流程執行失敗但沒有顯示錯誤
echo.
echo 🔗 請檢查 GitHub Actions 日誌：
echo https://github.com/[你的用戶名]/zenn_hackthon/actions
echo.

pause
