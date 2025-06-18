import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChangeTransportDialog extends StatefulWidget {
  final String initialTransportation;
  final int travelTimeMinutes;
  final Function(String, int) onUpdate;

  const ChangeTransportDialog({
    super.key,
    required this.initialTransportation,
    required this.travelTimeMinutes,
    required this.onUpdate,
  });

  @override
  State<ChangeTransportDialog> createState() => _ChangeTransportDialogState();
}

class _ChangeTransportDialogState extends State<ChangeTransportDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _selectedTransportation;
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  
  final List<Map<String, dynamic>> _transportOptions = [
    {'name': '汽車', 'icon': Icons.directions_car, 'color': Colors.blue},
    {'name': '自行車', 'icon': Icons.directions_bike, 'color': Colors.green},
    {'name': '大眾運輸', 'icon': Icons.directions_subway, 'color': Colors.orange},
    {'name': '步行', 'icon': Icons.directions_walk, 'color': Colors.purple},
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
    _hoursController = TextEditingController(text: hours > 0 ? hours.toString() : '');
    _minutesController = TextEditingController(text: minutes.toString());
    
    // 監聽標籤變更
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTransportation = _transportOptions[_tabController.index]['name'];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  // 計算總分鐘數
  int _calculateTotalMinutes() {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    return hours * 60 + minutes;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('設置交通方式'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 交通方式標籤欄
            TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: _transportOptions[_tabController.index]['color'],
              ),
              tabs: _transportOptions.map((option) {
                return Tab(
                  icon: Icon(option['icon']),
                  text: option['name'],
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // 時間設置
            Row(
              children: [
                const Text('耗時: '),
                // 小時
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _hoursController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const Text(' 時 '),
                // 分鐘
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const Text(' 分'),
              ],
            ),
            
            const SizedBox(height: 20),
            
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