# 📦 GitHub Pages 快速部署指南

## 🚀 快速更新流程

當你修改了程式碼並想要更新 GitHub Pages 網站時：

### 方法 1：使用快速部署腳本（推薦）

**Windows:**
```bash
.\quick_deploy.bat
```

**macOS/Linux:**
```bash
chmod +x quick_deploy.sh
./quick_deploy.sh
```

### 方法 2：手動命令

```bash
# 1. 添加所有變更
git add .

# 2. 提交變更
git commit -m "描述你的變更"

# 3. 推送到 GitHub
git push origin main
```

## ⏱️ 部署時間線

1. **推送程式碼** → 立即觸發 GitHub Actions
2. **建置階段** → 2-3 分鐘（下載依賴、建置 Flutter Web）
3. **部署階段** → 30-60 秒（上傳到 gh-pages 分支）
4. **網站更新** → 1-2 分鐘（GitHub Pages 更新）

**總時間：約 3-5 分鐘**

## 🔗 重要連結

### 監控部署進度
```
https://github.com/[你的用戶名]/zenn_hackthon/actions
```

### 查看網站
```
https://[你的用戶名].github.io/zenn_hackthon/
```

### GitHub Pages 設定
```
https://github.com/[你的用戶名]/zenn_hackthon/settings/pages
```

## 💡 實用小技巧

### 🔍 檢查部署狀態
- ✅ **綠色勾勾**：部署成功
- ❌ **紅色叉叉**：部署失敗，點擊查看錯誤日誌
- 🟡 **黃色圓圈**：正在進行中

### 🗂️ 快取問題
如果看不到最新變更：
- **Chrome/Edge**: `Ctrl + F5`
- **Firefox**: `Ctrl + Shift + R`
- **Safari**: `Cmd + Shift + R`

### 🔄 強制重新部署
如果沒有檔案變更但想重新部署：
```bash
git commit --allow-empty -m "Trigger redeploy"
git push origin main
```

## 📋 故障排除

### 常見問題

1. **Actions 沒有執行**
   - 檢查 GitHub Actions 是否已啟用
   - 確認推送到正確分支（main 或 master）

2. **建置失敗**
   - 檢查 `flutter pub get` 是否成功
   - 查看 Actions 日誌中的錯誤訊息

3. **網站無法訪問**
   - 確認 GitHub Pages 設定指向 `gh-pages` 分支
   - 檢查倉庫是否為公開

4. **地圖不顯示**
   - 檢查 Google Maps API 金鑰的網域限制
   - 確認已加入你的 GitHub Pages 網域

## 🛠️ 本地測試

在部署前本地測試：
```bash
# Windows
.\build_web.bat

# macOS/Linux
./build_web.sh
```

然後啟動本地伺服器：
```bash
cd build/web
python -m http.server 8080
# 或
npx serve . -p 8080
```

開啟 `http://localhost:8080` 查看結果。

---

**記住：每次推送到 main 分支，網站就會自動更新！** 🎉
