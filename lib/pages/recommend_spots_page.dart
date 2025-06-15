// filepath: c:\Users\P96111119\Documents\GitHub\zenn_hackthon\lib\pages\recommend_spots_page.dart
import 'package:flutter/material.dart';
import '../models/itinerary.dart';
import '../models/recommended_spot.dart';
import '../widgets/recommended_spot_card.dart';
import '../widgets/recommendation_tabs.dart';

class RecommendSpotsPage extends StatefulWidget {
  final Itinerary itinerary;

  const RecommendSpotsPage({
    super.key,
    required this.itinerary,
  });

  @override
  State<RecommendSpotsPage> createState() => _RecommendSpotsPageState();
}

class _RecommendSpotsPageState extends State<RecommendSpotsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<RecommendedSpot> _recommendedSpots = [];
  List<RecommendedSpot> _recommendedFood = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecommendations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 加載推薦數據
  Future<void> _loadRecommendations() async {
    // 在實際應用中，這裡會從API獲取數據
    // 現在使用模擬數據
    await Future.delayed(const Duration(milliseconds: 800)); // 模擬網絡請求

    setState(() {
      _recommendedSpots = _getMockSpots();
      _recommendedFood = _getMockFood();
      isLoading = false;
    });
  }

  // 添加景點到行程
  void _addSpotToItinerary(RecommendedSpot spot) async {
    // 找出已經被添加到行程的景點，更新其狀態
    final updatedSpots = _recommendedSpots.map((s) {
      if (s.id == spot.id) {
        return s.copyWith(isAdded: true);
      }
      return s;
    }).toList();

    setState(() {
      _recommendedSpots = updatedSpots;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('行程建議'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 標題部分
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '根據您的行程與喜好',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const Text(
                        '推薦專屬於您的必訪項目',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 頁籤控制
                RecommendationTabs(
                  tabController: _tabController,
                ),
                
                // 頁籤內容
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // 景點頁籤
                      _buildRecommendationList(_recommendedSpots),
                      
                      // 美食頁籤
                      _buildRecommendationList(_recommendedFood),
                    ],
                  ),
                ),
                
                // 底部關閉按鈕
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('關閉'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRecommendationList(List<RecommendedSpot> spots) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      itemCount: spots.length,
      itemBuilder: (context, index) {
        final spot = spots[index];
        return RecommendedSpotCard(
          spot: spot,
          itinerary: widget.itinerary,
          onAddToItinerary: (spot) {
            _addSpotToItinerary(spot);
          },
        );
      },
    );
  }

  // 模擬景點數據
  List<RecommendedSpot> _getMockSpots() {
    return [
      RecommendedSpot(
        id: 's1',
        name: '札幌電視塔',
        imageUrl: 'https://images.unsplash.com/photo-1570924151958-1aeb0acba87f?auto=format&fit=crop&w=300&q=80',
        district: '中央區',
        rating: 4.5,
        description: '札幌地標，可俯瞰整個城市美景，夜景尤其迷人。',
        latitude: 43.0623,
        longitude: 141.3546,
      ),
      RecommendedSpot(
        id: 's2',
        name: '北海道大學',
        imageUrl: 'https://images.weserv.nl/?url=daigakujc.jp/smart_phone/top_img/00038/2.jpg',
        district: '北區',
        rating: 4.7,
        description: '美麗的校園環境，特別是秋季的銀杏大道非常著名。',
        latitude: 43.0742,
        longitude: 141.3405,
      ),
      RecommendedSpot(
        id: 's3',
        name: '大通公園',
        imageUrl: 'https://images.unsplash.com/photo-1547559158-b526aee2fe65?auto=format&fit=crop&w=300&q=80',
        district: '中央區',
        rating: 4.6,
        description: '札幌市中心的大型公園，是雪祭等活動的舉辦地。',
        latitude: 43.0584,
        longitude: 141.3505,
      ),
      RecommendedSpot(
        id: 's4',
        name: '白色戀人公園',
        imageUrl: 'https://images.unsplash.com/photo-1570924071567-19097cc411ce?auto=format&fit=crop&w=300&q=80',
        district: '西區',
        rating: 4.3,
        description: '以北海道著名巧克力餅乾為主題的主題公園。',
        latitude: 43.0758,
        longitude: 141.3169,
      ),
    ];
  }

  // 模擬美食數據
  List<RecommendedSpot> _getMockFood() {
    return [
      RecommendedSpot(
        id: 'f1',
        name: '蟹本家',
        imageUrl: 'https://images.unsplash.com/photo-1559589311-5f45d0366944?auto=format&fit=crop&w=300&q=80',
        district: '中央區',
        rating: 4.8,
        description: '北海道螃蟹料理的知名餐廳，提供新鮮的帝王蟹。',
        latitude: 43.0593,
        longitude: 141.3515,
      ),
      RecommendedSpot(
        id: 'f2',
        name: '札幌拉麵共和國',
        imageUrl: 'https://images.unsplash.com/photo-1591154505555-2d13f98e1fd4?auto=format&fit=crop&w=300&q=80',
        district: '中央區',
        rating: 4.4,
        description: '匯集北海道各地知名拉麵店的美食主題公園。',
        latitude: 43.0685,
        longitude: 141.3507,
      ),
      RecommendedSpot(
        id: 'f3',
        name: '成吉思汗烤肉',
        imageUrl: 'https://images.unsplash.com/photo-1570490650450-21d1591b0e44?auto=format&fit=crop&w=300&q=80',
        district: '北區',
        rating: 4.6,
        description: '北海道傳統羊肉烤肉，使用特製圓頂烤盤。',
        latitude: 43.0772,
        longitude: 141.3392,
      ),
    ];
  }
}