# 景點加入行程時 address 和 category 欄位修正報告

## 問題描述
在將景點加入行程時，`Spot` 物件的 `address` 和 `category` 欄位為空值，但這些資料在原始 `FavoriteSpot` 或 `RecommendedSpot` 中是有的，應該一起寫入。

## 修正內容

### 1. ItineraryService.addSpotToItinerary()
**檔案**: `lib/feature/itinerary/services/itinerary_service.dart`

**修正前**:
```dart
final newSpot = Spot(
  id: favoriteSpot.id,
  name: favoriteSpot.name,
  imageUrl: favoriteSpot.imageUrl,
  order: targetDay.spots.length + 1,
  // ... 其他欄位，但缺少 address, rating, category
);
```

**修正後**:
```dart
final newSpot = Spot(
  id: favoriteSpot.id,
  name: favoriteSpot.name,
  imageUrl: favoriteSpot.imageUrl,
  address: favoriteSpot.address,     // ✅ 加入地址
  rating: favoriteSpot.rating,       // ✅ 加入評分
  category: favoriteSpot.category,   // ✅ 加入分類
  order: targetDay.spots.length + 1,
  // ... 其他欄位
);
```

### 2. ItineraryServiceFirebase.addSpotToItinerary()
**檔案**: `lib/feature/itinerary/services/itinerary_service_firebase.dart`

**修正**: 同樣新增 `address`、`rating`、`category` 欄位的對應

### 3. AddToDayDialog (RecommendedSpot 轉 Spot)
**檔案**: `lib/feature/itinerary/components/add_to_day_dialog.dart`

**修正前**:
```dart
final newSpot = Spot(
  id: widget.spot.id,
  name: widget.spot.name,
  imageUrl: widget.spot.imageUrl,
  // ... 缺少地址、評分、分類資訊
);
```

**修正後**:
```dart
final newSpot = Spot(
  id: widget.spot.id,
  name: widget.spot.name,
  imageUrl: widget.spot.imageUrl,
  address: widget.spot.district,      // ✅ 使用 district 作為 address
  rating: widget.spot.rating,         // ✅ 加入評分
  category: '推薦景點',                 // ✅ 設定固定分類
  // ... 其他欄位
);
```

## 資料對應關係

### FavoriteSpot → Spot
- `favoriteSpot.address` → `spot.address`
- `favoriteSpot.rating` → `spot.rating`
- `favoriteSpot.category` → `spot.category`

### RecommendedSpot → Spot
- `recommendedSpot.district` → `spot.address` (區域作為地址)
- `recommendedSpot.rating` → `spot.rating`
- `'推薦景點'` → `spot.category` (固定分類)

## 影響的功能

### 1. 從收藏清單加入行程
- 使用 `AddToItineraryDialog`
- 呼叫 `ItineraryService.addSpotToItineraryWithRoutes()`
- 現在會正確儲存地址、評分、分類資訊

### 2. 從推薦景點加入行程
- 使用 `AddToDayDialog`
- 現在會將區域作為地址，評分和固定分類一起儲存

### 3. 行程中的景點顯示
- 景點詳細頁面現在可以正確顯示地址資訊
- 景點卡片可以顯示評分和分類資訊

## 驗證方式

1. **從收藏加入行程**:
   ```
   收藏景點 → 詳細介紹 → 加入行程 → 選擇行程和天數 → 確認
   ```
   檢查行程中的景點是否包含完整的地址、評分、分類資訊

2. **從推薦加入行程**:
   ```
   推薦景點頁面 → 選擇景點 → 加入行程 → 選擇天數和位置 → 確認
   ```
   檢查行程中的景點是否包含區域(作為地址)、評分、分類資訊

3. **資料庫驗證**:
   檢查 Firestore 中 `itineraries` 集合的景點資料是否包含 `address`、`rating`、`category` 欄位

## 好處

1. **資料完整性**: 行程中的景點現在包含完整的基本資訊
2. **UI 一致性**: 不論從哪個來源加入的景點，都有相同的資料結構
3. **功能支援**: 支援未來可能需要使用地址、評分、分類的功能
4. **用戶體驗**: 在行程詳細頁面可以看到更完整的景點資訊

現在當您將景點加入行程時，`address`、`rating` 和 `category` 欄位都會正確填入，不再是空值！
