@echo off
echo 🔧 修復依賴版本問題...
echo.

echo ==========================================
echo 📋 1. 清理舊的依賴
echo ==========================================
flutter clean
echo.

echo ==========================================
echo 📋 2. 重新獲取依賴
echo ==========================================
flutter pub get
echo.

if %ERRORLEVEL% EQU 0 (
    echo ✅ 依賴解析成功！
    echo.
    
    echo ==========================================
    echo 📋 3. 測試 Web 建置
    echo ==========================================
    flutter build web --release --web-renderer html --base-href "/zenn_hackthon/"
    
    if %ERRORLEVEL% EQU 0 (
        echo ✅ Web 建置成功！
        echo.
        
        echo ==========================================
        echo 📋 4. 提交修復並重新部署
        echo ==========================================
        git add .
        git commit -m "Fix flutter_lints version compatibility for GitHub Actions"
        git push origin main
        
        echo.
        echo ✅ 修復完成並已推送！
        echo.
        echo 🔗 請檢查 GitHub Actions：
        echo https://github.com/[你的用戶名]/zenn_hackthon/actions
        
    ) else (
        echo ❌ Web 建置失敗，請檢查錯誤訊息
    )
    
) else (
    echo ❌ 依賴解析失敗
    echo.
    echo 💡 可能的解決方案：
    echo 1. 檢查網路連線
    echo 2. 更新 Flutter SDK: flutter upgrade
    echo 3. 清理 pub cache: flutter pub cache clean
)

echo.
pause
