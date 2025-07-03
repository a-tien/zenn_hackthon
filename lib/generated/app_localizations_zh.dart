// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '旅遊推薦';

  @override
  String get homeTab => '首頁';

  @override
  String get discoverTab => '探索';

  @override
  String get itineraryTab => '行程';

  @override
  String get profileTab => '我的';

  @override
  String get searchHint => '搜尋目的地...';

  @override
  String get popularDestinations => '熱門目的地';

  @override
  String get recentlyViewed => '最近瀏覽';

  @override
  String get nearbyAttractions => '附近景點';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => '旅遊推薦';

  @override
  String get homeTab => '首頁';

  @override
  String get discoverTab => '探索';

  @override
  String get itineraryTab => '行程';

  @override
  String get profileTab => '個人檔案';

  @override
  String get searchHint => '搜尋目的地...';

  @override
  String get popularDestinations => '熱門目的地';

  @override
  String get recentlyViewed => '最近瀏覽';

  @override
  String get nearbyAttractions => '附近景點';
}
