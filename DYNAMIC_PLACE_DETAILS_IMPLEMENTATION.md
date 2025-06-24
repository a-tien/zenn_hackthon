# 景點詳細資訊動態載入實現報告

## 修改目的
- 景點詳細資訊（地址、電話、營業時間、評論、簡介等）不儲存在資料庫中
- 在顯示詳細頁面時，透過 Places API 即時獲取完整資訊
- 使用您的 API Key：`AIzaSyBHEcitEBtZ7ezjlRCRgS-Hk1fm2SSY4is`

## 實現方案

### 1. 新增 DetailedFavoriteSpot 模型
**檔案**: `lib/feature/collection/models/detailed_favorite_spot.dart`

繼承自 `FavoriteSpot`，額外包含：
- `description` (景點簡介)
- `openingHours` (營業時間)  
- `website` (網站)
- `phone` (電話)
- `reviewCount` (評論數量)

### 2. 擴展 PlacesApiService
**檔案**: `lib/feature/discover/services/places_api_service.dart`

新增方法：
```dart
static Future<DetailedFavoriteSpot?> getDetailedPlaceInfo(String placeId)
```

#### API 呼叫格式：
```
GET https://places.googleapis.com/v1/places/{PLACE_ID}
Headers:
- X-Goog-Api-Key: AIzaSyBHEcitEBtZ7ezjlRCRgS-Hk1fm2SSY4is
- X-Goog-FieldMask: id,displayName,formattedAddress,location,rating,userRatingCount,types,photos,websiteUri,internationalPhoneNumber,regularOpeningHours,editorialSummary
```

#### 解析的欄位：
- `displayName.text` → name
- `formattedAddress` → address  
- `rating` → rating
- `userRatingCount` → reviewCount
- `editorialSummary.text` → description
- `regularOpeningHours.weekdayDescriptions` → openingHours
- `websiteUri` → website
- `internationalPhoneNumber` → phone
- `photos[0]` → imageUrl
- `types[0]` → category

### 3. 修改 SpotDetailPage
**檔案**: `lib/feature/collection/pages/spot_detail_page.dart`

#### 新增狀態管理：
```dart
DetailedFavoriteSpot? detailedSpot;
bool isLoadingDetails = true;
String? errorMessage;
```

#### 載入流程：
1. `initState()` 呼叫 `_loadSpotDetails()`
2. 使用 `PlacesApiService.getDetailedPlaceInfo(widget.spot.id)` 獲取詳細資訊
3. 根據載入狀態顯示不同 UI

#### UI 顯示邏輯：
- **載入中**: 顯示 `CircularProgressIndicator`
- **載入失敗**: 顯示錯誤訊息，回退到基本資訊
- **載入成功**: 顯示完整詳細資訊

### 4. 顯示的詳細資訊
當成功載入時，頁面會顯示：
- ✅ **景點介紹** (description)
- ✅ **營業時間** (openingHours)  
- ✅ **電話** (phone)
- ✅ **網站** (website)
- ✅ **評論數量** (reviewCount)
- ✅ **地址** (address，基本資訊)

### 5. 優化收藏卡片顯示
**檔案**: `lib/feature/collection/components/favorite_spot_card.dart`
- 移除分類顯示
- 改為顯示地址（更實用的資訊）

## 資料流程

### 儲存流程（不變）：
```
Places API → 基本資訊 → 儲存至 Firestore
```

### 詳細頁面顯示流程：
```
點擊景點 → SpotDetailPage → 
使用 placeId 呼叫 Places API → 
獲取完整詳細資訊 → 
即時顯示（不儲存）
```

## 好處
1. **儲存效率**: 資料庫僅儲存必要的基本資訊
2. **資訊即時性**: 詳細資訊總是最新的
3. **功能豐富**: 使用者可看到完整的景點資訊
4. **API 利用**: 充分利用 Google Places API 的詳細資料

## 錯誤處理
- 網路錯誤：顯示錯誤訊息，回退顯示基本資訊
- API 限制：有完善的錯誤處理和使用者提示
- 載入狀態：清楚的載入指示器

現在當您點擊任何景點的「詳細介紹」時，頁面會：
1. 顯示載入指示器
2. 呼叫 Places API 獲取完整資訊
3. 顯示包含簡介、營業時間、電話、網站等詳細資訊的完整頁面
