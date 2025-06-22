import 'package:flutter/material.dart';
import '../../common/services/firestore_service.dart';

class LoginRequiredDialog extends StatelessWidget {
  final String feature;
  final VoidCallback? onLoginPressed;

  const LoginRequiredDialog({
    super.key,
    required this.feature,
    this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.lock_outline, color: Colors.amber),
          const SizedBox(width: 8),
          const Text('需要登入'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '使用「$feature」功能需要先登入帳號',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.cloud, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      '雲端同步功能',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• 資料安全儲存在雲端\n• 多裝置同步存取\n• 永久保存不丟失',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('稍後再說'),
        ),
        ElevatedButton(
          onPressed: onLoginPressed ?? () {
            Navigator.of(context).pop();
            // 預設行為：導航到登入頁面
            Navigator.of(context).pushNamed('/auth');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('立即登入'),
        ),
      ],
    );
  }

  /// 顯示登入需求對話框
  static void show(
    BuildContext context, 
    String feature, {
    VoidCallback? onLoginPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => LoginRequiredDialog(
        feature: feature,
        onLoginPressed: onLoginPressed,
      ),
    );
  }

  /// 檢查登入狀態，如果未登入則顯示對話框
  static bool checkLoginAndShowDialog(
    BuildContext context, 
    String feature, {
    VoidCallback? onLoginPressed,
  }) {
    if (FirestoreService.isUserLoggedIn()) {
      return true;
    } else {
      show(context, feature, onLoginPressed: onLoginPressed);
      return false;
    }
  }
}
