import 'package:flutter/material.dart';

class DiscoverSelectPage extends StatelessWidget {
  final Map<String, List<Map<String, String>>> areas = {
    "北海道": [
      {"name": "札幌", "image": "assets/sapporo.png"},
      {"name": "函館", "image": "assets/hakodate.png"},
    ],
    "東京都": [
      {"name": "澀谷", "image": "assets/shibuya.png"},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("選地區")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: areas.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // ✅ 改成 Wrap 支援自動換行
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: entry.value.map((location) {
                  final name = location['name'] ?? '未知地區';
                  final imagePath = location['image'] ?? '';

                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, name); // 回傳名稱
                    },
                    child: SizedBox(
                      width: 120,
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              imagePath,
                              height: 100,
                              width: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            style: const TextStyle(color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
            ],
          );
        }).toList(),
      ),
    );
  }
}
