import 'package:flutter/material.dart';
import '../components/home_section_title.dart';
import '../components/home_product_slider.dart';
import '../model/home_item_model.dart';
import 'chat_demo_app.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final List<HomeItemModel> recommendedItems = [
    HomeItemModel(
      title: '桑葚園一日遊',
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
    ),
    HomeItemModel(
      title: '富良野花海一日',
      imageUrl: 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
    ),
  ];

  final List<HomeItemModel> popularItems = [
    HomeItemModel(
      title: '海灘日落',
      imageUrl: 'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?auto=format&fit=crop&w=400&q=80',
    ),
    HomeItemModel(
      title: '山脈探險',
      imageUrl: 'https://images.unsplash.com/photo-1499951360442-8f6c1b3e5c7b?auto=format&fit=crop&w=400&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const Text(
                  "哈囉，\n今天想去哪裡呢?",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 24),
                HomeSectionTitle(title: "為你推薦"),
                const SizedBox(height: 12),
                HomeProductSlider(items: recommendedItems),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatDemoApp()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.flash_on, color: Colors.black54),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "與智能助理聊聊",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black26),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                HomeSectionTitle(title: "熱門活動"),
                const SizedBox(height: 12),
                HomeProductSlider(items: popularItems),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
