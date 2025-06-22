import 'favorite_spot.dart';

class LightweightFavoriteSpot {
  final String placeId;
  final String name;
  final String description;
  final DateTime addedAt;

  LightweightFavoriteSpot({
    required this.placeId,
    required this.name,
    required this.description,
    required this.addedAt,
  });

  // 從JSON創建輕量化收藏景點
  factory LightweightFavoriteSpot.fromJson(Map<String, dynamic> json) {
    return LightweightFavoriteSpot(
      placeId: json['placeId'],
      name: json['name'],
      description: json['description'] ?? '',
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  // 轉換為JSON
  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'name': name,
      'description': description,
      'addedAt': addedAt.toIso8601String(),
    };
  }
  // 從完整的FavoriteSpot創建輕量化版本
  factory LightweightFavoriteSpot.fromFavoriteSpot(FavoriteSpot spot) {
    return LightweightFavoriteSpot(
      placeId: spot.id, // FavoriteSpot的id就是placeId
      name: spot.name,
      description: spot.category, // 使用 category 替代 description
      addedAt: spot.addedAt,
    );
  }
}
