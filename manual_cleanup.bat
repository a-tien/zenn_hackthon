@echo off
echo 🧹 手動清理重複的 GitHub Actions 工作流程...
echo.

echo ==========================================
echo 📋 當前工作流程檔案：
echo ==========================================
dir .github\workflows\*.yml /b 2>nul
echo.

echo ==========================================
echo 📋 手動清理步驟
echo ==========================================
echo 請手動執行以下步驟清理重複的工作流程：
echo.

echo 1️⃣ 打開檔案總管，瀏覽到：
echo    d:\GitHub\zenn_hackthon\.github\workflows\
echo.

echo 2️⃣ 保留以下檔案：
echo    ✅ deploy.yml
echo.

echo 3️⃣ 刪除以下檔案：
echo    ❌ deploy-simple.yml
echo    ❌ deploy-debug.yml
echo    ❌ test.yml
echo.

echo 4️⃣ 或在 VS Code 中：
echo    - 右鍵點擊不需要的 .yml 檔案
echo    - 選擇 "Delete"
echo.

set /p "manual_done=完成手動清理後按任意鍵繼續..."
echo.

echo ==========================================
echo 📋 檢查清理結果
echo ==========================================
echo 📂 剩餘的工作流程檔案：
dir .github\workflows\*.yml /b 2>nul
echo.

echo ==========================================
echo 📋 提交清理結果
echo ==========================================
echo 📝 執行以下命令提交變更：
echo.
echo git add .
echo git commit -m "Remove duplicate GitHub Actions workflows"
echo git push origin main
echo.

set /p "auto_commit=要自動執行提交嗎？(y/N): "
if /i "%auto_commit%"=="y" (
    git add .
    git commit -m "Remove duplicate GitHub Actions workflows - keep only deploy.yml"
    git push origin main
    
    echo ✅ 已自動提交！
    echo.
    echo 🔗 檢查 GitHub Actions（現在應該只有一個工作流程）：
    echo https://github.com/[你的用戶名]/zenn_hackthon/actions
)

echo.
echo ✅ 清理完成！下次推送應該只會執行一個部署動作。
pause
