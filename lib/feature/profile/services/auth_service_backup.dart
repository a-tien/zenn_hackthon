import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

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
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
      
      // 嘗試在 Firestore 中保存用戶額外資料
      try {
        await _firestore.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'travelType': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('用戶註冊成功並保存到 Firestore: $uid');
      } catch (firestoreError) {
        print('Firestore 寫入失敗，但用戶仍然註冊成功: $firestoreError');
        // 即使 Firestore 寫入失敗，用戶仍然在 Auth 中註冊成功
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
        // 創建基本用戶資料
        UserProfile userProfile = UserProfile(
          id: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          travelType: null,
          itineraryCount: 0,
          isLoggedIn: true,
        );
        
        // 嘗試從 Firestore 獲取詳細資料
        try {
          final DocumentSnapshot userDoc = await _firestore
              .collection('users')
              .doc(user.uid)
              .get()
              .timeout(const Duration(seconds: 3));
          
          if (userDoc.exists) {
            final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            
            // 更新用戶資料
            userProfile = UserProfile(
              id: user.uid,
              name: userData['name'] ?? user.displayName ?? 'User',
              email: user.email ?? '',
              travelType: userData['travelType'],
              itineraryCount: 0,
              isLoggedIn: true,
            );
          }
        } catch (firestoreError) {
          print('從 Firestore 獲取用戶資料失敗: $firestoreError');
          // 繼續使用基本資料，不影響登入流程
        }
        
        // 保存到 SharedPreferences
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_currentUserKey, jsonEncode(userProfile.toJson()));
        } catch (e) {
          print('保存到 SharedPreferences 失敗: $e');
          // 不影響登入流程
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
  }
  // 獲取當前登入用戶
  static Future<UserProfile?> getCurrentUser() async {
    try {
      // 從 Firebase 獲取當前用戶
      final User? currentUser = _auth.currentUser;
      
      if (currentUser != null) {
        try {
          // 從 Firestore 獲取用戶詳細資料 (添加超時限制)
          final DocumentSnapshot userDoc = await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .get()
              .timeout(const Duration(seconds: 5));
          
          if (userDoc.exists) {
            final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            
            return UserProfile(
              id: currentUser.uid,
              name: userData['name'] ?? currentUser.displayName ?? 'User',
              email: currentUser.email ?? '',
              travelType: userData['travelType'],
              itineraryCount: 0, // 可從 Firestore 另外查詢
              isLoggedIn: true,
            );
          } else {
            // 用戶存在於 Auth 但不存在於 Firestore，只返回基本資料
            return UserProfile(
              id: currentUser.uid,
              name: currentUser.displayName ?? 'User',
              email: currentUser.email ?? '',
              travelType: null,
              itineraryCount: 0,
              isLoggedIn: true,
            );
          }
        } catch (e) {
          print('從 Firestore 獲取用戶資料時發生錯誤: $e');
          // 如果 Firestore 查詢失敗，僅返回 Auth 中的基本用戶資料
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
      
      return null; // 沒有登入用戶
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
}
