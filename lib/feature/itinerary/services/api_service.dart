import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/itinerary.dart';

class ApiService {
  static const String baseUrl = 'https://imageapp-774572899941.us-central1.run.app/';
  // static const String baseUrl = 'https://generate-itinerary-774572899941.us-central1.run.app/';

  /// 發送行程規劃請求
  static Future<Map<String, dynamic>> planItinerary({
    required bool hasBudget,
    required double minBudget,
    required double maxBudget,
    required String additionalRequirements,
    required Itinerary itinerary,
    required bool preserveExisting, // 新增 preserveItineraryDays
  }) async {
    try {
      // 構建API請求資料
      final requestBody = {
        'hasBudget': hasBudget,
        'minBudget': minBudget,
        'maxBudget': maxBudget,
        'additionalRequirements': additionalRequirements,
        'location': itinerary.destination,
        'days': itinerary.days,
        'transportation': itinerary.transportation,
        'preserveExisting': preserveExisting, // 新增 preserveExisting
        'itineraryDays': itinerary.itineraryDays, // 新增 itineraryDays
      };

      print('發送API請求: $requestBody');

      // 發送HTTP POST請求
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('API回應狀態碼: ${response.statusCode}');
      print('API回應內容: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        
        // 確保回傳的是 Map<String, dynamic>
        if (jsonResult is Map<String, dynamic>) {
          return jsonResult;
        } else {
          throw ApiException('API回傳格式錯誤：期望Map但收到${jsonResult.runtimeType}');
        }
      } else {
        throw ApiException('API請求失敗：HTTP ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw ApiException('網路連接錯誤：$e');
    } on FormatException catch (e) {
      throw ApiException('資料格式錯誤：$e');
    } catch (e) {
      throw ApiException('未知錯誤：$e');
    }
  }
}

/// API異常類
class ApiException implements Exception {
  final String message;
  
  ApiException(this.message);
  
  @override
  String toString() => 'ApiException: $message';
}