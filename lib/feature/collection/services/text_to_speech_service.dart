import 'dart:convert';
import 'dart:html' as html;
import 'dart:async';
import 'package:http/http.dart' as http;

class TextToSpeechService {
  static const String _apiKey = 'AIzaSyBHEcitEBtZ7ezjlRCRgS-Hk1fm2SSY4is'; // 使用相同的 Google API Key
  static const String _baseUrl = 'https://texttospeech.googleapis.com/v1/text:synthesize';

  /// 將文字轉換為語音並播放
  static Future<void> textToSpeech(String text, {String languageCode = 'zh-TW'}) async {
    if (text.trim().isEmpty) {
      throw Exception('文字內容不能為空');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'input': {'text': text},
          'voice': {
            'languageCode': languageCode,
            'name': _getVoiceName(languageCode),
            'ssmlGender': 'FEMALE',
          },
          'audioConfig': {
            'audioEncoding': 'MP3',
            'effectsProfileId': ['small-bluetooth-speaker-class-device'],
            'pitch': 0,
            'speakingRate': 1.0,
          },
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final audioContent = responseData['audioContent'];
        
        if (audioContent != null && audioContent.isNotEmpty) {
          // 在 Web 平台播放音頻
          await _playAudio(audioContent);
        } else {
          throw Exception('未收到音頻數據');
        }
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error']?['message'] ?? '未知錯誤';
        throw Exception('Text-to-Speech API 錯誤: $errorMessage');
      }
    } catch (e) {
      print('Text-to-Speech error: $e');
      if (e.toString().contains('Text-to-Speech API 錯誤')) {
        rethrow;
      }
      throw Exception('語音播放失敗: $e');
    }
  }

  /// 根據語言代碼獲取合適的語音名稱
  static String _getVoiceName(String languageCode) {
    switch (languageCode) {
      case 'zh-TW':
        return 'cmn-TW-Standard-B';
      case 'zh-CN':
        return 'cmn-TW-Standard-B';
      case 'ja-JP':
        return 'ja-JP-Standard-C';
      case 'ko-KR':
        return 'ko-KR-Standard-A';
      case 'en-US':
      default:
        return 'en-US-Standard-C';
    }
  }

  /// 播放 Base64 編碼的音頻
  static Future<void> _playAudio(String base64Audio) async {
    try {
      // 創建 Blob URL
      final bytes = base64Decode(base64Audio);
      final blob = html.Blob([bytes], 'audio/mp3');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // 創建音頻元素並播放
      final audio = html.AudioElement()
        ..src = url
        ..autoplay = false
        ..preload = 'auto';

      // 設置樣式（隱藏）
      audio.style.display = 'none';
      
      // 將音頻元素添加到 DOM
      html.document.body?.append(audio);

      // 創建播放 Promise
      final playCompleter = Completer<void>();

      // 處理播放完成
      audio.onEnded.listen((_) {
        audio.remove();
        html.Url.revokeObjectUrl(url);
        if (!playCompleter.isCompleted) {
          playCompleter.complete();
        }
      });

      // 處理播放錯誤
      audio.onError.listen((error) {
        audio.remove();
        html.Url.revokeObjectUrl(url);
        if (!playCompleter.isCompleted) {
          playCompleter.completeError('音頻播放失敗');
        }
      });

      // 播放音頻
      try {
        await audio.play();
        // 等待播放完成
        await playCompleter.future;
      } catch (e) {
        audio.remove();
        html.Url.revokeObjectUrl(url);
        throw Exception('音頻播放失敗: $e');
      }

    } catch (e) {
      print('Audio playback error: $e');
      throw Exception('音頻播放失敗: $e');
    }
  }

  /// 檢測文字語言並選擇合適的語音
  static String _detectLanguage(String text) {
    // 中文字符檢測
    final chineseRegex = RegExp(r'[\u4e00-\u9fff]');
    if (chineseRegex.hasMatch(text)) {
      // 檢測常見的繁體中文字符或台灣地名
      final traditionalChars = RegExp(r'[萬與來說時間會過後沒錢開長們這個讓頭話國問點選擇臺灣縣市區鄉鎮村里號樓層]');
      final taiwanPlaces = RegExp(r'台灣|台北|新北|桃園|台中|台南|高雄|基隆|新竹|苗栗|彰化|南投|雲林|嘉義|屏東|宜蘭|花蓮|台東|澎湖|金門|連江');
      
      if (traditionalChars.hasMatch(text) || taiwanPlaces.hasMatch(text)) {
        return 'zh-TW';
      }
      return 'zh-CN';
    }
    
    // 日文字符檢測
    final japaneseRegex = RegExp(r'[\u3040-\u309f\u30a0-\u30ff]');
    if (japaneseRegex.hasMatch(text)) {
      return 'ja-JP';
    }
    
    // 韓文字符檢測
    final koreanRegex = RegExp(r'[\uac00-\ud7af]');
    if (koreanRegex.hasMatch(text)) {
      return 'ko-KR';
    }
    
    // 默認英文
    return 'en-US';
  }

  /// 智能語言檢測的文字轉語音
  static Future<void> smartTextToSpeech(String text) async {
    final languageCode = _detectLanguage(text);
    await textToSpeech(text, languageCode: languageCode);
  }
}
