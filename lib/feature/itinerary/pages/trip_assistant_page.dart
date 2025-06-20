import 'package:flutter/material.dart';
import '../models/itinerary.dart';
import 'recommend_spots_page.dart';
import 'trip_pre_planning_page.dart';

class TripAssistantPage extends StatelessWidget {
  final Itinerary itinerary;

  const TripAssistantPage({
    super.key,
    required this.itinerary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('行程規劃助理'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 歡迎標題
              const Text(
                '歡迎使用智能行程規劃助理',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // 歡迎文字
              Text(
                '我們將根據您的行程偏好和目的地資訊，提供個性化的旅行規劃服務。',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // 推薦景點按鈕
              _buildOptionCard(
                context,
                title: '推薦景點',
                description: '基於您的喜好，為您推薦附近值得一遊的景點和美食。',
                icon: Icons.place,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecommendSpotsPage(
                        itinerary: itinerary,
                      ),
                    ),
                  );
                },
              ),
              

              const SizedBox(height: 20),
              
              // 完整規劃按鈕
              _buildOptionCard(
                context,
                title: '完整規劃',
                description: '讓我們為您設計整個行程，包括景點安排、交通方式和時間規劃。',
                icon: Icons.schedule,
                color: Colors.amber,
                onTap: () {
                  _showPlanningOptions(context);
                },
              ),
              
              const Spacer(),
              
              // 關閉按鈕
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('關閉'),
              ),
            ],
          ),
        ),
      ),
    );
  }  // 顯示規劃選項對話框
  void _showPlanningOptions(BuildContext context) {
    print('Showing planning options dialog'); // 添加日誌
    
    // 覆蓋現有行程
    void _navigateToPrePlanning(bool preserveExisting) {
      print('Navigating to pre-planning with preserveExisting=$preserveExisting'); // 添加日誌
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripPrePlanningPage(
            itinerary: itinerary,
            preserveExisting: preserveExisting,
          ),
        ),
      );
    }
    
    // 顯示選項對話框
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('請選擇規劃方式'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 覆蓋現有行程選項
              ListTile(
                leading: const Icon(Icons.refresh, color: Colors.blue),
                title: const Text('覆蓋現有行程'),
                subtitle: const Text('刪除所有已選的景點，重新規劃整個行程'),
                onTap: () {
                  print('Dialog: selected overwrite'); // 添加日誌
                  Navigator.pop(dialogContext);
                  _navigateToPrePlanning(false);
                },
              ),
              // 保留已選行程選項
              ListTile(
                leading: const Icon(Icons.add_circle, color: Colors.green),
                title: const Text('保留已選的行程'),
                subtitle: const Text('根據已選景點，繼續規劃其他景點和活動'),
                onTap: () {
                  print('Dialog: selected preserve'); // 添加日誌
                  Navigator.pop(dialogContext);
                  _navigateToPrePlanning(true);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
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
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}