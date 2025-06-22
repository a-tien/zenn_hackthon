class Spot {
  String id;        // 這應該是 placeId，用於呼叫 Places API
  String name;
  String imageUrl;
  String? address;  // 新增地址資訊
  double? rating;   // 新增評分資訊
  String? category; // 新增分類資訊
  int order;        // 在當天行程中的順序
  int stayHours;
  int stayMinutes;
  String startTime; // 格式: "HH:MM"
  double latitude;
  double longitude;
  
  // 與下一個景點之間的交通信息
  String nextTransportation;  // 前往下一個景點的交通方式
  int travelTimeMinutes;     // 到下一個景點的時間(分鐘)
  
  Spot({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.address,
    this.rating,
    this.category,
    required this.order,
    required this.stayHours,
    required this.stayMinutes,
    required this.startTime,
    required this.latitude,
    required this.longitude,
    this.nextTransportation = '',
    this.travelTimeMinutes = 0,
  });
  factory Spot.fromJson(Map<String, dynamic> json) {
    return Spot(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      address: json['address'],
      rating: json['rating']?.toDouble(),
      category: json['category'],
      order: json['order'],
      stayHours: json['stayHours'],
      stayMinutes: json['stayMinutes'],
      startTime: json['startTime'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      nextTransportation: json['nextTransportation'] ?? '',
      travelTimeMinutes: json['travelTimeMinutes'] ?? 0,
    );
  }  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'address': address,
      'rating': rating,
      'category': category,
      'order': order,
      'stayHours': stayHours,
      'stayMinutes': stayMinutes,
      'startTime': startTime,
      'latitude': latitude,
      'longitude': longitude,
      'nextTransportation': nextTransportation,
      'travelTimeMinutes': travelTimeMinutes,
    };
  }
  
  // 獲取格式化的停留時間
  String getFormattedStayTime() {
    String hoursText = stayHours > 0 ? '${stayHours}時' : '';
    String minutesText = stayMinutes > 0 ? '${stayMinutes}分' : '';
    return '停留$hoursText$minutesText';
  }
  Spot copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? address,
    double? rating,
    String? category,
    int? order,
    int? stayHours,
    int? stayMinutes,
    String? startTime,
    double? latitude,
    double? longitude,
    String? nextTransportation,
    int? travelTimeMinutes,
  }) {
    return Spot(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      order: order ?? this.order,
      stayHours: stayHours ?? this.stayHours,
      stayMinutes: stayMinutes ?? this.stayMinutes,
      startTime: startTime ?? this.startTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      nextTransportation: nextTransportation ?? this.nextTransportation,
      travelTimeMinutes: travelTimeMinutes ?? this.travelTimeMinutes,
    );
  }
}