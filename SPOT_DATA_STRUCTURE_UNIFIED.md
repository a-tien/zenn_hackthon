# 景點資料結構統一修正報告

## 修正目的
1. 將行程存儲景點與收藏清單所儲存的資訊內容一致(保留顯示清單所需的必要資訊含照片url即可)
2. 確保儲存的資訊內容可以成功載入景點詳細資訊(必須包含placeID能呼叫回傳places detail api)

## 修正內容

### 1. FavoriteSpot 模型精簡
**檔案**: `lib/feature/collection/models/favorite_spot.dart`

**修正前**: 包含大量詳細資訊
- `id`, `name`, `imageUrl`, `address`, `rating`, `reviewCount`, `description`, `category`, `openingHours`, `website`, `phone`, `latitude`, `longitude`, `addedAt`

**修正後**: 僅保留必要資訊
- `id` (placeId，用於呼叫 Places API)
- `name`
- `imageUrl`
- `address`
- `rating`
- `category`
- `latitude`
- `longitude`
- `addedAt`

### 2. Spot 模型統一
**檔案**: `lib/feature/itinerary/models/spot.dart`

**已有欄位**: 
- `id` (placeId，用於呼叫 Places API)
- `name`, `imageUrl`, `address?`, `rating?`, `category?`, `latitude`, `longitude`
- 行程專用欄位：`order`, `stayHours`, `stayMinutes`, `startTime`, `nextTransportation`, `travelTimeMinutes`

### 3. 景點詳細資訊載入統一
**檔案**: `lib/feature/collection/services/favorite_service.dart`

**修正前**: `getFullSpotDetails()` 從 Firestore 收藏中搜尋景點資料
**修正後**: 直接呼叫 Places API 獲取最新詳細資訊

```dart
static Future<FavoriteSpot?> getFullSpotDetails(String placeId) async {
  try {
    // 直接使用 Places API 獲取景點詳細資訊
    return await PlacesApiService.getPlaceDetails(placeId);
  } catch (e) {
    print('獲取景點詳細資料時發生錯誤: $e');
    return null;
  }
}
```

### 4. PlacesApiService 修正
**檔案**: `lib/feature/discover/services/places_api_service.dart`

**修正**: `_parsePlaceToFavoriteSpot()` 方法配合新的 FavoriteSpot 結構，移除不存在的參數

### 5. UI 顯示修正

#### favorite_page.dart
- 移除 `reviewCount` 顯示

#### spot_detail_page.dart  
- 移除 `reviewCount`, `openingHours`, `website`, `phone`, `description` 的顯示
- 改為顯示 `category` 分類資訊

#### discover_page.dart
- 地圖標記信息移除 `reviewCount`
- 景點卡片描述改為顯示 `category`

## 資料流程
1. **行程景點點擊** → `_handleSpotTap(spot)` → `FavoriteService.getFullSpotDetails(spot.id)` → `PlacesApiService.getPlaceDetails(placeId)` → 獲取最新詳細資訊 → 顯示 `SpotDetailPage`

2. **收藏景點點擊** → 直接使用儲存的基本資訊 → 顯示 `SpotDetailPage`

3. **新增收藏** → 從 Places API 獲取基本資訊 → 儲存至 Firestore

## 好處
1. **資料一致性**: 行程和收藏景點使用相同的核心欄位結構
2. **即時性**: 景點詳細資訊總是從 Places API 獲取最新資料
3. **儲存效率**: 僅儲存顯示清單必要的資訊，詳細資訊即時獲取
4. **功能可靠**: 確保所有景點都能正確載入詳細資訊（只要有有效的 placeId）

## 驗證
- [x] FavoriteSpot 和 Spot 結構相容
- [x] 景點詳細資訊載入機制統一
- [x] UI 正確顯示新的資料結構
- [x] 編譯無錯誤
- [x] 功能測試通過
