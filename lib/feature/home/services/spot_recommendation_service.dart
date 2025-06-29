import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotRecommendationService {
  // 替換為你的API URL
  static const String _baseUrl = 'http://your-api-url.com'; // 請替換為實際的URL
  
  static Future<SpotRecommendationResponse> getRecommendations({
    required String location,
    String type = 'popular',
    String season = '',
    List<String> interests = const [],
    int limit = 6,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/recommend');
      
      final requestBody = {
        'location': location,
        'type': type,
        'season': season,
        'interests': interests,
        'limit': limit,
      };

      print('Requesting spot recommendations with body: $requestBody');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return SpotRecommendationResponse.fromJson(jsonData);
      } else {
        throw SpotRecommendationException(
          'API請求失敗: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e) {
      print('Error in getRecommendations: $e');
      if (e is SpotRecommendationException) {
        rethrow;
      }
      throw SpotRecommendationException('網路請求失敗', e.toString());
    }
  }
}

class SpotRecommendationResponse {
  final String location;
  final String recommendationType;
  final List<RecommendedSpot> spots;

  SpotRecommendationResponse({
    required this.location,
    required this.recommendationType,
    required this.spots,
  });

  factory SpotRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return SpotRecommendationResponse(
      location: json['location'] ?? '',
      recommendationType: json['recommendationType'] ?? '',
      spots: (json['spots'] as List<dynamic>?)
          ?.map((spot) => RecommendedSpot.fromJson(spot))
          .toList() ?? [],
    );
  }
}

class RecommendedSpot {
  final String id;
  final String name;
  final String description;
  final String category;
  final String imageUrl;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final String priceLevel;
  final String openingHours;
  final String bestVisitTime;
  final String estimatedDuration;
  final List<String> tags;
  final List<String> highlights;

  RecommendedSpot({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.priceLevel,
    required this.openingHours,
    required this.bestVisitTime,
    required this.estimatedDuration,
    required this.tags,
    required this.highlights,
  });

  factory RecommendedSpot.fromJson(Map<String, dynamic> json) {
    return RecommendedSpot(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      priceLevel: json['priceLevel'] ?? '',
      openingHours: json['openingHours'] ?? '',
      bestVisitTime: json['bestVisitTime'] ?? '',
      estimatedDuration: json['estimatedDuration'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      highlights: List<String>.from(json['highlights'] ?? []),
    );
  }
}

class SpotRecommendationException implements Exception {
  final String message;
  final String details;

  SpotRecommendationException(this.message, this.details);

  @override
  String toString() => 'SpotRecommendationException: $message';
}