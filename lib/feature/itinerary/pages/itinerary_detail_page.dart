import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/itinerary.dart';
import '../models/itinerary_day.dart';
import '../models/itinerary_member.dart';
import '../models/spot.dart';
import '../components/spot_card.dart';
import '../components/transportation_segment.dart';
import '../components/edit_itinerary_dialog.dart';
import '../components/add_spot_options.dart';
import '../components/day_transportation_dialog.dart';
import '../components/change_transport_dialog.dart';
import 'trip_assistant_page.dart';
import 'manage_itinerary_members_page.dart';
import 'add_edit_itinerary_member_page.dart';

class ItineraryDetailPage extends StatefulWidget {
  final Itinerary itinerary;

  const ItineraryDetailPage({super.key, required this.itinerary});

  @override
  State<ItineraryDetailPage> createState() => _ItineraryDetailPageState();
}

class _ItineraryDetailPageState extends State<ItineraryDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Itinerary _itinerary;
  bool _isMapView = false;

  @override
  void initState() {
    super.initState();
    _itinerary = widget.itinerary;
    // 如果沒有預設行程日，創建默認的
    if (_itinerary.itineraryDays.isEmpty) {
      _createDefaultItineraryDays();
    }

    // 初始化頁籤控制器
    _initTabController();
  }

  // 將 TabController 初始化邏輯移到單獨的方法
  void _initTabController() {
    _tabController = TabController(length: _itinerary.days + 1, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  // 處理頁籤變化
  void _handleTabChange() {
    // 只有當頁籤真的變化時才更新狀態
    if (_tabController.indexIsChanging) {
      setState(() {
        // 可以在這裡處理與頁籤變化相關的邏輯
      });
    }
  }

  @override
  void dispose() {
    // 確保在 dispose 前移除監聽器
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  // 創建默認的行程日數據
  void _createDefaultItineraryDays() {
    for (int i = 0; i < _itinerary.days; i++) {
      final day = ItineraryDay(
        dayNumber: i + 1,
        transportation: _itinerary.transportation,
        spots: i == 0 ? _getDefaultSpots() : [], // 為第一天添加一些默認景點
      );
      _itinerary.itineraryDays.add(day);
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

  // 保存行程變更
  Future<void> _saveItinerary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itinerariesJson = prefs.getStringList('itineraries') ?? [];

      // 查找並更新現有行程
      List<Map<String, dynamic>> itinerariesList = itinerariesJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList();

      bool found = false;
      int index = -1;

      // 根據行程名稱查找和更新
      for (int i = 0; i < itinerariesList.length; i++) {
        if (itinerariesList[i]['name'] == _itinerary.name) {
          index = i;
          found = true;
          break;
        }
      }

      // 避免在循環中直接修改，而是在找到後修改
      if (found && index >= 0) {
        itinerariesList[index] = _itinerary.toJson();
      } else {
        // 如果沒找到，添加一個新的
        itinerariesList.add(_itinerary.toJson());
      }

      // 儲存更新後的行程列表
      final updatedJson = itinerariesList
          .map((item) => jsonEncode(item))
          .toList();
      await prefs.setStringList('itineraries', updatedJson);

      return; // 正常完成
    } catch (e) {
      print('保存行程時出錯: $e');
      throw e; // 重新拋出錯誤以便上層處理
    }
  }

  // 刪除行程
  Future<void> _deleteItinerary() async {
    final prefs = await SharedPreferences.getInstance();
    final itinerariesJson = prefs.getStringList('itineraries') ?? [];

    // 過濾掉當前行程
    final filteredItineraries = itinerariesJson.where((json) {
      final item = jsonDecode(json);
      return item['name'] != _itinerary.name;
    }).toList();

    // 儲存過濾後的行程列表
    await prefs.setStringList('itineraries', filteredItineraries);

    if (mounted) {
      Navigator.pop(context, true); // 返回並通知更新
    }
  }

  // 增加天數
  void _addDay() async {
    // 記住當前頁籤位置
    final currentIndex = _tabController.index;

    // 先釋放舊的 controller
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();

    // 更新天數
    setState(() {
      _itinerary.addDay();

      // 重新初始化 TabController
      _tabController = TabController(
        length: _itinerary.days + 1,
        vsync: this,
        initialIndex: currentIndex,
      );
      _tabController.addListener(_handleTabChange);
    });

    // 保存變更
    await _saveItinerary();
  }

  // 減少天數
  void _removeDay() async {
    if (_itinerary.days <= 1) return;

    // 記住當前頁籤位置，確保不會超出範圍
    final currentIndex = _tabController.index;
    final newIndex = currentIndex >= _itinerary.days
        ? _itinerary.days - 1
        : currentIndex;

    // 先釋放舊的 controller
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();

    // 更新天數
    setState(() {
      _itinerary.removeLastDay();

      // 重新初始化 TabController
      _tabController = TabController(
        length: _itinerary.days + 1,
        vsync: this,
        initialIndex: newIndex,
      );
      _tabController.addListener(_handleTabChange);
    });

    // 保存變更
    await _saveItinerary();
  }

  // 更新行程基本信息
  Future<void> _updateItineraryInfo(Itinerary updatedItinerary) async {
    try {
      // 步驟 1: 保存當前狀態以便後續使用
      final oldDays = _itinerary.days;
      final currentTabIndex = _tabController.index;
      final List<ItineraryDay> existingDays = List.from(
        _itinerary.itineraryDays,
      );      // 步驟 2: 更新基本屬性
      _itinerary.name = updatedItinerary.name;
      _itinerary.useDateRange = updatedItinerary.useDateRange;
      _itinerary.days = updatedItinerary.days;
      _itinerary.startDate = updatedItinerary.startDate;
      _itinerary.endDate = updatedItinerary.endDate;
      _itinerary.destinations = updatedItinerary.destinations;

      // 步驟 3: 處理天數變化
      if (oldDays != _itinerary.days) {
        // 如果天數減少，移除多餘的天數
        if (_itinerary.days < oldDays) {
          _itinerary.itineraryDays = existingDays.sublist(0, _itinerary.days);
        }
        // 如果天數增加，添加新的天數
        else if (_itinerary.days > oldDays) {
          _itinerary.itineraryDays = List.from(existingDays); // 複製現有天數

          // 添加新的天數
          for (int i = oldDays; i < _itinerary.days; i++) {
            _itinerary.itineraryDays.add(
              ItineraryDay(
                dayNumber: i + 1,
                transportation: _itinerary.transportation,
                spots: [],
              ),
            );
          }
        }
      }

      // 步驟 4: 保存更新後的行程
      await _saveItinerary();

      // 步驟 5: 在主線程中更新 UI
      if (mounted) {
        // 關閉載入對話框
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // 計算新的頁籤索引
        final newTabIndex = currentTabIndex > _itinerary.days
            ? _itinerary.days
            : currentTabIndex;

        // 重新創建 TabController
        setState(() {
          // 釋放舊的 controller
          _tabController.removeListener(_handleTabChange);
          _tabController.dispose();

          // 創建新的 controller
          _tabController = TabController(
            length: _itinerary.days + 1,
            vsync: this,
            initialIndex: newTabIndex,
          );
          _tabController.addListener(_handleTabChange);
        });

        // 顯示成功消息
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('行程已更新')));
      }
    } catch (e) {
      // 錯誤處理
      print('更新行程時發生錯誤: $e');

      // 關閉載入對話框
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // 顯示錯誤信息
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('更新失敗: $e')));
      }
    }
  }

  // 顯示載入指示器對話框
  void _showLoadingDialog(BuildContext context, String message) {
    // 使用 showDialog 而不是直接構建對話框
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54, // 半透明背景
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async => false, // 防止返回鍵關閉對話框
          child: SimpleDialog(
            backgroundColor: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text(
                        message,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 更新日程交通方式
  void _updateDayTransportation(int dayIndex, String transportation) {
    setState(() {
      _itinerary.itineraryDays[dayIndex].transportation = transportation;
    });
    _saveItinerary();
  }

  // 顯示行程設置選單
  void _showItineraryOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('刪除行程'),
              onTap: () {
                Navigator.pop(context); // 關閉選單
                _showDeleteConfirmation();
              },
            ),
          ],
        );
      },
    );
  }

  // 顯示刪除確認對話框
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('確認刪除'),
          content: const Text('確定要刪除此行程嗎？此操作無法復原。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteItinerary();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('刪除'),
            ),
          ],
        );
      },
    );
  }

  // 顯示編輯行程信息對話框
  Future<void> _showEditItineraryDialog() async {
    // 使用 await 來等待對話框關閉並獲取結果
    final updatedItinerary = await showDialog<Itinerary>(
      context: context,
      barrierDismissible: false, // 防止用戶點擊外部關閉對話框
      builder: (context) {
        return EditItineraryDialog(
          itinerary: _itinerary,
          onUpdate: (itinerary) {}, // 空方法，我們將直接使用返回值
        );
      },
    );

    // 如果用戶取消編輯或對話框被異常關閉，updatedItinerary 將為 null
    if (updatedItinerary != null && mounted) {
      // 顯示載入對話框
      _showLoadingDialog(context, '正在更新行程...');

      // 使用 Future.delayed 來確保載入對話框顯示後再執行更新
      Future.delayed(const Duration(milliseconds: 200), () {
        _updateItineraryInfo(updatedItinerary);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_itinerary.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showItineraryOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // 頁籤欄
          _buildTabBar(),

          // 頁籤內容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 主頁
                _buildOverviewTab(),

                // 每天行程頁籤
                for (int i = 0; i < _itinerary.days; i++) _buildDayPlanTab(i),
              ],
            ),
          ),
        ],
      ),
      // 地圖/列表切換按鈕
      floatingActionButton: _tabController.index > 0
          ? FloatingActionButton(
              key: const ValueKey('mapListToggle'), // 添加key幫助Flutter識別
              onPressed: () {
                setState(() {
                  _isMapView = !_isMapView;
                });
              },
              backgroundColor: Colors.blueAccent,
              child: Icon(_isMapView ? Icons.list : Icons.map),
            )
          : null,
    );
  }

  // 構建頁籤欄
  Widget _buildTabBar() {
    return Container(
      height: 50,
      color: Colors.white,
      child: Row(
        children: [
          // 頁籤列表，可滾動
          Expanded(
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blueAccent,
              tabs: [
                const Tab(text: '主頁'),
                for (int i = 0; i < _itinerary.days; i++)
                  Tab(text: '第${i + 1}天'),
              ],
            ),
          ),

          // 減少天數按鈕
          IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.blueAccent),
            onPressed: _removeDay,
          ),

          // 增加天數按鈕
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.blueAccent),
            onPressed: _addDay,
          ),
        ],
      ),
    );
  }

  // 構建主頁內容
  Widget _buildOverviewTab() {
    String dateText;
    if (_itinerary.useDateRange) {
      final formatter = (DateTime date) =>
          "${date.year}/${date.month}/${date.day}";
      dateText =
          "${formatter(_itinerary.startDate)} - ${formatter(_itinerary.endDate)} (${_itinerary.days}天)";
    } else {
      dateText = "${_itinerary.days}天";
    }

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
                  // 行程標題與編輯按鈕
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _itinerary.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: _showEditItineraryDialog,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 行程日期或天數
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateText,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),                  // 行程目的地
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: _buildDestinationsDisplay()),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 主要交通方式
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_car,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _itinerary.transportation,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 旅遊類型
                  Row(
                    children: [
                      const Icon(Icons.people, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        _itinerary.travelType,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 新增: 智能行程規劃助理按鈕
          // 找到智能行程規劃助理按鈕的點擊事件
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TripAssistantPage(itinerary: _itinerary),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.bolt, // 閃電圖標
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    '智能行程規劃助理',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 行程成員區塊
          const Text(
            "行程成員",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // 行程成員內容
          _buildMembersSection(),

          const SizedBox(height: 24),

          // 行程天數概覽
          const Text(
            "行程概覽",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // 每天行程卡片列表
          for (int i = 0; i < _itinerary.days; i++) _buildDayOverviewCard(i),
        ],
      ),
    );
  }

  // 構建日期概覽卡片
  Widget _buildDayOverviewCard(int dayIndex) {
    final day = _itinerary.itineraryDays[dayIndex];
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
                decoration: BoxDecoration(
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
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // 查看箭頭
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // 構建每天行程頁籤
  Widget _buildDayPlanTab(int dayIndex) {
    final day = _itinerary.itineraryDays[dayIndex];

    // 如果是地圖模式，顯示地圖
    if (_isMapView) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "地圖視圖",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "此處將顯示第${dayIndex + 1}天的地圖視圖",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // 列表模式
    return Column(
      children: [
        // 日期與按鈕欄
        _buildDayHeader(dayIndex, day),

        // 景點列表
        Expanded(
          child: day.spots.isEmpty
              ? _buildEmptySpotsList(dayIndex)
              : _buildSpotsList(dayIndex, day),
        ),
      ],
    );
  }

  // 構建日期頭部欄
  Widget _buildDayHeader(int dayIndex, ItineraryDay day) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '第${dayIndex + 1}天',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),

          // 交通方式按鈕
          OutlinedButton.icon(
            icon: const Icon(Icons.directions_car, size: 18),
            label: Text(day.transportation),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blueAccent,
              side: const BorderSide(color: Colors.blueAccent),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => DayTransportationDialog(
                  initialTransportation: day.transportation,
                  onSelect: (transportation) {
                    _updateDayTransportation(dayIndex, transportation);
                  },
                ),
              );
            },
          ),

          const SizedBox(width: 8),

          // 一鍵安排按鈕
          ElevatedButton.icon(
            icon: const Icon(Icons.shuffle, size: 18),
            label: const Text('一鍵安排'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // 暫時顯示未實現提示
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('此功能尚未實現')));
            },
          ),
        ],
      ),
    );
  }

  // 構建空景點列表
  Widget _buildEmptySpotsList(int dayIndex) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "尚無景點",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("點擊下方按鈕添加第一個景點", style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('添加景點'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              _showAddSpotOptions();
            },
          ),
        ],
      ),
    );
  }

  // 構建景點列表
  Widget _buildSpotsList(int dayIndex, ItineraryDay day) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: day.spots.length + 1, // +1 for the add button at the end
      itemBuilder: (context, index) {
        // 底部的添加按鈕
        if (index == day.spots.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('添加景點'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  _showAddSpotOptions();
                },
              ),
            ),
          );
        }

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
                  _showChangeTransportDialog(spot);
                },
                onAddSpot: () {
                  _showInsertSpotOptions(index + 1);
                },
              ),
          ],
        );
      },
    );
  }

  // 顯示添加景點選項
  void _showAddSpotOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddSpotOptions(),
    );
  }

  // 顯示插入景點選項
  void _showInsertSpotOptions(int afterIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddSpotOptions(isInsert: true),
    );
  }

  // 顯示更改交通方式對話框
  void _showChangeTransportDialog(Spot spot) {
    showDialog(
      context: context,
      builder: (context) => ChangeTransportDialog(
        initialTransportation: spot.nextTransportation,
        travelTimeMinutes: spot.travelTimeMinutes,
        onUpdate: (transportation, minutes) {
          setState(() {
            spot.nextTransportation = transportation;
            spot.travelTimeMinutes = minutes;
          });
          _saveItinerary();
        },
      ),
    );
  }

  // 顯示行程成員區塊
  Widget _buildMembersSection() {
    if (_itinerary.members.isEmpty) {
      // 無成員時顯示空狀態
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: _manageTravelMembers,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                const Icon(Icons.person_add, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  '尚未設定行程成員',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _manageTravelMembers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('設定行程成員'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 有成員時顯示成員列表
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題與成員數量
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '共 ${_itinerary.members.length} 位成員',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('編輯'),
                  onPressed: _manageTravelMembers,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 成員頭像列表
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _itinerary.members.length,
                itemBuilder: (context, index) {
                  final member = _itinerary.members[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        member.getAvatar(size: 50, onTap: () {
                          _showMemberDetails(member);
                        }),
                        const SizedBox(height: 4),
                        Text(
                          member.nickname,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 顯示成員詳情
  void _showMemberDetails(ItineraryMember member) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題
            Row(
              children: [
                member.getAvatar(size: 40),
                const SizedBox(width: 12),
                Text(
                  member.nickname,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 年齡層
            Row(
              children: [
                const Icon(Icons.cake, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Text('年齡層: ${member.ageGroup}'),
              ],
            ),
            const SizedBox(height: 12),
            
            // 興趣
            if (member.interests.isNotEmpty) ...[
              const Text('興趣:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: member.interests.map((interest) => Chip(
                  label: Text(interest, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.blue.shade100,
                  padding: const EdgeInsets.all(4),
                )).toList(),
              ),
              const SizedBox(height: 12),
            ],
            
            // 特殊需求
            if (member.specialNeeds.isNotEmpty) ...[
              const Text('特殊需求:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: member.specialNeeds.map((need) => Chip(
                  label: Text(need, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.orange.shade100,
                  padding: const EdgeInsets.all(4),
                )).toList(),
              ),
            ],
            const SizedBox(height: 16),
            
            // 編輯按鈕
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _editMember(member);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('編輯成員'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 管理行程成員
  Future<void> _manageTravelMembers() async {
    final result = await Navigator.push<List<ItineraryMember>>(
      context,
      MaterialPageRoute(
        builder: (context) => ManageItineraryMembersPage(
          itinerary: _itinerary,
          onMembersUpdated: (updatedMembers) {
            setState(() {
              _itinerary.members = updatedMembers;
            });
            _saveItinerary();
          },
        ),
      ),
    );
    
    if (result != null) {
      setState(() {
        _itinerary.members = result;
      });
      await _saveItinerary();
    }
  }

  // 編輯成員
  Future<void> _editMember(ItineraryMember member) async {
    final result = await Navigator.push<ItineraryMember>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditItineraryMemberPage(member: member),
      ),
    );
    
    if (result == 'delete') {
      // 刪除成員
      setState(() {
        _itinerary.members.removeWhere((m) => m.id == member.id);
      });
    } else if (result != null) {
      // 更新成員
      setState(() {
        final index = _itinerary.members.indexWhere((m) => m.id == member.id);
        if (index != -1) {
          _itinerary.members[index] = result;
        }
      });
    }
    
    await _saveItinerary();
  }

  // 構建目的地顯示
  Widget _buildDestinationsDisplay() {
    if (_itinerary.destinations.isEmpty) {
      return Text(
        '尚未設定目的地',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _itinerary.destinations.map((destination) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          destination.name,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      )).toList(),
    );  }
}
