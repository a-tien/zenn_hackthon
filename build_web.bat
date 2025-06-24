@echo off
REM Flutter Web 本地測試腳本 (Windows)

echo 🚀 正在建置 Flutter Web...

REM 清理之前的建置
flutter clean
flutter pub get

REM 建置 web 版本（與 GitHub Pages 相同的配置）
flutter build web --release --web-renderer html --base-href "/zenn_hackthon/"

echo ✅ 建置完成！
echo.
echo 📂 建置檔案位於：build/web/
echo.
echo 🌐 啟動本地伺服器測試（選擇其中一種）：
echo.
echo 1. 使用 Python:
echo    cd build/web ^&^& python -m http.server 8080
echo.
echo 2. 使用 Node.js serve:
echo    npx serve build/web -p 8080
echo.
echo 然後開啟 http://localhost:8080 查看結果

pause
