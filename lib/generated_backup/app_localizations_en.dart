// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Travel Recommendation';

  @override
  String get homeTab => 'Home';

  @override
  String get discoverTab => 'Discover';

  @override
  String get itineraryTab => 'Itinerary';

  @override
  String get profileTab => 'Profile';

  @override
  String get searchHint => 'Search for destinations...';

  @override
  String get popularDestinations => 'Popular Destinations';

  @override
  String get recentlyViewed => 'Recently Viewed';

  @override
  String get nearbyAttractions => 'Nearby Attractions';
}
