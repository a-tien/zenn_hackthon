import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/home_item_model.dart';
import '../../itinerary/models/itinerary.dart';
import '../../itinerary/models/itinerary_day.dart';
import '../../itinerary/models/spot.dart';
import '../../itinerary/components/spot_card.dart';
import '../../itinerary/components/transportation_segment.dart';

class HomeDetailPage extends StatefulWidget {
  final String imageUrl;
  final String title;
  final Itinerary itinerary;
  final HomeItemModel? itemModel; // 新增：完整的景點資料

  const HomeDetailPage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.itinerary,
    this.itemModel,
  });

  @override
  State<HomeDetailPage> createState() => _HomeDetailPageState();
}

class _HomeDetailPageState extends State<HomeDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Itinerary _itinerary;
  bool isLoading = false;
  String errorMessage = '';
  List<HomeItemModel> nearbyPlaces = [];

  // API 基礎 URL
  final String apiBaseUrl = 'YOUR_API_BASE_URL'; // 請替換為實際的 API URL

  @override
  void initState() {
    super.initState();
    _itinerary = widget.itinerary;
    _tabController = TabController(length: 3, vsync: this); // 改為3個分頁
    _createDefaultItineraryDays();
    _loadNearbyPlaces();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 載入附近景點
  Future<void> _loadNearbyPlaces() async {
    if (widget.itemModel?.latitude == null || widget.itemModel?.longitude == null) {
      return;
    }

    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await http.post(
        Uri.parse('$apiBaseUrl/nearby'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'latitude': widget.itemModel!.latitude,
          'longitude': widget.itemModel!.longitude,
          'radius': 5000, // 5公里範圍
          'limit': 5,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> places = data['nearbyPlaces'] ?? [];

        setState(() {
          nearbyPlaces = places
              .map((place) => HomeItemModel.fromJson(place))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = '載入附近景點失敗: $e';
      });
    }
  }

  // 創建默認的行程日數據
  void _createDefaultItineraryDays() {
    final existingCount = _itinerary.itineraryDays.length;

    // 添加缺少的天數
    for (int i = existingCount; i < _itinerary.days; i++) {
      _itinerary.itineraryDays.add(
        ItineraryDay(
          dayNumber: i + 1,
          transportation: _itinerary.transportation,
          spots: [],
        ),
      );
    }

    // 確保第一天有默認景點
    if (_itinerary.itineraryDays.isNotEmpty &&
        _itinerary.itineraryDays[0].spots.isEmpty) {
      _itinerary.itineraryDays[0].spots = _getDefaultSpots();
    }
  }

  // 獲取默認景點（基於當前選擇的景點）
  List<Spot> _getDefaultSpots() {
    final item = widget.itemModel;
    if (item != null) {
      return [
        Spot(
          id: item.placeId.isNotEmpty ? item.placeId : '1',
          name: item.title,
          imageUrl: item.imageUrl,
          order: 1,
          stayHours: item.estimatedVisitHours,
          stayMinutes: 0,
          startTime: '09:00',
          latitude: item.latitude,
          longitude: item.longitude,
          nextTransportation: '步行',
          travelTimeMinutes: 15,
        ),
      ];
    }

    // 如果沒有詳細資料，使用預設值
    return [
      Spot(
        id: '1',
        name: widget.title,
        imageUrl: widget.imageUrl,
        order: 1,
        stayHours: 2,
        stayMinutes: 0,
        startTime: '09:00',
        latitude: 0,
        longitude: 0,
        nextTransportation: '',
        travelTimeMinutes: 0,
      ),
    ];
  }

  // 添加景點到行程
  void _addToItinerary(HomeItemModel place) {
    if (_itinerary.itineraryDays.isEmpty) return;

    final newSpot = Spot(
      id: place.placeId.isNotEmpty ? place.placeId : DateTime.now().millisecondsSinceEpoch.toString(),
      name: place.title,
      imageUrl: place.imageUrl,
      order: _itinerary.itineraryDays[0].spots.length + 1,
      stayHours: place.estimatedVisitHours,
      stayMinutes: 0,
      startTime: '14:00', // 預設時間
      latitude: place.latitude,
      longitude: place.longitude,
      nextTransportation: '步行',
      travelTimeMinutes: 20,
    );

    setState(() {
      _itinerary.itineraryDays[0].spots.add(newSpot);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已將 ${place.title} 加入行程'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '介紹'),
            Tab(text: '行程'),
            Tab(text: '附近景點'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 介紹 Tab
          _buildIntroductionTab(),
          // 行程 Tab
          _buildItineraryTab(),
          // 附近景點 Tab
          _buildNearbyPlacesTab(),
        ],
      ),
    );
  }

  Widget _buildIntroductionTab() {
    final item = widget.itemModel;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 主圖片
          Hero(
            tag: widget.imageUrl,
            child: Image.network(
              widget.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 60,
                  ),
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 標題
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 評分和類型
                if (item != null) ...[
                  Row(
                    children: [
                      if (item.rating > 0) ...[
                        Icon(
                          Icons.star,
                          size: 20,
                          color: Colors.amber[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getCategoryName(item.category),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 地址
                  if (item.address.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.address,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // 建議遊覽時間
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '建議遊覽時間：${item.estimatedVisitHours} 小時',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                ],
                
                // 描述
                if (item?.description.isNotEmpty == true) ...[
                  const Text(
                    '景點介紹',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item!.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ] else ...[
                  const Text(
                    '這是一個值得探索的精彩景點，等待著您的到來。在這裡，您可以體驗到獨特的文化魅力和美麗的風景。',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // 操作按鈕
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _tabController.animateTo(1); // 切換到行程分頁
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('加入行程'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        // 分享功能
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('分享功能尚未實現')),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('分享'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < _itinerary.itineraryDays.length; i++)
            _buildSpotsList(i, _itinerary.itineraryDays[i]),
        ],
      ),
    );
  }

  Widget _buildNearbyPlacesTab() {
    return Column(
      children: [
        // 標題
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.place, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                '附近景點推薦',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
        
        // 載入中或錯誤訊息
        if (isLoading)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在載入附近景點...'),
                ],
              ),
            ),
          )
        else if (errorMessage.isNotEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadNearbyPlaces,
                    child: const Text('重新載入'),
                  ),
                ],
              ),
            ),
          )
        else if (nearbyPlaces.isEmpty)
          const Expanded(
            child: Center(
              child: Text('暫無附近景點資料'),
            ),
          )
        else
          // 附近景點列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: nearbyPlaces.length,
              itemBuilder: (context, index) {
                final place = nearbyPlaces[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        place.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      place.title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (place.description.isNotEmpty) ...[
                          Text(
                            place.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Row(
                          children: [
                            if (place.rating > 0) ...[
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber[600],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                place.rating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              _getCategoryName(place.category),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () => _addToItinerary(place),
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: '加入行程',
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSpotsList(int dayIndex, ItineraryDay day) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Text(
            'Day ${day.dayNumber}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          itemCount: day.spots.length,
          itemBuilder: (context, index) {
            final spot = day.spots[index];
            return Column(
              children: [
                // 景點卡片
                SpotCard(
                  spot: spot,
                  onNavigate: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('導航功能尚未實現')),
                    );
                  },
                ),

                // 如果不是最後一個景點，顯示交通段落
                if (index < day.spots.length - 1)
                  TransportationSegment(
                    transportType: spot.nextTransportation,
                    duration: spot.travelTimeMinutes,
                    onTap: () {
                      // 更改交通方式的對話框
                    },
                    onAddSpot: () {
                      // 插入新景點的選項
                    },
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _getCategoryName(String category) {
    switch (category.toLowerCase()) {
      case 'tourist_attraction':
        return '景點';
      case 'museum':
        return '博物館';
      case 'park':
        return '公園';
      case 'temple':
        return '寺廟';
      case 'shopping':
        return '購物';
      case 'restaurant':
        return '餐廳';
      case 'entertainment':
        return '娛樂';
      case 'natural_feature':
        return '自然景觀';
      default:
        return '景點';
    }
  }
}