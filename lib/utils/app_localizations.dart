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
        return '目前尚無行程喔！點擊下方按鈕新增您的第一個行程。';
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

  // 建立行程
  String get createItineraryFeature {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程作成';
      case 'zh':
        return '建立行程';
      default:
        return 'Create Itinerary';
    }
  }

  // 建立失敗
  String get createFailed {
    switch (locale.languageCode) {
      case 'ja':
        return '作成に失敗しました: ';
      case 'zh':
        return '建立失敗: ';
      default:
        return 'Creation failed: ';
    }
  }

  // 選擇日期範圍
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

  // 請選擇主要交通方式
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

  // 請選擇旅遊型態
  String get pleaseSelectTravelType {
    switch (locale.languageCode) {
      case 'ja':
        return '旅行スタイルを選択してください';
      case 'zh':
        return '請選擇旅遊型態';
      default:
        return 'Please select travel style';
    }
  }

  // 天數計算格式（X天）
  String getDaysFormat(int days) {
    switch (locale.languageCode) {
      case 'ja':
        return '$days 日';
      case 'zh':
        return '$days 天';
      default:
        return '$days days';
    }
  }

  // 行程詳細頁面相關字串
  // 刪除行程
  String get deleteItineraryTitle {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程を削除';
      case 'zh':
        return '刪除行程';
      default:
        return 'Delete Itinerary';
    }
  }

  // 保存行程
  String get saveItinerary {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程を保存';
      case 'zh':
        return '保存行程';
      default:
        return 'Save Itinerary';
    }
  }

  // 保存失敗
  String get saveFailed {
    switch (locale.languageCode) {
      case 'ja':
        return '保存に失敗しました: ';
      case 'zh':
        return '保存失敗: ';
      default:
        return 'Save failed: ';
    }
  }

  // 刪除失敗
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

  // 行程已更新
  String get itineraryUpdated {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程が更新されました';
      case 'zh':
        return '行程已更新';
      default:
        return 'Itinerary updated';
    }
  }

  // 更新失敗
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

  // 正在更新
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

  // 行程詳細頁面其他字串
  // 保存行程功能
  String get saveItineraryFeature {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程保存';
      case 'zh':
        return '保存行程';
      default:
        return 'Save Itinerary';
    }
  }

  // 刪除行程功能
  String get deleteItineraryFeature {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程削除';
      case 'zh':
        return '刪除行程';
      default:
        return 'Delete Itinerary';
    }
  }

  // 確認刪除
  String get confirmDelete {
    switch (locale.languageCode) {
      case 'ja':
        return '削除確認';
      case 'zh':
        return '確認刪除';
      default:
        return 'Confirm Delete';
    }
  }

  // 確定要刪除此行程嗎？此操作無法復原。
  String get confirmDeleteMessage {
    switch (locale.languageCode) {
      case 'ja':
        return 'この旅程を削除してもよろしいですか？この操作は元に戻せません。';
      case 'zh':
        return '確定要刪除此行程嗎？此操作無法復原。';
      default:
        return 'Are you sure you want to delete this itinerary? This action cannot be undone.';
    }
  }

  // 刪除
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

  // 一鍵安排
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

  // 此功能尚未實現
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

  // 添加景點
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

  // 導航功能尚未實現
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

  // 設定行程成員
  String get setItineraryMembers {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程メンバーを設定';
      case 'zh':
        return '設定行程成員';
      default:
        return 'Set Itinerary Members';
    }
  }

  // 編輯
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

  // 年齡層
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

  // 興趣
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

  // 特殊需求
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

  // 編輯成員
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

  // 無法載入景點詳細資訊
  String get cannotLoadSpotDetails {
    switch (locale.languageCode) {
      case 'ja':
        return 'スポットの詳細情報を読み込めません';
      case 'zh':
        return '無法載入景點詳細資訊';
      default:
        return 'Cannot load spot details';
    }
  }

  // 加入行程
  String get addToItinerary {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程に追加';
      case 'zh':
        return '加入行程';
      default:
        return 'Add to Itinerary';
    }
  }

  // ===== 個人頁面相關字串 =====
  
  // 載入用戶資料時發生錯誤
  String get loadUserDataError {
    switch (locale.languageCode) {
      case 'ja':
        return 'ユーザーデータの読み込みでエラーが発生しました';
      case 'zh':
        return '載入用戶資料時發生錯誤';
      default:
        return 'Error loading user data';
    }
  }

  // 使用遊客模式
  String get usingGuestMode {
    switch (locale.languageCode) {
      case 'ja':
        return 'ゲストモードを使用します';
      case 'zh':
        return '使用遊客模式';
      default:
        return 'Using guest mode';
    }
  }

  // 使用者資料已更新
  String get userDataUpdated {
    switch (locale.languageCode) {
      case 'ja':
        return 'ユーザーデータが更新されました';
      case 'zh':
        return '使用者資料已更新';
      default:
        return 'User data updated';
    }
  }

  // 刷新失敗，請稍後再試
  String get refreshFailedTryLater {
    switch (locale.languageCode) {
      case 'ja':
        return '更新に失敗しました。後でもう一度お試しください';
      case 'zh':
        return '刷新失敗，請稍後再試';
      default:
        return 'Refresh failed, please try again later';
    }
  }

  // 刷新資料
  String get refreshData {
    switch (locale.languageCode) {
      case 'ja':
        return 'データ更新';
      case 'zh':
        return '刷新資料';
      default:
        return 'Refresh Data';
    }
  }

  // 設置
  String get settings {
    switch (locale.languageCode) {
      case 'ja':
        return '設定';
      case 'zh':
        return '設置';
      default:
        return 'Settings';
    }
  }

  // 登出
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

  // 登出時發生錯誤
  String getLogoutError(String error) {
    switch (locale.languageCode) {
      case 'ja':
        return 'ログアウト時にエラーが発生しました：$error';
      case 'zh':
        return '登出時發生錯誤：$error';
      default:
        return 'Error during logout: $error';
    }
  }

  // 個人頁面標題
  String get personalPage {
    switch (locale.languageCode) {
      case 'ja':
        return 'プロフィール';
      case 'zh':
        return '個人頁面';
      default:
        return 'Profile';
    }
  }

  // 嗨！{name}
  String getGreeting(String name) {
    switch (locale.languageCode) {
      case 'ja':
        return 'こんにちは！$name';
      case 'zh':
        return '嗨！$name';
      default:
        return 'Hi! $name';
    }
  }

  // 訪客
  String get guest {
    switch (locale.languageCode) {
      case 'ja':
        return 'ゲスト';
      case 'zh':
        return '訪客';
      default:
        return 'Guest';
    }
  }

  // 旅行足跡：{count} 個行程
  String getTravelFootprint(int count) {
    switch (locale.languageCode) {
      case 'ja':
        return '旅行記録：$count 個の旅程';
      case 'zh':
        return '旅行足跡：$count 個行程';
      default:
        return 'Travel Footprint: $count itineraries';
    }
  }

  // 登入按鈕
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

  // 功能
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

  // 我的旅伴
  String get myCompanions {
    switch (locale.languageCode) {
      case 'ja':
        return 'マイ旅行仲間';
      case 'zh':
        return '我的旅伴';
      default:
        return 'My Travel Companions';
    }
  }

  // 旅遊類型測驗
  String get travelTypeQuiz {
    switch (locale.languageCode) {
      case 'ja':
        return '旅行タイプ診断';
      case 'zh':
        return '旅遊類型測驗';
      default:
        return 'Travel Type Quiz';
    }
  }

  // ===== 收藏頁面相關字串 =====

  // 載入收藏失敗
  String getFavoriteLoadError(String error) {
    switch (locale.languageCode) {
      case 'ja':
        return 'お気に入りの読み込みに失敗しました：$error';
      case 'zh':
        return '載入收藏失敗：$error';
      default:
        return 'Failed to load favorites: $error';
    }
  }

  // 新增收藏集
  String get addNewCollection {
    switch (locale.languageCode) {
      case 'ja':
        return '新しいコレクションを追加';
      case 'zh':
        return '新增收藏集';
      default:
        return 'Add New Collection';
    }
  }

  // 收藏集名稱
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

  // 收藏集名稱提示
  String get collectionNameHint {
    switch (locale.languageCode) {
      case 'ja':
        return '例：北海道の必見スポット';
      case 'zh':
        return '例如：北海道必去景點';
      default:
        return 'e.g.: Must-visit spots in Hokkaido';
    }
  }

  // 收藏集說明
  String get collectionDescription {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクションの説明';
      case 'zh':
        return '收藏集說明';
      default:
        return 'Collection Description';
    }
  }

  // 收藏集說明提示
  String get collectionDescriptionHint {
    switch (locale.languageCode) {
      case 'ja':
        return '例：北海道旅行プランニング';
      case 'zh':
        return '例如：北海道旅遊規劃';
      default:
        return 'e.g.: Hokkaido travel planning';
    }
  }

  // 請輸入收藏集名稱
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

  // 創建收藏集失敗
  String getCreateCollectionError(String error) {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクションの作成に失敗しました：$error';
      case 'zh':
        return '創建收藏集失敗：$error';
      default:
        return 'Failed to create collection: $error';
    }
  }

  // 已創建收藏集
  String getCollectionCreated(String name) {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクション「$name」を作成しました';
      case 'zh':
        return '已創建收藏集「$name」';
      default:
        return 'Collection "$name" created';
    }
  }

  // 新增按鈕
  String get addButton {
    switch (locale.languageCode) {
      case 'ja':
        return '追加';
      case 'zh':
        return '新增';
      default:
        return 'Add';
    }
  }

  // 您的收藏
  String get yourCollections {
    switch (locale.languageCode) {
      case 'ja':
        return 'あなたのコレクション';
      case 'zh':
        return '您的收藏';
      default:
        return 'Your Collections';
    }
  }

  // 空狀態說明文字
  String get emptyCollectionMessage {
    switch (locale.languageCode) {
      case 'ja':
        return '現在コレクションはありません。右上の「＋追加」ボタンをクリックして最初のコレクションを作成してください。';
      case 'zh':
        return '目前尚無收藏集，點擊右上角的「+新增」按鈕建立您的第一個收藏集。';
      default:
        return 'No collections yet. Click the "+Add" button in the top right to create your first collection.';
    }
  }

  // 建立收藏集
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

  // 此處將顯示收藏地點的地圖視圖
  String get mapViewDescription {
    switch (locale.languageCode) {
      case 'ja':
        return 'ここにお気に入りの場所のマップビューが表示されます';
      case 'zh':
        return '此處將顯示收藏地點的地圖視圖';
      default:
        return 'Map view of favorite locations will be displayed here';
    }
  }

  // {count} 個景點
  String getSpotsCount(int count) {
    switch (locale.languageCode) {
      case 'ja':
        return '$count 個のスポット';
      case 'zh':
        return '$count 個景點';
      default:
        return '$count spots';
    }
  }

  // 詳細介紹
  String get detailedIntroduction {
    switch (locale.languageCode) {
      case 'ja':
        return '詳細紹介';
      case 'zh':
        return '詳細介紹';
      default:
        return 'Detailed Introduction';
    }
  }

  // 從收藏集移除
  String get removeFromCollectionTooltip {
    switch (locale.languageCode) {
      case 'ja':
        return 'コレクションから削除';
      case 'zh':
        return '從收藏集移除';
      default:
        return 'Remove from Collection';
    }
  }

  // ===== 景點詳細頁面相關字串 =====

  // 語音播放
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

  // 語音播放失敗
  String getVoicePlaybackError(String error) {
    switch (locale.languageCode) {
      case 'ja':
        return '音声再生に失敗しました：$error';
      case 'zh':
        return '語音播放失敗：$error';
      default:
        return 'Voice playback failed: $error';
    }
  }

  // 已收藏
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

  // 收藏
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

  // 導航
  String get navigation {
    switch (locale.languageCode) {
      case 'ja':
        return 'ナビ';
      case 'zh':
        return '導航';
      default:
        return 'Navigation';
    }
  }

  // 無法打開地圖應用
  String get cannotOpenMap {
    switch (locale.languageCode) {
      case 'ja':
        return 'マップアプリを開けません';
      case 'zh':
        return '無法打開地圖應用';
      default:
        return 'Cannot open map application';
    }
  }

  // 已取消收藏
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

  // 景點介紹
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

  // 營業時間
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

  // 電話
  String get phone {
    switch (locale.languageCode) {
      case 'ja':
        return '電話';
      case 'zh':
        return '電話';
      default:
        return 'Phone';
    }
  }

  // 網站
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

  // 評論數量
  String get reviewCount {
    switch (locale.languageCode) {
      case 'ja':
        return 'レビュー数';
      case 'zh':
        return '評論數量';
      default:
        return 'Review Count';
    }
  }

  // {count} 則評論
  String getReviewsCount(int count) {
    switch (locale.languageCode) {
      case 'ja':
        return '$count 件のレビュー';
      case 'zh':
        return '$count 則評論';
      default:
        return '$count reviews';
    }
  }

  // 地址
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

  // 附近推薦
  String get nearbyRecommendations {
    switch (locale.languageCode) {
      case 'ja':
        return '周辺のおすすめ';
      case 'zh':
        return '附近推薦';
      default:
        return 'Nearby Recommendations';
    }
  }

  // 我的收藏
  String get myFavorites {
    switch (locale.languageCode) {
      case 'ja':
        return 'マイお気に入り';
      case 'zh':
        return '我的收藏';
      default:
        return 'My Favorites';
    }
  }

  // 查看{spotName}
  String getViewSpot(String spotName) {
    switch (locale.languageCode) {
      case 'ja':
        return '${spotName}を見る';
      case 'zh':
        return '查看$spotName';
      default:
        return 'View $spotName';
    }
  }

  // 更新行程中
  String get updatingItinerary {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程を更新中...';
      case 'zh':
        return '正在更新行程...';
      default:
        return 'Updating itinerary...';
    }
  }

  // 主頁
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

  // 第{day}天
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

  // {days}天
  String getDaysOnly(int days) {
    switch (locale.languageCode) {
      case 'ja':
        return '${days}日間';
      case 'zh':
        return '${days}天';
      default:
        return '$days days';
    }
  }

  // 智能行程規劃助理
  String get smartTripAssistant {
    switch (locale.languageCode) {
      case 'ja':
        return 'スマート旅程プランナー';
      case 'zh':
        return '智能行程規劃助理';
      default:
        return 'Smart Trip Assistant';
    }
  }

  // 行程成員
  String get itineraryMembers {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程メンバー';
      case 'zh':
        return '行程成員';
      default:
        return 'Itinerary Members';
    }
  }

  // 行程概覽
  String get itineraryOverview {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程概要';
      case 'zh':
        return '行程概覽';
      default:
        return 'Itinerary Overview';
    }
  }

  // 尚無景點
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

  // 點擊下方按鈕添加第一個景點
  String get clickToAddFirstSpot {
    switch (locale.languageCode) {
      case 'ja':
        return '下のボタンをクリックして最初のスポットを追加';
      case 'zh':
        return '點擊下方按鈕添加第一個景點';
      default:
        return 'Click the button below to add your first spot';
    }
  }

  // 尚未設定行程成員
  String get noMembersSet {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程メンバーが設定されていません';
      case 'zh':
        return '尚未設定行程成員';
      default:
        return 'No members set';
    }
  }

  // 載入景點資訊時發生錯誤
  String get errorLoadingSpotInfo {
    switch (locale.languageCode) {
      case 'ja':
        return 'スポット情報の読み込み中にエラーが発生しました';
      case 'zh':
        return '載入景點資訊時發生錯誤';
      default:
        return 'Error loading spot information';
    }
  }

  // 第{day}天資訊
  String getDayInfo(int day) {
    switch (locale.languageCode) {
      case 'ja':
        return '第${day}日の情報';
      case 'zh':
        return '第${day}天資訊';
      default:
        return 'Day $day information';
    }
  }

  // 景點數量
  String get spotCount {
    switch (locale.languageCode) {
      case 'ja':
        return 'スポット数: ';
      case 'zh':
        return '景點數量: ';
      default:
        return 'Spot count: ';
    }
  }

  // 交通方式
  String get transportationMethod {
    switch (locale.languageCode) {
      case 'ja':
        return '交通手段: ';
      case 'zh':
        return '交通方式: ';
      default:
        return 'Transportation: ';
    }
  }

  // 景點列表
  String get spotList {
    switch (locale.languageCode) {
      case 'ja':
        return 'スポット一覧';
      case 'zh':
        return '景點列表';
      default:
        return 'Spot List';
    }
  }

  // 選擇目的地
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

  // 小時
  String get hours {
    switch (locale.languageCode) {
      case 'ja':
        return '時間';
      case 'zh':
        return '時';
      default:
        return 'hours';
    }
  }

  // 分鐘
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

  // === 規劃選項對話框 ===
  
  // 您希望？
  String get planningOptionTitle {
    switch (locale.languageCode) {
      case 'ja':
        return 'ご希望は？';
      case 'zh':
        return '您希望？';
      default:
        return 'What would you like?';
    }
  }

  // 覆蓋現有行程，進行完整規劃
  String get overwriteOption {
    switch (locale.languageCode) {
      case 'ja':
        return '既存の行程を上書きして、完全な計画を作成';
      case 'zh':
        return '覆蓋現有行程，進行完整規劃';
      default:
        return 'Overwrite existing itinerary and create complete plan';
    }
  }

  // 刪除所有已選的景點，重新規劃整個行程
  String get overwriteDescription {
    switch (locale.languageCode) {
      case 'ja':
        return '選択された全てのスポットを削除し、全体の行程を再計画';
      case 'zh':
        return '刪除所有已選的景點，重新規劃整個行程';
      default:
        return 'Remove all selected spots and re-plan the entire itinerary';
    }
  }

  // 保留已選的行程進行規劃
  String get preserveOption {
    switch (locale.languageCode) {
      case 'ja':
        return '選択済みの行程を保持して計画';
      case 'zh':
        return '保留已選的行程進行規劃';
      default:
        return 'Keep selected itinerary and continue planning';
    }
  }

  // 根據已選景點，繼續規劃其他景點和活動
  String get preserveDescription {
    switch (locale.languageCode) {
      case 'ja':
        return '選択済みのスポットに基づいて、他のスポットやアクティビティを計画';
      case 'zh':
        return '根據已選景點，繼續規劃其他景點和活動';
      default:
        return 'Based on selected spots, continue planning other spots and activities';
    }
  }

  // === 預算設定對話框 ===
  
  // 設定行程預算
  String get setBudgetTitle {
    switch (locale.languageCode) {
      case 'ja':
        return '旅程予算を設定';
      case 'zh':
        return '設定行程預算';
      default:
        return 'Set Itinerary Budget';
    }
  }

  // 設定每人預算
  String get setBudgetPerPerson {
    switch (locale.languageCode) {
      case 'ja':
        return '一人当たりの予算を設定';
      case 'zh':
        return '設定每人預算';
      default:
        return 'Set budget per person';
    }
  }

  // 不設定
  String get noSetting {
    switch (locale.languageCode) {
      case 'ja':
        return '設定しない';
      case 'zh':
        return '不設定';
      default:
        return 'No setting';
    }
  }

  // 最低
  String get minimum {
    switch (locale.languageCode) {
      case 'ja':
        return '最低';
      case 'zh':
        return '最低';
      default:
        return 'Min';
    }
  }

  // 最高
  String get maximum {
    switch (locale.languageCode) {
      case 'ja':
        return '最高';
      case 'zh':
        return '最高';
      default:
        return 'Max';
    }
  }

  // 貨幣單位
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

  // === 新增到天數對話框 ===
  
  // 選擇添加到哪一天
  String get selectDayToAdd {
    switch (locale.languageCode) {
      case 'ja':
        return 'どの日に追加するか選択';
      case 'zh':
        return '選擇添加到哪一天';
      default:
        return 'Select which day to add to';
    }
  }

  // 添加為第一個景點
  String get addAsFirstSpot {
    switch (locale.languageCode) {
      case 'ja':
        return '最初のスポットとして追加';
      case 'zh':
        return '添加為第一個景點';
      default:
        return 'Add as first spot';
    }
  }

  // 前一個景點
  String get previousSpot {
    switch (locale.languageCode) {
      case 'ja':
        return '前のスポット';
      case 'zh':
        return '前一個景點';
      default:
        return 'Previous spot';
    }
  }

  // 新增景點
  String get newSpot {
    switch (locale.languageCode) {
      case 'ja':
        return '新しいスポット';
      case 'zh':
        return '新增景點';
      default:
        return 'New spot';
    }
  }

  // 下一個景點
  String get nextSpot {
    switch (locale.languageCode) {
      case 'ja':
        return '次のスポット';
      case 'zh':
        return '下一個景點';
      default:
        return 'Next spot';
    }
  }

  // === 收藏功能相關 ===
  
  // 收藏功能
  String get favoriteFeature {
    switch (locale.languageCode) {
      case 'ja':
        return 'お気に入り機能';
      case 'zh':
        return '收藏功能';
      default:
        return 'Favorite feature';
    }
  }

  // 口袋清單
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

  // 加入收藏
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

  // === 交通工具選項 ===
  
  // 汽車
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

  // 自行車
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

  // 大眾運輸
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

  // 步行
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

  // 設置交通方式
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

  // 耗時
  String get timeRequired {
    switch (locale.languageCode) {
      case 'ja':
        return '所要時間: ';
      case 'zh':
        return '耗時: ';
      default:
        return 'Time: ';
    }
  }

  // === 添加景点选项 ===
  
  // 插入新景點
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

  // 從地圖搜尋
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

  // 區域搜尋
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

  // 從收藏選擇
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

  // 智慧推薦
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

  // 智慧推薦功能開發中
  String get smartRecommendationInDevelopment {
    switch (locale.languageCode) {
      case 'ja':
        return 'スマート推薦機能は開発中です...';
      case 'zh':
        return '智慧推薦功能開發中...';
      default:
        return 'Smart recommendation feature is under development...';
    }
  }

  // --- 主頁詳細頁面 Tabs ---
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
        return '近くのスポット';
      case 'zh':
        return '附近景點';
      default:
        return 'Nearby';
    }
  }
  String get introduction {
    switch (locale.languageCode) {
      case 'ja':
        return 'スポット紹介';
      case 'zh':
        return '景點介紹';
      default:
        return 'Introduction';
    }
  }
  String get suggestedVisitTime {
    switch (locale.languageCode) {
      case 'ja':
        return 'おすすめ滞在時間';
      case 'zh':
        return '建議遊覽時間';
      default:
        return 'Suggested visit time';
    }
  }
  String get defaultDescription {
    switch (locale.languageCode) {
      case 'ja':
        return 'ここは素晴らしいスポットです。ぜひ訪れてみてください。';
      case 'zh':
        return '這是一個值得探索的精彩景點，等待著您的到來。在這裡，您可以體驗到獨特的文化魅力和美麗的風景。';
      default:
        return 'This is a wonderful place to explore, waiting for your visit.';
    }
  }
  String get share {
    switch (locale.languageCode) {
      case 'ja':
        return 'シェア';
      case 'zh':
        return '分享';
      default:
        return 'Share';
    }
  }
  String get shareNotImplemented {
    switch (locale.languageCode) {
      case 'ja':
        return 'シェア機能は未実装です';
      case 'zh':
        return '分享功能尚未實現';
      default:
        return 'Share feature not implemented yet';
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
        return '自然';
      case 'zh':
        return '自然景觀';
      default:
        return 'Natural Feature';
    }
  }

  // 需要登入標題
  String get loginRequiredTitle {
    switch (locale.languageCode) {
      case 'ja':
        return 'ログインが必要です';
      case 'zh':
        return '需要登入';
      default:
        return 'Login Required';
    }
  }

  // 需要登入訊息
  String loginRequiredMessage(String feature) {
    switch (locale.languageCode) {
      case 'ja':
        return '「$feature」機能を利用するにはログインが必要です';
      case 'zh':
        return '使用「$feature」功能需要先登入帳號';
      default:
        return 'You need to log in to use "$feature".';
    }
  }

  // 雲端同步標題
  String get cloudSyncTitle {
    switch (locale.languageCode) {
      case 'ja':
        return 'クラウド同期機能';
      case 'zh':
        return '雲端同步功能';
      default:
        return 'Cloud Sync';
    }
  }

  // 雲端同步說明
  String get cloudSyncDesc {
    switch (locale.languageCode) {
      case 'ja':
        return '• データはクラウドに安全に保存\n• 複数デバイスで同期\n• 永久保存で紛失しません';
      case 'zh':
        return '• 資料安全儲存在雲端\n• 多裝置同步存取\n• 永久保存不丟失';
      default:
        return '• Data securely stored in the cloud\n• Sync across devices\n• Permanently saved';
    }
  }

  // 稍後再說
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

  // 登入成功
  String get loginSuccess {
    switch (locale.languageCode) {
      case 'ja':
        return 'ログイン成功！この機能が利用できます';
      case 'zh':
        return '登入成功！現在可以使用此功能了';
      default:
        return 'Login successful! You can now use this feature.';
    }
  }

  // 登入失敗
  String get loginFailed {
    switch (locale.languageCode) {
      case 'ja':
        return 'ログインページに移動できません。しばらくしてから再試行してください';
      case 'zh':
        return '無法跳轉到登入頁面，請稍後再試';
      default:
        return 'Unable to navigate to login page. Please try again later.';
    }
  }

  // 立即登入
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
