import 'spot.dart';

class ItineraryDay {
  int dayNumber;  // 第幾天
  String transportation;  // 當天主要交通方式
  List<Spot> spots;  // 當天景點列表
  
  ItineraryDay({
    required this.dayNumber,
    required this.transportation,
    required this.spots,
  });

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    List<Spot> spotsList = [];
    if (json.containsKey('spots') && json['spots'] != null) {
      spotsList = (json['spots'] as List)
          .map((spot) => Spot.fromJson(spot))
          .toList();
    }
    
    return ItineraryDay(
      dayNumber: json['dayNumber'],
      transportation: json['transportation'],
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
}