/// 行程日統計資訊
class DayStats {
  /// 第幾天
  final int dayNumber;
  
  /// 總景點數
  final int totalSpots;
  
  /// 總停留時間（分鐘）
  final int totalStayMinutes;
  
  /// 總交通時間（分鐘）
  final int totalTravelMinutes;
  
  /// 總距離（公里）
  final double totalDistance;
  
  /// 開始時間
  final String startTime;
  
  /// 結束時間
  final String endTime;

  DayStats({
    required this.dayNumber,
    required this.totalSpots,
    required this.totalStayMinutes,
    required this.totalTravelMinutes,
    required this.totalDistance,
    required this.startTime,
    required this.endTime,
  });

  /// 創建空的統計
  factory DayStats.empty() {
    return DayStats(
      dayNumber: 0,
      totalSpots: 0,
      totalStayMinutes: 0,
      totalTravelMinutes: 0,
      totalDistance: 0.0,
      startTime: '09:00',
      endTime: '18:00',
    );
  }

  /// 總時間（分鐘）
  int get totalMinutes => totalStayMinutes + totalTravelMinutes;

  /// 格式化的停留時間
  String get formattedStayTime {
    final hours = totalStayMinutes ~/ 60;
    final minutes = totalStayMinutes % 60;
    
    if (hours == 0) {
      return '${minutes}分鐘';
    } else if (minutes == 0) {
      return '${hours}小時';
    } else {
      return '${hours}小時${minutes}分鐘';
    }
  }

  /// 格式化的交通時間
  String get formattedTravelTime {
    final hours = totalTravelMinutes ~/ 60;
    final minutes = totalTravelMinutes % 60;
    
    if (hours == 0) {
      return '${minutes}分鐘';
    } else if (minutes == 0) {
      return '${hours}小時';
    } else {
      return '${hours}小時${minutes}分鐘';
    }
  }

  /// 格式化的總時間
  String get formattedTotalTime {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    
    if (hours == 0) {
      return '${minutes}分鐘';
    } else if (minutes == 0) {
      return '${hours}小時';
    } else {
      return '${hours}小時${minutes}分鐘';
    }
  }

  /// 格式化的距離
  String get formattedDistance {
    if (totalDistance >= 1.0) {
      return '${totalDistance.toStringAsFixed(1)} 公里';
    } else {
      return '${(totalDistance * 1000).round()} 公尺';
    }
  }

  /// 平均每個景點的停留時間（分鐘）
  double get averageStayTime {
    if (totalSpots == 0) return 0.0;
    return totalStayMinutes / totalSpots;
  }

  /// 轉換為JSON
  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'totalSpots': totalSpots,
      'totalStayMinutes': totalStayMinutes,
      'totalTravelMinutes': totalTravelMinutes,
      'totalDistance': totalDistance,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  /// 從JSON創建
  factory DayStats.fromJson(Map<String, dynamic> json) {
    return DayStats(
      dayNumber: json['dayNumber'],
      totalSpots: json['totalSpots'],
      totalStayMinutes: json['totalStayMinutes'],
      totalTravelMinutes: json['totalTravelMinutes'],
      totalDistance: json['totalDistance'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }

  @override
  String toString() {
    return 'DayStats(day: $dayNumber, spots: $totalSpots, stay: $formattedStayTime, travel: $formattedTravelTime, distance: $formattedDistance)';
  }
}
