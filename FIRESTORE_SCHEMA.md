/**
 * Firebase Cloud Firestore 資料結構設計
 * 
 * Collection: users/{userId}
 * - 儲存用戶基本資料
 * 
 * Collection: users/{userId}/itineraries/{itineraryId}
 * - 儲存用戶的行程資料
 *  * Collection: users/{userId}/favorites/{favoriteId}
 * - 儲存用戶的收藏景點
 * 
 * Collection: users/{userId}/collections/{collectionId}
 * - 儲存用戶的收藏集合
 * 
 * Collection: users/{userId}/companions/{companionId}
 * - 儲存用戶的旅伴資料
 */

// users/{userId} - 用戶基本資料
{
  "id": "string",           // 用戶ID (Firebase UID)
  "name": "string",         // 用戶名稱
  "email": "string",        // 電子郵件
  "travelType": "string",   // 偏好旅遊類型
  "itineraryCount": "number", // 行程數量
  "isLoggedIn": "boolean",  // 登入狀態
  "createdAt": "timestamp", // 建立時間
  "updatedAt": "timestamp"  // 更新時間
}

// users/{userId}/itineraries/{itineraryId} - 行程資料
{
  "id": "string",                    // 行程ID
  "name": "string",                  // 行程名稱
  "useDateRange": "boolean",         // 是否使用日期範圍
  "days": "number",                  // 天數
  "startDate": "timestamp",          // 開始日期
  "endDate": "timestamp",            // 結束日期
  "transportation": "string",        // 主要交通方式
  "travelType": "string",            // 旅遊類型
  "destinations": [                  // 目的地列表
    {
      "name": "string",
      "placeId": "string"
    }
  ],
  "itineraryDays": [                 // 每日行程
    {
      "dayNumber": "number",         // 第幾天
      "transportation": "string",    // 該天交通方式
      "spots": [                     // 景點列表
        {
          "id": "string",            // 景點ID (placeId)
          "name": "string",          // 景點名稱
          "imageUrl": "string",      // 圖片URL
          "order": "number",         // 順序
          "stayHours": "number",     // 停留小時
          "stayMinutes": "number",   // 停留分鐘
          "startTime": "string",     // 開始時間 "HH:MM"
          "latitude": "number",      // 緯度
          "longitude": "number",     // 經度
          "nextTransportation": "string", // 到下個景點的交通方式
          "travelTimeMinutes": "number"   // 到下個景點的時間
        }
      ]
    }
  ],
  "createdAt": "timestamp",          // 建立時間
  "updatedAt": "timestamp"           // 更新時間
}

// users/{userId}/favorites/{favoriteId} - 收藏景點
{
  "id": "string",              // 景點ID (placeId)
  "name": "string",            // 景點名稱
  "description": "string",     // 景點描述
  "imageUrl": "string",        // 圖片URL
  "latitude": "number",        // 緯度
  "longitude": "number",       // 經度
  "createdAt": "timestamp",    // 收藏時間
  "updatedAt": "timestamp"     // 更新時間
}

// users/{userId}/companions/{companionId} - 旅伴資料
{
  "id": "string",              // 旅伴ID
  "name": "string",            // 旅伴名稱
  "email": "string",           // 電子郵件
  "phone": "string",           // 電話號碼
  "emergencyContact": "string", // 緊急聯絡人
  "emergencyPhone": "string",  // 緊急聯絡人電話
  "relationship": "string",    // 關係
  "createdAt": "timestamp",    // 建立時間
  "updatedAt": "timestamp"     // 更新時間
}

// users/{userId}/collections/{collectionId} - 收藏集合
{
  "id": "string",              // 集合ID
  "name": "string",            // 集合名稱
  "description": "string",     // 集合描述
  "spotIds": ["string"],       // 包含的景點ID列表
  "createdAt": "timestamp",    // 建立時間
  "updatedAt": "timestamp"     // 更新時間
}
