import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // 應用程式標題
  String get appTitle {
    switch (locale.languageCode) {
      case 'ja':
        return '旅行推薦';
      case 'zh':
        return '旅遊推薦';
      default:
        return 'Travel Recommendation';
    }
  }

  // 主頁標籤
  String get homeTab {
    switch (locale.languageCode) {
      case 'ja':
        return 'ホーム';
      case 'zh':
        return '首頁';
      default:
        return 'Home';
    }
  }

  // 探索標籤
  String get discoverTab {
    switch (locale.languageCode) {
      case 'ja':
        return '発見';
      case 'zh':
        return '探索';
      default:
        return 'Discover';
    }
  }

  // 行程標籤
  String get itineraryTab {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程';
      case 'zh':
        return '行程';
      default:
        return 'Itinerary';
    }
  }

  // 個人檔案標籤
  String get profileTab {
    switch (locale.languageCode) {
      case 'ja':
        return 'プロフィール';
      case 'zh':
        return '我的';
      default:
        return 'Profile';
    }
  }

  // 搜尋提示
  String get searchHint {
    switch (locale.languageCode) {
      case 'ja':
        return '目的地を検索...';
      case 'zh':
        return '搜尋目的地...';
      default:
        return 'Search for destinations...';
    }
  }

  // 熱門目的地
  String get popularDestinations {
    switch (locale.languageCode) {
      case 'ja':
        return '人気の目的地';
      case 'zh':
        return '熱門目的地';
      default:
        return 'Popular Destinations';
    }
  }

  // 最近瀏覽
  String get recentlyViewed {
    switch (locale.languageCode) {
      case 'ja':
        return '最近見た';
      case 'zh':
        return '最近瀏覽';
      default:
        return 'Recently Viewed';
    }
  }

  // 附近景點
  String get nearbyAttractions {
    switch (locale.languageCode) {
      case 'ja':
        return '近くの観光地';
      case 'zh':
        return '附近景點';
      default:
        return 'Nearby Attractions';
    }
  }

  // 歡迎訊息
  String get welcomeMessage {
    switch (locale.languageCode) {
      case 'ja':
        return 'こんにちは！今日はどこに行きますか？';
      case 'zh':
        return '您好！今天想去哪裡呢？';
      default:
        return 'Hello! Where would you like to go today?';
    }
  }

  // 探索新地點
  String get exploreNewPlaces {
    switch (locale.languageCode) {
      case 'ja':
        return '新しい場所を探索';
      case 'zh':
        return '探索新地點';
      default:
        return 'Explore New Places';
    }
  }

  // 查看更多
  String get seeMore {
    switch (locale.languageCode) {
      case 'ja':
        return 'もっと見る';
      case 'zh':
        return '查看更多';
      default:
        return 'See More';
    }
  }

  // 語言設定
  String get languageSettings {
    switch (locale.languageCode) {
      case 'ja':
        return '言語設定';
      case 'zh':
        return '語言設定';
      default:
        return 'Language Settings';
    }
  }

  // 日文
  String get japanese {
    switch (locale.languageCode) {
      case 'ja':
        return '日本語';
      case 'zh':
        return '日文';
      default:
        return 'Japanese';
    }
  }

  // 中文
  String get chinese {
    switch (locale.languageCode) {
      case 'ja':
        return '中国語';
      case 'zh':
        return '繁體中文';
      default:
        return 'Chinese';
    }
  }

  // 英文
  String get english {
    switch (locale.languageCode) {
      case 'ja':
        return '英語';
      case 'zh':
        return '英文';
      default:
        return 'English';
    }
  }

  // 探索頁面相關字串
  // 選地區
  String get selectArea {
    switch (locale.languageCode) {
      case 'ja':
        return 'エリア選択';
      case 'zh':
        return '選地區';
      default:
        return 'Select Area';
    }
  }

  // 搜尋地點、美食、景點
  String get searchPlacesHint {
    switch (locale.languageCode) {
      case 'ja':
        return '場所、グルメ、観光地を検索';
      case 'zh':
        return '搜尋地點、美食、景點';
      default:
        return 'Search places, food, attractions';
    }
  }

  // 探索這個區域
  String get exploreThisArea {
    switch (locale.languageCode) {
      case 'ja':
        return 'このエリアを探索';
      case 'zh':
        return '探索這個區域';
      default:
        return 'Explore This Area';
    }
  }

  // 載入中
  String get loading {
    switch (locale.languageCode) {
      case 'ja':
        return '読み込み中...';
      case 'zh':
        return '載入中...';
      default:
        return 'Loading...';
    }
  }

  // 地圖視圖
  String get mapView {
    switch (locale.languageCode) {
      case 'ja':
        return '地図表示';
      case 'zh':
        return '地圖視圖';
      default:
        return 'Map View';
    }
  }

  // 列表視圖
  String get listView {
    switch (locale.languageCode) {
      case 'ja':
        return 'リスト表示';
      case 'zh':
        return '列表視圖';
      default:
        return 'List View';
    }
  }

  // 目前位置
  String get currentLocation {
    switch (locale.languageCode) {
      case 'ja':
        return '現在位置';
      case 'zh':
        return '目前位置';
      default:
        return 'Current Location';
    }
  }

  // 景點類型
  String get attractions {
    switch (locale.languageCode) {
      case 'ja':
        return '観光地';
      case 'zh':
        return '景點';
      default:
        return 'Attractions';
    }
  }

  String get restaurants {
    switch (locale.languageCode) {
      case 'ja':
        return 'レストラン';
      case 'zh':
        return '餐廳';
      default:
        return 'Restaurants';
    }
  }

  String get shopping {
    switch (locale.languageCode) {
      case 'ja':
        return 'ショッピング';
      case 'zh':
        return '購物';
      default:
        return 'Shopping';
    }
  }

  String get hotels {
    switch (locale.languageCode) {
      case 'ja':
        return 'ホテル';
      case 'zh':
        return '酒店';
      default:
        return 'Hotels';
    }
  }

  String get transport {
    switch (locale.languageCode) {
      case 'ja':
        return '交通';
      case 'zh':
        return '交通';
      default:
        return 'Transport';
    }
  }

  String get entertainment {
    switch (locale.languageCode) {
      case 'ja':
        return 'エンターテイメント';
      case 'zh':
        return '娛樂';
      default:
        return 'Entertainment';
    }
  }

  // 排序選項
  String get sortByRating {
    switch (locale.languageCode) {
      case 'ja':
        return '評価順';
      case 'zh':
        return '評分排序';
      default:
        return 'Sort by Rating';
    }
  }

  String get sortByDistance {
    switch (locale.languageCode) {
      case 'ja':
        return '距離順';
      case 'zh':
        return '距離排序';
      default:
        return 'Sort by Distance';
    }
  }

  // 獲取本地化的景點類型名稱
  String getSpotTypeName(String englishName) {
    switch (englishName) {
      case '全選':
        switch (locale.languageCode) {
          case 'ja':
            return 'すべて';
          case 'zh':
            return '全選';
          default:
            return 'All';
        }
      case '景點/觀光':
        switch (locale.languageCode) {
          case 'ja':
            return '観光スポット';
          case 'zh':
            return '景點/觀光';
          default:
            return 'Attractions';
        }
      case '美食/餐廳':
        switch (locale.languageCode) {
          case 'ja':
            return 'グルメ/レストラン';
          case 'zh':
            return '美食/餐廳';
          default:
            return 'Food/Restaurants';
        }
      case '購物':
        switch (locale.languageCode) {
          case 'ja':
            return 'ショッピング';
          case 'zh':
            return '購物';
          default:
            return 'Shopping';
        }
      case '住宿':
        switch (locale.languageCode) {
          case 'ja':
            return '宿泊施設';
          case 'zh':
            return '住宿';
          default:
            return 'Accommodation';
        }
      case '交通':
        switch (locale.languageCode) {
          case 'ja':
            return '交通';
          case 'zh':
            return '交通';
          default:
            return 'Transport';
        }
      case '醫療/健康':
        switch (locale.languageCode) {
          case 'ja':
            return '医療/健康';
          case 'zh':
            return '醫療/健康';
          default:
            return 'Health/Medical';
        }
      case '教育/宗教':
        switch (locale.languageCode) {
          case 'ja':
            return '教育/宗教';
          case 'zh':
            return '教育/宗教';
          default:
            return 'Education/Religion';
        }
      case '服務/金融':
        switch (locale.languageCode) {
          case 'ja':
            return 'サービス/金融';
          case 'zh':
            return '服務/金融';
          default:
            return 'Services/Finance';
        }
      case '娛樂/夜生活':
        switch (locale.languageCode) {
          case 'ja':
            return 'エンターテイメント/ナイトライフ';
          case 'zh':
            return '娛樂/夜生活';
          default:
            return 'Entertainment/Nightlife';
        }
      case '汽車服務':
        switch (locale.languageCode) {
          case 'ja':
            return '自動車サービス';
          case 'zh':
            return '汽車服務';
          default:
            return 'Car Services';
        }
      case '其他服務':
        switch (locale.languageCode) {
          case 'ja':
            return 'その他のサービス';
          case 'zh':
            return '其他服務';
          default:
            return 'Other Services';
        }
      default:
        return englishName;
    }
  }

  // 確定按鈕
  String get confirm {
    switch (locale.languageCode) {
      case 'ja':
        return '確定';
      case 'zh':
        return '確定';
      default:
        return 'Confirm';
    }
  }

  // 取消按鈕
  String get cancel {
    switch (locale.languageCode) {
      case 'ja':
        return 'キャンセル';
      case 'zh':
        return '取消';
      default:
        return 'Cancel';
    }
  }

  // 行程頁面相關字串
  // 您的行程
  String get yourItineraries {
    switch (locale.languageCode) {
      case 'ja':
        return 'あなたの旅程';
      case 'zh':
        return '您的行程';
      default:
        return 'Your Itineraries';
    }
  }

  // 目前尚無行程
  String get noItinerariesMessage {
    switch (locale.languageCode) {
      case 'ja':
        return '現在旅程がありません！下のボタンをクリックして最初の旅程を作成してください。';
      case 'zh':
        return '目前沒有行程！點擊下方按鈕建立你的第一個行程。';
      default:
        return 'No itineraries yet! Click the button below to create your first itinerary.';
    }
  }

  // 建立新行程
  String get createNewItinerary {
    switch (locale.languageCode) {
      case 'ja':
        return '新しい旅程を作成';
      case 'zh':
        return '建立新行程';
      default:
        return 'Create New Itinerary';
    }
  }

  // 我的行程 (標題用)
  String get myItineraries {
    switch (locale.languageCode) {
      case 'ja':
        return '私の旅程';
      case 'zh':
        return '我的行程';
      default:
        return 'My Itineraries';
    }
  }

  // 查看行程列表
  String get viewItineraryList {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程リストを表示';
      case 'zh':
        return '查看行程列表';
      default:
        return 'View Itinerary List';
    }
  }

  // 行程詳情
  String get itineraryDetails {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程詳細';
      case 'zh':
        return '行程詳情';
      default:
        return 'Itinerary Details';
    }
  }

  // 新增行程
  String get addItinerary {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程を追加';
      case 'zh':
        return '新增行程';
      default:
        return 'Add Itinerary';
    }
  }

  // 編輯行程
  String get editItinerary {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程を編集';
      case 'zh':
        return '編輯行程';
      default:
        return 'Edit Itinerary';
    }
  }

  // 刪除行程
  String get deleteItinerary {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程を削除';
      case 'zh':
        return '刪除行程';
      default:
        return 'Delete Itinerary';
    }
  }

  // 天數單位
  String get days {
    switch (locale.languageCode) {
      case 'ja':
        return '日';
      case 'zh':
        return '天';
      default:
        return 'days';
    }
  }

  // 日期格式分隔符
  String get dateSeparator {
    switch (locale.languageCode) {
      case 'ja':
        return '/';
      case 'zh':
        return '/';
      default:
        return '/';
    }
  }

  // 新增行程頁面相關字串
  // 行程名稱
  String get itineraryName {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程名';
      case 'zh':
        return '行程名稱';
      default:
        return 'Itinerary Name';
    }
  }

  // 請輸入此次行程的名稱
  String get enterItineraryNameHint {
    switch (locale.languageCode) {
      case 'ja':
        return 'この旅程の名前を入力してください';
      case 'zh':
        return '請輸入此次行程的名稱';
      default:
        return 'Please enter the name of this itinerary';
    }
  }

  // 請輸入行程名稱
  String get pleaseEnterItineraryName {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程名を入力してください';
      case 'zh':
        return '請輸入行程名稱';
      default:
        return 'Please enter itinerary name';
    }
  }

  // 交通方式
  String get transportation {
    switch (locale.languageCode) {
      case 'ja':
        return '交通手段';
      case 'zh':
        return '交通方式';
      default:
        return 'Transportation';
    }
  }

  // 旅行類型
  String get travelType {
    switch (locale.languageCode) {
      case 'ja':
        return '旅行タイプ';
      case 'zh':
        return '旅行類型';
      default:
        return 'Travel Type';
    }
  }

  // 交通方式選項
  String getTransportationOption(String option) {
    switch (option) {
      case '自行安排':
        switch (locale.languageCode) {
          case 'ja':
            return '自分で手配';
          case 'zh':
            return '自行安排';
          default:
            return 'Self-arranged';
        }
      case '開車':
        switch (locale.languageCode) {
          case 'ja':
            return '車';
          case 'zh':
            return '開車';
          default:
            return 'Driving';
        }
      case '大眾運輸':
        switch (locale.languageCode) {
          case 'ja':
            return '公共交通';
          case 'zh':
            return '大眾运輸';
          default:
            return 'Public Transport';
        }
      case '步行':
        switch (locale.languageCode) {
          case 'ja':
            return '徒歩';
          case 'zh':
            return '步行';
          default:
            return 'Walking';
        }
      case '機車':
        switch (locale.languageCode) {
          case 'ja':
            return 'バイク';
          case 'zh':
            return '機車';
          default:
            return 'Motorcycle';
        }
      default:
        return option;
    }
  }

  // 旅行類型選項
  String getTravelTypeOption(String type) {
    switch (type) {
      case '家庭旅遊':
        switch (locale.languageCode) {
          case 'ja':
            return '家族旅行';
          case 'zh':
            return '家庭旅遊';
          default:
            return 'Family Travel';
        }
      case '好友出遊':
        switch (locale.languageCode) {
          case 'ja':
            return '友人旅行';
          case 'zh':
            return '好友出遊';
          default:
            return 'Friends Travel';
        }
      case '情侶出遊':
        switch (locale.languageCode) {
          case 'ja':
            return 'カップル旅行';
          case 'zh':
            return '情侶出遊';
          default:
            return 'Couple Travel';
        }
      case '長輩出遊':
        switch (locale.languageCode) {
          case 'ja':
            return 'シニア旅行';
          case 'zh':
            return '長輩出遊';
          default:
            return 'Senior Travel';
        }
      case '無障礙出遊':
        switch (locale.languageCode) {
          case 'ja':
            return 'バリアフリー旅行';
          case 'zh':
            return '無障礙出遊';
          default:
            return 'Accessible Travel';
        }
      case '個人獨旅':
        switch (locale.languageCode) {
          case 'ja':
            return '一人旅';
          case 'zh':
            return '個人獨旅';
          default:
            return 'Solo Travel';
        }
      default:
        return type;
    }
  }

  // 保存
  String get save {
    switch (locale.languageCode) {
      case 'ja':
        return '保存';
      case 'zh':
        return '保存';
      default:
        return 'Save';
    }
  }

  // 使用日期範圍
  String get useDateRange {
    switch (locale.languageCode) {
      case 'ja':
        return '日付範囲を使用';
      case 'zh':
        return '使用日期範圍';
      default:
        return 'Use Date Range';
    }
  }

  // 天數
  String get numberOfDays {
    switch (locale.languageCode) {
      case 'ja':
        return '日数';
      case 'zh':
        return '天數';
      default:
        return 'Number of Days';
    }
  }

  // 開始日期
  String get startDate {
    switch (locale.languageCode) {
      case 'ja':
        return '開始日';
      case 'zh':
        return '開始日期';
      default:
        return 'Start Date';
    }
  }

  // 結束日期
  String get endDate {
    switch (locale.languageCode) {
      case 'ja':
        return '終了日';
      case 'zh':
        return '結束日期';
      default:
        return 'End Date';
    }
  }

  // 行程日程
  String get itinerarySchedule {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程スケジュール';
      case 'zh':
        return '行程日程';
      default:
        return 'Itinerary Schedule';
    }
  }

  // 天數
  String get daysLabel {
    switch (locale.languageCode) {
      case 'ja':
        return '日数';
      case 'zh':
        return '天數';
      default:
        return 'Days';
    }
  }

  // 日期
  String get dateLabel {
    switch (locale.languageCode) {
      case 'ja':
        return '日付';
      case 'zh':
        return '日期';
      default:
        return 'Date';
    }
  }

  // 目的地
  String get destinations {
    switch (locale.languageCode) {
      case 'ja':
        return '目的地';
      case 'zh':
        return '目的地';
      default:
        return 'Destinations';
    }
  }

  // 新增目的地
  String get addDestination {
    switch (locale.languageCode) {
      case 'ja':
        return '目的地を追加+';
      case 'zh':
        return '新增目的地+';
      default:
        return 'Add Destination+';
    }
  }

  // 新增
  String get add {
    switch (locale.languageCode) {
      case 'ja':
        return '追加+';
      case 'zh':
        return '新增+';
      default:
        return 'Add+';
    }
  }

  // 主要交通方式
  String get mainTransportation {
    switch (locale.languageCode) {
      case 'ja':
        return '主要交通手段';
      case 'zh':
        return '主要交通方式';
      default:
        return 'Main Transportation';
    }
  }

  // 旅遊型態
  String get travelPattern {
    switch (locale.languageCode) {
      case 'ja':
        return '旅行スタイル';
      case 'zh':
        return '旅遊型態';
      default:
        return 'Travel Style';
    }
  }

  // 建立行程
  String get createItinerary {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程を作成';
      case 'zh':
        return '建立行程';
      default:
        return 'Create Itinerary';
    }
  }

  // 請至少選擇一個目的地
  String get pleaseSelectAtLeastOneDestination {
    switch (locale.languageCode) {
      case 'ja':
        return '少なくとも1つの目的地を選択してください';
      case 'zh':
        return '請至少選擇一個目的地';
      default:
        return 'Please select at least one destination';
    }
  }

  // 建立失敗
  String getCreateFailed(String error) {
    switch (locale.languageCode) {
      case 'ja':
        return '作成に失敗しました: $error';
      case 'zh':
        return '建立失敗: $error';
      default:
        return 'Create failed: $error';
    }
  }

  // 導航功能尚未實現
  String get navigationNotImplementedYet {
    switch (locale.languageCode) {
      case 'ja':
        return 'ナビゲーション機能はまだ実装されていません';
      case 'zh':
        return '導航功能尚未實現';
      default:
        return 'Navigation feature not implemented yet';
    }
  }

  // 行程規劃前準備
  String get tripPrePlanning {
    switch (locale.languageCode) {
      case 'ja':
        return '行程計画前準備';
      case 'zh':
        return '行程規劃前準備';
      default:
        return 'Trip Pre-Planning';
    }
  }

  // 行程建議
  String get itinerarySuggestions {
    switch (locale.languageCode) {
      case 'ja':
        return '行程提案';
      case 'zh':
        return '行程建議';
      default:
        return 'Itinerary Suggestions';
    }
  }

  // 關閉
  String get close {
    switch (locale.languageCode) {
      case 'ja':
        return '閉じる';
      case 'zh':
        return '關閉';
      default:
        return 'Close';
    }
  }

  // 智慧行程助理頁面相關
  String get tripAssistant {
    switch (locale.languageCode) {
      case 'ja':
        return '行程計画アシスタント';
      case 'zh':
        return '行程規劃助理';
      default:
        return 'Trip Assistant';
    }
  }

  String get welcomeToTripAssistant {
    switch (locale.languageCode) {
      case 'ja':
        return 'スマート行程計画アシスタントへようこそ';
      case 'zh':
        return '歡迎使用智能行程規劃助理';
      default:
        return 'Welcome to Smart Trip Assistant';
    }
  }

  String get tripAssistantDescription {
    switch (locale.languageCode) {
      case 'ja':
        return 'お客様の行程の好みと目的地情報に基づいて、パーソナライズされた旅行計画サービスを提供いたします。';
      case 'zh':
        return '我們將根據您的行程偏好和目的地資訊，提供個性化的旅行規劃服務。';
      default:
        return 'We will provide personalized travel planning services based on your itinerary preferences and destination information.';
    }
  }

  String get recommendSpots {
    switch (locale.languageCode) {
      case 'ja':
        return 'スポット推薦';
      case 'zh':
        return '推薦景點';
      default:
        return 'Recommend Spots';
    }
  }

  String get recommendSpotsDescription {
    switch (locale.languageCode) {
      case 'ja':
        return 'お客様の好みに基づいて、近くの価値ある観光地やグルメを推薦いたします。';
      case 'zh':
        return '基於您的喜好，為您推薦附近值得一遊的景點和美食。';
      default:
        return 'Based on your preferences, we recommend nearby attractions and cuisine worth visiting.';
    }
  }

  String get completePlanning {
    switch (locale.languageCode) {
      case 'ja':
        return '完全計画';
      case 'zh':
        return '完整規劃';
      default:
        return 'Complete Planning';
    }
  }

  String get completePlanningDescription {
    switch (locale.languageCode) {
      case 'ja':
        return 'スポット配置、交通手段、時間計画を含む、お客様の全行程をデザインいたします。';
      case 'zh':
        return '讓我們為您設計整個行程，包括景點安排、交通方式和時間規劃。';
      default:
        return 'Let us design your entire itinerary, including spot arrangements, transportation, and time planning.';
    }
  }

  String get choosePlanningMethod {
    switch (locale.languageCode) {
      case 'ja':
        return '計画方法を選択してください';
      case 'zh':
        return '請選擇規劃方式';
      default:
        return 'Please Choose Planning Method';
    }
  }

  String get overwriteExistingItinerary {
    switch (locale.languageCode) {
      case 'ja':
        return '既存の行程を上書き';
      case 'zh':
        return '覆蓋現有行程';
      default:
        return 'Overwrite Existing Itinerary';
    }
  }

  String get keepSelectedItinerary {
    switch (locale.languageCode) {
      case 'ja':
        return '選択済みの行程を保持';
      case 'zh':
        return '保留已選的行程';
      default:
        return 'Keep Selected Itinerary';
    }
  }

  // AI 規劃結果頁面相關
  String get aiPlanningResult {
    switch (locale.languageCode) {
      case 'ja':
        return 'スマート計画結果';
      case 'zh':
        return '智能規劃結果';
      default:
        return 'AI Planning Result';
    }
  }

  String get itineraryUpdatedSuccessfully {
    switch (locale.languageCode) {
      case 'ja':
        return '行程が正常に更新されました';
      case 'zh':
        return '行程已成功更新';
      default:
        return 'Itinerary updated successfully';
    }
  }

  String get updateItineraryFailed {
    switch (locale.languageCode) {
      case 'ja':
        return '行程の更新に失敗しました';
      case 'zh':
        return '更新行程失敗';
      default:
        return 'Failed to update itinerary';
    }
  }

  String get userIdOrItineraryIdEmpty {
    switch (locale.languageCode) {
      case 'ja':
        return 'ユーザーIDまたは行程IDが空です、Firestoreを更新できません';
      case 'zh':
        return '使用者ID或行程ID為空，無法更新Firestore';
      default:
        return 'User ID or Itinerary ID is empty, cannot update Firestore';
    }
  }

  String get firestoreWriteSuccess {
    switch (locale.languageCode) {
      case 'ja':
        return 'Firestoreへの書き込み成功';
      case 'zh':
        return '成功寫入 Firestore';
      default:
        return 'Successfully written to Firestore';
    }
  }

  String get firestoreUpdateFailed {
    switch (locale.languageCode) {
      case 'ja':
        return 'Firestoreの更新に失敗しました';
      case 'zh':
        return 'Firestore 更新失敗';
      default:
        return 'Firestore update failed';
    }
  }

  String get comingSoon {
    switch (locale.languageCode) {
      case 'ja':
        return 'この機能は近日公開予定です';
      case 'zh':
        return '此功能即將推出';
      default:
        return 'This feature is coming soon';
    }
  }

  String get chatWithAiAssistant {
    switch (locale.languageCode) {
      case 'ja':
        return 'スマートアシスタントとチャット';
      case 'zh':
        return '與智能助理聊聊';
      default:
        return 'Chat with AI Assistant';
    }
  }

  String get discardItinerarySuggestion {
    switch (locale.languageCode) {
      case 'ja':
        return 'この行程提案を破棄';
      case 'zh':
        return '捨棄此行程建議';
      default:
        return 'Discard Itinerary Suggestion';
    }
  }

  String get updateToMyItinerary {
    switch (locale.languageCode) {
      case 'ja':
        return '私の行程に更新';
      case 'zh':
        return '更新至我的行程';
      default:
        return 'Update to My Itinerary';
    }
  }

  // 規劃選項對話框相關
  String get planningOptionTitle {
    switch (locale.languageCode) {
      case 'ja':
        return '計画オプション';
      case 'zh':
        return '規劃選項';
      default:
        return 'Planning Options';
    }
  }

  String get overwriteOption {
    switch (locale.languageCode) {
      case 'ja':
        return '既存の行程を上書き';
      case 'zh':
        return '覆蓋現有行程';
      default:
        return 'Overwrite Existing';
    }
  }

  String get overwriteDescription {
    switch (locale.languageCode) {
      case 'ja':
        return '全ての選択済みスポットを削除し、新しい行程を作成します';
      case 'zh':
        return '刪除所有已選的景點，重新規劃整個行程';
      default:
        return 'Remove all selected spots and create a new itinerary';
    }
  }

  String get preserveOption {
    switch (locale.languageCode) {
      case 'ja':
        return '選択済み行程を保持';
      case 'zh':
        return '保留已選行程';
      default:
        return 'Keep Selected Items';
    }
  }

  String get preserveDescription {
    switch (locale.languageCode) {
      case 'ja':
        return '選択済みスポットを基に、追加の行程を提案します';
      case 'zh':
        return '根據已選景點，繼續規劃其他景點和活動';
      default:
        return 'Continue planning based on selected spots';
    }
  }

  // 常用按鈕與對話框
  String get edit {
    switch (locale.languageCode) {
      case 'ja':
        return '編集';
      case 'zh':
        return '編輯';
      default:
        return 'Edit';
    }
  }

  String get delete {
    switch (locale.languageCode) {
      case 'ja':
        return '削除';
      case 'zh':
        return '刪除';
      default:
        return 'Delete';
    }
  }

  String get remove {
    switch (locale.languageCode) {
      case 'ja':
        return '削除';
      case 'zh':
        return '移除';
      default:
        return 'Remove';
    }
  }

  String get confirmDelete {
    switch (locale.languageCode) {
      case 'ja':
        return '削除の確認';
      case 'zh':
        return '確認刪除';
      default:
        return 'Confirm Delete';
    }
  }

  String get confirmRemove {
    switch (locale.languageCode) {
      case 'ja':
        return '削除の確認';
      case 'zh':
        return '確認移除';
      default:
        return 'Confirm Remove';
    }
  }

  String get deleteCollectionConfirmation {
    switch (locale.languageCode) {
      case 'ja':
        return '確定要刪除此收藏集嗎？此操作無法復原。';
      case 'zh':
        return '確定要刪除此收藏集嗎？此操作無法復原。';
      default:
        return 'Are you sure you want to delete this collection? This action cannot be undone.';
    }
  }

  String get loadingNearbySpots {
    switch (locale.languageCode) {
      case 'ja':
        return '近くのスポットを読み込み中...';
      case 'zh':
        return '正在載入附近景點...';
      default:
        return 'Loading nearby spots...';
    }
  }

  String get reload {
    switch (locale.languageCode) {
      case 'ja':
        return '再読み込み';
      case 'zh':
        return '重新載入';
      default:
        return 'Reload';
    }
  }

  String get noNearbySpots {
    switch (locale.languageCode) {
      case 'ja':
        return '近くのスポットデータがありません';
      case 'zh':
        return '暫無附近景點資料';
      default:
        return 'No nearby spots data available';
    }
  }

  String get loadSpotsError {
    switch (locale.languageCode) {
      case 'ja':
        return 'スポットの読み込みに失敗しました。ネットワーク接続を確認してください';
      case 'zh':
        return '載入景點失敗，請檢查網路連線';
      default:
        return 'Failed to load spots. Please check your network connection';
    }
  }

  String get addToFavorites {
    switch (locale.languageCode) {
      case 'ja':
        return 'お気に入りに追加';
      case 'zh':
        return '加入收藏';
      default:
        return 'Add to Favorites';
    }
  }

  String get addToItinerary {
    switch (locale.languageCode) {
      case 'ja':
        return '行程に追加';
      case 'zh':
        return '加入行程';
      default:
        return 'Add to Itinerary';
    }
  }

  String get addToThisItinerary {
    switch (locale.languageCode) {
      case 'ja':
        return 'この行程に追加';
      case 'zh':
        return '加入此行程';
      default:
        return 'Add to This Itinerary';
    }
  }

  String get myCompanions {
    switch (locale.languageCode) {
      case 'ja':
        return '私の旅行仲間';
      case 'zh':
        return '我的旅伴';
      default:
        return 'My Companions';
    }
  }

  String get addCompanion {
    switch (locale.languageCode) {
      case 'ja':
        return '旅行仲間を追加';
      case 'zh':
        return '新增旅伴';
      default:
        return 'Add Companion';
    }
  }

  String get register {
    switch (locale.languageCode) {
      case 'ja':
        return '登録';
      case 'zh':
        return '註冊';
      default:
        return 'Register';
    }
  }

  String get alreadyHaveAccount {
    switch (locale.languageCode) {
      case 'ja':
        return 'すでにアカウントをお持ちですか？';
      case 'zh':
        return '已有帳號？';
      default:
        return 'Already have an account?';
    }
  }

  String get goToLogin {
    switch (locale.languageCode) {
      case 'ja':
        return 'ログインへ';
      case 'zh':
        return '前往登入';
      default:
        return 'Go to Login';
    }
  }

  String get travelQuiz {
    switch (locale.languageCode) {
      case 'ja':
        return '旅行タイプクイズ';
      case 'zh':
        return '旅遊類型測驗';
      default:
        return 'Travel Quiz';
    }
  }

  String get quizResult {
    switch (locale.languageCode) {
      case 'ja':
        return 'クイズ結果';
      case 'zh':
        return '測驗結果';
      default:
        return 'Quiz Result';
    }
  }

  String get previous {
    switch (locale.languageCode) {
      case 'ja':
        return '前へ';
      case 'zh':
        return '上一題';
      default:
        return 'Previous';
    }
  }

  String get next {
    switch (locale.languageCode) {
      case 'ja':
        return '次へ';
      case 'zh':
        return '下一題';
      default:
        return 'Next';
    }
  }

  String get saveFailed {
    switch (locale.languageCode) {
      case 'ja':
        return '保存に失敗しました';
      case 'zh':
        return '保存失敗';
      default:
        return 'Save failed';
    }
  }

  String get submitQuizFailed {
    switch (locale.languageCode) {
      case 'ja':
        return 'クイズの提出に失敗しました';
      case 'zh':
        return '提交測驗失敗';
      default:
        return 'Failed to submit quiz';
    }
  }

  String foundSpotsCount(int count) {
    switch (locale.languageCode) {
      case 'ja':
        return '${count}個のスポットが見つかりました';
      case 'zh':
        return '找到 $count 個景點';
      default:
        return 'Found $count spots';
    }
  }

  String deleteCompanionConfirmation(String name) {
    switch (locale.languageCode) {
      case 'ja':
        return '旅行仲間「$name」を削除しますか？';
      case 'zh':
        return '確定要刪除旅伴 "$name" 嗎？';
      default:
        return 'Are you sure you want to delete companion "$name"?';
    }
  }

  String removeFromCollectionConfirmation(String collectionName, String spotName) {
    switch (locale.languageCode) {
      case 'ja':
        return '「$collectionName」から「$spotName」を削除しますか？';
      case 'zh':
        return '確定要從「$collectionName」移除「$spotName」嗎？';
      default:
        return 'Are you sure you want to remove "$spotName" from "$collectionName"?';
    }
  }

  String addedToItinerary(String spotName) {
    switch (locale.languageCode) {
      case 'ja':
        return '$spotNameを行程に追加しました';
      case 'zh':
        return '已將 $spotName 加入行程';
      default:
        return 'Added $spotName to itinerary';
    }
  }

  // 行程頁面相關
  String getItineraryCount(int count) {
    switch (locale.languageCode) {
      case 'ja':
        return '行程数: $count';
      case 'zh':
        return '行程數量: $count';
      default:
        return 'Itinerary count: $count';
    }
  }

  String get itineraryContent {
    switch (locale.languageCode) {
      case 'ja':
        return '行程内容';
      case 'zh':
        return '行程內容';
      default:
        return 'Itinerary Content';
    }
  }

  String get displayItineraryList {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程リストを表示';
      case 'zh':
        return '顯示行程列表';
      default:
        return 'Display Itinerary List';
    }
  }

  String get loadItineraryListError {
    switch (locale.languageCode) {
      case 'ja':
        return '行程リストの読み込みエラー';
      case 'zh':
        return '載入行程列表錯誤';
      default:
        return 'Error loading itinerary list';
    }
  }

  String getLoadError(String error) {
    switch (locale.languageCode) {
      case 'ja':
        return '読み込み失敗: $error';
      case 'zh':
        return '載入失敗: $error';
      default:
        return 'Load failed: $error';
    }
  }

  // 個人資料頁面相關
  String get loadUserDataError {
    switch (locale.languageCode) {
      case 'ja':
        return 'ユーザーデータの読み込みエラー';
      case 'zh':
        return '載入用戶資料錯誤';
      default:
        return 'Error loading user data';
    }
  }

  String get usingGuestMode {
    switch (locale.languageCode) {
      case 'ja':
        return 'ゲストモードを使用';
      case 'zh':
        return '使用遊客模式';
      default:
        return 'Using guest mode';
    }
  }

  String get userDataUpdated {
    switch (locale.languageCode) {
      case 'ja':
        return 'ユーザーデータが更新されました';
      case 'zh':
        return '用戶資料已更新';
      default:
        return 'User data updated';
    }
  }

  String get refreshFailedTryLater {
    switch (locale.languageCode) {
      case 'ja':
        return '更新に失敗しました、後でお試しください';
      case 'zh':
        return '刷新失敗，請稍後再試';
      default:
        return 'Refresh failed, please try again later';
    }
  }

  String get refreshData {
    switch (locale.languageCode) {
      case 'ja':
        return 'データを更新';
      case 'zh':
        return '刷新資料';
      default:
        return 'Refresh Data';
    }
  }

  String get settings {
    switch (locale.languageCode) {
      case 'ja':
        return '設定';
      case 'zh':
        return '設定';
      default:
        return 'Settings';
    }
  }

  String get logout {
    switch (locale.languageCode) {
      case 'ja':
        return 'ログアウト';
      case 'zh':
        return '登出';
      default:
        return 'Logout';
    }
  }

  String getLogoutError(String error) {
    switch (locale.languageCode) {
      case 'ja':
        return 'ログアウトエラー: $error';
      case 'zh':
        return '登出錯誤: $error';
      default:
        return 'Logout error: $error';
    }
  }

  String get personalPage {
    switch (locale.languageCode) {
      case 'ja':
        return '個人ページ';
      case 'zh':
        return '個人頁面';
      default:
        return 'Personal Page';
    }
  }

  String getGreeting(String name) {
    switch (locale.languageCode) {
      case 'ja':
        return 'こんにちは、${name}さん！';
      case 'zh':
        return '你好，$name！';
      default:
        return 'Hello, $name!';
    }
  }

  String get guest {
    switch (locale.languageCode) {
      case 'ja':
        return 'ゲスト';
      case 'zh':
        return '遊客';
      default:
        return 'Guest';
    }
  }

  String getTravelFootprint(int count) {
    switch (locale.languageCode) {
      case 'ja':
        return '旅行記録: $count回';
      case 'zh':
        return '旅行足跡: $count 次';
      default:
        return 'Travel footprint: $count trips';
    }
  }

  String get loginButton {
    switch (locale.languageCode) {
      case 'ja':
        return 'ログイン';
      case 'zh':
        return '登入';
      default:
        return 'Login';
    }
  }

  String get functions {
    switch (locale.languageCode) {
      case 'ja':
        return '機能';
      case 'zh':
        return '功能';
      default:
        return 'Functions';
    }
  }

  String get myFavorites {
    switch (locale.languageCode) {
      case 'ja':
        return 'お気に入り';
      case 'zh':
        return '我的收藏';
      default:
        return 'My Favorites';
    }
  }

  String get travelTypeQuiz {
    switch (locale.languageCode) {
      case 'ja':
        return '旅行タイプテスト';
      case 'zh':
        return '旅遊類型測驗';
      default:
        return 'Travel Type Quiz';
    }
  }

  // 登入頁面相關
  String get loginSuccess {
    switch (locale.languageCode) {
      case 'ja':
        return 'ログイン成功';
      case 'zh':
        return '登入成功';
      default:
        return 'Login successful';
    }
  }

  // 首頁詳細頁面相關
  String get introductionTab {
    switch (locale.languageCode) {
      case 'ja':
        return '紹介';
      case 'zh':
        return '介紹';
      default:
        return 'Introduction';
    }
  }

  String get nearbyTab {
    switch (locale.languageCode) {
      case 'ja':
        return '周辺スポット';
      case 'zh':
        return '附近景點';
      default:
        return 'Nearby Spots';
    }
  }

  String get suggestedVisitTime {
    switch (locale.languageCode) {
      case 'ja':
        return '推奨見学時間';
      case 'zh':
        return '建議遊覽時間';
      default:
        return 'Suggested Visit Time';
    }
  }

  String get introduction {
    switch (locale.languageCode) {
      case 'ja':
        return 'スポット紹介';
      case 'zh':
        return '景點介紹';
      default:
        return 'Spot Introduction';
    }
  }

  String get defaultDescription {
    switch (locale.languageCode) {
      case 'ja':
        return 'これは探索する価値のある素晴らしいスポットで、あなたの到着を待っています。ここでは、独特の文化的魅力と美しい風景を体験できます。';
      case 'zh':
        return '這是一個值得探索的精彩景點，等待著您的到來。在這裡，您可以體驗到獨特的文化魅力和美麗的風景。';
      default:
        return 'This is a wonderful spot worth exploring, waiting for your arrival. Here, you can experience unique cultural charm and beautiful scenery.';
    }
  }

  String get share {
    switch (locale.languageCode) {
      case 'ja':
        return '共有';
      case 'zh':
        return '分享';
      default:
        return 'Share';
    }
  }

  String get shareNotImplemented {
    switch (locale.languageCode) {
      case 'ja':
        return '共有機能はまだ実装されていません';
      case 'zh':
        return '分享功能尚未實現';
      default:
        return 'Share feature not yet implemented';
    }
  }

  String get nearbyRecommendations {
    switch (locale.languageCode) {
      case 'ja':
        return '周辺スポット推薦';
      case 'zh':
        return '附近景點推薦';
      default:
        return 'Nearby Recommendations';
    }
  }

  String get museum {
    switch (locale.languageCode) {
      case 'ja':
        return '博物館';
      case 'zh':
        return '博物館';
      default:
        return 'Museum';
    }
  }

  String get park {
    switch (locale.languageCode) {
      case 'ja':
        return '公園';
      case 'zh':
        return '公園';
      default:
        return 'Park';
    }
  }

  String get temple {
    switch (locale.languageCode) {
      case 'ja':
        return '寺院';
      case 'zh':
        return '寺廟';
      default:
        return 'Temple';
    }
  }

  String get naturalFeature {
    switch (locale.languageCode) {
      case 'ja':
        return '自然景観';
      case 'zh':
        return '自然景觀';
      default:
        return 'Natural Feature';
    }
  }

  // 景點詳細頁面相關
  String get cannotLoadSpotDetails {
    switch (locale.languageCode) {
      case 'ja':
        return 'スポット詳細を読み込めません';
      case 'zh':
        return '無法載入景點詳細資訊';
      default:
        return 'Cannot load spot details';
    }
  }

  String get cannotOpenMap {
    switch (locale.languageCode) {
      case 'ja':
        return '地図を開けません';
      case 'zh':
        return '無法開啟地圖';
      default:
        return 'Cannot open map';
    }
  }

  String get unfavorited {
    switch (locale.languageCode) {
      case 'ja':
        return 'お気に入りから削除しました';
      case 'zh':
        return '已取消收藏';
      default:
        return 'Removed from favorites';
    }
  }

  String getVoicePlaybackError(String error) {
    switch (locale.languageCode) {
      case 'ja':
        return '音声再生エラー: $error';
      case 'zh':
        return '語音播放錯誤: $error';
      default:
        return 'Voice playback error: $error';
    }
  }

  String get voicePlayback {
    switch (locale.languageCode) {
      case 'ja':
        return '音声再生';
      case 'zh':
        return '語音播放';
      default:
        return 'Voice Playback';
    }
  }

  String get favorited {
    switch (locale.languageCode) {
      case 'ja':
        return 'お気に入り済み';
      case 'zh':
        return '已收藏';
      default:
        return 'Favorited';
    }
  }

  String get favorite {
    switch (locale.languageCode) {
      case 'ja':
        return 'お気に入り';
      case 'zh':
        return '收藏';
      default:
        return 'Favorite';
    }
  }

  String get navigation {
    switch (locale.languageCode) {
      case 'ja':
        return 'ナビゲーション';
      case 'zh':
        return '導航';
      default:
        return 'Navigation';
    }
  }

  String get spotIntroduction {
    switch (locale.languageCode) {
      case 'ja':
        return 'スポット紹介';
      case 'zh':
        return '景點介紹';
      default:
        return 'Spot Introduction';
    }
  }

  String get openingHours {
    switch (locale.languageCode) {
      case 'ja':
        return '営業時間';
      case 'zh':
        return '營業時間';
      default:
        return 'Opening Hours';
    }
  }

  String get phone {
    switch (locale.languageCode) {
      case 'ja':
        return '電話番号';
      case 'zh':
        return '電話';
      default:
        return 'Phone';
    }
  }

  String get website {
    switch (locale.languageCode) {
      case 'ja':
        return 'ウェブサイト';
      case 'zh':
        return '網站';
      default:
        return 'Website';
    }
  }

  String get reviewCount {
    switch (locale.languageCode) {
      case 'ja':
        return 'レビュー数';
      case 'zh':
        return '評論數';
      default:
        return 'Review Count';
    }
  }

  String getReviewsCount(int count) {
    switch (locale.languageCode) {
      case 'ja':
        return '$count件のレビュー';
      case 'zh':
        return '$count 則評論';
      default:
        return '$count reviews';
    }
  }

  String get address {
    switch (locale.languageCode) {
      case 'ja':
        return '住所';
      case 'zh':
        return '地址';
      default:
        return 'Address';
    }
  }

  String getViewSpot(String spotName) {
    switch (locale.languageCode) {
      case 'ja':
        return '「$spotName」を表示';
      case 'zh':
        return '查看「$spotName」';
      default:
        return 'View "$spotName"';
    }
  }

  // 收藏對話框相關
  String get favoriteFeature {
    switch (locale.languageCode) {
      case 'ja':
        return 'お気に入り機能';
      case 'zh':
        return '收藏功能';
      default:
        return 'Favorite Feature';
    }
  }

  String get pocketList {
    switch (locale.languageCode) {
      case 'ja':
        return 'ポケットリスト';
      case 'zh':
        return '口袋清單';
      default:
        return 'Pocket List';
    }
  }

  String get defaultCollectionDescription {
    switch (locale.languageCode) {
      case 'ja':
        return '行きたい場所';
      case 'zh':
        return '我想去的地方';
      default:
        return 'Places I want to visit';
    }
  }

  String loadCollectionsFailedMessage(String error) {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクションの読み込みに失敗しました: $error';
      case 'zh':
        return '載入收藏集失敗: $error';
      default:
        return 'Failed to load collections: $error';
    }
  }

  String get pleaseEnterCollectionNameSnackbar {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクション名を入力してください';
      case 'zh':
        return '請輸入收藏集名稱';
      default:
        return 'Please enter collection name';
    }
  }

  String get spotAlreadyInCollection {
    switch (locale.languageCode) {
      case 'ja':
        return 'このスポットは既にそのコレクションにあります';
      case 'zh':
        return '此景點已在該收藏集中';
      default:
        return 'This spot is already in that collection';
    }
  }

  String addedToNewCollectionMessage(String collectionName) {
    switch (locale.languageCode) {
      case 'ja':
        return '新しいコレクション「$collectionName」に追加しました';
      case 'zh':
        return '已加入新收藏集「$collectionName」';
      default:
        return 'Added to new collection "$collectionName"';
    }
  }

  String addedToCollectionMessage(String collectionName) {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクション「$collectionName」に追加しました';
      case 'zh':
        return '已加入收藏集「$collectionName」';
      default:
        return 'Added to collection "$collectionName"';
    }
  }

  String addToCollectionFailedMessage(String error) {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクションへの追加に失敗しました: $error';
      case 'zh':
        return '加入收藏集失敗: $error';
      default:
        return 'Failed to add to collection: $error';
    }
  }

  String get addToFavoriteTitle {
    switch (locale.languageCode) {
      case 'ja':
        return 'お気に入りに追加';
      case 'zh':
        return '加入收藏';
      default:
        return 'Add to Favorite';
    }
  }

  String addSpotToCollectionMessage(String spotName) {
    switch (locale.languageCode) {
      case 'ja':
        return '「$spotName」を次に追加：';
      case 'zh':
        return '將「$spotName」加入到：';
      default:
        return 'Add "$spotName" to:';
    }
  }

  String get selectCollection {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクションを選択：';
      case 'zh':
        return '選擇收藏集：';
      default:
        return 'Select Collection:';
    }
  }

  String get createNewCollectionButton {
    switch (locale.languageCode) {
      case 'ja':
        return '新しいコレクションを作成';
      case 'zh':
        return '創建新收藏集';
      default:
        return 'Create New Collection';
    }
  }

  String get newCollectionName {
    switch (locale.languageCode) {
      case 'ja':
        return '新しいコレクション名：';
      case 'zh':
        return '新收藏集名稱：';
      default:
        return 'New Collection Name:';
    }
  }

  String get collectionNamePlaceholder {
    switch (locale.languageCode) {
      case 'ja':
        return '例：北海道スポット';
      case 'zh':
        return '例如：北海道景點';
      default:
        return 'e.g.: Hokkaido Spots';
    }
  }

  String get backToExistingCollections {
    switch (locale.languageCode) {
      case 'ja':
        return '既存のコレクション選択に戻る';
      case 'zh':
        return '返回選擇現有收藏集';
      default:
        return 'Back to Existing Collections';
    }
  }

  // 登入必需對話框相關
  String get loginRequiredTitle {
    switch (locale.languageCode) {
      case 'ja':
        return 'ログインが必要';
      case 'zh':
        return '需要登入';
      default:
        return 'Login Required';
    }
  }

  String loginRequiredMessage(String feature) {
    switch (locale.languageCode) {
      case 'ja':
        return '「$feature」機能を使用するには、まずアカウントにログインする必要があります';
      case 'zh':
        return '使用「$feature」功能需要先登入帳號';
      default:
        return 'Using "$feature" feature requires logging into your account first';
    }
  }

  String get cloudSyncTitle {
    switch (locale.languageCode) {
      case 'ja':
        return 'クラウド同期機能';
      case 'zh':
        return '雲端同步功能';
      default:
        return 'Cloud Sync Feature';
    }
  }

  String get cloudSyncDesc {
    switch (locale.languageCode) {
      case 'ja':
        return '• データはクラウドに安全に保存\n• 複数デバイス間で同期アクセス\n• 永続保存で紛失なし';
      case 'zh':
        return '• 資料安全儲存在雲端\n• 多裝置同步存取\n• 永久保存不丟失';
      default:
        return '• Data safely stored in cloud\n• Sync across multiple devices\n• Permanent storage, never lost';
    }
  }

  String get maybeLater {
    switch (locale.languageCode) {
      case 'ja':
        return '後で';
      case 'zh':
        return '稍後再說';
      default:
        return 'Maybe Later';
    }
  }

  String get loginNow {
    switch (locale.languageCode) {
      case 'ja':
        return '今すぐログイン';
      case 'zh':
        return '立即登入';
      default:
        return 'Login Now';
    }
  }

  // 行程詳細頁面相關
  String get saveItineraryFeature {
    switch (locale.languageCode) {
      case 'ja':
        return '行程を保存';
      case 'zh':
        return '保存行程';
      default:
        return 'Save Itinerary';
    }
  }

  String get deleteItineraryFeature {
    switch (locale.languageCode) {
      case 'ja':
        return '行程を削除';
      case 'zh':
        return '刪除行程';
      default:
        return 'Delete Itinerary';
    }
  }

  String get deleteFailed {
    switch (locale.languageCode) {
      case 'ja':
        return '削除に失敗しました: ';
      case 'zh':
        return '刪除失敗: ';
      default:
        return 'Delete failed: ';
    }
  }

  String get itineraryUpdated {
    switch (locale.languageCode) {
      case 'ja':
        return '行程が更新されました';
      case 'zh':
        return '行程已更新';
      default:
        return 'Itinerary updated';
    }
  }

  String get updateFailed {
    switch (locale.languageCode) {
      case 'ja':
        return '更新に失敗しました: ';
      case 'zh':
        return '更新失敗: ';
      default:
        return 'Update failed: ';
    }
  }

  String get updating {
    switch (locale.languageCode) {
      case 'ja':
        return '更新中...';
      case 'zh':
        return '正在更新...';
      default:
        return 'Updating...';
    }
  }

  String get confirmDeleteMessage {
    switch (locale.languageCode) {
      case 'ja':
        return 'この行程を削除してもよろしいですか？この操作は元に戻せません。';
      case 'zh':
        return '確定要刪除此行程嗎？此操作無法復原。';
      default:
        return 'Are you sure you want to delete this itinerary? This action cannot be undone.';
    }
  }

  String get updatingItinerary {
    switch (locale.languageCode) {
      case 'ja':
        return '行程を更新中...';
      case 'zh':
        return '正在更新行程...';
      default:
        return 'Updating itinerary...';
    }
  }

  String get homepage {
    switch (locale.languageCode) {
      case 'ja':
        return 'ホーム';
      case 'zh':
        return '主頁';
      default:
        return 'Home';
    }
  }

  String getDayTab(int day) {
    switch (locale.languageCode) {
      case 'ja':
        return '第${day}日';
      case 'zh':
        return '第${day}天';
      default:
        return 'Day $day';
    }
  }

  String getDaysOnly(int days) {
    switch (locale.languageCode) {
      case 'ja':
        return '${days}日';
      case 'zh':
        return '${days}天';
      default:
        return '$days days';
    }
  }

  String get smartTripAssistant {
    switch (locale.languageCode) {
      case 'ja':
        return 'スマート旅行アシスタント';
      case 'zh':
        return '智能行程規劃助理';
      default:
        return 'Smart Trip Assistant';
    }
  }

  String get itineraryMembers {
    switch (locale.languageCode) {
      case 'ja':
        return '行程メンバー';
      case 'zh':
        return '行程成員';
      default:
        return 'Itinerary Members';
    }
  }

  String get itineraryOverview {
    switch (locale.languageCode) {
      case 'ja':
        return '行程概要';
      case 'zh':
        return '行程概覽';
      default:
        return 'Itinerary Overview';
    }
  }

  String get oneClickArrange {
    switch (locale.languageCode) {
      case 'ja':
        return 'ワンクリック配置';
      case 'zh':
        return '一鍵安排';
      default:
        return 'One-Click Arrange';
    }
  }

  String get featureNotImplemented {
    switch (locale.languageCode) {
      case 'ja':
        return 'この機能はまだ実装されていません';
      case 'zh':
        return '此功能尚未實現';
      default:
        return 'This feature is not yet implemented';
    }
  }

  String get noSpots {
    switch (locale.languageCode) {
      case 'ja':
        return 'スポットがありません';
      case 'zh':
        return '尚無景點';
      default:
        return 'No spots';
    }
  }

  String get clickToAddFirstSpot {
    switch (locale.languageCode) {
      case 'ja':
        return '下のボタンをクリックして最初のスポットを追加';
      case 'zh':
        return '點擊下方按鈕添加第一個景點';
      default:
        return 'Click the button below to add the first spot';
    }
  }

  String get navigationNotImplemented {
    switch (locale.languageCode) {
      case 'ja':
        return 'ナビゲーション機能はまだ実装されていません';
      case 'zh':
        return '導航功能尚未實現';
      default:
        return 'Navigation feature is not yet implemented';
    }
  }

  String get noMembersSet {
    switch (locale.languageCode) {
      case 'ja':
        return 'まだ行程メンバーが設定されていません';
      case 'zh':
        return '尚未設定行程成員';
      default:
        return 'No itinerary members set yet';
    }
  }

  String get setItineraryMembers {
    switch (locale.languageCode) {
      case 'ja':
        return '行程メンバーを設定';
      case 'zh':
        return '設定行程成員';
      default:
        return 'Set Itinerary Members';
    }
  }

  String get ageGroup {
    switch (locale.languageCode) {
      case 'ja':
        return '年齢層: ';
      case 'zh':
        return '年齡層: ';
      default:
        return 'Age Group: ';
    }
  }

  String get interests {
    switch (locale.languageCode) {
      case 'ja':
        return '興味:';
      case 'zh':
        return '興趣:';
      default:
        return 'Interests:';
    }
  }

  String get specialNeeds {
    switch (locale.languageCode) {
      case 'ja':
        return '特別なニーズ:';
      case 'zh':
        return '特殊需求:';
      default:
        return 'Special Needs:';
    }
  }

  String get editMember {
    switch (locale.languageCode) {
      case 'ja':
        return 'メンバーを編集';
      case 'zh':
        return '編輯成員';
      default:
        return 'Edit Member';
    }
  }

  String get errorLoadingSpotInfo {
    switch (locale.languageCode) {
      case 'ja':
        return 'スポット情報の読み込み時にエラーが発生しました';
      case 'zh':
        return '載入景點資訊時發生錯誤';
      default:
        return 'Error occurred while loading spot information';
    }
  }

  String getDayInfo(int day) {
    switch (locale.languageCode) {
      case 'ja':
        return '第${day}日情報';
      case 'zh':
        return '第${day}天資訊';
      default:
        return 'Day $day Information';
    }
  }

  String get spotCount {
    switch (locale.languageCode) {
      case 'ja':
        return 'スポット数: ';
      case 'zh':
        return '景點數量: ';
      default:
        return 'Spot Count: ';
    }
  }

  String get transportationMethod {
    switch (locale.languageCode) {
      case 'ja':
        return '交通手段: ';
      case 'zh':
        return '交通方式: ';
      default:
        return 'Transportation Method: ';
    }
  }

  String get spotList {
    switch (locale.languageCode) {
      case 'ja':
        return 'スポットリスト:';
      case 'zh':
        return '景點列表:';
      default:
        return 'Spot List:';
    }
  }

  // 目的地選擇頁面相關
  String get selectDestinations {
    switch (locale.languageCode) {
      case 'ja':
        return '目的地を選択';
      case 'zh':
        return '選擇目的地';
      default:
        return 'Select Destinations';
    }
  }

  // 額外缺失的 getter
  String get loginFailed {
    switch (locale.languageCode) {
      case 'ja':
        return 'ログインページに移動できません。後でお試しください';
      case 'zh':
        return '無法跳轉到登入頁面，請稍後再試';
      default:
        return 'Cannot navigate to login page, please try again later';
    }
  }

  // 確保所有缺失的 getter 都被定義
  String getDaysFormat(int days) {
    switch (locale.languageCode) {
      case 'ja':
        return '${days}日';
      case 'zh':
        return '${days}天';
      default:
        return '$days days';
    }
  }

  String getSpotsCount(int count) {
    switch (locale.languageCode) {
      case 'ja':
        return '$count個のスポット';
      case 'zh':
        return '$count個景點';
      default:
        return '$count spots';
    }
  }

  String get addSpot {
    switch (locale.languageCode) {
      case 'ja':
        return 'スポットを追加';
      case 'zh':
        return '添加景點';
      default:
        return 'Add Spot';
    }
  }

  String get hours {
    switch (locale.languageCode) {
      case 'ja':
        return '時間';
      case 'zh':
        return '小時';
      default:
        return 'hours';
    }
  }

  String get addButton {
    switch (locale.languageCode) {
      case 'ja':
        return '追加';
      case 'zh':
        return '加入';
      default:
        return 'Add';
    }
  }

  // 新增所有遺漏的 getter 和 method
  String get accountOrPasswordError {
    switch (locale.languageCode) {
      case 'ja':
        return 'アカウントまたはパスワードエラー';
      case 'zh':
        return '帳號或密碼錯誤';
      default:
        return 'Account or password error';
    }
  }

  String get loginErrorMessage {
    switch (locale.languageCode) {
      case 'ja':
        return 'ログイン時にエラーが発生しました。後でお試しください';
      case 'zh':
        return '登入時發生錯誤，請稍後再試';
      default:
        return 'An error occurred during login, please try again later';
    }
  }

  String get pleaseEnterEmailFirst {
    switch (locale.languageCode) {
      case 'ja':
        return 'まずメールアドレスを入力してください';
      case 'zh':
        return '請先輸入您的電子郵件';
      default:
        return 'Please enter your email first';
    }
  }

  String passwordResetEmailSent(String email) {
    switch (locale.languageCode) {
      case 'ja':
        return 'パスワードリセットメールを $email に送信しました';
      case 'zh':
        return '密碼重設郵件已發送到 $email';
      default:
        return 'Password reset email sent to $email';
    }
  }

  String get passwordResetFailedMessage {
    switch (locale.languageCode) {
      case 'ja':
        return 'パスワードリセットメールの送信に失敗しました。メールアドレスが正しいか確認してください';
      case 'zh':
        return '發送密碼重設郵件失敗，請確認郵箱是否正確';
      default:
        return 'Failed to send password reset email, please check if the email is correct';
    }
  }

  String get passwordResetErrorMessage {
    switch (locale.languageCode) {
      case 'ja':
        return 'パスワードリセットメール送信時にエラーが発生しました';
      case 'zh':
        return '發送密碼重設郵件時發生錯誤';
      default:
        return 'Error occurred while sending password reset email';
    }
  }

  String get loginPageTitle {
    switch (locale.languageCode) {
      case 'ja':
        return 'ログイン';
      case 'zh':
        return '登入';
      default:
        return 'Login';
    }
  }

  String get welcomeBack {
    switch (locale.languageCode) {
      case 'ja':
        return 'おかえりなさい';
      case 'zh':
        return '歡迎回來';
      default:
        return 'Welcome Back';
    }
  }

  String get loginToContinue {
    switch (locale.languageCode) {
      case 'ja':
        return 'すべての機能を使用するにはログインしてください';
      case 'zh':
        return '登入以繼續使用所有功能';
      default:
        return 'Login to continue using all features';
    }
  }

  String get email {
    switch (locale.languageCode) {
      case 'ja':
        return 'メールアドレス';
      case 'zh':
        return '電子郵件';
      default:
        return 'Email';
    }
  }

  String get pleaseEnterEmail {
    switch (locale.languageCode) {
      case 'ja':
        return 'メールアドレスを入力してください';
      case 'zh':
        return '請輸入電子郵件';
      default:
        return 'Please enter email';
    }
  }

  String get password {
    switch (locale.languageCode) {
      case 'ja':
        return 'パスワード';
      case 'zh':
        return '密碼';
      default:
        return 'Password';
    }
  }

  String get pleaseEnterPassword {
    switch (locale.languageCode) {
      case 'ja':
        return 'パスワードを入力してください';
      case 'zh':
        return '請輸入密碼';
      default:
        return 'Please enter password';
    }
  }

  String get forgotPassword {
    switch (locale.languageCode) {
      case 'ja':
        return 'パスワードを忘れましたか？';
      case 'zh':
        return '忘記密碼？';
      default:
        return 'Forgot Password?';
    }
  }

  String get loginButtonText {
    switch (locale.languageCode) {
      case 'ja':
        return 'ログイン';
      case 'zh':
        return '登入';
      default:
        return 'Login';
    }
  }

  String get dontHaveAccount {
    switch (locale.languageCode) {
      case 'ja':
        return 'アカウントをお持ちでないですか？';
      case 'zh':
        return '還沒有帳號？';
      default:
        return "Don't have an account?";
    }
  }

  String get registerNow {
    switch (locale.languageCode) {
      case 'ja':
        return '今すぐ登録';
      case 'zh':
        return '立即註冊';
      default:
        return 'Register now';
    }
  }

  String get continueAsGuest {
    switch (locale.languageCode) {
      case 'ja':
        return 'ゲストとして続行';
      case 'zh':
        return '以遊客身份繼續';
      default:
        return 'Continue as guest';
    }
  }

  // 收藏頁面相關（確保重新定義）
  String get viewFavorites {
    switch (locale.languageCode) {
      case 'ja':
        return 'お気に入りを表示';
      case 'zh':
        return '查看收藏';
      default:
        return 'View Favorites';
    }
  }

  String getFavoriteLoadError(String error) {
    switch (locale.languageCode) {
      case 'ja':
        return 'お気に入りの読み込みエラー: $error';
      case 'zh':
        return '收藏載入錯誤: $error';
      default:
        return 'Favorite load error: $error';
    }
  }

  String get addNewCollection {
    switch (locale.languageCode) {
      case 'ja':
        return '新しいコレクションを追加';
      case 'zh':
        return '添加新收藏集';
      default:
        return 'Add New Collection';
    }
  }

  String get collectionName {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクション名';
      case 'zh':
        return '收藏集名稱';
      default:
        return 'Collection Name';
    }
  }

  String get collectionNameHint {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクション名を入力してください';
      case 'zh':
        return '請輸入收藏集名稱';
      default:
        return 'Please enter collection name';
    }
  }

  String get collectionDescription {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクションの説明';
      case 'zh':
        return '收藏集描述';
      default:
        return 'Collection Description';
    }
  }

  String get collectionDescriptionHint {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクションの説明を入力してください（オプション）';
      case 'zh':
        return '請輸入收藏集描述（選填）';
      default:
        return 'Please enter collection description (optional)';
    }
  }

  String get pleaseEnterCollectionName {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクション名を入力してください';
      case 'zh':
        return '請輸入收藏集名稱';
      default:
        return 'Please enter collection name';
    }
  }

  String getCollectionCreated(String collectionName) {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクション「$collectionName」を作成しました';
      case 'zh':
        return '收藏集「$collectionName」已建立';
      default:
        return 'Collection "$collectionName" created';
    }
  }

  String get createCollection {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクションを作成';
      case 'zh':
        return '建立收藏集';
      default:
        return 'Create Collection';
    }
  }

  String getCreateCollectionError(String error) {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクションの作成エラー: $error';
      case 'zh':
        return '建立收藏集錯誤: $error';
      default:
        return 'Create collection error: $error';
    }
  }

  String get yourCollections {
    switch (locale.languageCode) {
      case 'ja':
        return 'あなたのコレクション';
      case 'zh':
        return '你的收藏集';
      default:
        return 'Your Collections';
    }
  }

  String get emptyCollectionMessage {
    switch (locale.languageCode) {
      case 'ja':
        return '新しいコレクションを作成して、お気に入りの場所を整理しましょう';
      case 'zh':
        return '建立新收藏集，整理您喜愛的地點';
      default:
        return 'Create a new collection to organize your favorite places';
    }
  }

  String get mapViewDescription {
    switch (locale.languageCode) {
      case 'ja':
        return '地図でお気に入りの場所を表示';
      case 'zh':
        return '在地圖上顯示收藏的地點';
      default:
        return 'View your favorite places on the map';
    }
  }

  // 行程相關（確保重新定義）
  List<String> get transportationOptions {
    switch (locale.languageCode) {
      case 'ja':
        return ['徒歩', '自転車', '車', '公共交通機関'];
      case 'zh':
        return ['步行', '自行車', '汽車', '大眾運輸'];
      default:
        return ['Walking', 'Bicycle', 'Car', 'Public Transport'];
    }
  }

  List<String> get travelTypeOptions {
    switch (locale.languageCode) {
      case 'ja':
        return ['観光', 'ビジネス', 'レジャー', 'アドベンチャー'];
      case 'zh':
        return ['觀光', '商務', '休閒', '冒險'];
      default:
        return ['Tourism', 'Business', 'Leisure', 'Adventure'];
    }
  }

  String get createItineraryFeature {
    switch (locale.languageCode) {
      case 'ja':
        return '行程を作成';
      case 'zh':
        return '建立行程';
      default:
        return 'Create Itinerary';
    }
  }

  String get selectDateRange {
    switch (locale.languageCode) {
      case 'ja':
        return '日付範囲を選択';
      case 'zh':
        return '選擇日期範圍';
      default:
        return 'Select Date Range';
    }
  }

  String get pleaseSelectMainTransportation {
    switch (locale.languageCode) {
      case 'ja':
        return '主要交通手段を選択してください';
      case 'zh':
        return '請選擇主要交通方式';
      default:
        return 'Please select main transportation';
    }
  }

  String get pleaseSelectTravelType {
    switch (locale.languageCode) {
      case 'ja':
        return '旅行タイプを選択してください';
      case 'zh':
        return '請選擇旅遊型態';
      default:
        return 'Please select travel type';
    }
  }

  // 收藏集相關的缺失定義
  String get collectionUpdateSuccess {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクションの更新に成功しました';
      case 'zh':
        return '收藏集更新成功';
      default:
        return 'Collection updated successfully';
    }
  }

  String getUpdateCollectionFailed(String error) {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクションの更新に失敗しました: $error';
      case 'zh':
        return '更新收藏集失敗: $error';
      default:
        return 'Failed to update collection: $error';
    }
  }

  String get collectionDeleteSuccess {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクションの削除に成功しました';
      case 'zh':
        return '收藏集刪除成功';
      default:
        return 'Collection deleted successfully';
    }
  }

  String getDeleteCollectionFailed(String error) {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクションの削除に失敗しました: $error';
      case 'zh':
        return '刪除收藏集失敗: $error';
      default:
        return 'Failed to delete collection: $error';
    }
  }

  String getRemovedFromCollection(String spotName) {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクションから「$spotName」を削除しました';
      case 'zh':
        return '已從收藏集移除「$spotName」';
      default:
        return 'Removed "$spotName" from collection';
    }
  }

  String getRemoveSpotFailed(String error) {
    switch (locale.languageCode) {
      case 'ja':
        return 'スポットの削除に失敗しました: $error';
      case 'zh':
        return '移除景點失敗: $error';
      default:
        return 'Failed to remove spot: $error';
    }
  }

  // 行程相關的缺失定義
  String get selectDayToAdd {
    switch (locale.languageCode) {
      case 'ja':
        return '追加する日を選択してください';
      case 'zh':
        return '選擇添加到哪一天';
      default:
        return 'Select day to add';
    }
  }

  // 註冊相關的缺失定義
  String get registrationSuccess {
    switch (locale.languageCode) {
      case 'ja':
        return '登録が成功しました、ログインしてください';
      case 'zh':
        return '註冊成功，請登入';
      default:
        return 'Registration successful, please login';
    }
  }

  // 測驗相關的缺失定義
  String getMaxSelectionsReached(int maxSelections) {
    switch (locale.languageCode) {
      case 'ja':
        return '最大$maxSelections項まで選択できます';
      case 'zh':
        return '最多選擇$maxSelections項';
      default:
        return 'Maximum $maxSelections selections allowed';
    }
  }

  // 加入行程對話框相關
  String get itineraryIdNotExistError {
    switch (locale.languageCode) {
      case 'ja':
        return '行程IDが存在しません、スポットを追加できません';
      case 'zh':
        return '行程 ID 不存在，無法加入景點';
      default:
        return 'Itinerary ID does not exist, cannot add spot';
    }
  }

  String addedToItinerarySuccessMessage(String spotName, String itineraryName, int dayNumber) {
    switch (locale.languageCode) {
      case 'ja':
        return '「$spotName」を「$itineraryName」の第${dayNumber}日に追加しました';
      case 'zh':
        return '已將「$spotName」加入「$itineraryName」的第${dayNumber}天';
      default:
        return 'Added "$spotName" to day $dayNumber of "$itineraryName"';
    }
  }

  String get addToItineraryFailedMessage {
    switch (locale.languageCode) {
      case 'ja':
        return '行程に追加できませんでした、スポットが既に存在するか、他のエラーが発生しました';
      case 'zh':
        return '加入行程失敗，景點可能已存在或發生其他錯誤';
      default:
        return 'Failed to add to itinerary, spot may already exist or other error occurred';
    }
  }

  String addToItineraryErrorMessage(String error) {
    switch (locale.languageCode) {
      case 'ja':
        return '行程に追加する際にエラーが発生しました: $error';
      case 'zh':
        return '加入行程時發生錯誤: $error';
      default:
        return 'Error occurred while adding to itinerary: $error';
    }
  }

  String get createNewItineraryFirstMessage {
    switch (locale.languageCode) {
      case 'ja':
        return '新しい行程を作成してから、もう一度行程に追加をクリックしてください';
      case 'zh':
        return '請在新行程創建完成後再次點擊加入行程';
      default:
        return 'Please click add to itinerary again after creating new itinerary';
    }
  }

  // 收藏景點卡片相關
  String get detailedIntroduction {
    switch (locale.languageCode) {
      case 'ja':
        return '詳細な紹介';
      case 'zh':
        return '詳細介紹';
      default:
        return 'Detailed Introduction';
    }
  }

  String get removeFromCollectionTooltip {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクションから削除';
      case 'zh':
        return '從收藏集移除';
      default:
        return 'Remove from collection';
    }
  }

  // 景點選項相關
  String get insertNewSpot {
    switch (locale.languageCode) {
      case 'ja':
        return '新しいスポットを挿入';
      case 'zh':
        return '插入新景點';
      default:
        return 'Insert New Spot';
    }
  }

  String get searchFromMap {
    switch (locale.languageCode) {
      case 'ja':
        return '地図から検索';
      case 'zh':
        return '從地圖搜尋';
      default:
        return 'Search from Map';
    }
  }

  String get regionSearch {
    switch (locale.languageCode) {
      case 'ja':
        return '地域検索';
      case 'zh':
        return '區域搜尋';
      default:
        return 'Region Search';
    }
  }

  String get selectFromFavorites {
    switch (locale.languageCode) {
      case 'ja':
        return 'お気に入りから選択';
      case 'zh':
        return '從收藏選擇';
      default:
        return 'Select from Favorites';
    }
  }

  String get smartRecommendation {
    switch (locale.languageCode) {
      case 'ja':
        return 'スマート推薦';
      case 'zh':
        return '智慧推薦';
      default:
        return 'Smart Recommendation';
    }
  }

  String get smartRecommendationInDevelopment {
    switch (locale.languageCode) {
      case 'ja':
        return 'スマート推薦機能開発中...';
      case 'zh':
        return '智慧推薦功能開發中...';
      default:
        return 'Smart recommendation feature in development...';
    }
  }

  // 預算設定相關
  String get setBudgetTitle {
    switch (locale.languageCode) {
      case 'ja':
        return '行程予算を設定';
      case 'zh':
        return '設定行程預算';
      default:
        return 'Set Trip Budget';
    }
  }

  String get setBudgetPerPerson {
    switch (locale.languageCode) {
      case 'ja':
        return '一人当たりの予算を設定';
      case 'zh':
        return '設定每人預算';
      default:
        return 'Set Budget per Person';
    }
  }

  String get noSetting {
    switch (locale.languageCode) {
      case 'ja':
        return '設定なし';
      case 'zh':
        return '不設定';
      default:
        return 'No Setting';
    }
  }

  String get minimum {
    switch (locale.languageCode) {
      case 'ja':
        return '最低';
      case 'zh':
        return '最低';
      default:
        return 'Minimum';
    }
  }

  String get maximum {
    switch (locale.languageCode) {
      case 'ja':
        return '最高';
      case 'zh':
        return '最高';
      default:
        return 'Maximum';
    }
  }

  String get currency {
    switch (locale.languageCode) {
      case 'ja':
        return '円';
      case 'zh':
        return '元';
      default:
        return 'USD';
    }
  }

  // 交通方式相關
  String get car {
    switch (locale.languageCode) {
      case 'ja':
        return '車';
      case 'zh':
        return '汽車';
      default:
        return 'Car';
    }
  }

  String get bicycle {
    switch (locale.languageCode) {
      case 'ja':
        return '自転車';
      case 'zh':
        return '自行車';
      default:
        return 'Bicycle';
    }
  }

  String get publicTransport {
    switch (locale.languageCode) {
      case 'ja':
        return '公共交通';
      case 'zh':
        return '大眾運輸';
      default:
        return 'Public Transport';
    }
  }

  String get walking {
    switch (locale.languageCode) {
      case 'ja':
        return '徒歩';
      case 'zh':
        return '步行';
      default:
        return 'Walking';
    }
  }

  String get setTransportationMode {
    switch (locale.languageCode) {
      case 'ja':
        return '交通手段を設定';
      case 'zh':
        return '設置交通方式';
      default:
        return 'Set Transportation Mode';
    }
  }

  String get timeRequired {
    switch (locale.languageCode) {
      case 'ja':
        return '所要時間:';
      case 'zh':
        return '耗時:';
      default:
        return 'Time Required:';
    }
  }

  String get minutes {
    switch (locale.languageCode) {
      case 'ja':
        return '分';
      case 'zh':
        return '分';
      default:
        return 'minutes';
    }
  }

  // 旅伴相關
  String getLoadCompanionDataFailed(String error) {
    switch (locale.languageCode) {
      case 'ja':
        return '旅行仲間データの読み込みに失敗しました：$error';
      case 'zh':
        return '載入旅伴資料失敗：$error';
      default:
        return 'Failed to load companion data: $error';
    }
  }

  String get companionDeleted {
    switch (locale.languageCode) {
      case 'ja':
        return '旅行仲間が削除されました';
      case 'zh':
        return '旅伴已刪除';
      default:
        return 'Companion deleted';
    }
  }

  String getDeleteCompanionFailed(String error) {
    switch (locale.languageCode) {
      case 'ja':
        return '旅行仲間の削除に失敗しました：$error';
      case 'zh':
        return '刪除旅伴失敗：$error';
      default:
        return 'Failed to delete companion: $error';
    }
  }

  String getSaveCompanionFailed(String error) {
    switch (locale.languageCode) {
      case 'ja':
        return '旅行仲間の保存に失敗しました：$error';
      case 'zh':
        return '儲存旅伴失敗：$error';
      default:
        return 'Failed to save companion: $error';
    }
  }

  // 載入景點失敗
  String getLoadSpotsFailed(String error) {
    switch (locale.languageCode) {
      case 'ja':
        return 'スポットの読み込みに失敗しました: $error';
      case 'zh':
        return '載入景點失敗: $error';
      default:
        return 'Failed to load spots: $error';
    }
  }
}
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ja', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
