import 'package:flutter/material.dart';
import 'discover_select_page.dart';
import 'spot_detail_page.dart';
import 'package:my_app_1/feature/discover/models/spot.dart';



enum SortType {
  rating,
  distance,
}

class DiscoverPage extends StatefulWidget {
  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  SortType _selectedSort = SortType.rating;
  int _tabIndex = 0;
  String selectedArea = '選地區';

  void _navigateToSelectArea() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DiscoverSelectPage()),
    );

    if (result != null && result is String) {
      setState(() {
        selectedArea = result;
      });
    }
  }

  void _showSortOptions() async {
    SortType tempSort = _selectedSort;
    SortType? result = await showDialog<SortType>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('推薦排序'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<SortType>(
                title: const Text('評論 (高→低)'),
                value: SortType.rating,
                groupValue: tempSort,
                onChanged: (value) {
                  setState(() {
                    tempSort = value!;
                  });
                },
              ),
              RadioListTile<SortType>(
                title: const Text('距離 (近→遠)'),
                value: SortType.distance,
                groupValue: tempSort,
                onChanged: (value) {
                  setState(() {
                    tempSort = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, tempSort),
              child: const Text('確定'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedSort = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 主內容區
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: IndexedStack(
                index: _tabIndex,
                children: [
                  _buildMapView(),
                  _buildRecommendationView(),
                ],
              ),
            ),
          ),

          // 搜尋欄
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: _buildSearchBar(),
          ),

          // Tab 切換按鈕
          Positioned(
            bottom: 30,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'tab-map',
                  mini: true,
                  backgroundColor:
                      _tabIndex == 0 ? Colors.blueAccent : Colors.white,
                  child: Icon(
                    Icons.map,
                    color: _tabIndex == 0 ? Colors.white : Colors.blueAccent,
                  ),
                  onPressed: () {
                    setState(() => _tabIndex = 0);
                  },
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'tab-recommend',
                  mini: true,
                  backgroundColor: _tabIndex == 1 ? Colors.blueAccent : Colors.white,
                  child: Icon(
                    Icons.list,
                    color: _tabIndex == 1 ? Colors.white : Colors.blueAccent,
                  ),
                  onPressed: () {
                    setState(() => _tabIndex = 1);
                  },
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
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
            ),
          ),
          TextButton.icon(
            onPressed: _navigateToSelectArea,
            icon: const Icon(Icons.place, color: Colors.blueAccent),
            label: Text(
              selectedArea,
              style: const TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Image.asset('assets/map_sample.png', fit: BoxFit.cover);
  }

  Widget _buildRecommendationView() {
    // 模擬推薦資料
    List<Spot> spots = [
      Spot(
        name: '札幌車站',
        area: '北海道・札幌',
        image: 'assets/sapporo.png',
        address: '北海道札幌市中央區北4條西4丁目',
        rating: 4.8,
        distance: 1.1,
      ),
      Spot(
        name: '大通公園',
        area: '北海道・札幌',
        image: 'assets/sapporo.png',
        address: '北海道札幌市中央區大通西1～12丁目',
        rating: 4.3,
        distance: 1.5,
      ),
    ];


    // 排序
    if (_selectedSort == SortType.rating) {
      spots.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      spots.sort((a, b) => a.distance.compareTo(b.distance));
    }


    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("推薦景點",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showSortOptions,
              ),
            ],
          ),
          const SizedBox(height: 16),
            ...spots.map((spot) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildRecommendationCard(spot),
          )),
          if (spots.isEmpty)
            const Center(
              child: Text('沒有推薦的景點', style: TextStyle(color: Colors.grey)),
            ),
          const SizedBox(height: 32),

        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Spot spot) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SpotDetailPage(spot: spot),
          ),
        );
      },
      child: Card(
        child: Column(
          children: [
            Image.asset(spot.image, height: 120, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(spot.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${spot.distance} km', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}
