import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/quiz_service.dart';

class QuizResultPage extends StatefulWidget {
  final String result;

  const QuizResultPage({
    super.key,
    required this.result,
  });

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage> {
  late String _description;

  @override
  void initState() {
    super.initState();
    _description = QuizService.getTravelTypeDescription(widget.result);
    _saveTravelTypeToFirestore();
  }

  Future<void> _saveTravelTypeToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'travelType': widget.result,
        });
      }
    } catch (e) {
      // Handle error if needed
    }
  }
  
  void _navigateToProfile() {
    Navigator.of(context).pop(); // 關閉當前頁面，返回上一頁
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(); // 直接使用pop返回
        return false; // 我們自己處理返回，不需要系統處理
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('測驗結果'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          automaticallyImplyLeading: false, // 移除預設返回按鈕
          actions: [
            // 新增關閉按鈕
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _navigateToProfile,
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 慶祝動畫或圖示
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.celebration,
                    color: Colors.purple,
                    size: 70,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 恭喜文字
                const Text(
                  '恭喜！您已完成測驗',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 測驗結果
                Text(
                  '您的旅遊類型為：',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 旅遊類型
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    widget.result,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                  // 描述
                Text(
                  _description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                const SizedBox(height: 32),
                
                // 返回按鈕
                ElevatedButton(
                  onPressed: _navigateToProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '關閉結果頁面',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
