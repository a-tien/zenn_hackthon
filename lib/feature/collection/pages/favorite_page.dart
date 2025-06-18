import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_collection.dart';
import '../models/favorite_spot.dart';
import '../components/collection_card.dart';
import 'collection_detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<FavoriteCollection> collections = [];
  bool isLoading = true;
  bool isMapView = false;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  // 加載收藏集
  Future<void> _loadCollections() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    isLoading = true;
  });

  // 從本地存儲中加載收藏集數據
  final collectionsJson = prefs.getStringList('collections') ?? [];

  if (collectionsJson.isEmpty) {
    // 創建預設景點 - 北海道大學
    final hokudaiSpot = FavoriteSpot(
      id: 'spot_hokudai_001',
      name: '北海道大學',
      imageUrl: 'https://images.weserv.nl/?url=daigakujc.jp/smart_phone/top_img/00038/2.jpg',
      address: '日本北海道札幌市北區北8条西5丁目',
      rating: 4.5,
      reviewCount: 1250,
      description: '北海道大學是日本最著名的大學之一，校園內有美麗的白樺林道和古色古香的建築。秋季時紅葉環繞，景色特別美麗。',
      category: '景點',
      openingHours: '全天開放，建築內部需遵守各建築開放時間',
      website: 'https://www.hokudai.ac.jp/',
      phone: '+81-11-716-2111',
      latitude: 43.0770474,
      longitude: 141.3408576,
      addedAt: DateTime.now(),
    );
    
    // 保存預設景點
    await prefs.setStringList(
      'favorite_spots',
      [jsonEncode(hokudaiSpot.toJson())]
    );
    
    // 如果沒有收藏集，創建默認的"口袋清單"，並包含北海道大學
    final defaultCollection = FavoriteCollection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '口袋清單',
      description: '我想去的地方',
      spotIds: [hokudaiSpot.id], // 添加北海道大學ID
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 保存默認收藏集
    await prefs.setStringList(
      'collections', 
      [jsonEncode(defaultCollection.toJson())]
    );
    
    setState(() {
      collections = [defaultCollection];
      isLoading = false;
    });
  } else {
    setState(() {
      collections = collectionsJson
          .map((json) => FavoriteCollection.fromJson(jsonDecode(json)))
          .toList();
      isLoading = false;
    });
  }
}

  // 添加新收藏集
  void _addNewCollection() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新增收藏集'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '收藏集名稱',
                  hintText: '例如: 北海道必去景點',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '收藏集說明',
                  hintText: '例如: 北海道旅遊規劃',
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('請輸入收藏集名稱')),
                  );
                  return;
                }
                Navigator.pop(context, {
                  'name': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('確定'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      // 創建新收藏集
      final newCollection = FavoriteCollection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: result['name']!,
        description: result['description']!,
        spotIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 保存到本地存儲
      final prefs = await SharedPreferences.getInstance();
      final collectionsJson = prefs.getStringList('collections') ?? [];
      
      collectionsJson.add(jsonEncode(newCollection.toJson()));
      await prefs.setStringList('collections', collectionsJson);

      // 更新狀態
      setState(() {
        collections.add(newCollection);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // 新增按鈕
          TextButton.icon(
            icon: const Icon(Icons.add, size: 16),
            label: const Text('新增'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blueAccent,
            ),
            onPressed: _addNewCollection,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : collections.isEmpty
              ? _buildEmptyState()
              : _buildCollectionsList(),
      // 地圖/列表切換按鈕
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isMapView = !isMapView;
          });
        },
        backgroundColor: Colors.blueAccent,
        child: Icon(isMapView ? Icons.list : Icons.map),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bookmark_border,
            size: 80,
            color: Colors.blueGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            "您的收藏",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "目前尚無收藏集，點擊右上角的「+新增」按鈕建立您的第一個收藏集。",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueGrey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _addNewCollection,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('建立收藏集'),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionsList() {
    if (isMapView) {
      // 地圖視圖 - 實際應用中需要使用地圖元件
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "地圖視圖",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("此處將顯示收藏地點的地圖視圖", style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    // 列表視圖
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final collection = collections[index];
        return CollectionCard(
          collection: collection,
          onTap: () {
            // 導航到收藏集詳情頁面
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CollectionDetailPage(
                  collection: collection,
                ),
              ),
            ).then((_) {
              // 返回時刷新數據
              _loadCollections();
            });
          },
        );
      },
    );
  }
}