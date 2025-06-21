import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/itinerary.dart';
import '../models/destination.dart';
import '../pages/select_destinations_page.dart';

class EditItineraryDialog extends StatefulWidget {
  final Itinerary itinerary;
  final Function(Itinerary) onUpdate;

  const EditItineraryDialog({
    super.key,
    required this.itinerary,
    required this.onUpdate,
  });

  @override
  State<EditItineraryDialog> createState() => _EditItineraryDialogState();
}

class _EditItineraryDialogState extends State<EditItineraryDialog> {
  late TextEditingController _nameController;
  late bool _useDateRange;
  late int _days;
  late DateTime _startDate;
  late DateTime _endDate;  late DateTimeRange _dateRange;
  late List<Destination> _selectedDestinations;
  @override
  void initState() {
    super.initState();
    // 創建深拷貝而非直接引用
    _nameController = TextEditingController(text: widget.itinerary.name);
    _useDateRange = widget.itinerary.useDateRange;
    _days = widget.itinerary.days;
    _startDate = DateTime(
      widget.itinerary.startDate.year, 
      widget.itinerary.startDate.month, 
      widget.itinerary.startDate.day
    );
    _endDate = DateTime(
      widget.itinerary.endDate.year, 
      widget.itinerary.endDate.month, 
      widget.itinerary.endDate.day
    );
    _dateRange = DateTimeRange(start: _startDate, end: _endDate);
    _selectedDestinations = List.from(widget.itinerary.destinations);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 計算天數
  int _calculateDays() {
    if (_useDateRange) {
      return _dateRange.duration.inDays + 1;
    }
    return _days;
  }

  // 顯示日期範圍選擇器
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }
  void _handleUpdate() {
  if (_nameController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('行程名稱不能為空')),
    );
    return;
  }
  
  // 創建更新後的行程對象 (深拷貝避免直接修改原始對象)
  final updatedItinerary = Itinerary(
    name: _nameController.text,
    useDateRange: _useDateRange,
    days: _useDateRange ? _calculateDays() : _days,
    startDate: _startDate,
    endDate: _endDate,
    destinations: _selectedDestinations,
    transportation: widget.itinerary.transportation,
    travelType: widget.itinerary.travelType,
    // 不要包含 itineraryDays，讓主頁面處理這部分
  );
    // 返回更新後的行程對象，而不是直接調用回調
  Navigator.of(context).pop(updatedItinerary);
}

  // 構建目的地選擇區域
  Widget _buildDestinationsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '已選目的地',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _selectDestinations,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('新增'),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_selectedDestinations.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                '尚未選擇目的地',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _selectedDestinations.map((destination) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        destination.name,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _removeDestination(destination),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // 選擇目的地
  Future<void> _selectDestinations() async {
    final result = await Navigator.push<List<Destination>>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectDestinationsPage(
          initialSelectedDestinations: _selectedDestinations,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedDestinations = result;
      });
    }
  }

  // 移除目的地
  void _removeDestination(Destination destination) {
    setState(() {
      _selectedDestinations.removeWhere((d) => d.id == destination.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('編輯行程'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 行程名稱
            const Text(
              '行程名稱',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            
            // 行程日程
            const Text(
              '行程日程',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            
            // 日程選擇按鈕
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _useDateRange = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_useDateRange ? Colors.blueAccent : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '天數',
                          style: TextStyle(
                            color: !_useDateRange ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _useDateRange = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _useDateRange ? Colors.blueAccent : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '日期',
                          style: TextStyle(
                            color: _useDateRange ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // 天數或日期選擇器
            if (!_useDateRange)
              // 天數選擇
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_days 天',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_days > 1) {
                        setState(() => _days--);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() => _days++);
                    },
                  ),
                ],
              )
            else
              // 日期範圍選擇
              InkWell(
                onTap: _selectDateRange,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${DateFormat('yyyy/MM/dd').format(_dateRange.start)} - ${DateFormat('yyyy/MM/dd').format(_dateRange.end)} (${_calculateDays()}天)',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),            ),
            const SizedBox(height: 16),
            
            // 目的地管理
            const Text(
              '目的地',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildDestinationsSection(),
          ],
        ),
      ),
      actions: [
      TextButton(
        onPressed: () => Navigator.pop(context), // 直接關閉對話框，不返回數據
        child: const Text('取消'),
      ),
      ElevatedButton(
        onPressed: _handleUpdate, // 處理更新
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        child: const Text('更新'),
      ),
    ],
    );
  }
}