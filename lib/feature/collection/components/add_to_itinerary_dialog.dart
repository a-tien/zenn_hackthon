import 'package:flutter/material.dart';
import '../../itinerary/models/itinerary.dart';
import '../../itinerary/pages/add_itinerary_page.dart';
import '../../itinerary/services/itinerary_service.dart';
import '../models/favorite_spot.dart';
import '../../../utils/app_localizations.dart';

class AddToItineraryDialog extends StatefulWidget {
  final FavoriteSpot spot;
  final Itinerary? targetItinerary;

  const AddToItineraryDialog({
    super.key,
    required this.spot,
    this.targetItinerary,
  });

  @override
  State<AddToItineraryDialog> createState() => _AddToItineraryDialogState();
}

class _AddToItineraryDialogState extends State<AddToItineraryDialog> {
  List<Itinerary> itineraries = [];
  Map<int, int> selectedDays = {}; // 每個行程選擇的天數
  bool isLoading = true;
  int? expandedIndex; // 當前展開的行程索引
  final ItineraryService _itineraryService = ItineraryService();

  @override
  void initState() {
    super.initState();
    _loadItineraries();
  }
  // 加載行程
  Future<void> _loadItineraries() async {
    try {
      final loadedItineraries = await _itineraryService.getAllItineraries();
      
      // 初始化選擇的天數（默認為每個行程的最後一天）
      Map<int, int> initSelectedDays = {};
      int? targetItineraryIndex;
      
      for (int i = 0; i < loadedItineraries.length; i++) {
        // 設置默認選擇的天數
        final recommendedDay = _getRecommendedDay(loadedItineraries[i]);
        initSelectedDays[i] = recommendedDay;
        
        // 如果有目標行程，找到它的索引
        if (widget.targetItinerary != null && 
            loadedItineraries[i].id == widget.targetItinerary!.id) {
          targetItineraryIndex = i;
        }
      }
      
      setState(() {
        itineraries = loadedItineraries;
        selectedDays = initSelectedDays;
        isLoading = false;
        // 如果有目標行程，自動展開它
        if (targetItineraryIndex != null) {
          expandedIndex = targetItineraryIndex;
        }
      });
    } catch (e) {
      print('加載行程失敗: $e');
      setState(() {
        itineraries = [];
        isLoading = false;
      });
    }
  }

  // 獲取推薦的天數（這裡簡單地返回行程的最後一天）
  int _getRecommendedDay(Itinerary itinerary) {
    return itinerary.days - 1; // 索引從0開始
  }

  // 切換行程的展開/折疊狀態
  void _toggleItinerary(int index) {
    setState(() {
      if (expandedIndex == index) {
        expandedIndex = null; // 折疊當前展開的行程
      } else {
        expandedIndex = index; // 展開新行程
      }
    });
  }

  // 選擇天數
  void _selectDay(int itineraryIndex, int dayIndex) {
    setState(() {
      selectedDays[itineraryIndex] = dayIndex;
    });
  }
  // 添加景點到選定的行程和天數
  Future<void> _addToItinerary(int itineraryIndex) async {
    try {
      final dayIndex = selectedDays[itineraryIndex] ?? 0;
      final itinerary = itineraries[itineraryIndex];
      
      // 顯示加載狀態
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );      // 檢查行程 ID 是否存在
      if (itinerary.id == null || itinerary.id!.isEmpty) {
        // 關閉加載對話框
        if (mounted) Navigator.pop(context);
        
        if (mounted) {
          final localizations = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations?.itineraryIdNotExistError ?? '行程 ID 不存在，無法加入景點')),
          );
        }
        return;
      }
      
      // 使用 ItineraryService 添加景點並計算路線
      final updatedItinerary = await _itineraryService.addSpotToItineraryWithRoutes(
        itinerary.id!, // 使用行程 ID 而不是名稱
        dayIndex + 1, // dayIndex 是從0開始，但 addSpotToItineraryWithRoutes 期望從1開始
        widget.spot,
        calculateRoutes: true, // 啟用路線計算
      );
      
      // 關閉加載對話框
      if (mounted) Navigator.pop(context);
      
      // 關閉加入行程對話框，並返回添加結果
      if (mounted) Navigator.pop(context, updatedItinerary != null);
      
      // 顯示結果
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        if (updatedItinerary != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations?.addedToItinerarySuccessMessage(widget.spot.name, itinerary.name, dayIndex + 1) ?? 
                '已成功將 ${widget.spot.name} 加入到 ${itinerary.name} 的第 ${dayIndex + 1} 天',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations?.addToItineraryFailedMessage ?? '加入行程失敗，景點可能已存在或發生其他錯誤',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // 關閉可能存在的加載對話框
      if (mounted) Navigator.pop(context);
      
      print('添加景點到行程時發生錯誤: $e');
      
      // 關閉加入行程對話框，並返回失敗結果
      if (mounted) Navigator.pop(context, false);
      
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations?.addToItineraryErrorMessage(e.toString()) ?? '加入行程時發生錯誤: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 導航到創建新行程頁面
  void _navigateToAddItinerary() async {
    Navigator.pop(context); // 先關閉當前對話框
    
    // 導航到新增行程頁面
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddItineraryPage()),
    );
    
    // 返回後顯示提示
    if (mounted) {
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations?.createNewItineraryFirstMessage ?? '請在新行程創建完成後再次點擊加入行程')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 標題
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Text(
                    '加入行程',
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
            
            // 內容
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : itineraries.isEmpty
                      ? _buildEmptyState()
                      : _buildItinerariesList(),
            ),
            
            // 底部按鈕
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToAddItinerary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('建立新行程'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 構建空狀態
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, size: 50, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            '尚無行程',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '請點擊下方按鈕建立新行程',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // 構建行程列表
  Widget _buildItinerariesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itineraries.length,
      itemBuilder: (context, index) {
        final itinerary = itineraries[index];
        final isExpanded = expandedIndex == index;
        final selectedDay = selectedDays[index] ?? 0;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // 行程標題行
              InkWell(
                onTap: () => _toggleItinerary(index),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // 行程圖標
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.map,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 行程信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itinerary.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              itinerary.useDateRange
                                  ? '${_formatDate(itinerary.startDate)}-${_formatDate(itinerary.endDate)} (${itinerary.days}天)'
                                  : '${itinerary.days}天',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 展開/折疊圖標
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
              
              // 展開後的日期選擇
              if (isExpanded)
                Column(
                  children: [
                    const Divider(height: 1),
                    ...List.generate(
                      itinerary.days,
                      (dayIndex) {
                        final isRecommended = 
                            dayIndex == _getRecommendedDay(itinerary);
                        return _buildDayOption(
                          index,
                          dayIndex,
                          itinerary,
                          selectedDay == dayIndex,
                          isRecommended,
                        );
                      },
                    ),
                    const Divider(height: 1),
                    // 確認按鈕
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _addToItinerary(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('加入此行程'),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  // 構建日期選項
  Widget _buildDayOption(
    int itineraryIndex,
    int dayIndex,
    Itinerary itinerary,
    bool isSelected,
    bool isRecommended,
  ) {
    // 防禦性編程: 確保 itineraryDays 列表有足夠元素
    // 如果 itineraryDays 不存在或索引超出範圍，創建一個默認的空數據
    int spotCount = 0;
    if (itinerary.itineraryDays.length > dayIndex) {
      spotCount = itinerary.itineraryDays[dayIndex].spots.length;
    }
    
    return InkWell(
      onTap: () => _selectDay(itineraryIndex, dayIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            // 日期圖標
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blueAccent
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${dayIndex + 1}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 日期信息
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
                  const SizedBox(height: 2),
                  Text(
                    '$spotCount 個景點',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // 選中狀態和推薦標籤
            if (isRecommended && !isSelected)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '最佳安排',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.blueAccent,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
  
  // 格式化日期
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}