class UserProfile {
  final String id;
  final String name;
  final String? email; // 新增 email 字段
  final String? avatarUrl;
  final String? travelType; // 修改为可为 null
  final int itineraryCount;
  final bool isLoggedIn;
  final List<String> savedSpots; // 收藏的景點ID列表
  final List<String> travelCompanions; // 旅伴ID列表

  UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.travelType,
    required this.itineraryCount,
    required this.isLoggedIn,
    this.savedSpots = const [],
    this.travelCompanions = const [],
  });

  // 創建一個訪客用戶
  factory UserProfile.guest() {
    return UserProfile(
      id: 'guest',
      name: '訪客',
      travelType: null,
      itineraryCount: 0,
      isLoggedIn: false,
    );
  }

  // 從 JSON 創建用戶
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      travelType: json['travelType'],
      itineraryCount: json['itineraryCount'] ?? 0,
      isLoggedIn: json['isLoggedIn'] ?? false,
      savedSpots: List<String>.from(json['savedSpots'] ?? []),
      travelCompanions: List<String>.from(json['travelCompanions'] ?? []),
    );
  }

  // 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'travelType': travelType,
      'itineraryCount': itineraryCount,
      'isLoggedIn': isLoggedIn,
      'savedSpots': savedSpots,
      'travelCompanions': travelCompanions,
    };
  }

  // 創建一個更新後的用戶資料副本
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? travelType,
    int? itineraryCount,
    bool? isLoggedIn,
    List<String>? savedSpots,
    List<String>? travelCompanions,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      travelType: travelType ?? this.travelType,
      itineraryCount: itineraryCount ?? this.itineraryCount,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      savedSpots: savedSpots ?? this.savedSpots,
      travelCompanions: travelCompanions ?? this.travelCompanions,
    );
  }
}