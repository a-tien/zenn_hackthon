import 'package:flutter/material.dart';

class DiscoverSelectPage extends StatelessWidget {
  final Map<String, List<Map<String, String>>> areas = {
    "北海道": [
      {"name": "札幌", "image": "assets/sapporo.jpg"},
      {"name": "函館", "image": "assets/hakodate.jpg"},
    ],
    "東京都": [
      {"name": "澀谷", "image": "assets/shibuya.jpg"},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("選地區")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: areas.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Row(
                children: entry.value.map((location) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // TODO: 點擊地點後跳轉或設定地圖位置
                      },
                      child: Column(
                        children: [
                          Image.asset(location['image']!, height: 100, fit: BoxFit.cover),
                          Text(location['name']!, style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),
    );
  }
}
