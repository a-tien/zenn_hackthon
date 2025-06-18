import 'package:flutter/material.dart';
import '../models/itinerary.dart';
import '../models/recommended_spot.dart';
import '../models/spot.dart';
import '../models/itinerary_day.dart';

class AddToDayDialog extends StatefulWidget {
  final Itinerary itinerary;
  final RecommendedSpot spot;

  const AddToDayDialog({
    super.key,
    required this.itinerary,
    required this.spot,
  });

  @override
  State<AddToDayDialog> createState() => _AddToDayDialogState();
}

class _AddToDayDialogState extends State<AddToDayDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.itinerary.days, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedDayIndex = _tabController.index;
      });
    }
  }

  // 添加景點到行程
  void _addSpotToItinerary(int dayIndex, int position) async {
    // 獲取當前選定的行程日
    final day = widget.itinerary.itineraryDays[dayIndex];

    // 創建新的景點對象
    final newSpot = Spot(
      id: widget.spot.id,
      name: widget.spot.name,
      imageUrl: widget.spot.imageUrl,
      order: position + 1, // 順序從1開始
      stayHours: 1, // 默認停留時間1小時
      stayMinutes: 0,
      startTime: _calculateStartTime(day, position),
      latitude: widget.spot.latitude,
      longitude: widget.spot.longitude,
      nextTransportation: '步行', // 默認交通方式
      travelTimeMinutes: 15, // 默認交通時間
    );

    // 更新行程日的景點列表
    List<Spot> updatedSpots = List.from(day.spots);

    // 根據位置插入新景點
    if (position >= updatedSpots.length) {
      // 添加到末尾
      updatedSpots.add(newSpot);
    } else {
      // 插入到指定位置
      updatedSpots.insert(position, newSpot);

      // 更新後續景點的順序
      for (int i = position + 1; i < updatedSpots.length; i++) {
        updatedSpots[i] = updatedSpots[i].copyWith(order: i + 1);
      }
    }

    // 更新行程日
    widget.itinerary.itineraryDays[dayIndex] = ItineraryDay(
      dayNumber: day.dayNumber,
      transportation: day.transportation,
      spots: updatedSpots,
    );

    // 保存行程（這裡模擬，實際應用中需要調用保存方法）
    await Future.delayed(const Duration(milliseconds: 300));

    // 關閉對話框並返回成功結果
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  // 計算新景點的開始時間
  String _calculateStartTime(ItineraryDay day, int position) {
    if (day.spots.isEmpty) {
      return '09:00'; // 如果是第一個景點，默認9點開始
    }

    if (position >= day.spots.length) {
      // 如果添加到最後，取最後一個景點的結束時間
      final lastSpot = day.spots.last;
      return _addTime(
        lastSpot.startTime,
        lastSpot.stayHours,
        lastSpot.stayMinutes,
        lastSpot.travelTimeMinutes,
      );
    } else if (position == 0) {
      // 如果添加到最前面，默認9點開始
      return '09:00';
    } else {
      // 如果添加到中間，取前一個景點的結束時間
      final prevSpot = day.spots[position - 1];
      return _addTime(
        prevSpot.startTime,
        prevSpot.stayHours,
        prevSpot.stayMinutes,
        prevSpot.travelTimeMinutes,
      );
    }
  }

  // 簡單的時間計算函數
  String _addTime(String startTime, int hours, int minutes, int travelMinutes) {
    final parts = startTime.split(':');
    int totalMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    totalMinutes += hours * 60 + minutes + travelMinutes;

    final newHours = (totalMinutes ~/ 60) % 24;
    final newMinutes = totalMinutes % 60;

    return '${newHours.toString().padLeft(2, '0')}:${newMinutes.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // 調整對話框尺寸
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: double.maxFinite,
        // 設定固定高度而非最大高度
        height: MediaQuery.of(context).size.height * 0.6, // 固定高度為螢幕高度的60%
        constraints: const BoxConstraints(
          maxWidth: 450, // 最大寬度
        ),
        child: Column(
          children: [
            // 標題
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const Text(
                    '選擇添加到哪一天',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 日期頁籤
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                tabs: [
                  for (int i = 0; i < widget.itinerary.days; i++)
                    Tab(text: '第${i + 1}天'),
                ],
              ),
            ),

            // 內容區域 - 使用 Expanded 讓它填充剩餘空間
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  for (
                    int dayIndex = 0;
                    dayIndex < widget.itinerary.days;
                    dayIndex++
                  )
                    _buildDayOptionsView(dayIndex),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 構建日期選項視圖
  Widget _buildDayOptionsView(int dayIndex) {
    final day = widget.itinerary.itineraryDays[dayIndex];
    final spots = day.spots;

    // 創建位置選項卡片列表
    List<Widget> positionCards = _createPositionCards(dayIndex, spots);

    // 使用單獨的有狀態小部件來處理頁面和指示器
    return _PositionCardsPageView(
      cards: positionCards,
      onSpotAdd: (position) => _addSpotToItinerary(dayIndex, position),
    );
  }

  // 創建位置卡片列表的輔助方法
  List<Widget> _createPositionCards(int dayIndex, List<Spot> spots) {
    List<Widget> cards = [];
    
    // 如果沒有景點，只顯示"添加為第一個景點"
    if (spots.isEmpty) {
      cards.add(
        _buildPositionCard(
          dayIndex: dayIndex,
          position: 0,
          label: '添加為第一個景點',
          isFirst: true,
          isLast: true,
          isOptimal: true, // 空行程時，第一個位置就是最佳位置
        ),
      );
    } else {
      // 添加到第一個位置
      cards.add(
        _buildPositionCard(
          dayIndex: dayIndex,
          position: 0,
          label: '排在第一個',
          isFirst: true,
          isLast: false,
          prevSpotName: '',
          nextSpotName: spots[0].name,
        ),
      );

      // 添加到中間位置
      for (int i = 0; i < spots.length - 1; i++) {
        cards.add(
          _buildPositionCard(
            dayIndex: dayIndex,
            position: i + 1,
            label: '',
            isFirst: false,
            isLast: false,
            prevSpotName: spots[i].name,
            nextSpotName: spots[i + 1].name,
            prevOrder: i + 1,
            nextOrder: i + 2,
          ),
        );
      }

      // 添加到最後一個位置
      cards.add(
        _buildPositionCard(
          dayIndex: dayIndex,
          position: spots.length,
          label: '排在最後',
          isFirst: false,
          isLast: true,
          prevSpotName: spots.last.name,
          nextSpotName: '',
          prevOrder: spots.length,
          isOptimal: true, // 這裡假設最後一個是最佳選項
        ),
      );
    }
    
    return cards;
  }

  // 修改 _buildPositionCard 方法的參數和確定按鈕
  Widget _buildPositionCard({
    required int dayIndex,
    required int position,
    required String label,
    required bool isFirst,
    required bool isLast,
    String prevSpotName = '',
    String nextSpotName = '',
    int? prevOrder,
    int? nextOrder,
    bool isOptimal = false,
  }) {
    // 獲取當前日期的景點列表
    final spots = widget.itinerary.itineraryDays[dayIndex].spots;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOptimal
            ? const BorderSide(color: Colors.amber, width: 2)
            : BorderSide.none,
      ),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            height: 320, // 固定高度
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 如果有標籤，顯示標籤
                if (label.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // 顯示插入位置示意圖 - 垂直排列
                if (!isFirst && !isLast)
                  _buildVerticalOrderingDisplay(
                    prevSpotName: prevSpotName,
                    nextSpotName: nextSpotName,
                    prevOrder: prevOrder,
                    nextOrder: nextOrder,
                  )
                else if (isFirst && spots.isNotEmpty)
                  _buildFirstPositionDisplay(nextSpotName)
                else if (isLast && !isFirst)
                  _buildLastPositionDisplay(prevSpotName, prevOrder)
                else
                  _buildEmptyItineraryDisplay(),

                const Spacer(), // 這會把按鈕推到底部

                // 確定按鈕
                ElevatedButton(
                  onPressed: () => _addSpotToItinerary(dayIndex, position),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '確定',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 最佳排序標籤
          if (isOptimal)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  '全程最佳排序',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 中間位置的垂直排列顯示 - 改進版
  Widget _buildVerticalOrderingDisplay({
    required String prevSpotName,
    required String nextSpotName,
    int? prevOrder,
    int? nextOrder,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 前一個景點
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 數字圓圈
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$prevOrder',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 景點名稱
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '前一個景點',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    prevSpotName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        // 連接線 - 使用虛線
        Container(
          margin: const EdgeInsets.only(left: 18),
          height: 24,
          child: VerticalDivider(
            color: Colors.grey[400],
            thickness: 1,
            width: 20,
          ),
        ),

        // 新景點
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 加號圓圈
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            // 景點名稱
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '新增景點',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.spot.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        // 連接線 - 使用虛線
        Container(
          margin: const EdgeInsets.only(left: 18),
          height: 24,
          child: VerticalDivider(
            color: Colors.grey[400],
            thickness: 1,
            width: 20,
          ),
        ),

        // 下一個景點
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 數字圓圈
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$nextOrder',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 景點名稱
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '下一個景點',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    nextSpotName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 第一個位置的垂直排列顯示 - 改進版
  Widget _buildFirstPositionDisplay(String nextSpotName) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 新景點
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 加號圓圈
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            // 景點名稱
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '新增景點',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.spot.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        // 連接線 - 使用虛線
        Container(
          margin: const EdgeInsets.only(left: 18),
          height: 24,
          child: VerticalDivider(
            color: Colors.grey[400],
            thickness: 1,
            width: 20,
          ),
        ),

        // 第一個景點
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 數字圓圈
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 景點名稱
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '第一個景點',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    nextSpotName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 最後一個位置的垂直排列顯示 - 改進版
  Widget _buildLastPositionDisplay(String prevSpotName, int? prevOrder) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 前一個景點
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 數字圓圈
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$prevOrder',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 景點名稱
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '最後一個景點',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    prevSpotName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        // 連接線 - 使用虛線
        Container(
          margin: const EdgeInsets.only(left: 18),
          height: 24,
          child: VerticalDivider(
            color: Colors.grey[400],
            thickness: 1,
            width: 20,
          ),
        ),

        // 新景點
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 加號圓圈
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            // 景點名稱
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '新增景點',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.spot.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 空行程的顯示 - 改進版
  Widget _buildEmptyItineraryDisplay() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 加號圓圈
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.amber,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        // 景點名稱
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '第一個景點',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.amber,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                widget.spot.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 將 _PositionCardsPageView 類移到外部
class _PositionCardsPageView extends StatefulWidget {
  final List<Widget> cards;
  final Function(int) onSpotAdd;

  const _PositionCardsPageView({
    required this.cards,
    required this.onSpotAdd,
  });

  @override
  State<_PositionCardsPageView> createState() => _PositionCardsPageViewState();
}

class _PositionCardsPageViewState extends State<_PositionCardsPageView> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    if (!_pageController.hasClients) return;
    
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 頁面視圖
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.cards.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: widget.cards[index],
                );
              },
            ),
          ),
          
          // 指示器點點
          if (widget.cards.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.cards.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentPage
                          ? Colors.blueAccent
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
