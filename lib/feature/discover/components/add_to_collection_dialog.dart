import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../collection/models/favorite_collection.dart';
import '../../collection/models/favorite_spot.dart';

class AddToCollectionDialog extends StatefulWidget {
  final FavoriteSpot spot;

  const AddToCollectionDialog({super.key, required this.spot});

  @override
  State<AddToCollectionDialog> createState() => _AddToCollectionDialogState();
}

class _AddToCollectionDialogState extends State<AddToCollectionDialog> {
  List<FavoriteCollection> collections = [];
  String? selectedCollectionId;
  bool isLoading = true;
  final TextEditingController _newCollectionController = TextEditingController();
  bool isCreatingNew = false;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  @override
  void dispose() {
    _newCollectionController.dispose();
    super.dispose();
  }

  Future<void> _loadCollections() async {
    final prefs = await SharedPreferences.getInstance();
    final collectionsJson = prefs.getStringList('collections') ?? [];

    if (collectionsJson.isEmpty) {
      // 創建默認的"口袋清單"
      final defaultCollection = FavoriteCollection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '口袋清單',
        description: '我想去的地方',
        spotIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await prefs.setStringList(
        'collections',
        [jsonEncode(defaultCollection.toJson())]
      );

      setState(() {
        collections = [defaultCollection];
        selectedCollectionId = defaultCollection.id;
        isLoading = false;
      });
    } else {
      setState(() {
        collections = collectionsJson
            .map((json) => FavoriteCollection.fromJson(jsonDecode(json)))
            .toList();
        selectedCollectionId = collections.isNotEmpty ? collections.first.id : null;
        isLoading = false;
      });
    }
  }

  Future<void> _addToCollection() async {
    if (selectedCollectionId == null && !isCreatingNew) return;

    final prefs = await SharedPreferences.getInstance();

    // 如果是創建新收藏集
    if (isCreatingNew) {
      if (_newCollectionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('請輸入收藏集名稱')),
        );
        return;
      }

      // 創建新收藏集
      final newCollection = FavoriteCollection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _newCollectionController.text.trim(),
        description: '',
        spotIds: [widget.spot.id],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 保存新收藏集
      final collectionsJson = prefs.getStringList('collections') ?? [];
      collectionsJson.add(jsonEncode(newCollection.toJson()));
      await prefs.setStringList('collections', collectionsJson);
    } else {
      // 添加到現有收藏集
      final collectionIndex = collections.indexWhere((c) => c.id == selectedCollectionId);
      if (collectionIndex >= 0) {
        final collection = collections[collectionIndex];
        
        // 檢查是否已存在
        if (collection.spotIds.contains(widget.spot.id)) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('此景點已在該收藏集中')),
          );
          return;
        }

        // 添加景點到收藏集
        collection.spotIds.add(widget.spot.id);
        collection.updatedAt = DateTime.now();

        // 更新收藏集
        final collectionsJson = prefs.getStringList('collections') ?? [];
        collectionsJson[collectionIndex] = jsonEncode(collection.toJson());
        await prefs.setStringList('collections', collectionsJson);
      }
    }

    // 保存景點到收藏景點列表
    final spotsJson = prefs.getStringList('favorite_spots') ?? [];
    final existingSpots = spotsJson.map((json) => FavoriteSpot.fromJson(jsonDecode(json))).toList();
    
    // 檢查景點是否已存在
    if (!existingSpots.any((spot) => spot.id == widget.spot.id)) {
      spotsJson.add(jsonEncode(widget.spot.toJson()));
      await prefs.setStringList('favorite_spots', spotsJson);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCreatingNew 
          ? '已加入新收藏集「${_newCollectionController.text.trim()}」'
          : '已加入收藏集「${collections.firstWhere((c) => c.id == selectedCollectionId).name}」'
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('加入收藏'),
      content: isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '將「${widget.spot.name}」加入到：',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                
                if (!isCreatingNew) ...[
                  // 現有收藏集選擇
                  const Text('選擇收藏集：'),
                  const SizedBox(height: 8),
                  ...collections.map((collection) {
                    return RadioListTile<String>(
                      title: Text(collection.name),
                      subtitle: collection.description.isNotEmpty 
                          ? Text(collection.description)
                          : null,
                      value: collection.id,
                      groupValue: selectedCollectionId,
                      onChanged: (value) {
                        setState(() {
                          selectedCollectionId = value;
                        });
                      },
                    );
                  }),
                  
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        isCreatingNew = true;
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('創建新收藏集'),
                  ),
                ] else ...[
                  // 創建新收藏集
                  const Text('新收藏集名稱：'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _newCollectionController,
                    decoration: const InputDecoration(
                      hintText: '例如：北海道景點',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        isCreatingNew = false;
                        _newCollectionController.clear();
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('返回選擇現有收藏集'),
                  ),
                ],
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _addToCollection,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text('加入'),
        ),
      ],
    );
  }
}
