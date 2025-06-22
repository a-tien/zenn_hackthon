import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/spot.dart';
import '../services/google_routes_service.dart';

class EnhancedChangeTransportDialog extends StatefulWidget {
  final Spot originSpot;
  final Spot destinationSpot;
  final String initialTransportation;
  final int travelTimeMinutes;
  final Function(String, int) onUpdate;

  const EnhancedChangeTransportDialog({
    super.key,
    required this.originSpot,
    required this.destinationSpot,
    required this.initialTransportation,
    required this.travelTimeMinutes,
    required this.onUpdate,
  });

  @override
  State<EnhancedChangeTransportDialog> createState() => _EnhancedChangeTransportDialogState();
}

class _EnhancedChangeTransportDialogState extends State<EnhancedChangeTransportDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _selectedTransportation;
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  bool _isCalculating = false;
  bool _useManualTime = false;
  Map<String, int> _calculatedTimes = {}; // 存儲API計算的時間
  
  final GoogleRoutesService _routesService = GoogleRoutesService();
  
  final List<Map<String, dynamic>> _transportOptions = [
    {'name': '駕車', 'apiName': 'DRIVE', 'icon': Icons.directions_car, 'color': Colors.blue},
    {'name': '自行車', 'apiName': 'BICYCLE', 'icon': Icons.directions_bike, 'color': Colors.green},
    {'name': '大眾運輸', 'apiName': 'TRANSIT', 'icon': Icons.directions_subway, 'color': Colors.orange},
    {'name': '步行', 'apiName': 'WALK', 'icon': Icons.directions_walk, 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _transportOptions.length, vsync: this);
    
    // 尋找初始交通方式的索引
    int initialIndex = 0;
    for (int i = 0; i < _transportOptions.length; i++) {
      if (_transportOptions[i]['name'] == widget.initialTransportation) {
        initialIndex = i;
        break;
      }
    }
    _tabController.index = initialIndex;
    _selectedTransportation = _transportOptions[initialIndex]['name'];
    
    // 設置時間控制器
    final hours = widget.travelTimeMinutes ~/ 60;
    final minutes = widget.travelTimeMinutes % 60;
    _hoursController = TextEditingController(text: hours.toString());
    _minutesController = TextEditingController(text: minutes.toString());    // 監聽交通方式變化 (保留用於向後兼容)
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final newTransportation = _transportOptions[_tabController.index]['name'];
        if (_selectedTransportation != newTransportation) {
          setState(() {
            _selectedTransportation = newTransportation;
          });
          _updateTimeForSelectedTransport();
        }
      }
    });

    // 自動計算所有交通方式的時間
    _calculateAllTransportTimes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  // 計算所有交通方式的時間
  Future<void> _calculateAllTransportTimes() async {
    setState(() {
      _isCalculating = true;
    });

    for (final transport in _transportOptions) {
      try {
        final routeInfo = await _routesService.computeRoute(
          origin: widget.originSpot,
          destination: widget.destinationSpot,
          travelMode: transport['apiName'],
        );

        if (routeInfo != null) {
          _calculatedTimes[transport['name']] = routeInfo.duration;
        } else {
          // API失敗時使用預設計算
          final distance = _calculateDistance(
            widget.originSpot.latitude, widget.originSpot.longitude,
            widget.destinationSpot.latitude, widget.destinationSpot.longitude,
          );
          _calculatedTimes[transport['name']] = GoogleRoutesService.getDefaultTravelTime(
            transport['apiName'], distance
          );
        }
      } catch (e) {
        print('計算 ${transport['name']} 路線時發生錯誤: $e');
        // 使用預設時間
        final distance = _calculateDistance(
          widget.originSpot.latitude, widget.originSpot.longitude,
          widget.destinationSpot.latitude, widget.destinationSpot.longitude,
        );
        _calculatedTimes[transport['name']] = GoogleRoutesService.getDefaultTravelTime(
          transport['apiName'], distance
        );
      }
    }

    setState(() {
      _isCalculating = false;
    });

    // 更新當前選擇的交通方式時間
    _updateTimeForSelectedTransport();
  }

  // 計算兩點間距離（公里）
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371;
    final double dLat = (lat2 - lat1) * (3.14159265359 / 180.0);
    final double dLon = (lon2 - lon1) * (3.14159265359 / 180.0);
    
    final double a = 
        (dLat / 2) * (dLat / 2) +
        (lat1 * 3.14159265359 / 180.0) * (lat2 * 3.14159265359 / 180.0) *
        (dLon / 2) * (dLon / 2);
    
    final double c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  // 更新所選交通方式的時間
  void _updateTimeForSelectedTransport() {
    if (!_useManualTime && _calculatedTimes.containsKey(_selectedTransportation)) {
      final totalMinutes = _calculatedTimes[_selectedTransportation]!;
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      
      _hoursController.text = hours.toString();
      _minutesController.text = minutes.toString();
    }
  }

  int _calculateTotalMinutes() {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    return hours * 60 + minutes;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('調整交通方式'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 路線資訊
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.route, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.originSpot.name} → ${widget.destinationSpot.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),            // 交通方式選擇
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _transportOptions.length,
                itemBuilder: (context, index) {
                  final option = _transportOptions[index];
                  final isSelected = _selectedTransportation == option['name'];
                  final calculatedTime = _calculatedTimes[option['name']];
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTransportation = option['name'];
                        _tabController.index = index;
                      });
                      _updateTimeForSelectedTransport();
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? option['color'].withOpacity(0.1) : Colors.grey[50],
                        border: Border.all(
                          color: isSelected ? option['color'] : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            option['icon'],
                            color: isSelected ? option['color'] : Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            option['name'],
                            style: TextStyle(
                              color: isSelected ? option['color'] : Colors.grey[700],
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (calculatedTime != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${calculatedTime}分',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 載入指示器
            if (_isCalculating)
              Container(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '正在計算路線...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            
            // 手動調整開關
            Row(
              children: [
                Checkbox(
                  value: _useManualTime,
                  onChanged: (value) {
                    setState(() {
                      _useManualTime = value ?? false;
                      if (!_useManualTime) {
                        _updateTimeForSelectedTransport();
                      }
                    });
                  },
                ),
                const Text('手動設定時間'),
              ],
            ),
            
            // 時間設置
            Row(
              children: [
                const Text('耗時: '),
                // 小時
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _hoursController,
                    enabled: _useManualTime,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      if (_useManualTime) {
                        setState(() {});
                      }
                    },
                  ),
                ),
                const Text(' 時 '),
                // 分鐘
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _minutesController,
                    enabled: _useManualTime,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      if (_useManualTime) {
                        setState(() {});
                      }
                    },
                  ),
                ),
                const Text(' 分'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 交通方式預覽
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _transportOptions[_tabController.index]['icon'],
                    color: _transportOptions[_tabController.index]['color'],
                  ),
                  const SizedBox(width: 8),
                  Text(_selectedTransportation),
                  const Spacer(),
                  Text(
                    '${_calculateTotalMinutes()} 分鐘',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onUpdate(_selectedTransportation, _calculateTotalMinutes());
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text('確定'),
        ),
      ],
    );
  }
}
