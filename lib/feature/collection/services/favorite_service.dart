import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/favorite_spot.dart';
import '../models/lightweight_favorite_spot.dart';
import '../models/favorite_collection.dart';
import '../../common/services/firestore_service.dart';
import '../../discover/services/places_api_service.dart';

class FavoriteService {
  /// 檢查景點是否已收藏
  static Future<bool> isSpotFavorited(String placeId) async {
    try {
      FirestoreService.requireLogin();
      
      final doc = await FirestoreService.getFavoritesCollection()
          .doc(placeId)
          .get();
      
      return doc.exists;
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('查看收藏狀態需要登入');
      }
      print('檢查收藏狀態時發生錯誤: $e');
      return false;
    }
  }
  /// 添加景點到收藏
  static Future<void> addSpotToFavorites(FavoriteSpot spot) async {
    try {
      FirestoreService.requireLogin();
      
      final favoriteData = {
        'id': spot.id,
        'name': spot.name,
        'imageUrl': spot.imageUrl,
        'address': spot.address,
        'rating': spot.rating,
        'category': spot.category,
        'latitude': spot.latitude,
        'longitude': spot.longitude,
        'addedAt': Timestamp.fromDate(spot.addedAt),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await FirestoreService.getFavoritesCollection()
          .doc(spot.id)
          .set(favoriteData);
      
      print('✅ 景點已保存到收藏列表：${spot.name}');
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('收藏景點需要登入');
      }
      print('添加收藏時發生錯誤: $e');
      throw Exception('收藏失敗：${FirestoreService.getErrorMessage(e)}');
    }
  }

  /// 從收藏中移除景點
  static Future<void> removeSpotFromFavorites(String placeId) async {
    try {
      FirestoreService.requireLogin();
      
      await FirestoreService.getFavoritesCollection()
          .doc(placeId)
          .delete();
      
      print('✅ 景點已從收藏中移除：$placeId');
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('移除收藏需要登入');
      }
      print('移除收藏時發生錯誤: $e');
      throw Exception('移除失敗：${FirestoreService.getErrorMessage(e)}');
    }
  }
  /// 獲取景點完整詳細資料
  static Future<FavoriteSpot?> getFullSpotDetails(String placeId) async {
    try {
      // 直接使用 Places API 獲取景點詳細資訊
      return await PlacesApiService.getPlaceDetails(placeId);
    } catch (e) {
      print('獲取景點詳細資料時發生錯誤: $e');
      return null;
    }
  }

  /// 獲取所有輕量化收藏景點
  static Future<List<LightweightFavoriteSpot>> getAllLightweightSpots() async {
    try {
      FirestoreService.requireLogin();
      
      final querySnapshot = await FirestoreService.getFavoritesCollection()
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return LightweightFavoriteSpot(
          placeId: data['id'] ?? doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          addedAt: data['addedAt'] != null 
              ? (data['addedAt'] as Timestamp).toDate()
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('獲取收藏列表需要登入');
      }
      print('獲取收藏列表時發生錯誤: $e');
      return [];
    }
  }

  /// 獲取所有完整收藏景點
  static Future<List<FavoriteSpot>> getAllFavoriteSpots() async {
    try {
      FirestoreService.requireLogin();
      
      final querySnapshot = await FirestoreService.getFavoritesCollection()
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FavoriteSpot.fromFirestore(data);
      }).toList();
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('獲取收藏列表需要登入');
      }
      print('獲取收藏列表時發生錯誤: $e');
      return [];
    }
  }
  /// 獲取所有收藏集合
  static Future<List<FavoriteCollection>> getAllCollections() async {
    try {
      FirestoreService.requireLogin();
      
      final querySnapshot = await FirestoreService.getCollectionsCollection()
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FavoriteCollection.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('獲取收藏集合需要登入');
      }      print('獲取收藏集合時發生錯誤: $e');
      return [];
    }
  }

  /// 創建新的收藏集合
  static Future<FavoriteCollection> createCollection(FavoriteCollection collection) async {
    try {
      FirestoreService.requireLogin();
      
      // 使用 Firestore 自動生成的 ID
      final docRef = await FirestoreService.getCollectionsCollection()
          .add(collection.toFirestore());
      
      // 返回具有正確 Firestore ID 的 collection
      return collection.copyWith(id: docRef.id);
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('創建收藏集合需要登入');
      }
      print('創建收藏集合時發生錯誤: $e');
      throw Exception('創建失敗：${FirestoreService.getErrorMessage(e)}');
    }
  }
  /// 將景點添加到收藏集合
  static Future<void> addSpotToCollection(String collectionId, String placeId) async {
    try {
      FirestoreService.requireLogin();
      
      final doc = await FirestoreService.getCollectionsCollection()
          .doc(collectionId)
          .get();
      
      if (!doc.exists) {
        throw Exception('收藏集合不存在');
      }
      
      final data = doc.data() as Map<String, dynamic>;
      final collection = FavoriteCollection.fromFirestore(data, doc.id);
      
      // 檢查景點是否已在集合中
      if (!collection.spotIds.contains(placeId)) {
        collection.spotIds.add(placeId);
        collection.updatedAt = DateTime.now();
        
        final updateData = collection.toFirestore();
        updateData['updatedAt'] = FieldValue.serverTimestamp();
        
        await FirestoreService.getCollectionsCollection()
            .doc(collectionId)
            .update(updateData);
      }
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('添加到收藏集合需要登入');
      }
      print('添加景點到收藏集合時發生錯誤: $e');
      throw Exception('添加失敗：${FirestoreService.getErrorMessage(e)}');
    }
  }
  /// 從收藏集合中移除景點
  static Future<void> removeSpotFromCollection(String collectionId, String placeId) async {
    try {
      FirestoreService.requireLogin();
      
      final doc = await FirestoreService.getCollectionsCollection()
          .doc(collectionId)
          .get();
      
      if (!doc.exists) {
        throw Exception('收藏集合不存在');
      }
      
      final data = doc.data() as Map<String, dynamic>;
      final collection = FavoriteCollection.fromFirestore(data, doc.id);
      
      // 從集合中移除景點
      if (collection.spotIds.contains(placeId)) {
        collection.spotIds.remove(placeId);
        collection.updatedAt = DateTime.now();
        
        final updateData = collection.toFirestore();
        updateData['updatedAt'] = FieldValue.serverTimestamp();
        
        await FirestoreService.getCollectionsCollection()
            .doc(collectionId)
            .update(updateData);
      }
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('從收藏集合移除需要登入');
      }
      print('從收藏集合移除景點時發生錯誤: $e');
      throw Exception('移除失敗：${FirestoreService.getErrorMessage(e)}');
    }
  }
  /// 更新收藏集
  static Future<void> updateCollection(FavoriteCollection collection) async {
    try {
      FirestoreService.requireLogin();
      
      final updateData = collection.toFirestore();
      updateData['updatedAt'] = FieldValue.serverTimestamp();
      
      await FirestoreService.getCollectionsCollection()
          .doc(collection.id)
          .update(updateData);
          
      print('✅ 收藏集已更新：${collection.name}');
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('更新收藏集需要登入');
      }
      print('更新收藏集時發生錯誤: $e');
      throw Exception('更新失敗：${FirestoreService.getErrorMessage(e)}');
    }
  }

  /// 刪除收藏集
  static Future<void> deleteCollection(String collectionId) async {
    try {
      FirestoreService.requireLogin();
      
      await FirestoreService.getCollectionsCollection()
          .doc(collectionId)
          .delete();
          
      print('✅ 收藏集已刪除：$collectionId');
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('刪除收藏集需要登入');
      }
      print('刪除收藏集時發生錯誤: $e');
      throw Exception('刪除失敗：${FirestoreService.getErrorMessage(e)}');
    }
  }

  /// 遷移舊版本收藏資料（用於測試，不在生產環境使用）
  static Future<void> migrateLegacyFavorites() async {
    // 這個方法不再需要，因為我們直接切換到Firebase
    print('已切換到Firebase儲存，不再需要遷移舊資料');
  }
}
