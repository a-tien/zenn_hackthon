@echo off
echo 🔧 修復並重新部署到 GitHub Pages...
echo.

echo ==========================================
echo 📋 1. 運行診斷檢查
echo ==========================================
call diagnose_deployment.bat
echo.

echo ==========================================
echo 📋 2. 確認工作流程檔案修復
echo ==========================================
echo ✅ 已修復 deploy.yml 的語法錯誤
echo ✅ 已更新部署動作版本
echo ✅ 已加入除錯資訊
echo.

echo ==========================================
echo 📋 3. 提交修復並推送
echo ==========================================
git add .
git status
echo.

echo 📝 提交修復...
git commit -m "Fix GitHub Actions workflow syntax and improve deployment"
echo.

echo 📤 推送到遠端...
git push origin main
echo.

echo ==========================================
echo ✅ 部署修復完成！
echo ==========================================
echo.
echo 🔗 請立即檢查以下連結：
echo 1. Actions 執行狀態：
echo    https://github.com/[你的用戶名]/zenn_hackthon/actions
echo.
echo 2. 等待 3-5 分鐘後檢查分支：
echo    https://github.com/[你的用戶名]/zenn_hackthon/branches
echo.
echo 3. 部署成功後，網站將在此網址：
echo    https://[你的用戶名].github.io/zenn_hackthon/
echo.
echo 💡 關鍵修復：
echo - 修正了工作流程 YAML 語法錯誤
echo - 更新了 peaceiris/actions-gh-pages 到 v4
echo - 加入了 force_orphan: true 確保分支創建
echo - 加入了除錯輸出來診斷問題
echo.

pause
