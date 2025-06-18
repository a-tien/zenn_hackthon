import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/itinerary.dart';
import '../models/itinerary_day.dart';
import '../models/spot.dart'; // 導入 Spot 類

class AddItineraryPage extends StatefulWidget {
  const AddItineraryPage({super.key});

  @override
  State<AddItineraryPage> createState() => _AddItineraryPageState();
}

class _AddItineraryPageState extends State<AddItineraryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();
  
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
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _saveItinerary() async {
    if (_formKey.currentState!.validate()) {
      // 先創建行程實例
      final itinerary = Itinerary(
        name: _nameController.text,
        useDateRange: _useDateRange,
        days: _useDateRange ? _calculateDays() : _days,
        startDate: _useDateRange ? _dateRange!.start : _startDate,
        endDate: _useDateRange ? _dateRange!.end : _endDate,
        destination: _destinationController.text,
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
            spots: i == 0 ? _getDefaultSpots() : [], // 為第一天添加預設景點
          ),
        );
      }

      final prefs = await SharedPreferences.getInstance();
      final itinerariesJson = prefs.getStringList('itineraries') ?? [];
      
      itinerariesJson.add(jsonEncode(itinerary.toJson()));
      await prefs.setStringList('itineraries', itinerariesJson);
      
      if (mounted) {
        Navigator.pop(context, true);
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
        _endDate = picked.end;
      });
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
                  TextFormField(
                    controller: _destinationController,
                    decoration: const InputDecoration(
                      hintText: '請輸入行程的目的地',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入目的地';
                      }
                      return null;
                    },
                  ),
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