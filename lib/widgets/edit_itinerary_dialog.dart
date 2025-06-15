import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/itinerary.dart';

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
  late DateTime _endDate;
  late DateTimeRange _dateRange;
  bool _isProcessing = false;

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
    destination: widget.itinerary.destination,
    transportation: widget.itinerary.transportation,
    travelType: widget.itinerary.travelType,
    // 不要包含 itineraryDays，讓主頁面處理這部分
  );
  
  // 返回更新後的行程對象，而不是直接調用回調
  Navigator.of(context).pop(updatedItinerary);
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
                ),
              ),
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