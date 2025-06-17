import 'package:flutter/material.dart';
import '../../itinerary/models/itinerary.dart';
import '../../itinerary/models/itinerary_day.dart';
import '../../itinerary/models/spot.dart';
import '../../itinerary/components/spot_card.dart';
import '../../itinerary/components/transportation_segment.dart';

class HomeDetailPage extends StatefulWidget {
  final String imageUrl;
  final String title;
  final Itinerary itinerary;

  const HomeDetailPage({super.key, required this.imageUrl, required this.title, required this.itinerary});

  @override
  State<HomeDetailPage> createState() => _HomeDetailPageState();
}

class _HomeDetailPageState extends State<HomeDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Itinerary _itinerary;
  
  @override
  void initState() {
    super.initState();
    _itinerary = widget.itinerary;
    _tabController = TabController(length: 2, vsync: this);
    _createDefaultItineraryDays();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 創建默認的行程日數據
  void _createDefaultItineraryDays() {
  final existingCount = _itinerary.itineraryDays.length;

  // Add missing days
  for (int i = existingCount; i < _itinerary.days; i++) {
    _itinerary.itineraryDays.add(
      ItineraryDay(
        dayNumber: i + 1,
        transportation: _itinerary.transportation,
        spots: [],
      ),
    );
  }

  // Ensure Day 1 has default spots if empty
  if (_itinerary.itineraryDays.isNotEmpty && _itinerary.itineraryDays[0].spots.isEmpty) {
    _itinerary.itineraryDays[0].spots = _getDefaultSpots();
  }
}


  // 獲取默認景點（用於示例）
  List<Spot> _getDefaultSpots() {
    return [
      Spot(
        id: '1',
        name: '北海道大學',
        imageUrl:
            'https://images.weserv.nl/?url=daigakujc.jp/smart_phone/top_img/00038/2.jpg',
        order: 1,
        stayHours: 1,
        stayMinutes: 30,
        startTime: '09:00',
        latitude: 43.0742,
        longitude: 141.3405,
        nextTransportation: '步行',
        travelTimeMinutes: 15,
      ),
      Spot(
        id: '2',
        name: '札幌市時計台',
        imageUrl:
            'https://images.weserv.nl/?url=www.jigsaw.jp/img/goods/L/epo7738925113.jpg',
        order: 2,
        stayHours: 0,
        stayMinutes: 45,
        startTime: '11:00',
        latitude: 43.0631,
        longitude: 141.3536,
        nextTransportation: '地鐵',
        travelTimeMinutes: 20,
      ),
      Spot(
        id: '3',
        name: '狸小路商店街',
        imageUrl:
            'https://images.unsplash.com/photo-1591793826788-ae2ce68cca7c?auto=format&fit=crop&w=300&q=80',
        order: 3,
        stayHours: 2,
        stayMinutes: 0,
        startTime: '13:00',
        latitude: 43.0562,
        longitude: 141.3509,
        nextTransportation: '',
        travelTimeMinutes: 0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Debug print
    print('Itinerary days: ${_itinerary.itineraryDays.length}');
    for (var d in _itinerary.itineraryDays) {
      print('Day ${d.dayNumber}: ${d.spots.length} spots');
    }

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
                for (int i = 0; i < _itinerary.itineraryDays.length; i++) _buildSpotsList(i, _itinerary.itineraryDays[i]),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildSpotsList(int dayIndex, ItineraryDay day) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Text('Day ${day.dayNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          itemCount: day.spots.length,
          itemBuilder: (context, index) {
            // 景點卡片和交通段落
            final spot = day.spots[index];
            return Column(
              children: [
                // 景點卡片
                SpotCard(
                  spot: spot,
                  onNavigate: () {
                    // 導航功能（暫未實現）
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('導航功能尚未實現')));
                  },
                ),
        
                // 如果不是最後一個景點，顯示交通段落
                if (index < day.spots.length - 1)
                  TransportationSegment(
                    transportType: spot.nextTransportation,
                    duration: spot.travelTimeMinutes,
                    onTap: () {
                      // _showChangeTransportDialog(spot);
                    },
                    onAddSpot: () {
                      // _showInsertSpotOptions(index + 1);
                    },
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

