import 'package:flutter/material.dart';
import '../models/favorite_collection.dart';
import '../models/favorite_spot.dart';
import '../services/favorite_service.dart';
import '../../common/widgets/login_required_dialog.dart';
import '../components/collection_card.dart';
import 'collection_detail_page.dart';
import 'spot_detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<FavoriteCollection> collections = [];
  List<FavoriteSpot> favoriteSpots = [];
  bool isLoading = true;
  bool isMapView = false;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }  // 加載收藏集
  Future<void> _loadCollections() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 載入收藏集合
      final loadedCollections = await FavoriteService.getAllCollections();
      
      setState(() {
        collections = loadedCollections;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      if (e.toString().contains('需要登入')) {
        // 顯示登入提示對話框
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => LoginRequiredDialog(
              feature: '查看收藏',
              onLoginPressed: () {
                Navigator.of(context).pop();
                // 重新載入資料
                _loadCollections();
              },
            ),
          );
        }
        return;
      }
      
      print('載入收藏時出錯: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入失敗: $e')),
        );
      }
    }
  }  // 添加新收藏集
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
      try {        // 創建新收藏集
        final newCollection = FavoriteCollection(
          id: '', // Firestore 會自動生成
          name: result['name']!,
          description: result['description']!,
          spotIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final createdCollection = await FavoriteService.createCollection(newCollection);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已創建收藏集「${createdCollection.name}」')),
          );
          // 重新載入收藏集列表
          _loadCollections();
        }
      } catch (e) {
        if (e.toString().contains('需要登入')) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => const LoginRequiredDialog(feature: '創建收藏集'),
            );
          }
          return;
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('創建收藏集失敗: $e')),
          );
        }
      }
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
      ),      body: isLoading
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
        children: [          const Icon(
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
        final collection = collections[index];        return CollectionCard(
          collection: collection,
          onTap: () {
            // 導航到收藏集詳情頁面
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CollectionDetailPage(collection: collection),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFavoriteSpotsList() {
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

    // 列表視圖 - 顯示收藏的景點
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteSpots.length,
      itemBuilder: (context, index) {
        final spot = favoriteSpots[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                spot.imageUrl.isNotEmpty ? spot.imageUrl : 'https://via.placeholder.com/60x60',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.place, color: Colors.grey),
                  );
                },
              ),
            ),
            title: Text(
              spot.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (spot.address.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    spot.address,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),                    const SizedBox(width: 4),
                    Text(
                      spot.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 取消收藏按鈕
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () => _removeFavorite(spot),
                ),
                // 查看詳情按鈕
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () => _viewSpotDetail(spot),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 移除收藏
  Future<void> _removeFavorite(FavoriteSpot spot) async {
    try {
      await FavoriteService.removeSpotFromFavorites(spot.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已移除「${spot.name}」從收藏')),
        );
        // 重新載入收藏列表
        _loadCollections();
      }
    } catch (e) {
      if (e.toString().contains('需要登入')) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => const LoginRequiredDialog(feature: '移除收藏'),
          );
        }
        return;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('移除收藏失敗: $e')),
        );
      }
    }
  }

  // 查看景點詳情
  void _viewSpotDetail(FavoriteSpot spot) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpotDetailPage(spot: spot),
      ),
    );
  }

  // ...existing code...
}