@echo off
echo 🔍 檢查 GitHub Actions 工作流程語法...
echo.

echo ==========================================
echo 📋 1. 檢查 YAML 檔案是否存在
echo ==========================================
if exist ".github\workflows\deploy.yml" (
    echo ✅ deploy.yml 存在
) else (
    echo ❌ deploy.yml 不存在！
    pause
    exit /b 1
)
echo.

echo ==========================================
echo 📋 2. 顯示工作流程檔案內容
echo ==========================================
echo 📄 .github\workflows\deploy.yml:
echo ----------------------------------------
type .github\workflows\deploy.yml
echo ----------------------------------------
echo.

echo ==========================================
echo 📋 3. 檢查常見語法問題
echo ==========================================
echo 🔍 檢查縮排問題...

findstr /n "^[^ ]" .github\workflows\deploy.yml | findstr -v "^[0-9]*:name:" | findstr -v "^[0-9]*:on:" | findstr -v "^[0-9]*:jobs:" > nul
if %ERRORLEVEL% EQU 0 (
    echo ⚠️  可能存在縮排問題
    echo 檢查以下行是否正確縮排：
    findstr /n "^[^ ]" .github\workflows\deploy.yml | findstr -v "^[0-9]*:name:" | findstr -v "^[0-9]*:on:" | findstr -v "^[0-9]*:jobs:"
) else (
    echo ✅ 未發現明顯的縮排問題
)
echo.

echo 🔍 檢查 on 觸發器...
findstr /c:"on:" .github\workflows\deploy.yml > nul
if %ERRORLEVEL% EQU 0 (
    echo ✅ 找到 on 觸發器
) else (
    echo ❌ 未找到 on 觸發器！
)
echo.

echo ==========================================
echo 📋 4. 提交修復並測試
echo ==========================================
set /p "commit_fix=要提交修復並推送測試嗎？(y/N): "
if /i "%commit_fix%"=="y" (
    git add .github\workflows\deploy.yml
    git commit -m "Fix GitHub Actions workflow YAML syntax"
    git push origin main
    
    echo ✅ 已推送修復！
    echo.
    echo 🔗 請檢查 GitHub Actions 執行狀態：
    echo https://github.com/[你的用戶名]/zenn_hackthon/actions
    echo.
    echo ⏱️  等待 1-2 分鐘後查看結果
)

echo.
pause
