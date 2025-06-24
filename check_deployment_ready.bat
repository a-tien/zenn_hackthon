@echo off
echo 🔧 檢查 Flutter 環境和專案狀態...
echo.

echo 📋 1. 檢查 Flutter 版本:
flutter --version
echo.

echo 📋 2. 清理專案:
flutter clean
echo.

echo 📋 3. 獲取依賴:
flutter pub get
echo.

echo 📋 4. 分析程式碼:
flutter analyze
echo.

echo 📋 5. 測試 Web 建置:
flutter build web --release --web-renderer html --base-href "/zenn_hackthon/"
echo.

if %ERRORLEVEL% EQU 0 (
    echo ✅ 所有檢查通過！專案準備好部署到 GitHub Pages
    echo.
    echo 🚀 下一步：
    echo 1. git add .
    echo 2. git commit -m "Fix SDK version compatibility for GitHub Pages"
    echo 3. git push origin main
    echo 4. 到 GitHub 倉庫查看 Actions 執行狀態
) else (
    echo ❌ 發現問題，請檢查上方的錯誤訊息
)

pause
