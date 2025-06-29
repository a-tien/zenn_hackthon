import 'spot.dart';

class ItineraryDay {
  int dayNumber;  // 第幾天
  String transportation;  // 當天主要交通方式
  List<Spot> spots;  // 當天景點列表
  
  ItineraryDay({
    required this.dayNumber,
    required this.transportation,
    List<Spot>? spots,
  }) : this.spots = spots ?? [];

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    List<Spot> spotsList = [];
    if (json.containsKey('spots') && json['spots'] != null) {
      spotsList = (json['spots'] as List)
          .map((spot) => Spot.fromJson(spot))
          .toList();
    }
    
    return ItineraryDay(
      dayNumber: json['dayNumber'] ?? 0,
      transportation: json['transportation'] ?? '',
      spots: spotsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'transportation': transportation,
      'spots': spots.map((spot) => spot.toJson()).toList(),
    };
  }

  // 輔助方法：安全地添加景點
  void addSpot(Spot spot) {
    spots.add(spot);
  }

  // 輔助方法：安全地移除景點
  bool removeSpot(Spot spot) {
    return spots.remove(spot);
  }

  // 輔助方法：獲取景點數量
  int get spotsCount => spots.length;

  // 輔助方法：檢查是否有景點
  bool get hasSpots => spots.isNotEmpty;
}