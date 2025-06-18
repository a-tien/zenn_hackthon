import 'itinerary_day.dart';

class Itinerary {
  String name;
  bool useDateRange;
  int days;
  DateTime startDate;
  DateTime endDate;
  String destination;
  String transportation;
  String travelType;
  List<ItineraryDay> itineraryDays;

  Itinerary({
    required this.name,
    required this.useDateRange,
    required this.days,
    required this.startDate,
    required this.endDate,
    required this.destination,
    required this.transportation,
    required this.travelType,
    List<ItineraryDay>? itineraryDays,
  }) : this.itineraryDays = itineraryDays ?? [];

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    List<ItineraryDay> days = [];
    if (json.containsKey('itineraryDays') && json['itineraryDays'] != null) {
      days = (json['itineraryDays'] as List)
          .map((day) => ItineraryDay.fromJson(day))
          .toList();
    }

    // 創建行程實例
    Itinerary itinerary = Itinerary(
      name: json['name'],
      useDateRange: json['useDateRange'],
      days: json['days'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      destination: json['destination'],
      transportation: json['transportation'],
      travelType: json['travelType'],
      itineraryDays: days,
    );
    
    // 如果沒有行程天數數據，則初始化行程天數
    if (itinerary.itineraryDays.isEmpty && itinerary.days > 0) {
      for (int i = 0; i < itinerary.days; i++) {
        itinerary.itineraryDays.add(
          ItineraryDay(
            dayNumber: i + 1,
            transportation: itinerary.transportation,
            spots: [],
          ),
        );
      }
    }
    
    return itinerary;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'useDateRange': useDateRange,
      'days': days,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'destination': destination,
      'transportation': transportation,
      'travelType': travelType,
      'itineraryDays': itineraryDays.map((day) => day.toJson()).toList(),
    };
  }

  // 新增一天行程
  void addDay() {
    days++;
    if (useDateRange) {
      endDate = endDate.add(const Duration(days: 1));
    }
    
    final newDay = ItineraryDay(
      dayNumber: days,
      transportation: transportation, // 使用行程的默認交通方式
      spots: [],
    );
    itineraryDays.add(newDay);
  }

  // 刪除最後一天行程
  bool removeLastDay() {
    if (days <= 1) return false;
    
    days--;
    if (useDateRange) {
      endDate = endDate.subtract(const Duration(days: 1));
    }
    
    if (itineraryDays.isNotEmpty) {
      itineraryDays.removeLast();
    }
    return true;
  }
}