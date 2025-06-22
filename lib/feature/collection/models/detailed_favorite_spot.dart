import 'favorite_spot.dart';

/// 包含詳細資訊的景點模型（不儲存至資料庫，僅用於顯示）
class DetailedFavoriteSpot extends FavoriteSpot {
  final String description;      // 景點簡介
  final String openingHours;     // 營業時間
  final String website;          // 網站
  final String phone;            // 電話
  final int reviewCount;         // 評論數量

  DetailedFavoriteSpot({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.address,
    required super.rating,
    required super.category,
    required super.latitude,
    required super.longitude,
    required super.addedAt,
    required this.description,
    required this.openingHours,
    required this.website,
    required this.phone,
    required this.reviewCount,
  });

  /// 從基本的 FavoriteSpot 創建，用預設值填充詳細資訊
  factory DetailedFavoriteSpot.fromBasicSpot(
    FavoriteSpot basicSpot, {
    String description = '',
    String openingHours = '',
    String website = '',
    String phone = '',
    int reviewCount = 0,
  }) {
    return DetailedFavoriteSpot(
      id: basicSpot.id,
      name: basicSpot.name,
      imageUrl: basicSpot.imageUrl,
      address: basicSpot.address,
      rating: basicSpot.rating,
      category: basicSpot.category,
      latitude: basicSpot.latitude,
      longitude: basicSpot.longitude,
      addedAt: basicSpot.addedAt,
      description: description,
      openingHours: openingHours,
      website: website,
      phone: phone,
      reviewCount: reviewCount,
    );
  }
}
