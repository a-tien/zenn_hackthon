import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_collection.dart';
import '../models/favorite_spot.dart';
import '../components/favorite_spot_card.dart';
import 'spot_detail_page.dart';
import '../components/add_to_itinerary_dialog.dart';

class CollectionDetailPage extends StatefulWidget {
  final FavoriteCollection collection;

  const CollectionDetailPage({
    super.key,
    required this.collection,
  });

  @override
  State<CollectionDetailPage> createState() => _CollectionDetailPageState();
}

class _CollectionDetailPageState extends State<CollectionDetailPage> {
  late FavoriteCollection collection;
  List<FavoriteSpot> spots = [];
  bool isLoading = true;
  bool isMapView = false;

  @override
  void initState() {
    super.initState();
    collection = widget.collection;
    _loadSpots();
  }

  // 加載收藏景點
  Future<void> _loadSpots() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });

    // 從本地存儲中加載景點數據
    final spotsJson = prefs.getStringList('favorite_spots') ?? [];
    final allSpots = spotsJson
        .map((json) => FavoriteSpot.fromJson(jsonDecode(json)))
        .toList();

    // 過濾出該收藏集的景點
    final collectionSpots = allSpots
        .where((spot) => collection.spotIds.contains(spot.id))
        .toList();

    setState(() {
      spots = collectionSpots;
      isLoading = false;
    });
  }

  // 編輯收藏集信息
  void _editCollection() async {
    final TextEditingController nameController =
        TextEditingController(text: collection.name);
    final TextEditingController descriptionController =
        TextEditingController(text: collection.description);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('編輯收藏集'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '收藏集名稱'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: '收藏集說明'),
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
      // 更新收藏集信息
      final updatedCollection = collection.copyWith(
        name: result['name']!,
        description: result['description']!,
        updatedAt: DateTime.now(),
      );

      // 保存到本地存儲
      await _updateCollection(updatedCollection);

      setState(() {
        collection = updatedCollection;
      });
    }
  }

  // 更新收藏集
  Future<void> _updateCollection(FavoriteCollection updatedCollection) async {
    final prefs = await SharedPreferences.getInstance();
    final collectionsJson = prefs.getStringList('collections') ?? [];

    List<Map<String, dynamic>> collectionsData = collectionsJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();

    // 找到並更新收藏集
    for (int i = 0; i < collectionsData.length; i++) {
      if (collectionsData[i]['id'] == updatedCollection.id) {
        collectionsData[i] = updatedCollection.toJson();
        break;
      }
    }

    // 保存更新後的收藏集
    await prefs.setStringList(
      'collections',
      collectionsData.map((data) => jsonEncode(data)).toList(),
    );
  }

  // 刪除收藏集
  void _deleteCollection() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('確認刪除'),
          content: const Text('確定要刪除此收藏集嗎？此操作無法復原。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('刪除'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      final collectionsJson = prefs.getStringList('collections') ?? [];

      // 過濾掉要刪除的收藏集
      final filteredCollections = collectionsJson.where((json) {
        final data = jsonDecode(json) as Map<String, dynamic>;
        return data['id'] != collection.id;
      }).toList();

      // 保存更新後的收藏集列表
      await prefs.setStringList('collections', filteredCollections);

      if (mounted) {
        Navigator.pop(context); // 返回收藏主頁面
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(collection.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editCollection,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteCollection,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : spots.isEmpty
              ? _buildEmptyState()
              : _buildSpotsList(),
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
            Icons.place_outlined,
            size: 80,
            color: Colors.blueGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            "沒有收藏的景點",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "${collection.name}收藏集中尚無景點，您可以從探索頁面添加景點到此收藏集。",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blueGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotsList() {
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
            Text("此處將顯示收藏景點的地圖視圖", style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    // 列表視圖
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: spots.length,
      itemBuilder: (context, index) {
        final spot = spots[index];
        return FavoriteSpotCard(
          spot: spot,
          onDetailTap: () {
            // 導航到景點詳情頁面
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SpotDetailPage(spot: spot),
              ),
            );
          },
          onAddToItinerary: () {
            // 顯示加入行程對話框
            _showAddToItineraryDialog(spot);
          },
        );
      },
    );
  }

  // 顯示加入行程對話框
  // 修改 _showAddToItineraryDialog 方法
void _showAddToItineraryDialog(FavoriteSpot spot) {
  showDialog(
    context: context,
    builder: (context) => AddToItineraryDialog(spot: spot),
  );
}
}