import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 獲取當前登入用戶的UID
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// 檢查用戶是否已登入
  static bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  /// 獲取用戶收藏集合的引用
  static CollectionReference getFavoritesCollection() {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('用戶未登入');
    }
    return _db.collection('users').doc(userId).collection('favorites');
  }

  /// 獲取用戶行程集合的引用
  static CollectionReference getItinerariesCollection() {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('用戶未登入');
    }
    return _db.collection('users').doc(userId).collection('itineraries');
  }

  /// 獲取用戶旅伴集合的引用
  static CollectionReference getCompanionsCollection() {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('用戶未登入');
    }
    return _db.collection('users').doc(userId).collection('companions');
  }

  /// 獲取用戶資料文件的引用
  static DocumentReference getUserDocument() {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('用戶未登入');
    }
    return _db.collection('users').doc(userId);
  }

  /// 獲取用戶收藏集合的引用
  static CollectionReference getCollectionsCollection() {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('用戶未登入');
    }
    return _db.collection('users').doc(userId).collection('collections');
  }

  /// 通用錯誤處理
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return '沒有權限執行此操作，請確認已登入';
        case 'unavailable':
          return '服務暫時無法使用，請稍後再試';
        case 'deadline-exceeded':
          return '操作超時，請檢查網路連線';
        default:
          return '操作失敗：${error.message}';
      }
    }
    return '發生未知錯誤，請稍後再試';
  }

  /// 檢查並要求登入
  static void requireLogin() {
    if (!isUserLoggedIn()) {
      throw Exception('此功能需要登入才能使用');
    }
  }
}
