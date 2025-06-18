import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_auth.dart';
import '../models/user_profile.dart';

class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';

  // 初始化預設用戶
  static Future<void> initDefaultUser() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey);

    // 如果沒有用戶數據，創建預設用戶
    if (usersJson == null || usersJson.isEmpty) {
      final defaultUser = UserAuth(
        email: 'abc@google.com',
        password: '1234',
        name: '宗佑',
        travelType: null,
      );

      await prefs.setStringList(_usersKey, [jsonEncode(defaultUser.toJson())]);
    }
  }

  // 註冊新用戶
  static Future<bool> register(String email, String password, String name) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];

    // 檢查郵箱是否已被註冊
    for (final userJson in usersJson) {
      final user = UserAuth.fromJson(jsonDecode(userJson));
      if (user.email == email) {
        return false; // 郵箱已被註冊
      }
    }

    // 創建新用戶
    final newUser = UserAuth(
      email: email,
      password: password,
      name: name,
      travelType: null,
    );

    // 保存新用戶
    usersJson.add(jsonEncode(newUser.toJson()));
    await prefs.setStringList(_usersKey, usersJson);

    return true;
  }

  // 登入
  static Future<UserProfile?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];

    for (final userJson in usersJson) {
      final user = UserAuth.fromJson(jsonDecode(userJson));
      if (user.email == email && user.password == password) {
        // 創建用戶資料
        final userProfile = UserProfile(
          id: user.email,
          name: user.name,
          email: user.email,
          travelType: user.travelType,
          itineraryCount: 0, // 可以從其他地方加載
          isLoggedIn: true,
        );

        // 保存當前登入用戶
        await prefs.setString(_currentUserKey, jsonEncode(userProfile.toJson()));

        return userProfile;
      }
    }

    return null; // 登入失敗
  }

  // 獲取當前登入用戶
  static Future<UserProfile?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);

    if (userJson != null) {
      return UserProfile.fromJson(jsonDecode(userJson));
    }

    return null; // 沒有登入用戶
  }

  // 登出
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }
}
