import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteSpot {
  String id;
  String name;
  String imageUrl;
  String address;
  double rating;
  int reviewCount;
  String description;
  String category; // 如: '景點', '美食', '購物'
  String openingHours;
  String website;
  String phone;
  double latitude;
  double longitude;
  DateTime addedAt;

  FavoriteSpot({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.category,
    this.openingHours = '',
    this.website = '',
    this.phone = '',
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
      reviewCount: json['reviewCount'] ?? 0,
      description: json['description'] ?? '',
      category: json['category'] ?? '景點',
      openingHours: json['openingHours'] ?? '',
      website: json['website'] ?? '',
      phone: json['phone'] ?? '',
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
      'reviewCount': reviewCount,
      'description': description,
      'category': category,
      'openingHours': openingHours,
      'website': website,
      'phone': phone,
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
      reviewCount: data['reviewCount'] ?? 0,
      description: data['description'] ?? '',
      category: data['category'] ?? '景點',
      openingHours: data['openingHours'] ?? '',
      website: data['website'] ?? '',
      phone: data['phone'] ?? '',
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
      'reviewCount': reviewCount,
      'description': description,
      'category': category,
      'openingHours': openingHours,
      'website': website,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }
}