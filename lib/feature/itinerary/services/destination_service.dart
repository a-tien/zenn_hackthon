import '../models/destination.dart';

class DestinationService {  // 熱門國內地點（日本）
  static List<Destination> getPopularDomesticDestinations() {
    return [
      Destination(
        id: 'sapporo',
        name: '札幌',
        country: '日本',
        prefecture: '北海道',
        type: 'domestic',
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 43.0642,
        longitude: 141.3469,
      ),
      Destination(
        id: 'hakodate',
        name: '函館',
        country: '日本',
        prefecture: '北海道',
        type: 'domestic',
        imageUrl: 'https://images.unsplash.com/photo-1590736969955-71cc94901144?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 41.7687,
        longitude: 140.7290,
      ),
      Destination(
        id: 'tokyo',
        name: '東京',
        country: '日本',
        prefecture: '東京都',
        type: 'domestic',
        imageUrl: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 35.6762,
        longitude: 139.6503,
      ),
      Destination(
        id: 'osaka',
        name: '大阪',
        country: '日本',
        prefecture: '大阪府',
        type: 'domestic',
        imageUrl: 'https://images.unsplash.com/photo-1589452271712-64b8a66c7b64?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 34.6937,
        longitude: 135.5023,
      ),
      Destination(
        id: 'kyoto',
        name: '京都',
        country: '日本',
        prefecture: '京都府',
        type: 'domestic',
        imageUrl: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 35.0116,
        longitude: 135.7681,
      ),
      Destination(
        id: 'nara',
        name: '奈良',
        country: '日本',
        prefecture: '奈良縣',
        type: 'domestic',
        imageUrl: 'https://images.unsplash.com/photo-1578895210-2c91b6e28b3e?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 34.6851,
        longitude: 135.8048,
      ),
      Destination(
        id: 'yokohama',
        name: '橫濱',
        country: '日本',
        prefecture: '神奈川縣',
        type: 'domestic',
        imageUrl: 'https://images.unsplash.com/photo-1553986909-ca8acf9b7ac8?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 35.4437,
        longitude: 139.6380,
      ),
      Destination(
        id: 'hiroshima',
        name: '廣島',
        country: '日本',
        prefecture: '廣島縣',
        type: 'domestic',
        imageUrl: 'https://images.unsplash.com/photo-1588558351b5-a2a6e73b57fb?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 34.3853,
        longitude: 132.4553,
      ),      Destination(
        id: 'fukuoka',
        name: '福岡',
        country: '日本',
        prefecture: '福岡縣',
        type: 'domestic',
        imageUrl: 'https://images.unsplash.com/photo-1590736969955-71cc94901144?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 33.5904,
        longitude: 130.4017,
      ),
      Destination(
        id: 'okinawa',
        name: '沖繩',
        country: '日本',
        prefecture: '沖繩縣',
        type: 'domestic',
        imageUrl: 'https://images.unsplash.com/photo-1564544966451-e023d6372ab4?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 26.2124,
        longitude: 127.6792,
      ),
      Destination(
        id: 'nagoya',
        name: '名古屋',
        country: '日本',
        prefecture: '愛知縣',
        type: 'domestic',
        imageUrl: 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 35.1815,
        longitude: 136.9066,
      ),      Destination(
        id: 'kanazawa',
        name: '金澤',
        country: '日本',
        prefecture: '石川縣',
        type: 'domestic',
        imageUrl: 'https://images.unsplash.com/photo-1549048172-4b0e70ea8d10?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 36.5619,
        longitude: 136.6562,
      ),
    ];
  }

  // 熱門國外地點
  static List<Destination> getPopularInternationalDestinations() {
    return [      Destination(
        id: 'paris',
        name: '巴黎',
        country: '法國',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1502602898536-47ad22581b52?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 48.8566,
        longitude: 2.3522,
      ),
      Destination(
        id: 'london',
        name: '倫敦',
        country: '英國',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 51.5074,
        longitude: -0.1278,
      ),
      Destination(
        id: 'rome',
        name: '羅馬',
        country: '義大利',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 41.9028,
        longitude: 12.4964,
      ),
      Destination(
        id: 'barcelona',
        name: '巴塞隆納',
        country: '西班牙',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1539650116574-75c0c6d73aff?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 41.3851,
        longitude: 2.1734,
      ),
      Destination(
        id: 'amsterdam',
        name: '阿姆斯特丹',
        country: '荷蘭',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1534351590666-13e3e96b5017?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 52.3676,
        longitude: 4.9041,
      ),
      Destination(
        id: 'berlin',
        name: '柏林',
        country: '德國',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1560930950-5cc20e80d392?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 52.5200,
        longitude: 13.4050,
      ),
      Destination(
        id: 'vienna',
        name: '維也納',
        country: '奧地利',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1516550135131-fe3dcb0bedc7?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 48.2082,
        longitude: 16.3738,
      ),
      Destination(
        id: 'prague',
        name: '布拉格',
        country: '捷克',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1541849546-216549ae216d?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 50.0755,
        longitude: 14.4378,
      ),
      Destination(
        id: 'seoul',
        name: '首爾',
        country: '韓國',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1599367815384-3c1c47b2c17f?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 37.5665,
        longitude: 126.9780,
      ),
      Destination(
        id: 'singapore',
        name: '新加坡',
        country: '新加坡',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1525625293386-3f8f99389edd?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 1.3521,
        longitude: 103.8198,
      ),
      Destination(
        id: 'hongkong',
        name: '香港',
        country: '中國',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1536599018102-9f803c140fc1?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 22.3193,
        longitude: 114.1694,
      ),
      Destination(
        id: 'taipei',
        name: '台北',
        country: '台灣',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1508584454580-6eb4f0fa17b8?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 25.0330,
        longitude: 121.5654,
      ),
      Destination(
        id: 'bangkok',
        name: '曼谷',
        country: '泰國',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1506665531195-3566af2b4dfa?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 13.7563,
        longitude: 100.5018,
      ),      Destination(
        id: 'sydney',
        name: '雪梨',
        country: '澳洲',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: -33.8688,
        longitude: 151.2093,
      ),
      Destination(
        id: 'newyork',
        name: '紐約',
        country: '美國',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 40.7128,
        longitude: -74.0060,
      ),
      Destination(
        id: 'losangeles',
        name: '洛杉磯',
        country: '美國',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1534281219520-bc2e1b0f26ea?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 34.0522,
        longitude: -118.2437,
      ),
      Destination(
        id: 'vancouver',
        name: '溫哥華',
        country: '加拿大',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1549924231-f129b911e442?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 49.2827,
        longitude: -123.1207,
      ),
      Destination(
        id: 'toronto',
        name: '多倫多',
        country: '加拿大',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1517935706615-2717063c2225?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 43.6532,
        longitude: -79.3832,
      ),
      Destination(
        id: 'reykjavik',
        name: '雷克雅維克',
        country: '冰島',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1539650116574-75c0c6d73aff?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 64.1466,
        longitude: -21.9426,
      ),
      Destination(
        id: 'dubai',
        name: '杜拜',
        country: '阿聯酋',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1518684079-3c830dcef090?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 25.2048,
        longitude: 55.2708,
      ),
      Destination(
        id: 'istanbul',
        name: '伊斯坦堡',
        country: '土耳其',
        type: 'international',
        imageUrl: 'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?auto=format&fit=crop&w=300&q=80',
        isPopular: true,
        latitude: 41.0082,
        longitude: 28.9784,
      ),
    ];
  }
  // 所有日本都道府縣和城市
  static Map<String, List<Destination>> getDomesticDestinations() {
    return {
      '北海道': [
        Destination(id: 'sapporo', name: '札幌', country: '日本', prefecture: '北海道', type: 'domestic', latitude: 43.0642, longitude: 141.3469),
        Destination(id: 'hakodate', name: '函館', country: '日本', prefecture: '北海道', type: 'domestic', latitude: 41.7687, longitude: 140.7290),
        Destination(id: 'asahikawa', name: '旭川', country: '日本', prefecture: '北海道', type: 'domestic', latitude: 43.7711, longitude: 142.3649),
        Destination(id: 'kushiro', name: '釧路', country: '日本', prefecture: '北海道', type: 'domestic', latitude: 42.9849, longitude: 144.3820),
        Destination(id: 'obihiro', name: '帶廣', country: '日本', prefecture: '北海道', type: 'domestic', latitude: 42.9236, longitude: 143.2025),
      ],
      '東京都': [
        Destination(id: 'tokyo', name: '東京', country: '日本', prefecture: '東京都', type: 'domestic', latitude: 35.6762, longitude: 139.6503),
        Destination(id: 'shibuya', name: '澀谷', country: '日本', prefecture: '東京都', type: 'domestic', latitude: 35.6580, longitude: 139.7016),
        Destination(id: 'shinjuku', name: '新宿', country: '日本', prefecture: '東京都', type: 'domestic', latitude: 35.6896, longitude: 139.6917),
        Destination(id: 'harajuku', name: '原宿', country: '日本', prefecture: '東京都', type: 'domestic', latitude: 35.6702, longitude: 139.7026),
        Destination(id: 'asakusa', name: '淺草', country: '日本', prefecture: '東京都', type: 'domestic', latitude: 35.7148, longitude: 139.7967),
      ],
      '大阪府': [
        Destination(id: 'osaka', name: '大阪', country: '日本', prefecture: '大阪府', type: 'domestic', latitude: 34.6937, longitude: 135.5023),
        Destination(id: 'namba', name: '難波', country: '日本', prefecture: '大阪府', type: 'domestic', latitude: 34.6659, longitude: 135.5018),
        Destination(id: 'umeda', name: '梅田', country: '日本', prefecture: '大阪府', type: 'domestic', latitude: 34.7024, longitude: 135.4959),
        Destination(id: 'tennoji', name: '天王寺', country: '日本', prefecture: '大阪府', type: 'domestic', latitude: 34.6452, longitude: 135.5066),
      ],
      '京都府': [
        Destination(id: 'kyoto', name: '京都', country: '日本', prefecture: '京都府', type: 'domestic', latitude: 35.0116, longitude: 135.7681),
        Destination(id: 'arashiyama', name: '嵐山', country: '日本', prefecture: '京都府', type: 'domestic', latitude: 35.0175, longitude: 135.6761),
        Destination(id: 'gion', name: '祇園', country: '日本', prefecture: '京都府', type: 'domestic', latitude: 35.0037, longitude: 135.7751),
      ],
      '神奈川縣': [
        Destination(id: 'yokohama', name: '橫濱', country: '日本', prefecture: '神奈川縣', type: 'domestic', latitude: 35.4437, longitude: 139.6380),
        Destination(id: 'kamakura', name: '鎌倉', country: '日本', prefecture: '神奈川縣', type: 'domestic', latitude: 35.3191, longitude: 139.5466),
        Destination(id: 'hakone', name: '箱根', country: '日本', prefecture: '神奈川縣', type: 'domestic', latitude: 35.2323, longitude: 139.1070),
      ],
      '愛知縣': [
        Destination(id: 'nagoya', name: '名古屋', country: '日本', prefecture: '愛知縣', type: 'domestic', latitude: 35.1815, longitude: 136.9066),
      ],
      '福岡縣': [
        Destination(id: 'fukuoka', name: '福岡', country: '日本', prefecture: '福岡縣', type: 'domestic', latitude: 33.5904, longitude: 130.4017),
      ],
      '沖繩縣': [
        Destination(id: 'okinawa', name: '沖繩', country: '日本', prefecture: '沖繩縣', type: 'domestic', latitude: 26.2124, longitude: 127.6792),
        Destination(id: 'naha', name: '那霸', country: '日本', prefecture: '沖繩縣', type: 'domestic', latitude: 26.2124, longitude: 127.6792),
      ],
    };
  }
  // 國外目的地（按國家分組）
  static Map<String, List<Destination>> getInternationalDestinations() {
    return {
      '美國': [
        Destination(id: 'newyork', name: '紐約', country: '美國', type: 'international', latitude: 40.7128, longitude: -74.0060),
        Destination(id: 'losangeles', name: '洛杉磯', country: '美國', type: 'international', latitude: 34.0522, longitude: -118.2437),
        Destination(id: 'chicago', name: '芝加哥', country: '美國', type: 'international', latitude: 41.8781, longitude: -87.6298),
        Destination(id: 'sanfrancisco', name: '舊金山', country: '美國', type: 'international', latitude: 37.7749, longitude: -122.4194),
      ],
      '法國': [
        Destination(id: 'paris', name: '巴黎', country: '法國', type: 'international', latitude: 48.8566, longitude: 2.3522),
        Destination(id: 'nice', name: '尼斯', country: '法國', type: 'international', latitude: 43.7102, longitude: 7.2620),
        Destination(id: 'lyon', name: '里昂', country: '法國', type: 'international', latitude: 45.7640, longitude: 4.8357),
      ],
      '英國': [
        Destination(id: 'london', name: '倫敦', country: '英國', type: 'international', latitude: 51.5074, longitude: -0.1278),
        Destination(id: 'manchester', name: '曼徹斯特', country: '英國', type: 'international', latitude: 53.4808, longitude: -2.2426),
        Destination(id: 'edinburgh', name: '愛丁堡', country: '英國', type: 'international', latitude: 55.9533, longitude: -3.1883),
      ],
      '韓國': [
        Destination(id: 'seoul', name: '首爾', country: '韓國', type: 'international', latitude: 37.5665, longitude: 126.9780),
        Destination(id: 'busan', name: '釜山', country: '韓國', type: 'international', latitude: 35.1796, longitude: 129.0756),
        Destination(id: 'jeju', name: '濟州', country: '韓國', type: 'international', latitude: 33.4996, longitude: 126.5312),
      ],
      '泰國': [
        Destination(id: 'bangkok', name: '曼谷', country: '泰國', type: 'international', latitude: 13.7563, longitude: 100.5018),
        Destination(id: 'phuket', name: '普吉島', country: '泰國', type: 'international', latitude: 7.8804, longitude: 98.3923),
        Destination(id: 'chiangmai', name: '清邁', country: '泰國', type: 'international', latitude: 18.7883, longitude: 98.9853),
      ],
      '新加坡': [
        Destination(id: 'singapore', name: '新加坡', country: '新加坡', type: 'international', latitude: 1.3521, longitude: 103.8198),
      ],
      '澳洲': [
        Destination(id: 'sydney', name: '雪梨', country: '澳洲', type: 'international', latitude: -33.8688, longitude: 151.2093),
        Destination(id: 'melbourne', name: '墨爾本', country: '澳洲', type: 'international', latitude: -37.8136, longitude: 144.9631),
        Destination(id: 'brisbane', name: '布里斯本', country: '澳洲', type: 'international', latitude: -27.4698, longitude: 153.0251),
      ],
      '加拿大': [
        Destination(id: 'vancouver', name: '溫哥華', country: '加拿大', type: 'international', latitude: 49.2827, longitude: -123.1207),
        Destination(id: 'toronto', name: '多倫多', country: '加拿大', type: 'international', latitude: 43.6532, longitude: -79.3832),
        Destination(id: 'montreal', name: '蒙特婁', country: '加拿大', type: 'international', latitude: 45.5017, longitude: -73.5673),
      ],
    };
  }

  // 搜尋目的地
  static List<Destination> searchDestinations(String query) {
    final allDestinations = <Destination>[];
    
    // 添加所有熱門地點
    allDestinations.addAll(getPopularDomesticDestinations());
    allDestinations.addAll(getPopularInternationalDestinations());
    
    // 添加所有國內地點
    getDomesticDestinations().values.forEach((destinations) {
      allDestinations.addAll(destinations);
    });
    
    // 添加所有國外地點
    getInternationalDestinations().values.forEach((destinations) {
      allDestinations.addAll(destinations);
    });
    
    // 去重
    final uniqueDestinations = <String, Destination>{};
    for (final destination in allDestinations) {
      uniqueDestinations[destination.id] = destination;
    }
    
    // 搜尋
    if (query.isEmpty) {
      return uniqueDestinations.values.toList();
    }
    
    return uniqueDestinations.values
        .where((destination) =>
            destination.name.toLowerCase().contains(query.toLowerCase()) ||
            destination.country.toLowerCase().contains(query.toLowerCase()) ||
            (destination.prefecture?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .toList();
  }
}
