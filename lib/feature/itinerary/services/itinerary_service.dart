import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import '../models/itinerary.dart';
import '../models/itinerary_day.dart';
import '../models/spot.dart';
import '../../collection/models/favorite_spot.dart';
import '../../common/services/firestore_service.dart';
import 'google_routes_service.dart';

class ItineraryService {
  final GoogleRoutesService _routesService = GoogleRoutesService();

  /// 獲取所有行程
  Future<List<Itinerary>> getAllItineraries() async {
    try {
      FirestoreService.requireLogin();
      
      final querySnapshot = await FirestoreService.getItinerariesCollection()
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Itinerary.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('獲取行程列表需要登入');
      }
      print('獲取行程列表時發生錯誤: $e');
      return [];
    }
  }

  /// 保存行程到Firestore
  Future<void> saveItinerary(Itinerary itinerary) async {
    try {
      FirestoreService.requireLogin();
      
      final itineraryData = itinerary.toFirestore();
      
      // 如果有ID，則更新；否則創建新的
      if (itinerary.id != null && itinerary.id!.isNotEmpty) {
        itineraryData['updatedAt'] = FieldValue.serverTimestamp();
        await FirestoreService.getItinerariesCollection()
            .doc(itinerary.id)
            .update(itineraryData);
      } else {
        itineraryData['createdAt'] = FieldValue.serverTimestamp();
        itineraryData['updatedAt'] = FieldValue.serverTimestamp();
        final docRef = await FirestoreService.getItinerariesCollection()
            .add(itineraryData);
        itinerary.id = docRef.id;
      }
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('保存行程需要登入');
      }
      print('保存行程時發生錯誤: $e');
      throw Exception('保存失敗：${FirestoreService.getErrorMessage(e)}');
    }
  }

  /// 刪除行程
  Future<void> deleteItinerary(String itineraryId) async {
    try {
      FirestoreService.requireLogin();
      
      await FirestoreService.getItinerariesCollection()
          .doc(itineraryId)
          .delete();
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('刪除行程需要登入');
      }
      print('刪除行程時發生錯誤: $e');
      throw Exception('刪除失敗：${FirestoreService.getErrorMessage(e)}');
    }
  }

  /// 將收藏的景點加入指定行程的指定天數
  Future<bool> addSpotToItinerary(
    String itineraryId, 
    int dayNumber, 
    FavoriteSpot favoriteSpot,
    {
      int? stayHours = 1,
      int? stayMinutes = 30,
      String? customStartTime,
    }
  ) async {
    try {
      FirestoreService.requireLogin();
      
      final doc = await FirestoreService.getItinerariesCollection()
          .doc(itineraryId)
          .get();
      
      if (!doc.exists) {
        print('找不到行程: $itineraryId');
        return false;
      }
      
      final data = doc.data() as Map<String, dynamic>;
      final itinerary = Itinerary.fromFirestore(data, doc.id);
      
      // 確保有足夠的行程天數
      while (itinerary.itineraryDays.length < dayNumber) {
        itinerary.itineraryDays.add(ItineraryDay(
          dayNumber: itinerary.itineraryDays.length + 1,
          transportation: itinerary.transportation,
          spots: [],
        ));
      }
      
      final targetDay = itinerary.itineraryDays[dayNumber - 1];
      
      // 檢查景點是否已存在
      final existingSpotIndex = targetDay.spots.indexWhere(
        (spot) => spot.id == favoriteSpot.id,
      );
      
      if (existingSpotIndex != -1) {
        print('景點已存在於此行程中');
        return false;
      }
      
      // 計算開始時間
      String startTime = customStartTime ?? '09:00';
      if (targetDay.spots.isNotEmpty && customStartTime == null) {
        final lastSpot = targetDay.spots.last;
        final lastEndTime = _calculateEndTime(lastSpot);
        startTime = _addMinutesToTime(lastEndTime, 30); // 預設間隔30分鐘
      }
      
      // 創建新景點
      final newSpot = Spot(
        id: favoriteSpot.id,
        name: favoriteSpot.name,
        imageUrl: favoriteSpot.imageUrl,
        order: targetDay.spots.length + 1,
        stayHours: stayHours ?? 1,
        stayMinutes: stayMinutes ?? 30,
        startTime: startTime,
        latitude: favoriteSpot.latitude,
        longitude: favoriteSpot.longitude,
        nextTransportation: '',
        travelTimeMinutes: 0,
      );
      
      targetDay.spots.add(newSpot);
      
      // 保存更新後的行程
      await saveItinerary(itinerary);
      
      print('✅ 成功添加景點 ${favoriteSpot.name} 到行程');
      return true;
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('加入行程需要登入');
      }
      print('添加景點到行程時發生錯誤: $e');
      return false;
    }
  }

  /// 將收藏的景點加入指定行程並計算路線，返回更新後的行程
  Future<Itinerary?> addSpotToItineraryWithRoutes(
    String itineraryId, 
    int dayNumber, 
    FavoriteSpot favoriteSpot,
    {
      int? stayHours = 1,
      int? stayMinutes = 30,
      String? customStartTime,
      bool calculateRoutes = true,
    }
  ) async {
    // 先添加景點
    final success = await addSpotToItinerary(
      itineraryId, 
      dayNumber, 
      favoriteSpot,
      stayHours: stayHours,
      stayMinutes: stayMinutes,
      customStartTime: customStartTime,
    );
    
    if (!success) return null;
    
    if (!calculateRoutes) {
      // 如果不需要計算路線，直接返回更新後的行程
      final doc = await FirestoreService.getItinerariesCollection()
          .doc(itineraryId)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Itinerary.fromFirestore(data, doc.id);
      }
      return null;
    }
    
    // 計算路線資訊並返回更新後的行程
    return await _updateRoutesForDay(itineraryId, dayNumber);
  }

  /// 更新指定天數的路線資訊，並返回更新後的行程
  Future<Itinerary?> _updateRoutesForDay(String itineraryId, int dayNumber) async {
    try {
      FirestoreService.requireLogin();
      
      final doc = await FirestoreService.getItinerariesCollection()
          .doc(itineraryId)
          .get();
      
      if (!doc.exists || dayNumber > (doc.data() as Map<String, dynamic>)['days']) {
        return null;
      }
      
      final data = doc.data() as Map<String, dynamic>;
      final itinerary = Itinerary.fromFirestore(data, doc.id);
      final targetDay = itinerary.itineraryDays[dayNumber - 1];
      final spots = List<Spot>.from(targetDay.spots);
      
      if (spots.length < 2) return itinerary;
      
      print('開始計算 ${itinerary.name} 第 $dayNumber 天的路線...');
      
      // 計算所有相鄰景點間的路線
      for (int i = 0; i < spots.length - 1; i++) {
        final currentSpot = spots[i];
        final nextSpot = spots[i + 1];
        
        // 獲取交通方式
        final travelMode = GoogleRoutesService.convertTravelModeToApi(targetDay.transportation);
        
        // 計算路線
        final routeInfo = await _routesService.computeRoute(
          origin: currentSpot,
          destination: nextSpot,
          travelMode: travelMode,
        );
        
        int travelTimeMinutes = 0;
        String transportationDisplay = GoogleRoutesService.getTravelModeDisplayName(travelMode);
        
        if (routeInfo != null) {
          travelTimeMinutes = routeInfo.duration;
          print('API 計算結果: ${routeInfo.formattedDuration}');
        } else {
          // 如果API失敗，使用預設計算
          final distance = _calculateDistance(
            currentSpot.latitude, currentSpot.longitude,
            nextSpot.latitude, nextSpot.longitude,
          );
          
          travelTimeMinutes = GoogleRoutesService.getDefaultTravelTime(travelMode, distance);
          print('使用預設計算: ${travelTimeMinutes}分鐘');
        }
        
        // 更新當前景點的交通資訊
        spots[i] = currentSpot.copyWith(
          nextTransportation: transportationDisplay,
          travelTimeMinutes: travelTimeMinutes,
        );
        
        // 更新下一個景點的開始時間
        if (i + 1 < spots.length) {
          final updatedStartTime = _calculateNextStartTime(spots[i], spots[i + 1].startTime);
          spots[i + 1] = spots[i + 1].copyWith(startTime: updatedStartTime);
        }
      }
      
      // 將更新後的景點列表重新賦值給 targetDay
      targetDay.spots = spots;
      
      // 保存更新後的行程
      await saveItinerary(itinerary);
      
      print('完成 ${itinerary.name} 第 $dayNumber 天的路線計算和保存');
      
      return itinerary;
      
    } catch (e) {
      if (e.toString().contains('此功能需要登入')) {
        throw Exception('計算路線需要登入');
      }
      print('更新路線資訊時發生錯誤: $e');
      return null;
    }
  }

  // 其他輔助方法
  String _calculateEndTime(Spot spot) {
    final startParts = spot.startTime.split(':');
    final startHour = int.parse(startParts[0]);
    final startMinute = int.parse(startParts[1]);
    
    final endMinute = startMinute + spot.stayMinutes + (spot.stayHours * 60);
    final endHour = startHour + (endMinute ~/ 60);
    final finalMinute = endMinute % 60;
    
    return '${endHour.toString().padLeft(2, '0')}:${finalMinute.toString().padLeft(2, '0')}';
  }

  String _addMinutesToTime(String time, int minutes) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    final totalMinutes = minute + minutes;
    final newHour = hour + (totalMinutes ~/ 60);
    final newMinute = totalMinutes % 60;
    
    return '${newHour.toString().padLeft(2, '0')}:${newMinute.toString().padLeft(2, '0')}';
  }

  String _calculateNextStartTime(Spot currentSpot, String originalStartTime) {
    final currentStartTime = _parseTime(currentSpot.startTime);
    final stayDuration = Duration(
      hours: currentSpot.stayHours,
      minutes: currentSpot.stayMinutes,
    );
    final travelDuration = Duration(minutes: currentSpot.travelTimeMinutes);
    
    final nextStartTime = currentStartTime.add(stayDuration).add(travelDuration);
    
    return '${nextStartTime.hour.toString().padLeft(2, '0')}:${nextStartTime.minute.toString().padLeft(2, '0')}';
  }

  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371;
    
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    
    final double a = 
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (3.14159265359 / 180.0);
  }
}
