import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/itinerary.dart';
import '../models/spot.dart';
import '../models/itinerary_day.dart';
import '../components/spot_card.dart';
import '../components/transportation_segment.dart';
import 'update_firestore.dart';
import '../../../utils/app_localizations.dart';

class AIPlanningResultPage extends StatefulWidget {
  final Itinerary originalItinerary;
  final Itinerary resultItinerary;
  final bool preserveExisting;
  final String? itineraryId;

  const AIPlanningResultPage({
    super.key,
    required this.originalItinerary,
    required this.resultItinerary,
    required this.preserveExisting,
    required this.itineraryId,
  });

  @override
  State<AIPlanningResultPage> createState() => _AIPlanningResultPageState();
}

class _AIPlanningResultPageState extends State<AIPlanningResultPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late Itinerary _resultItinerary;

  @override
  void initState() {
    super.initState();
    _resultItinerary = widget.resultItinerary;
    
    // 如果是模擬數據，先生成一些示例景點
    if (!widget.preserveExisting) {
      _generateSampleItinerary();
    }
    
    // 初始化頁籤控制器
    _tabController = TabController(length: _resultItinerary.days + 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 生成示例行程
  void _generateSampleItinerary() {
    // 確保每天都有景點數據
    for (int i = 0; i < _resultItinerary.days; i++) {
      if (i >= _resultItinerary.itineraryDays.length) {
        _resultItinerary.itineraryDays.add(ItineraryDay(
          dayNumber: i + 1,
          transportation: _resultItinerary.transportation,
          spots: [],
        ));
      }
      
      // 只為第一天添加示例景點（如果需要）
      if (i == 0 && _resultItinerary.itineraryDays[i].spots.isEmpty) {
        _resultItinerary.itineraryDays[i].spots = _getSampleSpots();
      }
    }
  }

  // 獲取示例景點
  List<Spot> _getSampleSpots() {
    return [
      Spot(
        id: '101',
        name: '札幌電視塔',
        imageUrl: 'https://www.tv-tower.co.jp/images/index/mv01.jpg',
        order: 1,
        stayHours: 1,
        stayMinutes: 0,
        startTime: '09:00',
        latitude: 43.0611,
        longitude: 141.3539,
        nextTransportation: '步行',
        travelTimeMinutes: 15,
      ),
      Spot(
        id: '102',
        name: '大通公園',
        imageUrl: 'https://www.sapporo.travel/content/files/sites/2/2019/12/d99fd1ac1fb98f8d23b6ffc26d85ab9c.jpg',
        order: 2,
        stayHours: 1,
        stayMinutes: 30,
        startTime: '10:30',
        latitude: 43.0591,
        longitude: 141.3502,
        nextTransportation: '地鐵',
        travelTimeMinutes: 20,
      ),
      Spot(
        id: '103',
        name: '札幌市舊道廳',
        imageUrl: 'https://www.jalan.net/jalan/img/0/kuchikomi/0400/KS/9b5de_0400642_1.jpg',
        order: 3,
        stayHours: 1,
        stayMinutes: 0,
        startTime: '12:30',
        latitude: 43.0633,
        longitude: 141.3533,
        nextTransportation: '步行',
        travelTimeMinutes: 10,
      ),
      Spot(
        id: '104',
        name: '狸小路商店街',
        imageUrl: 'https://www.sapporo.travel/content/files/sites/2/2019/12/5c9346daf5b1d26fcc7d5eef2a1d02c0.jpg',
        order: 4,
        stayHours: 2,
        stayMinutes: 0,
        startTime: '14:00',
        latitude: 43.0562,
        longitude: 141.3509,
        nextTransportation: '計程車',
        travelTimeMinutes: 15,
      ),
      Spot(
        id: '105',
        name: '白色戀人公園',
        imageUrl: 'https://www.shiroikoibitopark.jp/english/images/img_top_kv_01.jpg',
        order: 5,
        stayHours: 2,
        stayMinutes: 30,
        startTime: '16:30',
        latitude: 43.0881,
        longitude: 141.2694,
        nextTransportation: '',
        travelTimeMinutes: 0,
      ),
    ];
  }

  // Firestore 更新行程
  Future<void> _updateItineraryToFirestore() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final itineraryId = widget.itineraryId;
    final jsonResult = _resultItinerary.toJson();

    if (userId == null || itineraryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.userIdOrItineraryIdEmpty)),
      );
      return;
    }

    try {
      await updateItineraryPartial(userId, itineraryId, jsonResult);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.firestoreWriteSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.firestoreUpdateFailed}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.aiPlanningResult),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 頁籤欄
          Container(
            height: 50,
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blueAccent,
              tabs: [
                const Tab(text: '主頁'),
                for (int i = 0; i < _resultItinerary.days; i++)
                  Tab(text: '第${i + 1}天'),
              ],
            ),
          ),
          
          // 頁籤內容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 主頁
                _buildOverviewTab(),
                
                // 各天的行程頁
                for (int i = 0; i < _resultItinerary.days; i++)
                  _buildDayTab(i),
              ],
            ),
          ),
          
          // 底部按鈕
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                // 與智能助理聊聊
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.comingSoon)),
                      );
                    },
                    icon: const Icon(Icons.chat),
                    label: Text(AppLocalizations.of(context)!.chatWithAiAssistant),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // 捨棄此行程建議
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete),
                    label: Text(AppLocalizations.of(context)!.discardItinerarySuggestion),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // 更新至我的行程
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _updateItineraryToFirestore,
                    icon: const Icon(Icons.check),
                    label: Text(AppLocalizations.of(context)!.updateToMyItinerary),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 構建主頁內容
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 行程信息卡片
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 行程標題
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _resultItinerary.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Colors.amber,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'AI規劃',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  
                  // 行程日期
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        _resultItinerary.useDateRange
                            ? "${_formatDate(_resultItinerary.startDate)} - ${_formatDate(_resultItinerary.endDate)}"
                            : "共${_resultItinerary.days}天",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  
                  // 行程地點
                  Row(
                    children: [
                      Icon(Icons.place, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        _resultItinerary.destination,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  
                  // 成員數量
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        "${_resultItinerary.members.length}位成員",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // AI規劃說明
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.amber.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.amber,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'AI規劃說明',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '根據您的行程設定、成員需求和預算，我們為您規劃了最適合的${_resultItinerary.days}天行程。包含了熱門景點、特色餐廳和當地活動，兼顧了不同成員的喜好。',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '您可以點擊各天的行程標籤查看詳細安排，或與智能助理聊聊來進一步調整行程。',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 行程天數概覽
          const Text(
            "行程概覽",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // 每天行程卡片列表
          for (int i = 0; i < _resultItinerary.days; i++) 
            _buildDayOverviewCard(i),
        ],
      ),
    );
  }

  // 構建日期概覽卡片
  Widget _buildDayOverviewCard(int dayIndex) {
    final day = _resultItinerary.itineraryDays[dayIndex];
    final spotCount = day.spots.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          _tabController.animateTo(dayIndex + 1); // 切換到對應的天數頁籤
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 天數圓形標籤
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${dayIndex + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 行程信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '第${dayIndex + 1}天',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$spotCount 個景點 · ${day.transportation}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // 箭頭圖標
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 構建每日行程標籤頁
  Widget _buildDayTab(int dayIndex) {
    final day = _resultItinerary.itineraryDays[dayIndex];
    
    if (day.spots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "尚無景點規劃",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("此天行程尚未規劃完成", style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.navigationNotImplementedYet)),
                );
              },
            ),

            // 如果不是最後一個景點，顯示交通段落
            if (index < day.spots.length - 1)              TransportationSegment(
                transportType: spot.nextTransportation,
                duration: spot.travelTimeMinutes,
                onTap: () {}, // 結果頁面不允許修改
                onAddSpot: () {}, // 結果頁面不允許添加
              ),
          ],
        );
      },
    );
  }
  
  // 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}
