class HomeItemModel {
  final String title;
  final String imageUrl;
  final String description;
  final String placeId;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final String category;
  final int estimatedVisitHours;

  HomeItemModel({
    required this.title,
    required this.imageUrl,
    this.description = '',
    this.placeId = '',
    this.address = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.rating = 4.0,
    this.category = 'tourist_attraction',
    this.estimatedVisitHours = 2,
  });

  // 從 JSON 建立物件
  factory HomeItemModel.fromJson(Map<String, dynamic> json) {
    return HomeItemModel(
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? 'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?auto=format&fit=crop&w=400&q=80',
      description: json['description'] ?? '',
      placeId: json['placeId'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      rating: json['rating']?.toDouble() ?? 4.0,
      category: json['category'] ?? 'tourist_attraction',
      estimatedVisitHours: json['estimatedVisitHours'] ?? 2,
    );
  }

  // 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
      'placeId': placeId,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'category': category,
      'estimatedVisitHours': estimatedVisitHours,
    };
  }

  // 複製物件並修改部分屬性
  HomeItemModel copyWith({
    String? title,
    String? imageUrl,
    String? description,
    String? placeId,
    String? address,
    double? latitude,
    double? longitude,
    double? rating,
    String? category,
    int? estimatedVisitHours,
  }) {
    return HomeItemModel(
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      placeId: placeId ?? this.placeId,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      estimatedVisitHours: estimatedVisitHours ?? this.estimatedVisitHours,
    );
  }
}