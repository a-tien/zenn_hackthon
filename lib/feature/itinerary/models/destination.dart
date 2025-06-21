class Destination {
  final String id;
  final String name;
  final String country;
  final String? prefecture; // 都道府縣（僅日本）
  final String type; // 'domestic' 或 'international'
  final String? imageUrl;
  final bool isPopular; // 是否為熱門地點
  final double? latitude; // 緯度
  final double? longitude; // 經度

  Destination({
    required this.id,
    required this.name,
    required this.country,
    this.prefecture,
    required this.type,
    this.imageUrl,
    this.isPopular = false,
    this.latitude,
    this.longitude,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      prefecture: json['prefecture'],
      type: json['type'],
      imageUrl: json['imageUrl'],
      isPopular: json['isPopular'] ?? false,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'prefecture': prefecture,
      'type': type,
      'imageUrl': imageUrl,
      'isPopular': isPopular,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // 獲取顯示名稱
  String get displayName {
    if (type == 'domestic' && prefecture != null) {
      return '$prefecture$name';
    }
    return name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Destination && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
