import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/spot.dart';

/// Google Routes API 服務
/// 用於計算景點間的路線、距離和時間
class GoogleRoutesService {
  static const String _baseUrl = 'https://routes.googleapis.com/directions/v2:computeRoutes';
  static const String _apiKey = 'AIzaSyBHEcitEBtZ7ezjlRCRgS-Hk1fm2SSY4is';
  
  /// 計算兩個景點之間的路線資訊
  /// [origin] 起始景點
  /// [destination] 目的地景點
  /// [travelMode] 交通方式: DRIVE, WALK, BICYCLE, TRANSIT
  /// [departureTime] 出發時間（可選）
  Future<RouteInfo?> computeRoute({
    required Spot origin,
    required Spot destination,
    required String travelMode,
    DateTime? departureTime,
  }) async {
    try {
      final requestBody = _buildRouteRequest(
        origin: origin,
        destination: destination,
        travelMode: travelMode,
        departureTime: departureTime,
      );

      print('計算路線: ${origin.name} -> ${destination.name}, 交通方式: $travelMode');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey,
          'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,routes.staticDuration,routes.polyline.encodedPolyline',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          
          return RouteInfo(
            duration: _parseDuration(route['duration']),
            distance: route['distanceMeters']?.toDouble() ?? 0.0,
            staticDuration: _parseDuration(route['staticDuration']),
            polyline: route['polyline']?['encodedPolyline'] ?? '',
            travelMode: travelMode,
          );
        } else {
          print('無法找到路線');
          return null;
        }
      } else {
        print('Google Routes API 錯誤: ${response.statusCode}');
        print('錯誤內容: ${response.body}');
        return null;
      }
    } catch (e) {
      print('計算路線時發生錯誤: $e');
      return null;
    }
  }

  /// 批量計算多個景點之間的路線（用於整天行程優化）
  /// [spots] 景點列表
  /// [travelMode] 交通方式
  Future<List<RouteInfo?>> computeMultipleRoutes({
    required List<Spot> spots,
    required String travelMode,
  }) async {
    if (spots.length < 2) return [];

    final routes = <RouteInfo?>[];
    
    for (int i = 0; i < spots.length - 1; i++) {
      final route = await computeRoute(
        origin: spots[i],
        destination: spots[i + 1],
        travelMode: travelMode,
      );
      routes.add(route);
      
      // 避免API請求過於頻繁
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    return routes;
  }

  /// 建構 Google Routes API 請求體
  Map<String, dynamic> _buildRouteRequest({
    required Spot origin,
    required Spot destination,
    required String travelMode,
    DateTime? departureTime,
  }) {
    final request = {
      'origin': {
        'location': {
          'latLng': {
            'latitude': origin.latitude,
            'longitude': origin.longitude,
          }
        }
      },
      'destination': {
        'location': {
          'latLng': {
            'latitude': destination.latitude,
            'longitude': destination.longitude,
          }
        }
      },
      'travelMode': travelMode,
      'routingPreference': 'TRAFFIC_AWARE',
      'computeAlternativeRoutes': false,
      'routeModifiers': {
        'avoidTolls': false,
        'avoidHighways': false,
        'avoidFerries': false,
      },
      'languageCode': 'zh-TW',
      'units': 'METRIC',
    };

    // 如果指定了出發時間，添加到請求中
    if (departureTime != null) {
      request['departureTime'] = departureTime.toIso8601String();
    }

    return request;
  }

  /// 解析持續時間字串 (如 "123s")
  int _parseDuration(String? durationString) {
    if (durationString == null) return 0;
    
    // 移除 's' 後綴並轉換為秒數
    final seconds = int.tryParse(durationString.replaceAll('s', '')) ?? 0;
    return (seconds / 60).round(); // 轉換為分鐘
  }

  /// 根據交通方式獲取預設的旅行時間（當API無法使用時的備用方案）
  static int getDefaultTravelTime(String travelMode, double distance) {
    // distance 以公里為單位
    switch (travelMode.toUpperCase()) {
      case 'WALK':
        return ((distance / 5.0) * 60).round(); // 步行速度約5km/h
      case 'BICYCLE':
        return ((distance / 15.0) * 60).round(); // 自行車速度約15km/h
      case 'TRANSIT':
        return ((distance / 25.0) * 60).round(); // 大眾運輸平均25km/h
      case 'DRIVE':
      default:
        return ((distance / 40.0) * 60).round(); // 駕駛平均40km/h（考慮城市交通）
    }
  }

  /// 將交通方式轉換為中文
  static String getTravelModeDisplayName(String travelMode) {
    switch (travelMode.toUpperCase()) {
      case 'WALK':
        return '步行';
      case 'BICYCLE':
        return '自行車';
      case 'TRANSIT':
        return '大眾運輸';
      case 'DRIVE':
        return '駕車';
      default:
        return '未知';
    }
  }

  /// 將中文交通方式轉換為API格式
  static String convertTravelModeToApi(String chineseTravelMode) {
    switch (chineseTravelMode) {
      case '步行':
        return 'WALK';
      case '自行車':
        return 'BICYCLE';
      case '大眾運輸':
        return 'TRANSIT';
      case '駕車':
      case '開車':
        return 'DRIVE';
      default:
        return 'DRIVE';
    }
  }
}

/// 路線資訊類別
class RouteInfo {
  /// 行程時間（分鐘）
  final int duration;
  
  /// 距離（公尺）
  final double distance;
  
  /// 靜態時間（不考慮交通狀況，分鐘）
  final int staticDuration;
  
  /// 路線的編碼折線
  final String polyline;
  
  /// 交通方式
  final String travelMode;

  RouteInfo({
    required this.duration,
    required this.distance,
    required this.staticDuration,
    required this.polyline,
    required this.travelMode,
  });

  /// 獲取格式化的距離文字
  String get formattedDistance {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)} 公里';
    } else {
      return '${distance.round()} 公尺';
    }
  }

  /// 獲取格式化的時間文字
  String get formattedDuration {
    if (duration >= 60) {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      if (minutes == 0) {
        return '${hours}小時';
      } else {
        return '${hours}小時${minutes}分鐘';
      }
    } else {
      return '${duration}分鐘';
    }
  }

  /// 轉換為JSON
  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'distance': distance,
      'staticDuration': staticDuration,
      'polyline': polyline,
      'travelMode': travelMode,
    };
  }

  /// 從JSON創建
  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      duration: json['duration'],
      distance: json['distance'],
      staticDuration: json['staticDuration'],
      polyline: json['polyline'],
      travelMode: json['travelMode'],
    );
  }

  @override
  String toString() {
    return 'RouteInfo(duration: ${formattedDuration}, distance: ${formattedDistance}, travelMode: ${GoogleRoutesService.getTravelModeDisplayName(travelMode)})';
  }
}
