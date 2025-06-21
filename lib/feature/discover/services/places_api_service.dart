import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../collection/models/favorite_spot.dart';

class PlacesApiService {
  static const String _apiKey = 'AIzaSyAnRvpAlNC5UdLoqUur8z75yej9s4D_L9c'; // 已填入你的 API KEY
  static const String _baseUrl = 'https://places.googleapis.com/v1';
  /// 取得附近景點（新版API，radius單位公尺）
  static Future<List<FavoriteSpot>> searchNearbyPlaces({
    required double latitude,
    required double longitude,
    int radius = 3000,
    String type = 'tourist_attraction',
    String language = 'zh-TW',
  }) async {
    final url = Uri.parse('$_baseUrl/places:searchNearby');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask': 'places.id,places.displayName,places.formattedAddress,places.location,places.rating,places.userRatingCount,places.types,places.photos,places.websiteUri,places.internationalPhoneNumber,places.regularOpeningHours,places.editorialSummary',
      },
      body: jsonEncode({
        'locationRestriction': {
          'circle': {
            'center': {'latitude': latitude, 'longitude': longitude},
            'radius': radius.toDouble(),
          }
        },
        'includedTypes': [type],
        'languageCode': language,
        'maxResultCount': 20,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List places = data['places'] ?? [];
      return places.map((p) => _parsePlaceToFavoriteSpot(p)).toList();
    } else {
      print('Places API Nearby Error: ${response.body}');
      return [];
    }
  }
  /// 關鍵字搜尋景點
  static Future<List<FavoriteSpot>> searchPlacesByText({
    required String query,
    double? latitude,
    double? longitude,
    int radius = 3000,
    String language = 'zh-TW',
  }) async {
    final url = Uri.parse('$_baseUrl/places:searchText');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask': 'places.id,places.displayName,places.formattedAddress,places.location,places.rating,places.userRatingCount,places.types,places.photos,places.websiteUri,places.internationalPhoneNumber,places.regularOpeningHours,places.editorialSummary',
      },
      body: jsonEncode({
        'textQuery': query,
        if (latitude != null && longitude != null)
          'locationBias': {
            'circle': {
              'center': {'latitude': latitude, 'longitude': longitude},
              'radius': radius.toDouble(),
            }
          },
        'languageCode': language,
        'maxResultCount': 20,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List places = data['places'] ?? [];
      return places.map((p) => _parsePlaceToFavoriteSpot(p)).toList();
    } else {
      print('Places API Text Error: ${response.body}');
      return [];
    }
  }

  /// 取得景點詳細資訊
  static Future<FavoriteSpot?> getPlaceDetails(String placeId) async {
    final url = Uri.parse('$_baseUrl/places/$placeId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask': 'id,displayName,formattedAddress,location,rating,userRatingCount,types,photos,websiteUri,internationalPhoneNumber,regularOpeningHours',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _parsePlaceToFavoriteSpot(data);
    } else {
      print('Places API Detail Error: ${response.body}');
      return null;
    }
  }
  /// 將 Google Place 轉換為 FavoriteSpot
  static FavoriteSpot _parsePlaceToFavoriteSpot(Map place) {
    // 處理營業時間
    String openingHours = '';
    if (place['regularOpeningHours'] != null && 
        place['regularOpeningHours']['weekdayDescriptions'] != null) {
      final List weekdayDescriptions = place['regularOpeningHours']['weekdayDescriptions'];
      openingHours = weekdayDescriptions.join('\n');
    }
    
    // 處理景點描述
    String description = '';
    if (place['editorialSummary'] != null && 
        place['editorialSummary']['text'] != null) {
      description = place['editorialSummary']['text'];
    }
    
    return FavoriteSpot(
      id: place['id'] ?? '',
      name: place['displayName']?['text'] ?? '',
      imageUrl: (place['photos'] != null && place['photos'].isNotEmpty)
          ? _getPhotoUrl(place['photos'][0]['name'])
          : '',
      address: place['formattedAddress'] ?? '',
      rating: (place['rating'] ?? 0).toDouble(),
      reviewCount: place['userRatingCount'] ?? 0,
      description: description,
      category: (place['types'] != null && place['types'].isNotEmpty) ? place['types'][0] : '',
      openingHours: openingHours,
      website: place['websiteUri'] ?? '',
      phone: place['internationalPhoneNumber'] ?? '',
      latitude: place['location']?['latitude'] ?? 0.0,
      longitude: place['location']?['longitude'] ?? 0.0,
      addedAt: DateTime.now(),
    );
  }

  /// 取得照片網址
  static String _getPhotoUrl(String photoName) {
    return 'https://places.googleapis.com/v1/$photoName/media?maxWidthPx=400&key=$_apiKey';
  }

  /// 搜尋多種類型的附近景點
  static Future<List<FavoriteSpot>> searchNearbyPlacesMultipleTypes({
    required double latitude,
    required double longitude,
    int radius = 3000,
    List<String> types = const ['tourist_attraction', 'restaurant', 'shopping_mall', 'hospital', 'bank'],
    String language = 'zh-TW',
  }) async {
    List<FavoriteSpot> allPlaces = [];
    
    for (String type in types) {
      try {
        final places = await searchNearbyPlaces(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
          type: type,
          language: language,
        );
        allPlaces.addAll(places);
      } catch (e) {
        print('Error searching type $type: $e');
      }
    }
    
    // 去除重複的地點（基於ID）
    final uniquePlaces = <String, FavoriteSpot>{};
    for (var place in allPlaces) {
      uniquePlaces[place.id] = place;
    }
    
    return uniquePlaces.values.toList();
  }
}
