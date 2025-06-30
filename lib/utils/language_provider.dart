import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('ja', ''); // 預設日文

  Locale get currentLocale => _currentLocale;

  LanguageProvider() {
    _loadLanguage();
  }

  // 從本地存儲加載語言設定
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'ja';
    final countryCode = prefs.getString('country_code') ?? '';
    
    _currentLocale = Locale(languageCode, countryCode);
    notifyListeners();
  }

  // 切換語言
  Future<void> changeLanguage(Locale locale) async {
    if (_currentLocale == locale) return;

    _currentLocale = locale;
    
    // 保存到本地存儲
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setString('country_code', locale.countryCode ?? '');
    
    notifyListeners();
  }

  // 獲取支援的語言列表
  List<Locale> get supportedLocales => const [
    Locale('ja', ''), // 日文
    Locale('zh', 'TW'), // 繁體中文
    Locale('en', ''), // 英文
  ];

  // 獲取語言名稱
  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'ja':
        return '日本語';
      case 'zh':
        return '繁體中文';
      case 'en':
        return 'English';
      default:
        return locale.languageCode;
    }
  }

  // 獲取語言旗幟emoji
  String getLanguageFlag(Locale locale) {
    switch ('${locale.languageCode}_${locale.countryCode}') {
      case 'ja_':
        return '🇯🇵';
      case 'zh_TW':
        return '🇹🇼';
      case 'en_':
        return '🇺🇸';
      default:
        return '🌐';
    }
  }
}
