import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../../collection/models/favorite_collection.dart';
import '../../collection/services/favorite_service.dart';

// 註冊結果類
class RegisterResult {
  final bool success;
  final String? errorMessage;

  RegisterResult({required this.success, this.errorMessage});
}

// 登入結果類
class LoginResult {
  final bool success;
  final UserProfile? userProfile;
  final String? errorMessage;

  LoginResult({
    required this.success,
    this.userProfile,
    this.errorMessage,
  });
}

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _currentUserKey = 'current_user';

  // 初始化預設用戶功能將不再使用，Firebase不需要預設用戶
  static Future<void> initDefaultUser() async {
    // 這個方法留空，保持相容性，但不再創建本地預設用戶
    // Firebase Authentication 會自動管理用戶資料
  }  // 註冊新用戶
  static Future<RegisterResult> register(String email, String password, String name) async {
    try {
      // 使用 Firebase 創建新用戶
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // 獲取用戶 UID
      final String uid = userCredential.user!.uid;
      
      // 更新 Firebase Auth 用戶顯示名稱
      await userCredential.user!.updateDisplayName(name);
        // 建立 Firestore 使用者資料（加強錯誤提示）
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'id': uid,
          'name': name,
          'email': email,
          'travelType': null,
          'itineraryCount': 0,
          'isLoggedIn': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('用戶註冊成功並建立 Firestore 資料: $uid');
          // 建立預設的"口袋清單"收藏集
        try {
          final defaultCollection = FavoriteCollection(
            id: '', // 將由 Firestore 自動生成
            name: '口袋清單',
            description: '我想去的地方',
            spotIds: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          await FavoriteService.createCollection(defaultCollection);
          print('預設收藏集"口袋清單"建立成功');
        } catch (e) {
          print('建立預設收藏集失敗: $e');
          // 不影響註冊流程，只記錄錯誤
        }
      } catch (e) {
        print('Firestore 建立個人資料失敗: $e');
      }
      
      return RegisterResult(success: true);
    } on FirebaseAuthException catch (e) {
      print('註冊失敗 (FirebaseAuthException): ${e.code} ${e.message}');
      String errorMessage = '註冊時發生錯誤';
      
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = '電子郵件已被註冊過';
          break;
        case 'invalid-email':
          errorMessage = '無效的電子郵件格式';
          break;
        case 'operation-not-allowed':
          errorMessage = '此註冊方式未啟用，請聯繫管理員';
          break;
        case 'weak-password':
          errorMessage = '密碼強度不足，請使用更強的密碼';
          break;
        default:
          errorMessage = e.message ?? '註冊失敗';
      }
      
      return RegisterResult(success: false, errorMessage: errorMessage);
    } catch (e) {
      print('註冊時發生未知錯誤: $e');
      return RegisterResult(success: false, errorMessage: '註冊時發生錯誤，請稍後再試');
    }
  }  // 登入
  static Future<LoginResult> login(String email, String password) async {
    try {
      // 使用 Firebase 驗證登入
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = userCredential.user;
      
      if (user != null) {
        // 先創建基本使用者資料，避免卡住
        UserProfile userProfile = UserProfile(
          id: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          travelType: null,
          itineraryCount: 0,
          isLoggedIn: true,
        );
        
        // 保存到 SharedPreferences
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_currentUserKey, jsonEncode(userProfile.toJson()));
        } catch (e) {
          print('保存到 SharedPreferences 失敗: $e');
        }
        
        print('用戶登入成功: ${user.uid}');
        return LoginResult(success: true, userProfile: userProfile);
      }
      
      return LoginResult(success: false, errorMessage: '登入失敗');
    } on FirebaseAuthException catch (e) {
      print('登入失敗 (FirebaseAuthException): ${e.code} ${e.message}');
      String errorMessage = '登入失敗';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = '找不到該使用者，請檢查郵箱或註冊新帳號';
          break;
        case 'wrong-password':
          errorMessage = '密碼錯誤，請重新輸入';
          break;
        case 'invalid-email':
          errorMessage = '無效的電子郵件格式';
          break;
        case 'user-disabled':
          errorMessage = '該帳號已被停用';
          break;
        case 'too-many-requests':
          errorMessage = '登入嘗試次數過多，請稍後再試';
          break;
        case 'network-request-failed':
          errorMessage = '網路連線失敗，請檢查您的網路連線';
          break;
        default:
          errorMessage = e.message ?? '登入失敗';
      }
      
      return LoginResult(success: false, errorMessage: errorMessage);
    } catch (e) {
      print('登入時發生未知錯誤: $e');
      return LoginResult(success: false, errorMessage: '登入時發生錯誤，請稍後再試');
    }
  }  // 獲取當前登入用戶
  static Future<UserProfile?> getCurrentUser() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // 從 Firestore 取得完整個人資料
        final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          return UserProfile(
            id: data['id'] ?? currentUser.uid,
            name: data['name'] ?? currentUser.displayName ?? 'User',
            email: data['email'] ?? currentUser.email ?? '',
            travelType: data['travelType'],
            itineraryCount: data['itineraryCount'] ?? 0,
            isLoggedIn: true,
          );
        } else {
          // 若 Firestore 無資料，回傳基本資料
          return UserProfile(
            id: currentUser.uid,
            name: currentUser.displayName ?? 'User',
            email: currentUser.email ?? '',
            travelType: null,
            itineraryCount: 0,
            isLoggedIn: true,
          );
        }
      }
      return null;
    } catch (e) {
      print('獲取當前用戶時發生錯誤: $e');
      return null;
    }
  }

  // 登出
  static Future<void> logout() async {
    try {
      await _auth.signOut();
      
      // 清除本地緩存的用戶資料
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
    } catch (e) {
      print('登出時發生錯誤: $e');
    }
  }

  // 忘記密碼功能
  static Future<bool> resetPassword(String email) async {
    try {
      print('發送密碼重設郵件到: $email');
      await _auth.sendPasswordResetEmail(email: email);
      print('密碼重設郵件發送成功');
      return true;
    } catch (e) {
      print('發送密碼重設郵件失敗: $e');
      return false;
    }
  }
}
