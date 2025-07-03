import 'package:flutter/material.dart';
import '../../collection/models/favorite_collection.dart';
import '../../collection/models/favorite_spot.dart';
import '../../collection/services/favorite_service.dart';
import '../../common/widgets/login_required_dialog.dart';
import '../../common/services/firestore_service.dart';
import '../../../utils/app_localizations.dart';

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
    if (!FirestoreService.isUserLoggedIn()) {
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        showDialog(
          context: context,
          builder: (context) => LoginRequiredDialog(feature: localizations?.favoriteFeature ?? '收藏功能'),
        );
      }
      return;
    }

    try {
      final loadedCollections = await FavoriteService.getAllCollections();
      
      // 如果沒有收藏集，創建默認的"口袋清單"
      if (loadedCollections.isEmpty) {
        final localizations = AppLocalizations.of(context);
        final defaultCollection = FavoriteCollection(
          id: '', // 將由 Firestore 自動生成
          name: localizations?.pocketList ?? '口袋清單',
          description: localizations?.defaultCollectionDescription ?? '我想去的地方',
          spotIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final createdCollection = await FavoriteService.createCollection(defaultCollection);

        setState(() {
          collections = [createdCollection];
          selectedCollectionId = createdCollection.id;
          isLoading = false;
        });
      } else {
        setState(() {
          collections = loadedCollections;
          selectedCollectionId = collections.isNotEmpty ? collections.first.id : null;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.loadCollectionsFailedMessage(e.toString()) ?? '載入收藏集失敗: $e')),
        );
      }
    }
  }
  Future<void> _addToCollection() async {
    if (!FirestoreService.isUserLoggedIn()) {
      final localizations = AppLocalizations.of(context);
      showDialog(
        context: context,
        builder: (context) => LoginRequiredDialog(feature: localizations?.favoriteFeature ?? '收藏功能'),
      );
      return;
    }

    if (selectedCollectionId == null && !isCreatingNew) return;

    try {
      final localizations = AppLocalizations.of(context);
      // 如果是創建新收藏集
      if (isCreatingNew) {
        if (_newCollectionController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations?.pleaseEnterCollectionNameSnackbar ?? '請輸入收藏集名稱')),
          );
          return;
        }

        // 創建新收藏集
        final newCollection = FavoriteCollection(
          id: '', // 將由 Firestore 自動生成
          name: _newCollectionController.text.trim(),
          description: '',
          spotIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // 保存新收藏集到 Firestore
        final createdCollection = await FavoriteService.createCollection(newCollection);
        
        // 將景點添加到新收藏集
        await FavoriteService.addSpotToCollection(createdCollection.id, widget.spot.id);
      } else {
        // 添加到現有收藏集
        final collection = collections.firstWhere((c) => c.id == selectedCollectionId);
        
        // 檢查是否已存在
        if (collection.spotIds.contains(widget.spot.id)) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations?.spotAlreadyInCollection ?? '此景點已在該收藏集中')),
          );
          return;
        }

        // 添加景點到收藏集
        await FavoriteService.addSpotToCollection(selectedCollectionId!, widget.spot.id);
      }

      // 將景點保存到 favorites collection
      await FavoriteService.addSpotToFavorites(widget.spot);

      Navigator.pop(context);
      final localizations2 = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isCreatingNew 
            ? (localizations2?.addedToNewCollectionMessage(_newCollectionController.text.trim()) ?? '已加入新收藏集「${_newCollectionController.text.trim()}」')
            : (localizations2?.addedToCollectionMessage(collections.firstWhere((c) => c.id == selectedCollectionId).name) ?? '已加入收藏集「${collections.firstWhere((c) => c.id == selectedCollectionId).name}」')
          ),
        ),
      );
    } catch (e) {
      print('Error adding to collection: $e');
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.addToCollectionFailedMessage(e.toString()) ?? '加入收藏集失敗: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(localizations?.addToFavoriteTitle ?? '加入收藏'),
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
                  localizations?.addSpotToCollectionMessage(widget.spot.name) ?? '將「${widget.spot.name}」加入到：',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                
                if (!isCreatingNew) ...[
                  // 現有收藏集選擇
                  Text(localizations?.selectCollection ?? '選擇收藏集：'),
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
                    label: Text(localizations?.createNewCollectionButton ?? '創建新收藏集'),
                  ),
                ] else ...[
                  // 創建新收藏集
                  Text(localizations?.newCollectionName ?? '新收藏集名稱：'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _newCollectionController,
                    decoration: InputDecoration(
                      hintText: localizations?.collectionNamePlaceholder ?? '例如：北海道景點',
                      border: const OutlineInputBorder(),
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
                    label: Text(localizations?.backToExistingCollections ?? '返回選擇現有收藏集'),
                  ),
                ],
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations?.cancel ?? '取消'),
        ),
        ElevatedButton(
          onPressed: _addToCollection,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          child: Text(localizations?.addButton ?? '加入'),
        ),
      ],
    );
  }
}
