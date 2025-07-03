// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '旅行推薦';

  @override
  String get homeTab => 'ホーム';

  @override
  String get discoverTab => '発見';

  @override
  String get itineraryTab => '旅程';

  @override
  String get profileTab => 'プロフィール';

  @override
  String get searchHint => '目的地を検索...';

  @override
  String get popularDestinations => '人気の目的地';

  @override
  String get recentlyViewed => '最近見た';

  @override
  String get nearbyAttractions => '近くの観光地';
}
