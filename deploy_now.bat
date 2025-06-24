@echo off
echo 🚀 超快速部署...
git add .
git commit -m "Quick update - %date% %time%"
git push origin main
echo ✅ 已推送！請到 GitHub Actions 查看部署進度
echo 🔗 https://github.com/[你的用戶名]/zenn_hackthon/actions
pause
