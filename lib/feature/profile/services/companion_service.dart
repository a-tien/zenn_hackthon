import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/travel_companion.dart';

class CompanionService {
  static const String _companionsKey = 'travel_companions';

  // 獲取所有旅伴
  static Future<List<TravelCompanion>> getAllCompanions() async {
    final prefs = await SharedPreferences.getInstance();
    final companionsJson = prefs.getStringList(_companionsKey) ?? [];

    return companionsJson
        .map((json) => TravelCompanion.fromJson(jsonDecode(json)))
        .toList();
  }

  // 新增旅伴
  static Future<void> addCompanion(TravelCompanion companion) async {
    final prefs = await SharedPreferences.getInstance();
    final companionsJson = prefs.getStringList(_companionsKey) ?? [];

    companionsJson.add(jsonEncode(companion.toJson()));
    await prefs.setStringList(_companionsKey, companionsJson);
  }

  // 更新旅伴
  static Future<void> updateCompanion(TravelCompanion companion) async {
    final prefs = await SharedPreferences.getInstance();
    final companionsJson = prefs.getStringList(_companionsKey) ?? [];

    final companionsList = companionsJson
        .map((json) => TravelCompanion.fromJson(jsonDecode(json)))
        .toList();

    final index = companionsList.indexWhere((c) => c.id == companion.id);
    if (index != -1) {
      companionsList[index] = companion;
      
      final updatedJson = companionsList
          .map((companion) => jsonEncode(companion.toJson()))
          .toList();
      
      await prefs.setStringList(_companionsKey, updatedJson);
    }
  }

  // 刪除旅伴
  static Future<void> deleteCompanion(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final companionsJson = prefs.getStringList(_companionsKey) ?? [];

    final companionsList = companionsJson
        .map((json) => TravelCompanion.fromJson(jsonDecode(json)))
        .toList();

    companionsList.removeWhere((c) => c.id == id);
    
    final updatedJson = companionsList
        .map((companion) => jsonEncode(companion.toJson()))
        .toList();
    
    await prefs.setStringList(_companionsKey, updatedJson);
  }

  // 根據ID獲取旅伴
  static Future<TravelCompanion?> getCompanionById(String id) async {
    final companions = await getAllCompanions();
    final index = companions.indexWhere((c) => c.id == id);
    
    if (index != -1) {
      return companions[index];
    }
    
    return null;
  }
}
