class RecommendedSpot {
  final String id;
  final String name;
  final String imageUrl;
  final String district; // 區域，例如：中央區
  final double rating; // 評分，例如：4.5
  final String description; // 簡短描述
  final double latitude;
  final double longitude;
  bool isAdded; // 是否已加入行程

  RecommendedSpot({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.district,
    required this.rating,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.isAdded = false,
  });

  // 深拷貝方法
  RecommendedSpot copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? district,
    double? rating,
    String? description,
    double? latitude,
    double? longitude,
    bool? isAdded,
  }) {
    return RecommendedSpot(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      district: district ?? this.district,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isAdded: isAdded ?? this.isAdded,
    );
  }
}