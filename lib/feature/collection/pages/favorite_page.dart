import 'package:flutter/material.dart';
import '../../../utils/app_localizations.dart';
import '../models/favorite_collection.dart';
import '../models/favorite_spot.dart';
import '../services/favorite_service.dart';
import '../../common/widgets/login_required_dialog.dart';
import '../components/collection_card.dart';
import 'collection_detail_page.dart';
import '../../itinerary/models/itinerary.dart';

class FavoritePage extends StatefulWidget {
  final Itinerary? targetItinerary;
  
  const FavoritePage({super.key, this.targetItinerary});

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
      
      print('Error loading favorites: $e'); // 載入收藏時出錯
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.getFavoriteLoadError(e.toString()))),
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
          title: Text(AppLocalizations.of(context)!.addNewCollection),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.collectionName,
                  hintText: AppLocalizations.of(context)!.collectionNameHint,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.collectionDescription,
                  hintText: AppLocalizations.of(context)!.collectionDescriptionHint,
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.pleaseEnterCollectionName)),
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
              child: Text(AppLocalizations.of(context)!.confirm),
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
            SnackBar(content: Text(AppLocalizations.of(context)!.getCollectionCreated(createdCollection.name))),
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
        }          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.getCreateCollectionError(e.toString()))),
            );
          }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myFavorites),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // 新增按鈕
          TextButton.icon(
            icon: const Icon(Icons.add, size: 16),
            label: Text(AppLocalizations.of(context)!.addButton),
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
          Text(
            AppLocalizations.of(context)!.yourCollections,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                AppLocalizations.of(context)!.emptyCollectionMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
            child: Text(AppLocalizations.of(context)!.createCollection),
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
            Text(
              AppLocalizations.of(context)!.mapView,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.mapViewDescription, style: TextStyle(color: Colors.grey[600])),
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
          onTap: () async {
            // 導航到收藏集詳情頁面，傳遞目標行程資訊
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => CollectionDetailPage(
                  collection: collection,
                  targetItinerary: widget.targetItinerary,
                ),
              ),
            );
            
            // 如果成功添加到行程，返回結果給調用者
            if (result == true && mounted && widget.targetItinerary != null) {
              Navigator.pop(context, true); // 返回到行程細節頁面，並告知成功添加
            }
          },
        );
      },
    );
  }
}