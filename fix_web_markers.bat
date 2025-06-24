@echo off
echo 🔧 修復 Flutter Web 圖片顯示問題...
echo.

echo ==========================================
echo 📋 問題分析
echo ==========================================
echo ❌ 問題：SVG 圖片在 Flutter Web 的 BitmapDescriptor 中不被支援
echo ✅ 解決方案：使用不同顏色的預設 Google Maps 標記
echo.

echo ==========================================
echo 📋 1. 清理並重新建置
echo ==========================================
flutter clean
flutter pub get
echo.

echo ==========================================
echo 📋 2. 測試本地 Web 建置
echo ==========================================
flutter build web --release --web-renderer html --base-href "/zenn_hackthon/"

if %ERRORLEVEL% EQU 0 (
    echo ✅ 本地建置成功！
    echo.
    
    echo ==========================================
    echo 📋 3. 提交修復並重新部署
    echo ==========================================
    git add .
    git commit -m "Fix SVG marker icons for Flutter Web - use colored default markers"
    git push origin main
    
    echo.
    echo ✅ 修復已推送到 GitHub！
    echo.
    echo 🎯 修復說明：
    echo - 移除了 SVG 圖標載入（Web 不支援）
    echo - 使用不同顏色的 Google Maps 預設標記
    echo - 每種景點類型有不同顏色：
    echo   • 景點/觀光: 紅色
    echo   • 美食/餐廳: 橙色
    echo   • 購物: 藍色
    echo   • 住宿: 綠色
    echo   • 交通: 青色
    echo   • 醫療: 紫紅色
    echo   • 教育: 黃色
    echo   • 服務: 紫色
    echo   • 娛樂: 玫瑰色
    echo   • 汽車: 天藍色
    echo.
    echo 🔗 等待 2-3 分鐘後檢查網站：
    echo https://a-tien.github.io/zenn_hackthon/
    
) else (
    echo ❌ 本地建置失敗，請檢查錯誤訊息
)

echo.
pause
