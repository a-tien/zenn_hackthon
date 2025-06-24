@echo off
echo 🚀 強制觸發 GitHub Actions 部署...
echo.

echo 📝 創建空提交以觸發 Actions...
git add .
git commit -m "Trigger GitHub Actions deployment" --allow-empty
echo.

echo 📤 推送到遠端倉庫...
git push origin main
echo.

echo ✅ 推送完成！
echo.
echo 🔗 請到以下位置檢查 Actions 執行狀態：
echo https://github.com/[你的用戶名]/zenn_hackthon/actions
echo.
echo 💡 如果還是沒有執行，請檢查：
echo 1. GitHub 倉庫的 Settings → Actions → General
echo 2. 確認 Actions permissions 已啟用
echo 3. 檢查分支名稱是否為 'main' 或 'master'

pause
