import 'itinerary_day.dart';
import 'itinerary_member.dart';
import 'destination.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Itinerary {
  String? id; // Firestore文件ID
  String name;
  bool useDateRange;
  int days;
  DateTime startDate;
  DateTime endDate;
  List<Destination> destinations; // 目的地列表
  String transportation;
  String travelType;
  List<ItineraryDay> itineraryDays;
  List<ItineraryMember> members;
  
  Itinerary({
    this.id,
    required this.name,
    required this.useDateRange,
    required this.days,
    required this.startDate,
    required this.endDate,
    required this.destinations,
    required this.transportation,
    required this.travelType,
    List<ItineraryDay>? itineraryDays,
    List<ItineraryMember>? members,
  }) : 
      this.itineraryDays = itineraryDays ?? [],
      this.members = members ?? [];

  // 向後兼容的目的地屬性（將第一個目的地作為主要目的地）
  String get destination => destinations.isNotEmpty ? destinations.first.name : '';
  
  // 目的地顯示文字
  String get destinationsDisplay {
    if (destinations.isEmpty) return '';
    if (destinations.length == 1) return destinations.first.name;
    if (destinations.length <= 3) {
      return destinations.map((d) => d.name).join('、');
    }
    return '${destinations.take(2).map((d) => d.name).join('、')} 等 ${destinations.length} 個地點';
  }

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    List<ItineraryDay> days = [];
    if (json.containsKey('itineraryDays') && json['itineraryDays'] != null) {
      days = (json['itineraryDays'] as List)
          .map((day) => ItineraryDay.fromJson(day))
          .toList();
    }
    
    // 解析成員
    List<ItineraryMember> members = [];
    if (json.containsKey('members') && json['members'] != null) {
      members = (json['members'] as List)
          .map((member) => ItineraryMember.fromJson(member))
          .toList();
    }

    // 解析目的地 - 支援舊格式的向後兼容
    List<Destination> destinations = [];
    if (json.containsKey('destinations') && json['destinations'] != null) {
      // 新格式：目的地列表
      destinations = (json['destinations'] as List)
          .map((dest) => Destination.fromJson(dest))
          .toList();
    } else if (json.containsKey('destination') && json['destination'] != null) {
      // 舊格式：單一目的地字串，轉換為 Destination 物件
      final destinationName = json['destination'] as String;
      destinations = [
        Destination(
          id: destinationName.toLowerCase().replaceAll(' ', '_'),
          name: destinationName,
          country: '未指定',
          type: 'other',
        ),
      ];
    }

    // 創建行程實例
    Itinerary itinerary = Itinerary(
      id: json['id'],
      name: json['name'] ?? '',
      useDateRange: json['useDateRange'] ?? false,
      days: json['days'] ?? 0,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : DateTime.now(),
      destinations: destinations,
      transportation: json['transportation'] ?? '',
      travelType: json['travelType'] ?? '',
      itineraryDays: days,
      members: members,
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
      'id': id,
      'name': name,
      'useDateRange': useDateRange,
      'days': days,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'destinations': destinations.map((dest) => dest.toJson()).toList(),
      'destination': destination, // 保留舊格式兼容性
      'transportation': transportation,
      'travelType': travelType,
      'itineraryDays': itineraryDays.map((day) => day.toJson()).toList(),
      'members': members.map((member) => member.toJson()).toList(),
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

  /// Firebase Firestore 支援方法
  
  /// 從Firestore文件創建Itinerary實例
  factory Itinerary.fromFirestore(Map<String, dynamic> data, String documentId) {
    List<ItineraryDay> days = [];
    if (data.containsKey('itineraryDays') && data['itineraryDays'] != null) {
      days = (data['itineraryDays'] as List)
          .map((day) => ItineraryDay.fromJson(day))
          .toList();
    }
    
    // 解析成員
    List<ItineraryMember> members = [];
    if (data.containsKey('members') && data['members'] != null) {
      members = (data['members'] as List)
          .map((member) => ItineraryMember.fromJson(member))
          .toList();
    }

    // 解析目的地 - 支援舊格式的向後兼容
    List<Destination> destinations = [];
    if (data.containsKey('destinations') && data['destinations'] != null) {
      // 新格式：目的地列表
      destinations = (data['destinations'] as List)
          .map((dest) => Destination.fromJson(dest))
          .toList();
    } else if (data.containsKey('destination') && data['destination'] != null) {
      // 舊格式：單一目的地字串，轉換為 Destination 物件
      final destinationName = data['destination'] as String;
      destinations = [
        Destination(
          id: destinationName.toLowerCase().replaceAll(' ', '_'),
          name: destinationName,
          country: '未指定',
          type: 'other',
        ),
      ];
    }

    // 創建行程實例
    Itinerary itinerary = Itinerary(
      id: documentId,
      name: data['name'] ?? '',
      useDateRange: data['useDateRange'] ?? false,
      days: data['days'] ?? 0,
      startDate: data['startDate'] is Timestamp 
          ? (data['startDate'] as Timestamp).toDate()
          : (data['startDate'] != null ? DateTime.parse(data['startDate']) : DateTime.now()),
      endDate: data['endDate'] is Timestamp 
          ? (data['endDate'] as Timestamp).toDate()
          : (data['endDate'] != null ? DateTime.parse(data['endDate']) : DateTime.now()),
      destinations: destinations,
      transportation: data['transportation'] ?? '',
      travelType: data['travelType'] ?? '',
      itineraryDays: days,
      members: members,
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

  /// 轉換為Firestore文件格式
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'useDateRange': useDateRange,
      'days': days,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'destinations': destinations.map((dest) => dest.toJson()).toList(),
      'destination': destination, // 保留舊格式兼容性
      'transportation': transportation,
      'travelType': travelType,
      'itineraryDays': itineraryDays.map((day) => day.toJson()).toList(),
      'members': members.map((member) => member.toJson()).toList(),
    };
  }
}