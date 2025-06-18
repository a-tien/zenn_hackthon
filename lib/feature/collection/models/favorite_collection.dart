class FavoriteCollection {
  String id;
  String name;
  String description;
  List<String> spotIds; // 儲存景點ID列表
  DateTime createdAt;
  DateTime updatedAt;

  FavoriteCollection({
    required this.id,
    required this.name,
    this.description = '',
    required this.spotIds,
    required this.createdAt,
    required this.updatedAt,
  });

  // 從JSON創建收藏集
  factory FavoriteCollection.fromJson(Map<String, dynamic> json) {
    return FavoriteCollection(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      spotIds: List<String>.from(json['spotIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // 轉換為JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'spotIds': spotIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // 創建一個更新後的收藏集副本
  FavoriteCollection copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? spotIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FavoriteCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      spotIds: spotIds ?? this.spotIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}