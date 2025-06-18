import 'package:flutter/material.dart';

class HomeDetailPage extends StatefulWidget {
  final String imageUrl;
  final String title;

  const HomeDetailPage({super.key, required this.imageUrl, required this.title});

  @override
  State<HomeDetailPage> createState() => _HomeDetailPageState();
}

class _HomeDetailPageState extends State<HomeDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '介紹'),
            Tab(text: '行程'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 介紹 Tab
          SingleChildScrollView(
            child: Column(
              children: [
                Image.network(widget.imageUrl, width: double.infinity, height: 180, fit: BoxFit.cover),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('夏天要來點哈密瓜...'),
                ),
              ],
            ),
          ),
          // 行程 Tab
          SingleChildScrollView(
            child: Column(
              children: [
                // Example itinerary item
                Card(
                  margin: const EdgeInsets.all(16),
                  child: ListTile(
                    leading: Image.network(widget.imageUrl, width: 56, height: 56, fit: BoxFit.cover),
                    title: const Text('10:00 哈密瓜田\n停留1時'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.favorite_border),
                        SizedBox(width: 8),
                        Icon(Icons.favorite),
                      ],
                    ),
                  ),
                ),
                // Add more itinerary items as needed
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('加入我的行程'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}