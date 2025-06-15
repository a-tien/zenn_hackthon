import 'package:flutter/material.dart';
import 'discover_select_page.dart';

class DiscoverPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 地圖背景圖（模擬用）
        Positioned.fill(
          child: Image.asset(
            'assets/map_sample.png',
            fit: BoxFit.cover,
          ),
        ),

        // 搜尋欄
        Positioned(
          top: 40,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: '搜尋地點、美食、景點',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) {
                      // TODO: 處理搜尋
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // 放在 Stack 或 Column 裡
        Positioned(
          top: 100, // 根據實際搜尋欄位置微調
          left: 0,
          right: 0,
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTagButton(context, '選地區'),
                _buildTagButton(context, '搜尋'),
                _buildTagButton(context, '收藏'),
                _buildTagButton(context, '景點'),
                _buildTagButton(context, '美食'),
              ],
            ),
          ),
        ),

        // GPS icon
        Positioned(
          bottom: 30,
          right: 20,
          child: FloatingActionButton(
            heroTag: 'gps',
            backgroundColor: Colors.white,
            elevation: 3,
            onPressed: () {
              // TODO: 移到使用者位置
            },
            child: const Icon(Icons.my_location, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
