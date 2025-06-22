import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/travel_companion.dart';
import '../../common/services/firestore_service.dart';

class CompanionService {
  // 獲取所有旅伴
  static Future<List<TravelCompanion>> getAllCompanions() async {
    try {
      FirestoreService.requireLogin();
      
      final querySnapshot = await FirestoreService.getCompanionsCollection()
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TravelCompanion.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('獲取旅伴列表需要登入');
      }
      print('獲取旅伴列表時發生錯誤: $e');
      return [];
    }
  }

  // 新增旅伴
  static Future<void> addCompanion(TravelCompanion companion) async {
    try {
      FirestoreService.requireLogin();
      
      await FirestoreService.getCompanionsCollection()
          .add(companion.toFirestore());
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('新增旅伴需要登入');
      }
      print('新增旅伴時發生錯誤: $e');
      throw Exception('新增失敗：${FirestoreService.getErrorMessage(e)}');
    }
  }

  // 更新旅伴
  static Future<void> updateCompanion(TravelCompanion companion) async {
    try {
      FirestoreService.requireLogin();
      
      final updateData = companion.toFirestore();
      updateData['updatedAt'] = FieldValue.serverTimestamp();
      
      await FirestoreService.getCompanionsCollection()
          .doc(companion.id)
          .update(updateData);
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('更新旅伴需要登入');
      }
      print('更新旅伴時發生錯誤: $e');
      throw Exception('更新失敗：${FirestoreService.getErrorMessage(e)}');
    }
  }

  // 刪除旅伴
  static Future<void> deleteCompanion(String companionId) async {
    try {
      FirestoreService.requireLogin();
      
      await FirestoreService.getCompanionsCollection()
          .doc(companionId)
          .delete();
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('刪除旅伴需要登入');
      }
      print('刪除旅伴時發生錯誤: $e');
      throw Exception('刪除失敗：${FirestoreService.getErrorMessage(e)}');
    }
  }

  // 根據ID獲取旅伴
  static Future<TravelCompanion?> getCompanionById(String id) async {
    try {
      FirestoreService.requireLogin();
      
      final doc = await FirestoreService.getCompanionsCollection()
          .doc(id)
          .get();
      
      if (!doc.exists) {
        return null;
      }
      
      final data = doc.data() as Map<String, dynamic>;
      return TravelCompanion.fromFirestore(data, doc.id);
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('獲取旅伴資料需要登入');
      }
      print('獲取旅伴資料時發生錯誤: $e');
      return null;
    }
  }

  // 檢查昵稱是否已存在
  static Future<bool> isNicknameExists(String nickname, {String? excludeId}) async {
    try {
      FirestoreService.requireLogin();
      
      final querySnapshot = await FirestoreService.getCompanionsCollection()
          .where('nickname', isEqualTo: nickname)
          .get();
      
      // 如果有 excludeId，需要排除該旅伴
      if (excludeId != null) {
        return querySnapshot.docs.any((doc) => doc.id != excludeId);
      }
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('檢查昵稱需要登入');
      }
      print('檢查昵稱時發生錯誤: $e');
      return false;
    }
  }
}
