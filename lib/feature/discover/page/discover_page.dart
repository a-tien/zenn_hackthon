import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'discover_destinations_page.dart';
import '../../collection/pages/spot_detail_page.dart';
import '../../collection/models/favorite_spot.dart';
import '../../collection/components/add_to_itinerary_dialog.dart';
import '../../itinerary/models/destination.dart';
import '../components/add_to_collection_dialog.dart';
import '../services/places_api_service.dart';

enum SortType {
  rating,
  distance,
}

class _SpotType {
  final String label;
  final IconData icon;
  final String markerAsset;
  final List<String> keywords;
  
  const _SpotType(this.label, this.icon, this.markerAsset, this.keywords);
}

class DiscoverPage extends StatefulWidget {
  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  SortType _selectedSort = SortType.rating;
  bool _isMapView = true;
  Destination? _selectedDestination;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<FavoriteSpot> _currentSpots = [];
  bool _isLoadingSpots = false;
  LatLng? _currentLocation;
  Circle? _currentLocationCircle;
  final TextEditingController _searchController = TextEditingController();
  List<FavoriteSpot> _searchResults = [];
  LatLng? _lastMapCenter;
  Map<String, BitmapDescriptor> _customMarkers = {};

  // 景點類型定義
  final List<_SpotType> _spotTypes = [
    _SpotType('全選', Icons.select_all, '', []),
    _SpotType('景點/觀光', Icons.location_on, 'icons/attraction_marker.svg', ['tourist_attraction', 'museum', 'art_gallery', 'aquarium', 'zoo', 'stadium','torist_attraction', 'landmark']),
    _SpotType('美食/餐廳', Icons.restaurant, 'icons/restaurant_marker.svg', ['restaurant', 'cafe', 'bakery', 'bar', 'meal_takeaway', 'meal_delivery']),
    _SpotType('購物', Icons.shopping_bag, 'icons/shopping_marker.svg', ['shopping_mall', 'store', 'clothing_store', 'electronics_store', 'book_store', 'jewelry_store', 'shoe_store', 'supermarket', 'convenience_store', 'department_store']),
    _SpotType('住宿', Icons.hotel, 'icons/hotel_marker.svg', ['lodging', 'rv_park', 'campground']),
    _SpotType('交通', Icons.train, 'icons/transport_marker.svg', ['train_station', 'subway_station', 'bus_station', 'light_rail_station', 'transit_station', 'airport', 'taxi_stand']),
    _SpotType('醫療/健康', Icons.local_hospital, 'icons/health_marker.svg', ['hospital', 'doctor', 'dentist', 'pharmacy', 'physiotherapist', 'veterinary_care', 'beauty_salon', 'hair_care', 'spa', 'gym']),
    _SpotType('教育/宗教', Icons.school, 'icons/education_marker.svg', ['school', 'primary_school', 'secondary_school', 'university', 'library', 'church', 'mosque', 'synagogue', 'hindu_temple']),
    _SpotType('服務/金融', Icons.business, 'icons/service_marker.svg', ['bank', 'atm', 'post_office', 'insurance_agency', 'real_estate_agency', 'lawyer', 'accountant', 'travel_agency']),
    _SpotType('娛樂/夜生活', Icons.nightlife, 'icons/entertainment_marker.svg', ['movie_theater', 'night_club', 'casino', 'bowling_alley']),
    _SpotType('汽車服務', Icons.car_repair, 'icons/car_service_marker.svg', ['gas_station', 'car_dealer', 'car_rental', 'car_repair', 'car_wash', 'parking']),
    _SpotType('其他服務', Icons.build, 'icons/other_marker.svg', ['electrician', 'plumber', 'locksmith', 'painter', 'roofing_contractor', 'moving_company', 'storage', 'laundry']),
  ];
  
  Set<int> _selectedTypeIndexes = {0}; // 預設全選

  // 預設位置：札幌市中心
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(43.0642, 141.3469),
    zoom: 12.0,
  );
  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
    _loadSpots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 根據類別獲取對應圖標
  IconData _getIconForCategory(String category) {
    String lowerCategory = category.toLowerCase();
    
    for (int i = 1; i < _spotTypes.length; i++) {
      final spotType = _spotTypes[i];
      if (spotType.keywords.any((keyword) => lowerCategory.contains(keyword.toLowerCase()))) {
        return spotType.icon;
      }
    }
    return Icons.location_on; // 預設圖標
  }

  // 根據類別獲取對應的 marker asset 路徑
  String _getMarkerAssetForCategory(String category) {
    String lowerCategory = category.toLowerCase();
    
    for (int i = 1; i < _spotTypes.length; i++) {
      final spotType = _spotTypes[i];
      if (spotType.keywords.any((keyword) => lowerCategory.contains(keyword.toLowerCase()))) {
        return spotType.markerAsset;
      }
    }
    return 'icons/attraction_marker.svg'; // 預設圖標
  }

  // 獲取過濾後的景點列表
  List<FavoriteSpot> get _filteredSpots {
    final spots = _searchResults.isNotEmpty ? _searchResults : _currentSpots;
    print('[DEBUG] 所有景點類型:');
    for (var s in spots) {
      print('${s.name} - ${s.category}');
    }
    // 如果選中全選，返回所有景點
    if (_selectedTypeIndexes.contains(0)) {
      return spots;
    }
    
    // 獲取所有選中類型的關鍵字
    Set<String> selectedKeywords = {};
    for (int index in _selectedTypeIndexes) {
      if (index < _spotTypes.length) {
        selectedKeywords.addAll(_spotTypes[index].keywords);
      }
    }

    print('選取類型: $selectedKeywords');
    print('景點類型: ${spots.map((e) => e.category).toList()}');

    
    // 過濾景點
    return spots.where((spot) {
      String lowerCategory = spot.category.toLowerCase();
      return selectedKeywords.any((keyword) => lowerCategory.contains(keyword.toLowerCase()));
    }).toList();
  }
  // 獲取地圖標記顏色
  double _getMarkerHue(IconData iconData) {
    if (iconData == Icons.restaurant) return BitmapDescriptor.hueOrange; // 橙色 - 餐廳
    if (iconData == Icons.shopping_bag) return BitmapDescriptor.hueBlue; // 藍色 - 購物
    if (iconData == Icons.hotel) return BitmapDescriptor.hueRose; // 玫瑰色 - 住宿
    if (iconData == Icons.train) return BitmapDescriptor.hueAzure; // 青色 - 交通
    if (iconData == Icons.local_hospital) return BitmapDescriptor.hueGreen; // 綠色 - 醫療/健康
    if (iconData == Icons.school) return BitmapDescriptor.hueYellow; // 黃色 - 教育/宗教
    if (iconData == Icons.business) return BitmapDescriptor.hueViolet; // 紫色 - 服務/金融
    if (iconData == Icons.nightlife) return BitmapDescriptor.hueMagenta; // 洋紅色 - 娛樂/夜生活
    if (iconData == Icons.car_repair) return BitmapDescriptor.hueCyan; // 青綠色 - 汽車服務
    if (iconData == Icons.build) return BitmapDescriptor.hueOrange; // 橙色 - 其他服務
    return BitmapDescriptor.hueRed; // 紅色 - 景點觀光(預設)
  }

  Future<void> _loadCustomMarkers() async {
    for (final spotType in _spotTypes) {
      if (spotType.markerAsset.isNotEmpty) {
        try {
          final markerIcon = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(48, 48)),
            spotType.markerAsset,
          );
          _customMarkers[spotType.markerAsset] = markerIcon;
        } catch (e) {
          print('Error loading marker asset ${spotType.markerAsset}: $e');
        }
      }
    }
    // 確保預設 marker 也被加載
    if (!_customMarkers.containsKey('icons/attraction_marker.svg')) {
       try {
          final defaultIcon = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(48, 48)),
            'icons/attraction_marker.svg',
          );
          _customMarkers['icons/attraction_marker.svg'] = defaultIcon;
        } catch (e) {
          print('Error loading default marker asset: $e');
        }
    }
  }

  void _loadSpots() async {
    setState(() {
      _isLoadingSpots = true;
    });

    try {
      List<FavoriteSpot> spots;
        if (_selectedDestination != null && 
          _selectedDestination!.latitude != null && 
          _selectedDestination!.longitude != null) {
        // 使用 API 獲取該地區的多種類型景點
        spots = await PlacesApiService.searchNearbyPlacesMultipleTypes(
          latitude: _selectedDestination!.latitude!,
          longitude: _selectedDestination!.longitude!,
          radius: 15000,
          types: ['tourist_attraction', 'restaurant', 'cafe', 'shopping_mall', 
                  'hospital', 'bank', 'gas_station', 'hotel', 'museum', 
                  'amusement_park', 'train_station', 'airport'],
        );
        
        // 如果 API 沒有返回結果，使用示例數據
        if (spots.isEmpty) {
          spots = _getExampleSpots();
        }
      } else {
        // 沒有選擇目的地時使用示例數據
        spots = _getExampleSpots();
      }      setState(() {
        _currentSpots = spots;
        _isLoadingSpots = false;
      });
      
      _initializeMarkers();
    } catch (e) {
      print('Error loading spots: $e');
      setState(() {
        _currentSpots = _getExampleSpots();
        _isLoadingSpots = false;
      });
      _initializeMarkers();
    }
  }
  void _initializeMarkers() {
    final filteredSpots = _filteredSpots;
  
    setState(() {
      _markers = filteredSpots.map((spot) {
        final markerAsset = _getMarkerAssetForCategory(spot.category);
        final customIcon = _customMarkers[markerAsset];

        return Marker(
          markerId: MarkerId(spot.id),
          position: LatLng(spot.latitude, spot.longitude),
          icon: customIcon ?? BitmapDescriptor.defaultMarker, // 如果自訂圖標加載失敗，使用預設圖標
          infoWindow: InfoWindow(
            title: spot.name,
            snippet: '⭐ ${spot.rating} (${spot.reviewCount}評論)\n點擊查看詳細資訊',
            onTap: () {
              _showSpotDetailsWithApi(spot);
            },
          ),
        );
      }).toSet();
    });
    
  }

  void _showSpotDetails(FavoriteSpot spot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 拖拽指示器
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 景點信息
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          spot.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            spot.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    spot.address,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    spot.description,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 按鈕
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (context) => AddToCollectionDialog(spot: spot),
                            );
                          },
                          icon: const Icon(Icons.bookmark_add, size: 16),
                          label: const Text('加入收藏'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blueAccent,
                            side: const BorderSide(color: Colors.blueAccent),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (context) => AddToItineraryDialog(spot: spot),
                            );
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('加入行程'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 查看詳情按鈕
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SpotDetailPage(spot: spot),
                          ),
                        );
                      },
                      child: const Text('查看詳細資訊'),
                    ),
                  ),
                ],
              ),
            ),          ),
        ),
      ),
    );
  }

  void _navigateToSelectArea() async {
    final result = await Navigator.push<Destination>(
      context,
      MaterialPageRoute(builder: (context) => const DiscoverDestinationsPage()),
    );

    if (result != null) {
      setState(() {
        _selectedDestination = result;
      });
      
      // 重新加載該地區的景點
      _loadSpots();
      
      // 如果在地圖視圖，移動到選擇的目的地
      if (_isMapView && _mapController != null) {
        _moveToDestination(result);
      }
    }
  }
  void _moveToDestination(Destination destination) {
    if (destination.latitude != null && destination.longitude != null) {
      final position = CameraPosition(
        target: LatLng(destination.latitude!, destination.longitude!),
        zoom: 12.0,
      );
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(position),
      );
    }
  }

  void _showSortOptions() async {
    SortType tempSort = _selectedSort;
    SortType? result = await showDialog<SortType>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('推薦排序'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<SortType>(
                title: const Text('評論 (高→低)'),
                value: SortType.rating,
                groupValue: tempSort,
                onChanged: (value) {
                  setState(() {
                    tempSort = value!;
                  });
                },
              ),
              RadioListTile<SortType>(
                title: const Text('距離 (近→遠)'),
                value: SortType.distance,
                groupValue: tempSort,
                onChanged: (value) {
                  setState(() {
                    tempSort = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, tempSort),
              child: const Text('確定'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedSort = result;
      });
    }
  }
  // 獲取示例景點數據
  List<FavoriteSpot> _getExampleSpots() {
    // 所有景點的完整列表
    final allSpots = [
      // 札幌景點
      FavoriteSpot(
        id: 'spot_hokudai_001',
        name: '北海道大學',
        imageUrl: 'https://images.weserv.nl/?url=daigakujc.jp/smart_phone/top_img/00038/2.jpg',
        address: '日本北海道札幌市北區北8条西5丁目',
        rating: 4.5,
        reviewCount: 1250,        description: '北海道大學是日本最著名的大學之一，校園內有美麗的白樺林道和古色古香的建築。秋季時紅葉環繞，景色特別美麗。',
        category: 'tourist_attraction',
        openingHours: '全天開放，建築內部需遵守各建築開放時間',
        website: 'https://www.hokudai.ac.jp/',
        phone: '+81-11-716-2111',
        latitude: 43.0770474,
        longitude: 141.3408576,
        addedAt: DateTime.now(),
      ),
      FavoriteSpot(
        id: 'spot_sapporo_tv_tower',
        name: '札幌電視塔',
        imageUrl: 'https://images.unsplash.com/photo-1610948237719-5386e03f6d65?auto=format&fit=crop&w=300&q=80',
        address: '日本北海道札幌市中央區大通西1丁目',
        rating: 4.2,
        reviewCount: 890,        description: '札幌的地標建築，可以俯瞰整個大通公園和札幌市區的美景。',
        category: 'tourist_attraction',
        openingHours: '09:00-22:00',
        website: 'https://www.tv-tower.co.jp/',
        phone: '+81-11-241-1131',
        latitude: 43.0609,
        longitude: 141.3565,
        addedAt: DateTime.now(),
      ),      FavoriteSpot(
        id: 'spot_sapporo_ramen',
        name: '拉麵橫丁',
        imageUrl: 'https://images.unsplash.com/photo-1584858574980-cee28babf9cb?auto=format&fit=crop&w=300&q=80',
        address: '日本北海道札幌市中央區薄野',
        rating: 4.6,
        reviewCount: 2100,
        description: '札幌著名的拉麵街，匯集了多家知名拉麵店。',
        category: 'restaurant',
        openingHours: '11:00-02:00（各店舖時間不同）',
        website: '',
        phone: '',
        latitude: 43.0546,
        longitude: 141.3534,
        addedAt: DateTime.now(),
      ),
      
      // 東京景點
      FavoriteSpot(
        id: 'spot_tokyo_tower',
        name: '東京鐵塔',
        imageUrl: 'https://images.unsplash.com/photo-1513407030348-c983a97b98d8?auto=format&fit=crop&w=300&q=80',
        address: '日本東京都港區芝公園4丁目2-8',
        rating: 4.4,
        reviewCount: 2150,
        description: '東京的象徵性地標，高333公尺的紅白色鐵塔，可俯瞰東京全景。',
        category: '景點',
        openingHours: '09:00-23:00',
        website: 'https://www.tokyotower.co.jp/',
        phone: '+81-3-3433-5111',
        latitude: 35.6586,
        longitude: 139.7454,
        addedAt: DateTime.now(),
      ),
      FavoriteSpot(
        id: 'spot_senso_ji',
        name: '淺草寺',
        imageUrl: 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?auto=format&fit=crop&w=300&q=80',
        address: '日本東京都台東區淺草2丁目3-1',
        rating: 4.6,
        reviewCount: 3200,
        description: '東京最古老的佛教寺廟，擁有千年歷史，雷門和仲見世通商店街聞名於世。',
        category: '景點',
        openingHours: '06:00-17:00',
        website: '',
        phone: '',
        latitude: 35.7148,
        longitude: 139.7967,
        addedAt: DateTime.now(),
      ),
      
      // 大阪景點
      FavoriteSpot(
        id: 'spot_osaka_castle',
        name: '大阪城',
        imageUrl: 'https://images.unsplash.com/photo-1590736969955-71cc94901144?auto=format&fit=crop&w=300&q=80',
        address: '日本大阪府大阪市中央區大阪城1-1',
        rating: 4.5,
        reviewCount: 1890,
        description: '日本三大名城之一，豐臣秀吉建造的歷史名城，櫻花季節尤其美麗。',
        category: '景點',
        openingHours: '09:00-17:00',
        website: 'https://www.osakacastle.net/',
        phone: '+81-6-6941-3044',
        latitude: 34.6873,
        longitude: 135.5262,
        addedAt: DateTime.now(),
      ),
      FavoriteSpot(
        id: 'spot_dotonbori',
        name: '道頓堀',
        imageUrl: 'https://images.unsplash.com/photo-1589452271712-64b8a66c7b64?auto=format&fit=crop&w=300&q=80',
        address: '日本大阪府大阪市中央區道頓堀',
        rating: 4.3,
        reviewCount: 2450,
        description: '大阪最熱鬧的商業區，以美食和霓虹燈招牌聞名，是體驗大阪夜生活的絕佳地點。',
        category: '景點',
        openingHours: '全天開放',
        website: '',
        phone: '',
        latitude: 34.6688,
        longitude: 135.5017,
        addedAt: DateTime.now(),
      ),
      FavoriteSpot(
        id: 'spot_tanuki_shopping',
        name: '狸小路商店街',
        imageUrl: 'https://images.unsplash.com/photo-1591793826788-ae2ce68cca7c?auto=format&fit=crop&w=300&q=80',
        address: '日本北海道札幌市中央區南2条西～南3条西',
        rating: 4.1,
        reviewCount: 850,
        description: '札幌最古老的商店街，有各種商店和美食。',
        category: 'shopping_mall',
        openingHours: '10:00-22:00（各店舖時間不同）',
        website: '',
        phone: '',
        latitude: 43.0570,
        longitude: 141.3538,
        addedAt: DateTime.now(),
      ),
      FavoriteSpot(
        id: 'spot_maruyama_park',
        name: '圓山公園',
        imageUrl: 'https://images.unsplash.com/photo-1522383225653-ed111181a951?auto=format&fit=crop&w=300&q=80',
        address: '日本北海道札幌市中央區宮之森',
        rating: 4.4,
        reviewCount: 1200,
        description: '札幌著名的櫻花賞花地點，春季時滿山櫻花盛開。',
        category: 'park',
        openingHours: '全天開放',
        website: '',
        phone: '',
        latitude: 43.0540,
        longitude: 141.3180,
        addedAt: DateTime.now(),
      ),
      FavoriteSpot(
        id: 'spot_hokkaido_museum',
        name: '北海道博物館',
        imageUrl: 'https://images.unsplash.com/photo-1566127992631-137a642a90f4?auto=format&fit=crop&w=300&q=80',
        address: '日本北海道札幌市厚別區厚別町小野幌53-2',
        rating: 4.2,
        reviewCount: 650,
        description: '展示北海道的自然與歷史文化的綜合博物館。',
        category: 'museum',
        openingHours: '09:30-17:00（週一休館）',
        website: 'http://www.hm.pref.hokkaido.lg.jp/',
        phone: '+81-11-898-0466',
        latitude: 43.0205,
        longitude: 141.4619,
        addedAt: DateTime.now(),
      ),
      FavoriteSpot(
        id: 'spot_sapporo_station',
        name: '札幌車站',
        imageUrl: 'https://images.unsplash.com/photo-1544640647-1f040a83de37?auto=format&fit=crop&w=300&q=80',
        address: '日本北海道札幌市北區北6条西4丁目',
        rating: 4.0,
        reviewCount: 2500,
        description: '札幌的主要交通樞紐，連接JR線和地下鐵。',
        category: 'train_station',
        openingHours: '全天開放',
        website: '',
        phone: '',
        latitude: 43.0683,
        longitude: 141.3507,
        addedAt: DateTime.now(),
      ),
      FavoriteSpot(
        id: 'spot_sapporo_cafe',
        name: '札幌咖啡館',
        imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=300&q=80',
        address: '日本北海道札幌市中央區大通西3丁目',
        rating: 4.3,
        reviewCount: 420,        description: '溫馨的咖啡館，提供精品咖啡和手工甜點。',
        category: 'cafe',
        openingHours: '08:00-20:00',
        website: '',
        phone: '+81-11-222-3333',
        latitude: 43.0595,
        longitude: 141.3520,
        addedAt: DateTime.now(),
      ),
      FavoriteSpot(
        id: 'spot_sushi_restaurant',
        name: '札幌壽司店',
        imageUrl: 'https://images.unsplash.com/photo-1559925393-8be0ec4767c8?auto=format&fit=crop&w=300&q=80',
        address: '日本北海道札幌市中央區薄野南4丁目',
        rating: 4.7,
        reviewCount: 890,
        description: '新鮮的北海道海鮮壽司，品質優良。',
        category: 'restaurant',
        openingHours: '17:00-23:00',
        website: '',
        phone: '+81-11-555-7777',
        latitude: 43.0520,
        longitude: 141.3560,
        addedAt: DateTime.now(),
      ),
      FavoriteSpot(
        id: 'spot_sapporo_hospital',
        name: '札幌市立醫院',
        imageUrl: 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=300&q=80',
        address: '日本北海道札幌市中央區北11条西13丁目',
        rating: 4.0,
        reviewCount: 150,
        description: '札幌主要的綜合醫院，提供全面的醫療服務。',
        category: 'hospital',
        openingHours: '08:00-17:00（急診24小時）',
        website: '',
        phone: '+81-11-726-2211',
        latitude: 43.0745,
        longitude: 141.3350,
        addedAt: DateTime.now(),
      ),
      FavoriteSpot(
        id: 'spot_sapporo_bank',
        name: '北洋銀行本店',
        imageUrl: 'https://images.unsplash.com/photo-1541354329998-f4d9a9f9297f?auto=format&fit=crop&w=300&q=80',
        address: '日本北海道札幌市中央區大通西3丁目',
        rating: 3.8,
        reviewCount: 85,
        description: '北海道地區主要銀行之一。',
        category: 'bank',
        openingHours: '09:00-15:00（週末休息）',
        website: '',
        phone: '+81-11-261-1311',
        latitude: 43.0610,
        longitude: 141.3530,
        addedAt: DateTime.now(),
      ),
      FavoriteSpot(
        id: 'spot_gas_station',
        name: 'ENEOS加油站',
        imageUrl: 'https://images.unsplash.com/photo-1545558014-8692077e9b5c?auto=format&fit=crop&w=300&q=80',
        address: '日本北海道札幌市中央區南1条西10丁目',
        rating: 3.5,
        reviewCount: 45,
        description: '24小時營業的加油站，提供各種汽車服務。',
        category: 'gas_station',
        openingHours: '24小時營業',
        website: '',
        phone: '+81-11-222-3344',
        latitude: 43.0580,
        longitude: 141.3450,
        addedAt: DateTime.now(),
      ),
    ];

    // 根據選擇的目的地過濾景點
    if (_selectedDestination == null) {
      return allSpots; // 顯示所有景點
    }

    // 根據目的地過濾景點
    switch (_selectedDestination!.id) {
      case 'sapporo':
        return allSpots.where((spot) => 
          spot.address.contains('札幌') || spot.address.contains('北海道')).toList();
      case 'tokyo':
        return allSpots.where((spot) => 
          spot.address.contains('東京')).toList();
      case 'osaka':
        return allSpots.where((spot) => 
          spot.address.contains('大阪')).toList();
      default:
        return allSpots; // 其他地區暫時顯示所有景點
    }
  }

  Future<void> _showCurrentLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    if (_locationData.latitude != null && _locationData.longitude != null) {
      setState(() {
        _currentLocation = LatLng(_locationData.latitude!, _locationData.longitude!);
        _currentLocationCircle = Circle(
          circleId: const CircleId('current_location'),
          center: _currentLocation!,
          radius: 30,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        );
      });
      if (_isMapView && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentLocation!),
        );
      }
    }
  }

 getRadiusFromZoom(double zoom) {
    if (zoom >= 16) return 500;
    if (zoom >= 14) return 1000;
    if (zoom >= 12) return 2000;
    return 3000; // zoom 太小，保持最大搜尋半徑
  }


  void _onMapCameraIdle() async {
  if (_mapController == null) return;

  final size = MediaQuery.of(context).size;
  final screenCenter = ScreenCoordinate(
    x: (size.width / 2).round(),
    y: (size.height / 2).round(),
  );

  final center = await _mapController!.getLatLng(screenCenter);

  // 避免重複搜尋
  if (_lastMapCenter != null &&
      (center.latitude - _lastMapCenter!.latitude).abs() < 0.001 &&
      (center.longitude - _lastMapCenter!.longitude).abs() < 0.001) {
    return;
  }

  _lastMapCenter = center;
  final zoomLevel = await _mapController!.getZoomLevel();
  final radius = getRadiusFromZoom(zoomLevel);

  setState(() => _isLoadingSpots = true);

  // 🎯 依據使用者選擇的類別，決定要查詢的 Google types
  final selectedTypes = _selectedTypeIndexes.contains(0)
      ? _spotTypes
          .skip(1) // 跳過「全選」
          .expand((type) => type.keywords)
          .toSet()
          .toList()
      : _selectedTypeIndexes
          .map((index) => _spotTypes[index])
          .expand((type) => type.keywords)
          .toSet()
          .toList();

  try {
    final spots = await PlacesApiService.searchNearbyPlacesMultipleTypes(
      latitude: center.latitude,
      longitude: center.longitude,
      radius: radius,
      types: selectedTypes,
    );

    setState(() {
      _currentSpots = spots;
      _isLoadingSpots = false;
    });

    _initializeMarkers();
  } catch (e) {
    print('Error fetching nearby places: $e');
    setState(() => _isLoadingSpots = false);
  }
}


  void _onSearchChanged(String value) async {
    if (value.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    final spots = await PlacesApiService.searchPlacesByText(
      query: value,
      latitude: _currentLocation?.latitude,
      longitude: _currentLocation?.longitude,
      radius: 3000,
    );
    setState(() {
      _searchResults = spots;
    });
  }
  Future<void> _showSpotDetailsWithApi(FavoriteSpot spot) async {
    // 直接導航到景點詳細頁面，而不是使用 modal
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpotDetailPage(spot: spot),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 主內容區 - 全螢幕，移除top padding
          Positioned.fill(
            child: _isMapView ? _buildMapView() : _buildListView(),
          ),

          // 搜尋欄 - 懸浮在地圖上
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: _buildSearchBar(),
          ),

          // 地圖/列表切換按鈕
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(              onPressed: () {
                setState(() {
                  _isMapView = !_isMapView;
                });
                
                // 如果切換到地圖視圖且有選擇目的地，稍後移動到該位置
                if (_isMapView && _selectedDestination != null) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (_mapController != null) {
                      _moveToDestination(_selectedDestination!);
                    }
                  });
                }
              },
              backgroundColor: Colors.blueAccent,
              child: Icon(_isMapView ? Icons.list : Icons.map),
            ),
          ),

          // 現在地點按鈕（在切換按鈕上方）
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'current_location_btn',
              onPressed: _showCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blueAccent),
            ),
          ),
        ],      ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Row(
            children: [
              // 地區選擇按鈕（左邊）
              TextButton.icon(
                onPressed: _navigateToSelectArea,
                icon: const Icon(Icons.place, color: Colors.blueAccent),
                label: Text(
                  _selectedDestination?.name ?? '選地區',
                  style: const TextStyle(color: Colors.blueAccent),
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              // 搜尋框（右邊）
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: '搜尋地點、美食、景點',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildTypeSelector(),
      ],
    );
  }
  Widget _buildTypeSelector() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.transparent, // 移除白色背景
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _spotTypes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final spotType = _spotTypes[index];
          final isSelected = _selectedTypeIndexes.contains(index);
          
          return GestureDetector(
            onTap: () {
              setState(() {
                if (index == 0) {
                  // 點擊全選
                  _selectedTypeIndexes = {0};
                } else {
                  // 點擊其他類型
                  if (_selectedTypeIndexes.contains(index)) {
                    _selectedTypeIndexes.remove(index);
                    if (_selectedTypeIndexes.isEmpty) {
                      _selectedTypeIndexes = {0};
                    }
                  } else {
                    _selectedTypeIndexes.remove(0);
                    _selectedTypeIndexes.add(index);
                  }
                }
              });
              _initializeMarkers(); // 更新地圖標記
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    spotType.icon,
                    color: isSelected ? Colors.white : Colors.blueAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    spotType.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapView() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        
        // 如果選擇了特定目的地，移動到該位置
        if (_selectedDestination != null) {
          _moveToDestination(_selectedDestination!);
        }
      },
      initialCameraPosition: _selectedDestination != null &&
              _selectedDestination!.latitude != null &&
              _selectedDestination!.longitude != null
          ? CameraPosition(
              target: LatLng(_selectedDestination!.latitude!, _selectedDestination!.longitude!),
              zoom: 12.0,
            )
          : _initialPosition,
      markers: _markers,
      circles: _currentLocationCircle != null ? {_currentLocationCircle!} : {},
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      mapType: MapType.normal,
      zoomControlsEnabled: false,
      compassEnabled: false,
      trafficEnabled: false,      buildingsEnabled: true,
      onCameraIdle: _onMapCameraIdle,
    );
  }

  Widget _buildListView() {
    // 使用過濾後的景點
    final spots = _filteredSpots;
    if (_selectedSort == SortType.rating) {
      spots.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      // 這裡可以根據實際距離排序，暫時使用名稱排序
      spots.sort((a, b) => a.name.compareTo(b.name));
    }

    return SafeArea(
      child: _isLoadingSpots
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(top: 140, left: 16, right: 16, bottom: 16), // 增加top padding避免被搜尋欄遮擋
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDestination != null 
                        ? "${_selectedDestination!.name}推薦景點"
                        : "推薦景點",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                    ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showSortOptions,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...spots.map((spot) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildSpotCard(spot),
          )),
          if (spots.isEmpty)
            const Center(
              child: Text('沒有推薦的景點', style: TextStyle(color: Colors.grey)),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSpotCard(FavoriteSpot spot) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _showSpotDetailsWithApi(spot);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 圖片
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  spot.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    );
                  },
                ),
              ),
            ),
            
            // 內容
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [                  // 標題和評分
                  Row(
                    children: [
                      Icon(
                        _getIconForCategory(spot.category),
                        color: Colors.blueAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          spot.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            spot.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // 地址
                  Text(
                    spot.address,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 描述
                  Text(
                    spot.description,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 按鈕
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddToCollectionDialog(spot: spot),
                            );
                          },
                          icon: const Icon(Icons.bookmark_add, size: 16),
                          label: const Text('加入收藏'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blueAccent,
                            side: const BorderSide(color: Colors.blueAccent),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddToItineraryDialog(spot: spot),
                            );
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('加入行程'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
