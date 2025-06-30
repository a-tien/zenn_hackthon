import 'package:flutter/material.dart';
import '../../discover/page/discover_destinations_page.dart';
import '../../collection/pages/favorite_page.dart';
import '../models/itinerary.dart';
import '../models/destination.dart';
import '../../../main.dart';
import '../../../utils/app_localizations.dart';

class AddSpotOptions extends StatelessWidget {
  final bool isInsert;
  final Itinerary? targetItinerary;

  const AddSpotOptions({
    super.key,
    this.isInsert = false,
    this.targetItinerary,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isInsert ? (localizations?.insertNewSpot ?? '插入新景點') : (localizations?.addSpot ?? '添加景點'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // 選項按鈕
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOptionButton(
                context,
                Icons.map,
                localizations?.searchFromMap ?? '從地圖搜尋',
                Colors.green.shade700,
                () => _navigateToMapSearch(context),
              ),
              _buildOptionButton(
                context,
                Icons.search,
                localizations?.regionSearch ?? '區域搜尋',
                Colors.blue.shade700,
                () => _navigateToRegionSearch(context),
              ),
              _buildOptionButton(
                context,
                Icons.bookmark,
                localizations?.selectFromFavorites ?? '從收藏選擇',
                Colors.orange.shade700,
                () => _navigateToFavorites(context),
              ),
              _buildOptionButton(
                context,
                Icons.auto_awesome,
                localizations?.smartRecommendation ?? '智慧推薦',
                Colors.purple.shade700,
                () => _showSmartRecommendation(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 導航到地圖搜尋（探索頁面）
  void _navigateToMapSearch(BuildContext context) {
    // 先保存根導航器的引用
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    
    Navigator.pop(context); // 先關閉底部對話框
    
    // 跳轉到主導航頁面並切換到探索標籤
    rootNavigator.pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainNavigation(initialTab: 1),
      ),
    );
  }

  // 導航到區域搜尋
  void _navigateToRegionSearch(BuildContext context) async {
    // 先保存根導航器的引用
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    
    Navigator.pop(context); // 先關閉底部對話框
    
    // 使用根導航器進行導航，這樣即使當前 widget 被銷毀也不會影響
    final selectedDestination = await rootNavigator.push<Destination>(
      MaterialPageRoute(
        builder: (context) => const DiscoverDestinationsPage(),
      ),
    );
    
    print('📱 區域選擇完成');
    print('🎯 選擇的區域: ${selectedDestination?.name ?? "null"}');
    
    // 如果用戶選擇了區域，跳轉到主導航頁面的探索標籤並傳遞選擇的目的地
    if (selectedDestination != null) {
      print('📍 座標: (${selectedDestination.latitude}, ${selectedDestination.longitude})');
      
      print('🚀 正在跳轉到探索頁面...');
      
      // 使用根導航器替換整個路由棧
      rootNavigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MainNavigation(
            initialTab: 1,
            initialDestination: selectedDestination,
          ),
        ),
        (route) => false,  // 移除所有現有路由
      );
    } else {
      print('❌ 沒有選擇區域');
    }
  }

  // 導航到收藏頁面
  void _navigateToFavorites(BuildContext context) async {
    // 先保存根導航器的引用
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    
    Navigator.pop(context, 'favorites_selected'); // 關閉底部對話框，並返回標識
    
    // 跳轉到收藏頁面，傳遞目標行程資訊
    final result = await rootNavigator.push<bool>(
      MaterialPageRoute(
        builder: (context) => FavoritePage(targetItinerary: targetItinerary),
      ),
    );
    
    // 如果成功添加到行程，返回結果
    if (result == true) {
      print('✅ 成功從收藏中添加景點到行程');
      // 這裡可以觸發額外的回調或事件
    }
  }

  // 顯示智慧推薦（暫時保持原樣）
  void _showSmartRecommendation(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    // 由於只顯示 SnackBar，我們可以先關閉對話框再顯示
    Navigator.pop(context); // 關閉底部對話框
    
    // 使用 context 的 ScaffoldMessenger 顯示 SnackBar
    // 這裡需要找到有效的 Scaffold context
    Future.delayed(const Duration(milliseconds: 100), () {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      if (scaffoldMessenger.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(localizations?.smartRecommendationInDevelopment ?? '智慧推薦功能開發中...'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }
}