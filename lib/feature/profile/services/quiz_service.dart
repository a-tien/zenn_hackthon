import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class QuizService {
  static const String _currentUserKey = 'current_user';
  
  // 根據測驗結果更新用戶的旅遊類型
  static Future<UserProfile?> updateTravelType(List<List<int>> answers) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    
    // 如果沒有登入用戶，返回null
    if (userJson == null) return null;
    
    // 解析用戶資料
    final user = UserProfile.fromJson(jsonDecode(userJson));
    
    // 根據答案計算旅遊類型
    final travelType = calculateQuizResult(answers);
    final updatedUser = user.copyWith(travelType: travelType);
    
    // 更新儲存的用戶資料
    await prefs.setString(_currentUserKey, jsonEncode(updatedUser.toJson()));
    
    return updatedUser;
  }
    // 計算測驗結果
  static String calculateQuizResult(List<List<int>> answers) {
    // 旅遊類型評分
    Map<String, int> scores = {
      '冒險型': 0,
      '文化型': 0,
      '休閒型': 0,
      '美食型': 0,
      '購物型': 0,
    };
    
    // 問題1: 關於出去旅遊我更偏好 (獨自/三五好友)
    if (answers[0].isNotEmpty && answers[0][0] != -1) {
      if (answers[0][0] == 0) { // 獨自旅行
        scores['冒險型'] = scores['冒險型']! + 2;
        scores['文化型'] = scores['文化型']! + 1;
      } else { // 三五好友一同旅行
        scores['休閒型'] = scores['休閒型']! + 2;
        scores['美食型'] = scores['美食型']! + 1;
        scores['購物型'] = scores['購物型']! + 1;
      }
    }
    
    // 問題2: 我更喜歡 (親近大自然/探訪都市)
    if (answers[1].isNotEmpty && answers[1][0] != -1) {
      if (answers[1][0] == 0) { // 親近大自然
        scores['冒險型'] = scores['冒險型']! + 2;
        scores['休閒型'] = scores['休閒型']! + 1;
      } else { // 探訪都市
        scores['文化型'] = scores['文化型']! + 1;
        scores['美食型'] = scores['美食型']! + 2;
        scores['購物型'] = scores['購物型']! + 2;
      }
    }
    
    // 問題3: 你旅行的主要目的是什麼？ (多選)
    if (answers[2].isNotEmpty) {
      for (int option in answers[2]) {
        switch (option) {
          case 0: // 放鬆休息
            scores['休閒型'] = scores['休閒型']! + 2;
            break;
          case 1: // 冒險體驗
            scores['冒險型'] = scores['冒險型']! + 3;
            break;
          case 2: // 探索美食
            scores['美食型'] = scores['美食型']! + 3;
            break;
          case 3: // 購物
            scores['購物型'] = scores['購物型']! + 3;
            break;
          case 4: // 文化體驗
            scores['文化型'] = scores['文化型']! + 3;
            break;
        }
      }
    }
    
    // 問題4: 你喜歡哪種旅遊步調？ (悠閒慢活/緊湊充實)
    if (answers[3].isNotEmpty && answers[3][0] != -1) {
      if (answers[3][0] == 0) { // 悠閒慢活
        scores['休閒型'] = scores['休閒型']! + 2;
        scores['美食型'] = scores['美食型']! + 1;
      } else { // 緊湊充實
        scores['冒險型'] = scores['冒險型']! + 2;
        scores['文化型'] = scores['文化型']! + 2;
        scores['購物型'] = scores['購物型']! + 1;
      }
    }
    
    // 問題5: 你的旅遊預算傾向於？ (經濟實惠/豪華享受)
    if (answers[4].isNotEmpty && answers[4][0] != -1) {
      if (answers[4][0] == 0) { // 經濟實惠
        scores['冒險型'] = scores['冒險型']! + 1;
        scores['文化型'] = scores['文化型']! + 1;
      } else { // 豪華享受
        scores['休閒型'] = scores['休閒型']! + 2;
        scores['美食型'] = scores['美食型']! + 2;
        scores['購物型'] = scores['購物型']! + 2;
      }
    }
    
    // 問題6: 你偏好哪種交通方式？ (大眾運輸/自駕)
    if (answers[5].isNotEmpty && answers[5][0] != -1) {
      if (answers[5][0] == 0) { // 大眾運輸
        scores['文化型'] = scores['文化型']! + 1;
      } else { // 自駕(包車)
        scores['冒險型'] = scores['冒險型']! + 1;
        scores['休閒型'] = scores['休閒型']! + 1;
      }
    }
    
    // 問題7: 抵達一個景點時我認為最重要的是 (到每一個角落拍照/探索景點細節)
    if (answers[6].isNotEmpty && answers[6][0] != -1) {
      if (answers[6][0] == 0) { // 到每一個角落拍照
        scores['冒險型'] = scores['冒險型']! + 1;
        scores['購物型'] = scores['購物型']! + 1;
      } else { // 探索景點細節
        scores['文化型'] = scores['文化型']! + 2;
      }
    }
    
    // 問題8: 請選擇您最感興趣的三項活動 (多選)
    if (answers[7].isNotEmpty) {
      for (int option in answers[7]) {
        switch (option) {
          case 0: // 爬山
            scores['冒險型'] = scores['冒險型']! + 2;
            break;
          case 1: // 海上活動
            scores['冒險型'] = scores['冒險型']! + 2;
            scores['休閒型'] = scores['休閒型']! + 1;
            break;
          case 2: // 歷史古蹟
            scores['文化型'] = scores['文化型']! + 2;
            break;
          case 3: // 博物館
            scores['文化型'] = scores['文化型']! + 2;
            break;
          case 4: // 主題樂園
            scores['休閒型'] = scores['休閒型']! + 2;
            break;
          case 5: // 購物商圈
            scores['購物型'] = scores['購物型']! + 2;
            break;
          case 6: // 在地小吃
            scores['美食型'] = scores['美食型']! + 2;
            break;
          case 7: // 咖啡店
            scores['休閒型'] = scores['休閒型']! + 1;
            scores['美食型'] = scores['美食型']! + 1;
            break;
          case 8: // 冒險活動
            scores['冒險型'] = scores['冒險型']! + 3;
            break;
          case 9: // 溫泉
            scores['休閒型'] = scores['休閒型']! + 2;
            break;
          case 10: // 兒童樂園
            scores['休閒型'] = scores['休閒型']! + 1;
            break;
        }
      }
    }
    
    // 找出得分最高的旅遊類型
    String highestType = '冒險型';
    int highestScore = scores['冒險型']!;
    
    scores.forEach((type, score) {
      if (score > highestScore) {
        highestType = type;
        highestScore = score;
      }
    });
    
    return highestType;
  }
  
  // 根據類型返回描述
  static String getTravelTypeDescription(String type) {
    switch (type) {
      case '冒險型':
        return '您是一位喜歡探索未知、尋找刺激的旅行者。您享受挑戰自我，體驗新奇和刺激的活動。您傾向於選擇非主流目的地，喜歡戶外活動和探險。建議您嘗試徒步旅行、潛水、攀岩等活動。';
      case '文化型':
        return '您是一位對歷史文化充滿好奇心的旅行者。您喜歡探索當地文化、歷史古蹟和藝術。您重視深度旅遊體驗，並希望了解不同地區的生活方式和傳統。建議您前往歷史名城、博物館、藝術展覽和文化遺產地。';
      case '休閒型':
        return '您是一位注重放鬆和舒適的旅行者。您喜歡輕鬆的步調，享受美麗的風景和舒適的環境。您旅行的主要目的是放鬆身心，遠離日常生活的壓力。建議您考慮度假勝地、溫泉、海灘度假和精品酒店。';
      case '美食型':
        return '您是一位熱愛美食的旅行者。您旅行的重要目的之一是探索當地美食和飲食文化。您願意花時間尋找正宗的當地餐廳，參加美食之旅或烹飪課程。建議您前往美食之都、特色餐廳和美食節慶活動。';
      case '購物型':
        return '您是一位喜歡逛街購物的旅行者。您享受在旅途中購買獨特的商品、紀念品或奢侈品。您可能會為了特定的購物體驗而選擇旅遊目的地。建議您前往知名購物城市、特色市集和奢侈品購物區。';
      default:
        return '您的旅遊偏好獨一無二。我們期待為您提供更符合您旅遊風格的旅行建議。';
    }
  }
}
