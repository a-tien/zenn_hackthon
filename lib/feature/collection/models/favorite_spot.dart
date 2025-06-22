import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteSpot {
  String id;        // placeId，用於呼叫 Places API
  String name;
  String imageUrl;
  String address;
  double rating;
  String category;  // 如: '景點', '美食', '購物'
  double latitude;
  double longitude;
  DateTime addedAt;
  FavoriteSpot({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.address,
    required this.rating,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.addedAt,
  });
  // 從JSON創建收藏景點
  factory FavoriteSpot.fromJson(Map<String, dynamic> json) {
    return FavoriteSpot(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'] ?? '',
      address: json['address'] ?? '',
      rating: json['rating']?.toDouble() ?? 0.0,
      category: json['category'] ?? '景點',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      addedAt: DateTime.parse(json['addedAt']),
    );
  }
  // 轉換為JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'address': address,
      'rating': rating,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'addedAt': addedAt.toIso8601String(),
    };
  }
  // 從Firestore文檔創建收藏景點
  factory FavoriteSpot.fromFirestore(Map<String, dynamic> data) {
    return FavoriteSpot(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      address: data['address'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] ?? '景點',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      addedAt: data['addedAt'] != null
          ? (data['addedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
  // 轉換為Firestore格式
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'address': address,
      'rating': rating,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }
}