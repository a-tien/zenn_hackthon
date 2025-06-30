import 'package:flutter/material.dart';
import '../../../utils/app_localizations.dart';

class LoginRequiredDialog extends StatefulWidget {
  final String feature;
  final VoidCallback? onLoginPressed;

  const LoginRequiredDialog({
    super.key,
    required this.feature,
    this.onLoginPressed,
  });

  @override
  State<LoginRequiredDialog> createState() => _LoginRequiredDialogState();
}

class _LoginRequiredDialogState extends State<LoginRequiredDialog> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.lock_outline, color: Colors.amber),
          const SizedBox(width: 8),
          Text(localizations?.loginRequiredTitle ?? '需要登入'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations?.loginRequiredMessage(widget.feature) ?? '使用「${widget.feature}」功能需要先登入帳號',
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
                    Text(
                      localizations?.cloudSyncTitle ?? '雲端同步功能',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  localizations?.cloudSyncDesc ?? '• 資料安全儲存在雲端\n• 多裝置同步存取\n• 永久保存不丟失',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations?.maybeLater ?? '稍後再說'),
        ),
        ElevatedButton(
          onPressed: _isNavigating ? null : () {
            if (_isNavigating) return;
            
            setState(() {
              _isNavigating = true;
            });
            
            // 獲取必要的引用
            final navigator = Navigator.of(context, rootNavigator: true);
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            
            // 先關閉對話框
            Navigator.of(context).pop();
            
            // 使用 addPostFrameCallback 確保在下一幀執行導航
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              try {
                if (!mounted) return;
                
                // 導航到登入頁面
                final result = await navigator.pushNamed('/login');
                
                if (result == true && mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(localizations?.loginSuccess ?? '登入成功！現在可以使用此功能了'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  
                  // 如果有自定義的登入後回調，執行它
                  if (widget.onLoginPressed != null) {
                    widget.onLoginPressed!();
                  }
                }
              } catch (e) {
                print('導航到登入頁面時發生錯誤: $e');
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(localizations?.loginFailed ?? '無法跳轉到登入頁面，請稍後再試'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    _isNavigating = false;
                  });
                }
              }
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: _isNavigating 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(localizations?.loginNow ?? '立即登入'),
        ),
      ],
    );
  }

  // /// 檢查登入狀態，如果未登入則顯示對話框
  // static bool checkLoginAndShowDialog(
  //   BuildContext context, 
  //   String feature, {
  //   VoidCallback? onLoginPressed,
  // }) {
  //   if (FirestoreService.isUserLoggedIn()) {
  //     return true;
  //   } else {
  //     show(context, feature, onLoginPressed: onLoginPressed);
  //     return false;
  //   }
  // }
}
