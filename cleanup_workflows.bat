@echo off
echo 🧹 清理多餘的 GitHub Actions 工作流程檔案...
echo.

echo ==========================================
echo 📋 目前存在的工作流程檔案：
echo ==========================================
dir .github\workflows\*.yml /b
echo.

echo ==========================================
echo 📋 分析各檔案用途：
echo ==========================================
echo 📄 deploy.yml - 主要部署檔案（完整版）
echo 📄 deploy-simple.yml - 簡化版部署檔案
echo 📄 deploy-debug.yml - 除錯版本
echo 📄 test.yml - 測試檔案
echo.

echo ==========================================
echo 📋 建議保留最佳的單一工作流程
echo ==========================================
echo 💡 我們將：
echo ✅ 保留 deploy.yml（最完整的版本）
echo ❌ 刪除 deploy-simple.yml
echo ❌ 刪除 deploy-debug.yml  
echo ❌ 刪除 test.yml
echo.

set /p "confirm=確認要清理多餘檔案嗎？(y/N): "
if /i not "%confirm%"=="y" (
    echo 已取消清理
    pause
    exit /b 0
)

echo.
echo 🗑️ 正在刪除多餘檔案...

if exist ".github\workflows\deploy-simple.yml" (
    del .github\workflows\deploy-simple.yml
    echo ✅ 已刪除 deploy-simple.yml
)

if exist ".github\workflows\deploy-debug.yml" (
    del .github\workflows\deploy-debug.yml
    echo ✅ 已刪除 deploy-debug.yml
)

if exist ".github\workflows\test.yml" (
    del .github\workflows\test.yml
    echo ✅ 已刪除 test.yml
)

echo.
echo ==========================================
echo 📋 檢查剩餘檔案：
echo ==========================================
dir .github\workflows\*.yml /b
echo.

echo ==========================================
echo 📋 顯示保留的工作流程內容：
echo ==========================================
if exist ".github\workflows\deploy.yml" (
    echo 📄 deploy.yml 內容：
    echo ----------------------------------------
    type .github\workflows\deploy.yml
    echo ----------------------------------------
) else (
    echo ❌ 主要部署檔案不存在！
)
echo.

echo ==========================================
echo 📋 提交清理結果
echo ==========================================
set /p "commit_clean=要提交清理結果嗎？(y/N): "
if /i "%commit_clean%"=="y" (
    git add .github\workflows\
    git commit -m "Clean up duplicate GitHub Actions workflows - keep only deploy.yml"
    git push origin main
    
    echo ✅ 已提交清理結果！
    echo.
    echo 🔗 檢查 GitHub Actions（現在應該只有一個工作流程）：
    echo https://github.com/[你的用戶名]/zenn_hackthon/actions
    echo.
    echo 💡 下次推送應該只會觸發一個部署動作
) else (
    echo ℹ️  清理完成但未提交。請手動執行：
    echo git add .github\workflows\
    echo git commit -m "Clean up duplicate workflows"
    echo git push origin main
)

echo.
pause
