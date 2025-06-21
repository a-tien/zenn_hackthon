@echo off
echo 正在檢查 Flutter 狀態...
flutter doctor

echo.
echo 正在清理專案...
flutter clean

echo.
echo 正在獲取依賴...
flutter pub get

echo.
echo 正在分析程式碼...
flutter analyze

echo.
echo 正在檢查可用設備...
flutter devices

echo.
echo 準備啟動應用程式...
echo 請在瀏覽器中查看應用程式
flutter run -d chrome

pause
