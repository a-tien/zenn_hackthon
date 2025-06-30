import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math' as math;
import '../models/itinerary.dart';
import '../models/itinerary_day.dart';
import '../models/itinerary_member.dart';
import '../models/spot.dart';
import '../components/spot_card.dart';
import '../components/transportation_segment.dart';
import '../components/edit_itinerary_dialog.dart';
import '../components/add_spot_options.dart';
import '../components/day_transportation_dialog.dart';
import '../components/enhanced_change_transport_dialog.dart';
import '../components/edit_stay_time_dialog.dart';
import '../../collection/pages/spot_detail_page.dart';
import '../../collection/services/favorite_service.dart';
import '../services/itinerary_service.dart';
import '../../common/widgets/login_required_dialog.dart';
import 'trip_assistant_page.dart';
import 'manage_itinerary_members_page.dart';
import 'add_edit_itinerary_member_page.dart';
import '../../../utils/app_localizations.dart';

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
  final ItineraryService _itineraryService = ItineraryService();
  
  // 地圖相關變量
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Map<int, BitmapDescriptor> _numberMarkers = {};
  int _currentMapDayIndex = 0; // 追蹤當前地圖顯示的天數
  bool _isMapReady = false; // 追蹤地圖是否已經準備好
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
    
    // 重新載入資料以確保顯示最新狀態
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reloadItinerary();
    });
    
    // 初始化編號標記
    _initializeNumberMarkers();
  }

  // 將 TabController 初始化邏輯移到單獨的方法
  void _initTabController() {
    _tabController = TabController(length: _itinerary.days + 1, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  // 處理頁籤變化
  void _handleTabChange() {
    // 當頁籤變化時，總是觸發重建以更新 FloatingActionButton 的顯示狀態
    if (mounted) {
      print('Tab changed to index: ${_tabController.index}');
      setState(() {
        // 更新當前地圖顯示的天數
        if (_tabController.index > 0) {
          _currentMapDayIndex = _tabController.index - 1;
          print('Map day index updated to: $_currentMapDayIndex');

          // 如果當前是地圖視圖且地圖已經準備好，才更新地圖
          if (_isMapView && _isMapReady && _mapController != null) {
            // 只更新標記，不調整視角（避免 web 版本的問題）
            _createMarkersForDay(_currentMapDayIndex);
          } else if (_isMapView) {
            // 如果地圖還沒準備好，只更新標記
            _createMarkersForDay(_currentMapDayIndex);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    // 確保在 dispose 前移除監聽器並清理資源
    try {
      _tabController.removeListener(_handleTabChange);
    } catch (e) {
      // 忽略已經釋放的 controller 錯誤
    }
    _tabController.dispose();
    
    // 清理地圖相關資源
    _isMapReady = false;
    _mapController?.dispose();
    _mapController = null;
    
    super.dispose();
  }
  // 創建默認的行程日數據
  void _createDefaultItineraryDays() {
    for (int i = 0; i < _itinerary.days; i++) {
      final day = ItineraryDay(
        dayNumber: i + 1,
        transportation: _itinerary.transportation,
        spots: [], // 移除模擬數據，現在全部通過加入行程功能添加
      );
      _itinerary.itineraryDays.add(day);
    }
  }  // 保存行程變更
  Future<void> _saveItinerary() async {
    try {
      await _itineraryService.saveItinerary(_itinerary);
    } catch (e) {        if (e.toString().contains('需要登入')) {
          // 顯示登入提示對話框
          if (mounted) {
            final localizations = AppLocalizations.of(context);
            showDialog(
              context: context,
              builder: (context) => LoginRequiredDialog(feature: localizations?.saveItineraryFeature ?? '保存行程'),
            );
          }
          return;
        }
        
        print('保存行程時出錯: $e');
        if (mounted) {
          final localizations = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${localizations?.saveFailed ?? '保存失敗: '}$e')),
          );
        }
      throw e;
    }
  }
  // 刪除行程
  Future<void> _deleteItinerary() async {
    try {
      if (_itinerary.id == null || _itinerary.id!.isEmpty) {
        throw Exception('無法刪除：行程ID不存在');
      }
      
      await _itineraryService.deleteItinerary(_itinerary.id!);
      
      if (mounted) {
        Navigator.pop(context, true); // 返回並通知更新
      }
    } catch (e) {        if (e.toString().contains('需要登入')) {
          // 顯示登入提示對話框
          if (mounted) {
            final localizations = AppLocalizations.of(context);
            showDialog(
              context: context,
              builder: (context) => LoginRequiredDialog(feature: localizations?.deleteItineraryFeature ?? '刪除行程'),
            );
          }
          return;
        }
        
        print('刪除行程時出錯: $e');
        if (mounted) {
          final localizations = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${localizations?.deleteFailed ?? '刪除失敗: '}$e')),
          );
        }
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
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizations?.itineraryUpdated ?? '行程已更新')));
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
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${localizations?.updateFailed ?? '更新失敗: '}$e')));
      }
    }
  }

  // 顯示載入指示器對話框
  void _showLoadingDialog(BuildContext context, String message) {
    final localizations = AppLocalizations.of(context);
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
                        message.isEmpty ? (localizations?.updating ?? '正在更新...') : message,
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
    final localizations = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(localizations?.deleteItinerary ?? '刪除行程'),
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
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations?.confirmDelete ?? '確認刪除'),
          content: Text(localizations?.confirmDeleteMessage ?? '確定要刪除此行程嗎？此操作無法復原。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations?.cancel ?? '取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteItinerary();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(localizations?.delete ?? '刪除'),
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
      final localizations = AppLocalizations.of(context);
      // 顯示載入對話框
      _showLoadingDialog(context, localizations?.updatingItinerary ?? '正在更新行程...');

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
      // 地圖/列表切換按鈕 - 只在天數頁籤顯示
      floatingActionButton: _tabController.index > 0
          ? FloatingActionButton(
              key: const ValueKey('mapListToggle'), // 添加key幫助Flutter識別
              onPressed: () {
                print('FloatingActionButton pressed: current tab index = ${_tabController.index}');
                setState(() {
                  _isMapView = !_isMapView;
                  print('Map view toggled to: $_isMapView');
                  
                  // 如果切換到地圖視圖，準備當前天數索引
                  if (_isMapView && _tabController.index > 0) {
                    _currentMapDayIndex = _tabController.index - 1;
                    print('Preparing map for day index: $_currentMapDayIndex');
                    
                    // 不立即操作地圖，讓 onMapCreated 處理初始化
                  }
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
    final localizations = AppLocalizations.of(context);
    
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
                Tab(text: localizations?.homepage ?? '主頁'),
                for (int i = 0; i < _itinerary.days; i++)
                  Tab(text: localizations?.getDayTab(i + 1) ?? '第${i + 1}天'),
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
    final localizations = AppLocalizations.of(context);
    
    String dateText;
    if (_itinerary.useDateRange) {
      final formatter = (DateTime date) =>
          "${date.year}/${date.month}/${date.day}";
      dateText =
          "${formatter(_itinerary.startDate)} - ${formatter(_itinerary.endDate)} (${localizations?.getDaysFormat(_itinerary.days) ?? '${_itinerary.days}天'})";
    } else {
      dateText = localizations?.getDaysOnly(_itinerary.days) ?? "${_itinerary.days}天";
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
                children: [
                  const Icon(
                    Icons.bolt, // 閃電圖標
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    localizations?.smartTripAssistant ?? '智能行程規劃助理',
                    style: const TextStyle(
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
          Text(
            localizations?.itineraryMembers ?? "行程成員",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // 行程成員內容
          _buildMembersSection(),

          const SizedBox(height: 24),

          // 行程天數概覽
          Text(
            localizations?.itineraryOverview ?? "行程概覽",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    final localizations = AppLocalizations.of(context);
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
                      localizations?.getDayTab(dayIndex + 1) ?? '第${dayIndex + 1}天',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${localizations?.getSpotsCount(spotCount) ?? '$spotCount 個景點'} · ${day.transportation}',
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
      // 如果當天沒有景點，顯示提示
      if (day.spots.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "尚無景點",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "第${dayIndex + 1}天還沒有加入任何景點",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }
      
      return _buildMapView(dayIndex, day);
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

  // 構建地圖視圖
  Widget _buildMapView(int dayIndex, ItineraryDay day) {
    // 確保當前天數索引正確
    _currentMapDayIndex = dayIndex;
    
    return Stack(
      children: [
        GoogleMap(
          key: const ValueKey('itinerary_map'), // 使用固定的 key 避免重建
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(
              day.spots[0].latitude,
              day.spots[0].longitude,
            ),
            zoom: 14.0,
          ),
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            print('Map created for day $dayIndex');
            
            // 只在第一次創建時設置 controller
            if (_mapController == null) {
              _mapController = controller;
              
              print('Map controller initialized');
              
              // 延遲更新，確保地圖完全準備好
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted && _mapController != null) {
                  print('Initial map setup for day $dayIndex');
                  _createMarkersForDay(dayIndex);
                  setState(() {}); // 觸發重建以顯示標記
                  
                  // 設置地圖準備好的狀態
                  _isMapReady = true;
                  
                  // 不自動調整視角，讓用戶手動觸發
                  print('Map ready, user can manually adjust view');
                }
              });
            } else {
              // 地圖已經存在，只更新標記
              print('Map already exists, updating markers for day $dayIndex');
              _createMarkersForDay(dayIndex);
              setState(() {}); // 觸發重建以顯示標記
            }
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          padding: const EdgeInsets.all(16),
        ),
        // 頂部資訊卡片
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '第${dayIndex + 1}天 • ${day.spots.length}個景點',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.center_focus_strong),
                    tooltip: '調整地圖視角',
                    onPressed: () {
                      print('Manual map focus requested for day $dayIndex');
                      _safelyFitMapToSpots(dayIndex);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      _showDayInfoDialog(dayIndex);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 構建日期頭部欄
  Widget _buildDayHeader(int dayIndex, ItineraryDay day) {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            localizations?.getDayTab(dayIndex + 1) ?? '第${dayIndex + 1}天',
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
            label: Text(localizations?.oneClickArrange ?? '一鍵安排'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // 暫時顯示未實現提示
              final localizations = AppLocalizations.of(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(localizations?.featureNotImplemented ?? '此功能尚未實現')));
            },
          ),
        ],
      ),
    );
  }

  // 構建空景點列表
  Widget _buildEmptySpotsList(int dayIndex) {
    final localizations = AppLocalizations.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            localizations?.noSpots ?? "尚無景點",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(localizations?.clickToAddFirstSpot ?? "點擊下方按鈕添加第一個景點", style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: Text(localizations?.addSpot ?? '添加景點'),
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
    final localizations = AppLocalizations.of(context);
    
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
                label: Text(localizations?.addSpot ?? '添加景點'),
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
          children: [            // 景點卡片
            SpotCard(
              spot: spot,
              onTap: () => _handleSpotTap(spot), // 添加點擊處理
              onNavigate: () {
                // 導航功能（暫未實現）
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(localizations?.navigationNotImplemented ?? '導航功能尚未實現')));
              },
              onEditStayTime: () => _showEditStayTimeDialog(spot), // 添加編輯停留時間功能
            ),// 如果不是最後一個景點，顯示交通段落
            if (index < day.spots.length - 1)
              TransportationSegment(
                transportType: spot.nextTransportation,
                duration: spot.travelTimeMinutes,
                onTap: () {
                  _showChangeTransportDialog(spot, day.spots[index + 1]);
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
  }  // 顯示更改交通方式對話框
  void _showChangeTransportDialog(Spot originSpot, Spot destinationSpot) {
    showDialog(
      context: context,
      builder: (context) => EnhancedChangeTransportDialog(
        originSpot: originSpot,
        destinationSpot: destinationSpot,
        initialTransportation: originSpot.nextTransportation,
        travelTimeMinutes: originSpot.travelTimeMinutes,
        onUpdate: (transportation, minutes) async {
          setState(() {
            originSpot.nextTransportation = transportation;
            originSpot.travelTimeMinutes = minutes;
          });
          
          // 重新計算後續景點的開始時間
          await _recalculateSubsequentTimes(originSpot, destinationSpot);
          
          await _saveItinerary();
          // 強制刷新UI以確保顯示更新
          if (mounted) {
            setState(() {});
          }
        },
      ),
    );
  }
  
  // 重新計算後續景點的開始時間
  Future<void> _recalculateSubsequentTimes(Spot originSpot, Spot destinationSpot) async {
    // 找到當前景點所在的天數和位置
    for (final day in _itinerary.itineraryDays) {
      final spotIndex = day.spots.indexWhere((spot) => spot.id == originSpot.id);
      if (spotIndex != -1 && spotIndex < day.spots.length - 1) {
        // 從修改的景點開始，重新計算後續所有景點的時間
        for (int i = spotIndex; i < day.spots.length - 1; i++) {
          final currentSpot = day.spots[i];
          final nextSpot = day.spots[i + 1];
          
          // 計算下一個景點的開始時間
          final currentStartTime = _parseTime(currentSpot.startTime);
          final stayDuration = Duration(
            hours: currentSpot.stayHours,
            minutes: currentSpot.stayMinutes,
          );
          final travelDuration = Duration(minutes: currentSpot.travelTimeMinutes);
          
          final nextStartTime = currentStartTime.add(stayDuration).add(travelDuration);
          final timeString = '${nextStartTime.hour.toString().padLeft(2, '0')}:${nextStartTime.minute.toString().padLeft(2, '0')}';
          
          // 更新下一個景點的開始時間
          day.spots[i + 1] = nextSpot.copyWith(startTime: timeString);
        }
        break;
      }
    }
  }
  
  // 解析時間字符串為 DateTime
  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  // 顯示編輯停留時間對話框
  void _showEditStayTimeDialog(Spot spot) {
    showDialog(
      context: context,
      builder: (context) => EditStayTimeDialog(
        spot: spot,
        onUpdate: (hours, minutes) async {
          setState(() {
            spot.stayHours = hours;
            spot.stayMinutes = minutes;
          });
          
          // 重新計算後續景點的開始時間
          await _recalculateAllSubsequentTimes(spot);
          
          await _saveItinerary();
          // 強制刷新UI以確保顯示更新
          if (mounted) {
            setState(() {});
          }
        },
      ),
    );
  }
  
  // 重新計算指定景點之後所有景點的開始時間
  Future<void> _recalculateAllSubsequentTimes(Spot changedSpot) async {
    // 找到修改的景點所在的天數和位置
    for (final day in _itinerary.itineraryDays) {
      final spotIndex = day.spots.indexWhere((spot) => spot.id == changedSpot.id);
      if (spotIndex != -1) {
        // 從修改的景點開始，重新計算後續所有景點的時間
        for (int i = spotIndex; i < day.spots.length - 1; i++) {
          final currentSpot = day.spots[i];
          final nextSpot = day.spots[i + 1];
          
          // 計算下一個景點的開始時間
          final currentStartTime = _parseTime(currentSpot.startTime);
          final stayDuration = Duration(
            hours: currentSpot.stayHours,
            minutes: currentSpot.stayMinutes,
          );
          final travelDuration = Duration(minutes: currentSpot.travelTimeMinutes);
          
          final nextStartTime = currentStartTime.add(stayDuration).add(travelDuration);
          final timeString = '${nextStartTime.hour.toString().padLeft(2, '0')}:${nextStartTime.minute.toString().padLeft(2, '0')}';
          
          // 更新下一個景點的開始時間
          day.spots[i + 1] = nextSpot.copyWith(startTime: timeString);
        }
        break;
      }
    }
  }

  // 顯示行程成員區塊
  Widget _buildMembersSection() {
    final localizations = AppLocalizations.of(context);
    
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
                Text(
                  localizations?.noMembersSet ?? '尚未設定行程成員',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _manageTravelMembers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(localizations?.setItineraryMembers ?? '設定行程成員'),
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
                  label: Text(localizations?.edit ?? '編輯'),
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
    final localizations = AppLocalizations.of(context);
    
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
                Text('${localizations?.ageGroup ?? '年齡層: '}${member.ageGroup}'),
              ],
            ),
            const SizedBox(height: 12),
            
            // 興趣
            if (member.interests.isNotEmpty) ...[
              Text(localizations?.interests ?? '興趣:', style: const TextStyle(fontWeight: FontWeight.bold)),
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
              Text(localizations?.specialNeeds ?? '特殊需求:', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                child: Text(localizations?.editMember ?? '編輯成員'),
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
  // 重新載入行程資料
  Future<void> _reloadItinerary() async {
    try {
      // 如果行程沒有ID，就不需要重新載入
      if (_itinerary.id == null || _itinerary.id!.isEmpty) {
        return;
      }
      
      // 從Firestore獲取最新的行程列表
      final itineraries = await _itineraryService.getAllItineraries();
      
      // 查找當前行程的最新資料
      final updatedItinerary = itineraries.firstWhere(
        (itinerary) => itinerary.id == _itinerary.id,
        orElse: () => _itinerary, // 如果找不到就使用原本的
      );
      
      if (mounted) {
        setState(() {
          _itinerary = updatedItinerary;
        });
      }
    } catch (e) {
      if (e.toString().contains('需要登入')) {
        // 登入狀態改變了，但不顯示對話框，只是靜默處理
        print('重新載入行程資料需要登入');
        return;
      }
      print('重新載入行程資料時出錯: $e');
    }
  }

  // 處理景點卡片點擊，跳轉到景點詳細頁面
  Future<void> _handleSpotTap(Spot spot) async {
    final localizations = AppLocalizations.of(context);
    
    try {      // 根據 placeId 獲取詳細的景點資訊
      final favoriteSpot = await FavoriteService.getFullSpotDetails(spot.id);
      
      if (favoriteSpot != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpotDetailPage(spot: favoriteSpot),
          ),
        );
      } else {
        // 如果無法獲取詳細資訊，顯示錯誤訊息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations?.cannotLoadSpotDetails ?? '無法載入景點詳細資訊')),
          );
        }
      }
    } catch (e) {
      print('載入景點詳細資訊時發生錯誤: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.errorLoadingSpotInfo ?? '載入景點資訊時發生錯誤')),
        );
      }
    }
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

  // 初始化編號標記
  Future<void> _initializeNumberMarkers() async {
    for (int i = 1; i <= 20; i++) {
      final markerIcon = await _createNumberedMarker(i);
      _numberMarkers[i] = markerIcon;
    }
  }

  // 創建帶編號的標記圖標
  Future<BitmapDescriptor> _createNumberedMarker(int number) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = 60.0;

    // 繪製圓形背景
    final Paint circlePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    const double radius = size / 2;
    const Offset center = Offset(radius, radius);
    
    canvas.drawCircle(center, radius - 2, circlePaint);
    canvas.drawCircle(center, radius - 2, borderPaint);

    // 繪製數字
    final textPainter = TextPainter(
      text: TextSpan(
        text: number.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );

    textPainter.layout();
    final double textX = (size - textPainter.width) / 2;
    final double textY = (size - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(textX, textY));

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }

  // 為特定天數創建地圖標記
  void _createMarkersForDay(int dayIndex) {
    if (dayIndex < 0 || dayIndex >= _itinerary.itineraryDays.length) {
      _markers.clear();
      return;
    }
    
    final day = _itinerary.itineraryDays[dayIndex];
    final newMarkers = <Marker>{};

    for (int i = 0; i < day.spots.length; i++) {
      final spot = day.spots[i];
      final markerIcon = _numberMarkers[i + 1] ?? BitmapDescriptor.defaultMarker;
      
      newMarkers.add(
        Marker(
          markerId: MarkerId('day_${dayIndex}_spot_${spot.id}'),
          position: LatLng(spot.latitude, spot.longitude),
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: spot.name,
            snippet: '第${i + 1}站 • ${spot.startTime}',
          ),
        ),
      );
    }
    
    _markers = newMarkers;
  }

  // 安全地調整地圖視角，避免 web 版本的錯誤
  void _safelyFitMapToSpots(int dayIndex) {
    print('Attempting to safely fit map to spots for day $dayIndex');
    
    // 多重延遲確保地圖完全穩定
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      // 再次檢查所有條件
      if (_mapController == null || !_isMapReady) {
        print('Map not ready for fitting, skipping');
        return;
      }
      
      if (dayIndex < 0 || dayIndex >= _itinerary.itineraryDays.length) {
        print('Invalid day index for fitting: $dayIndex');
        return;
      }
      
      final day = _itinerary.itineraryDays[dayIndex];
      if (day.spots.isEmpty) {
        print('No spots to fit for day $dayIndex');
        return;
      }
      
      // 嘗試調整視角，但捕獲所有可能的錯誤
      try {
        print('Attempting camera animation for ${day.spots.length} spots');
        
        if (day.spots.length == 1) {
          final spot = day.spots[0];
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(spot.latitude, spot.longitude),
              15.0,
            ),
          ).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('Camera animation timeout for single spot');
            },
          );
        } else {
          // 多個景點時，計算邊界
          double minLat = day.spots[0].latitude;
          double maxLat = day.spots[0].latitude;
          double minLng = day.spots[0].longitude;
          double maxLng = day.spots[0].longitude;

          for (final spot in day.spots) {
            minLat = math.min(minLat, spot.latitude);
            maxLat = math.max(maxLat, spot.latitude);
            minLng = math.min(minLng, spot.longitude);
            maxLng = math.max(maxLng, spot.longitude);
          }

          const double padding = 0.01;
          minLat -= padding;
          maxLat += padding;
          minLng -= padding;
          maxLng += padding;

          _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(minLat, minLng),
                northeast: LatLng(maxLat, maxLng),
              ),
              100.0,
            ),
          ).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('Camera animation timeout for multiple spots');
            },
          );
        }
        
        print('Camera animation completed successfully');
      } catch (e, stackTrace) {
        print('Error during camera animation: $e');
        print('Stack trace: $stackTrace');
        
        // 發生錯誤時重置地圖狀態，允許重試
        _isMapReady = false;
        
        // 延遲重新啟用
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _mapController != null) {
            _isMapReady = true;
            print('Map ready state restored after error');
          }
        });
      }
    });
  }

  // 顯示天數資訊對話框
  void _showDayInfoDialog(int dayIndex) {
    final localizations = AppLocalizations.of(context);
    final day = _itinerary.itineraryDays[dayIndex];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations?.getDayInfo(dayIndex + 1) ?? '第${dayIndex + 1}天資訊'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${localizations?.spotCount ?? '景點數量: '}${day.spots.length}'),
            const SizedBox(height: 8),
            Text('${localizations?.transportationMethod ?? '交通方式: '}${day.transportation}'),
            if (day.spots.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(localizations?.spotList ?? '景點列表:'),
              ...day.spots.asMap().entries.map((entry) {
                final index = entry.key;
                final spot = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text('${index + 1}. ${spot.name}'),
                );
              }),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations?.close ?? '關閉'),
          ),
        ],
      ),
    );
  }
}
