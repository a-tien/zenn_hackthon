import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/home_section_title.dart';
import '../components/home_product_slider.dart';
import '../model/home_item_model.dart';
import 'chat_demo_app.dart';
import 'home_detail_page.dart';
import '../../itinerary/models/itinerary.dart';
import '../../../utils/app_localizations.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<HomeItemModel> recommendedItems = [];
  List<HomeItemModel> popularItems = [];
  bool isLoading = true;
  String errorMessage = '';

  bool _hasLoadedRecommendations = false; // 新增 flag

  final String apiBaseUrl = 'https://recommendation-774572899941.us-central1.run.app';
  final String userLocation = '札幌';

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    if (_hasLoadedRecommendations) return; // 已載入就不再呼叫
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await http.post(
        Uri.parse('$apiBaseUrl/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'location': userLocation}),
      );

      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> places = data['recommendedPlaces'] ?? [];

        final List<HomeItemModel> newRecommendedItems = places.map((place) {
          double rating = 4.0;
          if (place['rating'] != null) {
            try {
              rating = (place['rating'] as num).toDouble();
            } catch (_) {}
          }

          int estimatedVisitHours = 2;
          if (place['estimatedVisitHours'] != null) {
            try {
              estimatedVisitHours = (place['estimatedVisitHours'] as num).toInt();
            } catch (_) {}
          }

          return HomeItemModel(
            title: place['title'] ?? '',
            imageUrl: place['imageUrl'] ?? '',
            description: place['description'] ?? '',
            placeId: place['placeId'] ?? '',
            address: place['address'] ?? '',
            latitude: place['latitude'] != null ? (place['latitude'] as num).toDouble() : 0.0,
            longitude: place['longitude'] != null ? (place['longitude'] as num).toDouble() : 0.0,
            rating: rating,
            category: place['category'] ?? 'tourist_attraction',
            estimatedVisitHours: estimatedVisitHours,
          );
        }).toList();

        setState(() {
          recommendedItems = newRecommendedItems;
          popularItems = newRecommendedItems.take(2).toList();
          isLoading = false;
          _hasLoadedRecommendations = true; // 標記已載入
        });
      } else {
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = '載入推薦景點失敗: $e';
        _loadDefaultData();
      });
    }
  }

  void _onRecommendedItemTap(HomeItemModel item) {
    final itinerary = Itinerary(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      name: item.title,
      useDateRange: false,
      days: 1,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      destinations: [],
      transportation: 'walk',
      travelType: '自由行',
      members: [],
      itineraryDays: [],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeDetailPage(
          imageUrl: item.imageUrl,
          title: item.title,
          itinerary: itinerary,
          itemModel: item,
        ),
      ),
    );
  }

  void _loadDefaultData() {
    recommendedItems = [
      HomeItemModel(
        title: '桑葚園一日遊',
        imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
        description: '體驗採摘樂趣',
      ),
      HomeItemModel(
        title: '富良野花海一日',
        imageUrl: 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
        description: '薰衣草花海美景',
      ),
    ];

    popularItems = [
      HomeItemModel(
        title: '海灘日落',
        imageUrl: 'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?auto=format&fit=crop&w=400&q=80',
        description: '欣賞美麗日落',
      ),
      HomeItemModel(
        title: '山脈探險',
        imageUrl: 'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?auto=format&fit=crop&w=400&q=80',
        description: '探索自然之美',
      ),
    ];
  }

  Future<void> _refreshRecommendations() async {
    await _loadRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshRecommendations,
          child: ListView(
            padding: const EdgeInsets.only(top: 16), // 調整上方間距
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 移除語言切換按鈕
                    const SizedBox(height: 16),
                    Text(
                      localizations?.welcomeMessage ?? "こんにちは！\n今日はどこに行きますか？",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange[800]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    HomeSectionTitle(title: localizations?.exploreNewPlaces ?? "新しい場所を探索"),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              // 推薦內容區域 - 移出 Container 避免 padding 重疊
              if (isLoading)
                Container(
                  height: 200,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('おすすめスポットを探しています...'),
                      ],
                    ),
                  ),
                )
              else
                HomeProductSlider(
                  items: recommendedItems,
                  onItemTap: _onRecommendedItemTap,
                ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChatDemoApp()),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    HomeSectionTitle(title: localizations?.popularDestinations ?? "人気の目的地"),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              // 熱門內容區域
              HomeProductSlider(
                items: popularItems,
                onItemTap: _onRecommendedItemTap,
              ),
              const SizedBox(height: 32), // 底部間距
            ],
          ),
        ),
      ),
    );
  }
}
