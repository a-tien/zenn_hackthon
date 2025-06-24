#!/bin/bash

echo "🚀 快速更新並部署到 GitHub Pages..."
echo

echo "=========================================="
echo "📋 1. 檢查當前狀態"
echo "=========================================="
echo "🌳 當前分支："
git branch --show-current
echo
echo "📝 檢查是否有未提交的變更："
git status --porcelain
echo

echo "=========================================="
echo "📋 2. 建置並測試本地版本（可選）"
echo "=========================================="
read -p "要先在本地測試建置嗎？(y/N): " build_local
if [[ $build_local =~ ^[Yy]$ ]]; then
    echo "🔨 正在建置本地版本..."
    flutter clean
    flutter pub get
    flutter build web --release --web-renderer html --base-href "/zenn_hackthon/"
    
    if [ $? -eq 0 ]; then
        echo "✅ 本地建置成功！"
    else
        echo "❌ 本地建置失敗，請檢查錯誤後再繼續"
        exit 1
    fi
    echo
fi

echo "=========================================="
echo "📋 3. 提交變更並推送"
echo "=========================================="
read -p "輸入提交訊息（預設：Update application）: " commit_msg
commit_msg=${commit_msg:-"Update application"}

echo
echo "📤 正在提交變更..."
git add .
git commit -m "$commit_msg"

if [ $? -eq 0 ]; then
    echo "✅ 提交成功！"
    echo
    echo "📤 正在推送到 GitHub..."
    git push origin main
    
    if [ $? -eq 0 ]; then
        echo "✅ 推送成功！"
        echo
        echo "=========================================="
        echo "🎉 部署已觸發！"
        echo "=========================================="
        echo
        echo "🔗 監控部署進度："
        echo "https://github.com/[你的用戶名]/zenn_hackthon/actions"
        echo
        echo "⏱️  部署通常需要 3-5 分鐘完成"
        echo
        echo "🌐 部署完成後，網站將在此更新："
        echo "https://[你的用戶名].github.io/zenn_hackthon/"
        echo
        echo "💡 小提示："
        echo "- 可能需要清除瀏覽器快取才能看到最新變更"
        echo "- 按 Cmd+Shift+R (Mac) 或 Ctrl+F5 (Linux) 強制重新載入"
        
    else
        echo "❌ 推送失敗，請檢查網路連線或權限"
    fi
    
else
    echo "ℹ️  沒有新的變更需要提交，或提交失敗"
    echo
    read -p "🔄 要強制推送現有內容來重新觸發部署嗎？(y/N): " force_deploy
    if [[ $force_deploy =~ ^[Yy]$ ]]; then
        git commit --allow-empty -m "Trigger GitHub Pages redeploy"
        git push origin main
        echo "✅ 已觸發重新部署！"
    fi
fi

echo
