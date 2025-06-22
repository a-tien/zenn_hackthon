import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/itinerary.dart';
import '../models/itinerary_day.dart';
import '../models/destination.dart';
import '../services/itinerary_service.dart';
import '../../common/widgets/login_required_dialog.dart';
import 'select_destinations_page.dart';

class AddItineraryPage extends StatefulWidget {
  const AddItineraryPage({super.key});

  @override
  State<AddItineraryPage> createState() => _AddItineraryPageState();
}

class _AddItineraryPageState extends State<AddItineraryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final ItineraryService _itineraryService = ItineraryService();
  
  List<Destination> _selectedDestinations = [];
  
  bool _useDateRange = false;
  int _days = 1;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  String _transportation = '自行安排';
  String _travelType = '家庭旅遊';

  final List<String> _transportationOptions = ['自行安排', '開車', '大眾運輸', '步行', '機車'];
  final List<String> _travelTypeOptions = ['家庭旅遊', '好友出遊', '情侶出遊', '長輩出遊', '無障礙出遊', '個人獨旅'];
  
  // 新增日期範圍選擇狀態
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _dateRange = DateTimeRange(
      start: _startDate,
      end: _endDate,
    );
  }
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }  Future<void> _saveItinerary() async {
    if (_formKey.currentState!.validate()) {
      // 檢查是否至少選擇了一個目的地
      if (_selectedDestinations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('請至少選擇一個目的地')),
        );
        return;
      }
      
      try {
        // 先創建行程實例
        final itinerary = Itinerary(
          name: _nameController.text,
          useDateRange: _useDateRange,
          days: _useDateRange ? _calculateDays() : _days,
          startDate: _useDateRange ? _dateRange!.start : _startDate,
          endDate: _useDateRange ? _dateRange!.end : _endDate,
          destinations: _selectedDestinations,
          transportation: _transportation,
          travelType: _travelType,
          // 初始化空的行程天數列表
          itineraryDays: [],
        );
        
        // 為每天創建 ItineraryDay 實例
        for (int i = 0; i < itinerary.days; i++) {
          itinerary.itineraryDays.add(
            ItineraryDay(
              dayNumber: i + 1,
              transportation: _transportation,
              spots: [], // 移除預設景點，現在全部通過加入行程功能添加
            ),
          );
        }

        // 使用 Firebase 保存行程
        await _itineraryService.saveItinerary(itinerary);
        
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (e.toString().contains('需要登入')) {
          // 顯示登入提示對話框
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => const LoginRequiredDialog(feature: '建立行程'),
            );
          }
          return;
        }
        
        print('建立行程時出錯: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('建立失敗: $e')),
          );
        }
      }
    }
  }

  int _calculateDays() {
    if (_useDateRange && _dateRange != null) {
      return _dateRange!.duration.inDays + 1;
    }
    return _endDate.difference(_startDate).inDays + 1;
  }

  // 顯示日期範圍選擇器
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime.now(),
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
        _endDate = picked.end;      });
    }
  }

  // 構建目的地選擇區塊
  Widget _buildDestinationSection() {
    if (_selectedDestinations.isEmpty) {
      // 顯示新增目的地按鈕
      return GestureDetector(
        onTap: _openDestinationSelector,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade400,
              style: BorderStyle.solid,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '新增目的地+',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 顯示已選目的地標籤
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // 已選目的地標籤
        ..._selectedDestinations.map((destination) => _buildDestinationChip(destination)),
        // 新增按鈕
        _buildAddDestinationChip(),
      ],
    );
  }

  // 構建目的地標籤
  Widget _buildDestinationChip(Destination destination) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            destination.name,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeDestination(destination),
            child: const Icon(
              Icons.close,
              size: 16,
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  // 構建新增目的地標籤
  Widget _buildAddDestinationChip() {
    return GestureDetector(
      onTap: _openDestinationSelector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              '新增+',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 開啟目的地選擇頁面
  Future<void> _openDestinationSelector() async {
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
      _selectedDestinations.remove(destination);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新增行程'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              // 表單內容
              ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 100), // 底部留空給按鈕
                children: [
                  // 1. 行程名稱 - 標題與內容分離
                  const Text(
                    '行程名稱',
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: '請輸入此次行程的名稱',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入行程名稱';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // 2. 行程日程 - 標題與內容分離
                  const Text(
                    '行程日程',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // 日程選擇按鈕
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                  
                  // 天數或日期選擇器 - 優化版本
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
                    // 日期範圍選擇 - 單一控制項
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
                                _dateRange != null
                                    ? '${DateFormat('yyyy/MM/dd').format(_dateRange!.start)} - ${DateFormat('yyyy/MM/dd').format(_dateRange!.end)} (${_calculateDays()}天)'
                                    : '選擇日期範圍',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                    // 3. 目的地 - 標題與內容分離
                  const Text(
                    '目的地',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDestinationSection(),
                  const SizedBox(height: 24),
                  
                  // 4. 主要交通方式 - 標題與內容分離
                  const Text(
                    '主要交通方式',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _transportation,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      ),
                      items: _transportationOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _transportation = newValue!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '請選擇主要交通方式';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 5. 旅遊型態 - 標題與內容分離
                  const Text(
                    '旅遊型態',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _travelType,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      ),
                      items: _travelTypeOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _travelType = newValue!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '請選擇旅遊型態';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              // 固定在底部的按鈕
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _saveItinerary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '建立行程',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}