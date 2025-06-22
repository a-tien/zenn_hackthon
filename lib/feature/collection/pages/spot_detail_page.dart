import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/favorite_spot.dart';
import '../models/detailed_favorite_spot.dart';
import '../components/nearby_spot_card.dart';
import '../components/add_to_itinerary_dialog.dart';
import '../services/favorite_service.dart';
import '../../discover/components/add_to_collection_dialog.dart';
import '../../discover/services/places_api_service.dart';

class SpotDetailPage extends StatefulWidget {
  final FavoriteSpot spot;

  const SpotDetailPage({super.key, required this.spot});

  @override
  State<SpotDetailPage> createState() => _SpotDetailPageState();
}

class _SpotDetailPageState extends State<SpotDetailPage> {
  List<Map<String, dynamic>> nearbySpots = [];
  bool isLoading = true;
  bool isFavorited = false;
  bool isCheckingFavorite = true;
    // 詳細資訊狀態
  DetailedFavoriteSpot? detailedSpot;
  bool isLoadingDetails = true;
  String? errorMessage;
  @override
  void initState() {
    super.initState();
    _loadSpotDetails();
    _loadNearbySpots();
    _checkFavoriteStatus();
  }
    // 載入景點詳細資訊
  Future<void> _loadSpotDetails() async {
    try {
      setState(() {
        isLoadingDetails = true;
        errorMessage = null;
      });
      
      final details = await PlacesApiService.getDetailedPlaceInfo(widget.spot.id);
      
      if (mounted) {
        setState(() {
          detailedSpot = details;
          isLoadingDetails = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingDetails = false;
          errorMessage = '無法載入景點詳細資訊';
        });
      }
    }
  }

  // 檢查收藏狀態
  Future<void> _checkFavoriteStatus() async {
    final favorited = await FavoriteService.isSpotFavorited(widget.spot.id);
    if (mounted) {
      setState(() {
        isFavorited = favorited;
        isCheckingFavorite = false;
      });
    }
  }

  // 加載附近推薦景點
  Future<void> _loadNearbySpots() async {
    // 模擬API請求延遲
    await Future.delayed(const Duration(milliseconds: 800));

    // 這裡將來會替換為實際的API調用
    setState(() {
      nearbySpots = _getMockNearbySpots();
      isLoading = false;
    });
  }

  // 模擬附近景點數據
  List<Map<String, dynamic>> _getMockNearbySpots() {
    return [
      {
        'id': 'n1',
        'name': '札幌電視塔',
        'imageUrl':
            'https://images.unsplash.com/photo-1610948237719-5386e03f6d65?auto=format&fit=crop&w=300&q=80',
        'category': '景點',
      },
      {
        'id': 'n2',
        'name': '拉麵橫丁',
        'imageUrl':
            'https://images.unsplash.com/photo-1584858574980-cee28babf9cb?auto=format&fit=crop&w=300&q=80',
        'category': '美食',
      },
      {
        'id': 'n3',
        'name': '狸小路商店街',
        'imageUrl':
            'https://images.unsplash.com/photo-1591793826788-ae2ce68cca7c?auto=format&fit=crop&w=300&q=80',
        'category': '購物',
      },
      {
        'id': 'n4',
        'name': '北海道大學',
        'imageUrl':
            'https://images.unsplash.com/photo-1645388490166-e153ac9f6e9b?auto=format&fit=crop&w=300&q=80',
        'category': '景點',
      },
    ];
  }

  // 打開Google地圖進行導航
  Future<void> _navigateToSpot() async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${widget.spot.latitude},${widget.spot.longitude}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('無法打開地圖應用')));
      }
    }
  }
  // 加入行程
  void _addToItinerary() {
    showDialog(
      context: context,
      builder: (context) => AddToItineraryDialog(spot: widget.spot),
    );
  }

  // 切換收藏狀態
  Future<void> _toggleFavorite() async {
    if (isFavorited) {
      // 取消收藏
      await FavoriteService.removeSpotFromFavorites(widget.spot.id);
      if (mounted) {
        setState(() {
          isFavorited = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已取消收藏')),
        );
      }
    } else {
      // 加入收藏 - 顯示收藏集選擇對話框
      showDialog(
        context: context,
        builder: (context) => AddToCollectionDialog(spot: widget.spot),
      ).then((_) {
        // 對話框關閉後重新檢查收藏狀態
        _checkFavoriteStatus();
      });
    }
  }

  // 文字轉語音
  void _textToSpeech(String text) {
    // 這裡將來會實現文字轉語音功能
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('播放: $text')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 頂部圖片和應用欄
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.spot.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),

          // 內容區域
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 景點名稱
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.spot.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () => _textToSpeech(widget.spot.name),
                        tooltip: '語音播放',
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 地址
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.spot.address,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () => _textToSpeech(widget.spot.address),
                        tooltip: '語音播放',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 評分
                  Row(
                    children: [
                      // 星級評分
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < widget.spot.rating.floor()
                                ? Icons.star
                                : (index < widget.spot.rating
                                      ? Icons.star_half
                                      : Icons.star_border),
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.spot.rating}',
                        style: const TextStyle(                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),                  // 功能按鈕
                  Row(
                    children: [
                      // 收藏按鈕
                      Expanded(
                        child: isCheckingFavorite
                            ? const OutlinedButton(
                                onPressed: null,
                                child: SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : OutlinedButton.icon(
                                icon: Icon(
                                  isFavorited ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorited ? Colors.red : null,
                                ),
                                label: Text(isFavorited ? '已收藏' : '收藏'),
                                onPressed: _toggleFavorite,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isFavorited ? Colors.red : Colors.blueAccent,
                                  side: BorderSide(
                                    color: isFavorited ? Colors.red : Colors.blueAccent,
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      // 導航按鈕
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.directions),
                          label: const Text('導航'),
                          onPressed: _navigateToSpot,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blueAccent,
                            side: const BorderSide(color: Colors.blueAccent),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 加入行程按鈕
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('加入行程'),
                          onPressed: _addToItinerary,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),                  const SizedBox(height: 24),

                  // 景點詳細資訊區塊
                  if (isLoadingDetails)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red[600]),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else if (detailedSpot != null) ...[
                    // 景點描述
                    if (detailedSpot!.description.isNotEmpty) ...[
                      _buildInfoSection('景點介紹', detailedSpot!.description),
                      const Divider(),
                    ],
                    
                    // 營業時間
                    if (detailedSpot!.openingHours.isNotEmpty) ...[
                      _buildInfoSection('營業時間', detailedSpot!.openingHours),
                      const Divider(),
                    ],
                    
                    // 聯絡資訊
                    if (detailedSpot!.phone.isNotEmpty) ...[
                      _buildInfoSection('電話', detailedSpot!.phone),
                      const Divider(),
                    ],
                    
                    // 網站
                    if (detailedSpot!.website.isNotEmpty) ...[
                      _buildInfoSection('網站', detailedSpot!.website),
                      const Divider(),
                    ],
                    
                    // 評論數量
                    if (detailedSpot!.reviewCount > 0) ...[
                      _buildInfoSection('評論數量', '${detailedSpot!.reviewCount} 則評論'),
                      const Divider(),
                    ],
                  ] else ...[
                    // 顯示基本資訊
                    _buildInfoSection('地址', widget.spot.address),
                    const Divider(),
                  ],

                  // 附近推薦
                  const SizedBox(height: 16),
                  const Text(
                    '附近推薦',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // 附近景點橫向列表
                  SizedBox(
                    height: 150,
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: nearbySpots.length,
                            itemBuilder: (context, index) {
                              final spot = nearbySpots[index];
                              return NearbySpotCard(
                                name: spot['name'],
                                imageUrl: spot['imageUrl'],
                                category: spot['category'],
                                onTap: () {
                                  // 點擊附近景點的處理
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('查看${spot['name']}'),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 構建信息區塊
  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}
