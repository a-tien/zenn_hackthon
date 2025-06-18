class QuizQuestion {
  final String question;
  final List<String> options;
  final bool multiSelect;
  final int maxSelections; // 如果是多选题，最多可以选几项

  QuizQuestion({
    required this.question,
    required this.options, 
    this.multiSelect = false,
    this.maxSelections = 1,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'],
      options: List<String>.from(json['options']),
      multiSelect: json['multiSelect'] ?? false,
      maxSelections: json['maxSelections'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'multiSelect': multiSelect,
      'maxSelections': maxSelections,
    };
  }
}

class QuizData {
  static List<QuizQuestion> getQuizQuestions() {
    return [
      QuizQuestion(
        question: '關於出去旅遊我更偏好',
        options: ['獨自旅行', '三五好友一同旅行'],
        multiSelect: false,
      ),
      QuizQuestion(
        question: '我更喜歡',
        options: ['親近大自然', '探訪都市'],
        multiSelect: false,
      ),
      QuizQuestion(
        question: '你旅行的主要目的是什麼？',
        options: ['放鬆休息', '冒險體驗', '探索美食', '購物', '文化體驗'],
        multiSelect: true,
        maxSelections: 2,
      ),
      QuizQuestion(
        question: '你喜歡哪種旅遊步調？',
        options: ['悠閒慢活', '緊湊充實'],
        multiSelect: false,
      ),
      QuizQuestion(
        question: '你的旅遊預算傾向於？',
        options: ['經濟實惠', '豪華享受'],
        multiSelect: false,
      ),
      QuizQuestion(
        question: '你偏好哪種交通方式？',
        options: ['大眾運輸', '自駕(包車)'],
        multiSelect: false,
      ),
      QuizQuestion(
        question: '抵達一個景點時我認為最重要的是',
        options: ['到每一個角落拍照', '探索景點細節'],
        multiSelect: false,
      ),
      QuizQuestion(
        question: '請選擇您最感興趣的三項活動',
        options: ['爬山', '海上活動', '歷史古蹟', '博物館', '主題樂園', '購物商圈', '在地小吃', '咖啡店', '冒險活動', '溫泉', '兒童樂園'],
        multiSelect: true,
        maxSelections: 3,
      ),
    ];
  }
}
