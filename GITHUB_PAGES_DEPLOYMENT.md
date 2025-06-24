# Flutter Web - GitHub Pages 部署指南

本專案已設定自動部署到 GitHub Pages。

## 🚀 自動部署

當你推送程式碼到 `main` 或 `master` 分支時，GitHub Actions 會自動：

1. 設置 Flutter 開發環境
2. 安裝專案依賴
3. 建置 Flutter Web 應用程式
4. 部署到 GitHub Pages

## 📋 部署步驟

### 1. 啟用 GitHub Pages

1. 到你的 GitHub 倉庫設定頁面
2. 點選左側選單的 "Pages"
3. 在 "Source" 選擇 "Deploy from a branch"
4. 選擇 `gh-pages` 分支和 `/ (root)` 資料夾
5. 點選 "Save"

### 2. 推送程式碼

```bash
git add .
git commit -m "Setup GitHub Pages deployment"
git push origin main
```

### 3. 檢查部署狀態

1. 到你的倉庫的 "Actions" 標籤頁
2. 查看最新的工作流程執行狀態
3. 部署成功後，你的網站會在以下網址可用：
   `https://[你的GitHub用戶名].github.io/zenn_hackthon/`

## 🔧 配置說明

### GitHub Actions 工作流程
- 檔案位置：`.github/workflows/deploy.yml`
- 觸發條件：推送到 main/master 分支
- 建置命令：`flutter build web --release --web-renderer html --base-href "/zenn_hackthon/"`

### 重要設定
- **Base href**：`/zenn_hackthon/` - 對應你的倉庫名稱
- **Web renderer**：HTML - 確保在所有瀏覽器中的相容性
- **Release mode**：優化後的產品版本

## 🛠️ 本地測試

在推送前，你可以本地測試 web 版本：

```bash
# 建置 web 版本
flutter build web --release

# 啟動本地伺服器（需要 Python）
cd build/web
python -m http.server 8080

# 或使用 Node.js serve
npx serve . -p 8080
```

然後開啟 `http://localhost:8080` 查看結果。

## 📝 注意事項

1. **API 金鑰安全性**：確保 Google Maps API 金鑰已設定適當的網域限制
2. **CORS 問題**：某些 API 調用在網頁版本中可能會遇到 CORS 限制
3. **檔案大小**：web 版本可能會比較大，第一次載入較慢
4. **瀏覽器相容性**：使用 HTML renderer 確保更好的相容性

## 🔍 故障排除

如果部署失敗：

1. 檢查 Actions 日誌查看錯誤訊息
2. 確認 `pubspec.yaml` 中沒有語法錯誤
3. 確認所有依賴都支援 web 平台
4. 檢查是否有任何平台特定的程式碼需要條件編譯

## 🌐 網站網址

部署成功後，你的 Flutter Web 應用程式將可在以下網址存取：
**https://[你的GitHub用戶名].github.io/zenn_hackthon/**

---

*自動更新於每次推送程式碼時*
