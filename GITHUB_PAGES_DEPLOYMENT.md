# Flutter Web - GitHub Pages 部署指南

本專案已設定自動部署到 GitHub Pages。

## 🚀 自動部署

當你推送程式碼到 `main` 或 `master` 分支時，GitHub Actions 會自動：

1. 設置 Flutter 開發環境
2. 安裝專案依賴
3. 建置 Flutter Web 應用程式
4. 部署到 GitHub Pages

## 📋 部署步驟

### 1. 推送程式碼觸發首次部署

**重要：** `gh-pages` 分支是自動創建的，在第一次成功部署後才會出現。

```bash
git add .
git commit -m "Setup GitHub Pages deployment"
git push origin main
```

### 2. 等待首次部署完成

1. 推送程式碼後，到你的倉庫的 "Actions" 標籤頁
2. 等待 "Deploy Flutter Web to GitHub Pages" 工作流程執行完成
3. 首次部署大約需要 3-5 分鐘
4. **只有在首次部署成功後，`gh-pages` 分支才會自動創建**

### 3. 設定 GitHub Pages（首次部署成功後）

**注意：只有在第一次部署成功後才能進行此步驟**

1. 到你的 GitHub 倉庫設定頁面
2. 點選左側選單的 "Pages"
3. 在 "Source" 選擇 "Deploy from a branch"
4. 選擇 `gh-pages` 分支和 `/ (root)` 資料夾
5. 點選 "Save"

### 4. 檢查部署狀態

1. 到你的倉庫的 "Actions" 標籤頁
2. 查看最新的工作流程執行狀態
3. 部署成功後，你的網站會在以下網址可用：
   `https://[你的GitHub用戶名].github.io/zenn_hackthon/`

## 🔍 故障排除

### 如果沒有看到 gh-pages 分支：

1. **檢查 Actions 執行狀態**：
   - 到倉庫的 "Actions" 標籤頁
   - 確認工作流程是否成功執行
   - 如果失敗，查看錯誤日誌

2. **常見失敗原因**：
   - Flutter 版本不相容
   - 依賴安裝失敗
   - 建置過程中出錯
   - API 金鑰相關問題

3. **手動觸發部署**：
   ```bash
   # 推送一個小改動重新觸發部署
   git commit --allow-empty -m "Trigger deployment"
   git push origin main
   ```

### 如果部署成功但網站無法訪問：

1. 確認 GitHub Pages 設定正確選擇了 `gh-pages` 分支
2. 等待 5-10 分鐘讓 DNS 生效
3. 檢查瀏覽器控制台是否有 API 金鑰相關錯誤

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

## �️ 故障排除

如果部署失敗：

### 常見問題與解決方案：

1. **SDK 版本不相容錯誤**：
   ```
   Because my_app_1 requires SDK version ^3.8.1, version solving failed.
   ```
   **解決方案**：已修正 `pubspec.yaml` 中的 SDK 版本要求為 `'>=3.0.0 <4.0.0'`

2. **gh-pages 分支不存在**：
   - `gh-pages` 分支會在第一次成功部署後自動創建
   - 確保先推送程式碼，然後等待 GitHub Actions 執行完成

3. **其他部署問題**：
   - 檢查 Actions 日誌查看錯誤訊息
   - 確認 `pubspec.yaml` 中沒有語法錯誤
   - 確認所有依賴都支援 web 平台
   - 檢查是否有任何平台特定的程式碼需要條件編譯

## 🌐 網站網址

部署成功後，你的 Flutter Web 應用程式將可在以下網址存取：
**https://[你的GitHub用戶名].github.io/zenn_hackthon/**

---

*自動更新於每次推送程式碼時*
