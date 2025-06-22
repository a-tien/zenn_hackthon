import 'package:flutter/material.dart';
import '../models/favorite_collection.dart';
import '../models/favorite_spot.dart';
import '../components/favorite_spot_card.dart';
import '../services/favorite_service.dart';
import 'spot_detail_page.dart';
import '../components/add_to_itinerary_dialog.dart';
import '../../common/widgets/login_required_dialog.dart';
import '../../common/services/firestore_service.dart';

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
  }  // 加載收藏景點
  Future<void> _loadSpots() async {
    if (!FirestoreService.isUserLoggedIn()) {      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => const LoginRequiredDialog(feature: '收藏功能'),
        );
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      List<FavoriteSpot> collectionSpots = [];
        // 從 Firestore 獲取景點詳情
      for (String spotId in collection.spotIds) {
        try {
          final spot = await FavoriteService.getFullSpotDetails(spotId);
          if (spot != null) {
            collectionSpots.add(spot);
          }
        } catch (e) {
          print('Error loading spot $spotId: $e');
        }
      }

      setState(() {
        spots = collectionSpots;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading spots: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入景點失敗: $e')),
        );
      }
    }
  }  // 編輯收藏集信息
  void _editCollection() async {    if (!FirestoreService.isUserLoggedIn()) {
      showDialog(
        context: context,
        builder: (context) => const LoginRequiredDialog(feature: '編輯收藏集'),
      );
      return;
    }

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
      try {
        // 更新收藏集信息
        final updatedCollection = collection.copyWith(
          name: result['name']!,
          description: result['description']!,
          updatedAt: DateTime.now(),
        );        // 保存到 Firestore
        await FavoriteService.updateCollection(updatedCollection);

        setState(() {
          collection = updatedCollection;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('收藏集更新成功')),
          );
        }
      } catch (e) {
        print('Error updating collection: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('更新收藏集失敗: $e')),          );
        }
      }
    }
  }

  // 刪除收藏集
  void _deleteCollection() async {
    if (!FirestoreService.isUserLoggedIn()) {
      showDialog(
        context: context,
        builder: (context) => const LoginRequiredDialog(feature: '刪除收藏集'),
      );
      return;
    }

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
      try {        // 從 Firestore 刪除收藏集
        await FavoriteService.deleteCollection(collection.id);
        
        if (mounted) {
          Navigator.pop(context); // 返回收藏主頁面
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('收藏集刪除成功')),
          );
        }
      } catch (e) {
        print('Error deleting collection: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('刪除收藏集失敗: $e')),
          );
        }
      }
    }
  }  // 從收藏集移除景點
  Future<void> _removeSpotFromCollection(FavoriteSpot spot) async {    if (!FirestoreService.isUserLoggedIn()) {
      showDialog(
        context: context,
        builder: (context) => const LoginRequiredDialog(feature: '移除景點'),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('確認移除'),
          content: Text('確定要從「${collection.name}」移除「${spot.name}」嗎？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('移除'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {        // 從 Firestore 移除景點
        await FavoriteService.removeSpotFromCollection(collection.id, spot.id);
        
        // 更新本地狀態
        setState(() {
          spots.removeWhere((s) => s.id == spot.id);
          collection = collection.copyWith(
            spotIds: collection.spotIds.where((id) => id != spot.id).toList(),
            updatedAt: DateTime.now(),
          );
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已從收藏集移除「${spot.name}」')),
          );
        }
      } catch (e) {
        print('Error removing spot from collection: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('移除景點失敗: $e')),
          );
        }
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
        final spot = spots[index];        return FavoriteSpotCard(
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
          onRemove: () {
            // 從收藏集移除景點
            _removeSpotFromCollection(spot);
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