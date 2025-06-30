import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/app_localizations.dart';

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
  TabController? _tabController;
  late String _selectedTransportation;
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  
  List<Map<String, dynamic>> _getTransportOptions(AppLocalizations? localizations) {
    return [
      {'name': localizations?.car ?? '汽車', 'icon': Icons.directions_car, 'color': Colors.blue},
      {'name': localizations?.bicycle ?? '自行車', 'icon': Icons.directions_bike, 'color': Colors.green},
      {'name': localizations?.publicTransport ?? '大眾運輸', 'icon': Icons.directions_subway, 'color': Colors.orange},
      {'name': localizations?.walking ?? '步行', 'icon': Icons.directions_walk, 'color': Colors.purple},
    ];
  }

  @override
  void initState() {
    super.initState();
    
    // 設置時間控制器
    final hours = widget.travelTimeMinutes ~/ 60;
    final minutes = widget.travelTimeMinutes % 60;
    _hoursController = TextEditingController(text: hours.toString());
    _minutesController = TextEditingController(text: minutes.toString());
    
    // 延遲初始化 TabController，因為需要 context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTabController();
    });
  }

  void _initializeTabController() {
    final localizations = AppLocalizations.of(context);
    final transportOptions = _getTransportOptions(localizations);
    
    _tabController = TabController(length: transportOptions.length, vsync: this);
    
    // 尋找初始交通方式的索引
    int initialIndex = 0;
    for (int i = 0; i < transportOptions.length; i++) {
      if (transportOptions[i]['name'] == widget.initialTransportation) {
        initialIndex = i;
        break;
      }
    }
    
    _tabController!.index = initialIndex;
    _selectedTransportation = transportOptions[initialIndex]['name'];
    
    _tabController!.addListener(() {
      if (mounted && _tabController != null) {
        setState(() {
          _selectedTransportation = transportOptions[_tabController!.index]['name'];
        });
      }
    });
    
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
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
    final localizations = AppLocalizations.of(context);
    final transportOptions = _getTransportOptions(localizations);
    
    // 如果 TabController 還沒初始化，初始化它
    if (_tabController == null) {
      _tabController = TabController(length: transportOptions.length, vsync: this);
      
      // 尋找初始交通方式的索引
      int initialIndex = 0;
      for (int i = 0; i < transportOptions.length; i++) {
        if (transportOptions[i]['name'] == widget.initialTransportation) {
          initialIndex = i;
          break;
        }
      }
      
      _tabController!.index = initialIndex;
      _selectedTransportation = transportOptions[initialIndex]['name'];
      
      _tabController!.addListener(() {
        if (mounted) {
          setState(() {
            _selectedTransportation = transportOptions[_tabController!.index]['name'];
          });
        }
      });
    }
    
    return AlertDialog(
      title: Text(localizations?.setTransportationMode ?? '設置交通方式'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 交通方式標籤欄
            TabBar(
              controller: _tabController!,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: transportOptions[_tabController!.index]['color'],
              ),
              tabs: transportOptions.map((option) {
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
                Text(localizations?.timeRequired ?? '耗時: '),
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
                Text(' ${localizations?.hours ?? '時'} '),
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
                Text(' ${localizations?.minutes ?? '分'}'),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 交通方式預覽
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(
                    transportOptions[_tabController!.index]['icon'],
                    color: transportOptions[_tabController!.index]['color'],
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transportOptions[_tabController!.index]['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${_hoursController.text} ${localizations?.hours ?? '時'} ${_minutesController.text} ${localizations?.minutes ?? '分'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations?.cancel ?? '取消'),
        ),
        ElevatedButton(
          onPressed: () {
            final totalMinutes = _calculateTotalMinutes();
            widget.onUpdate(_selectedTransportation, totalMinutes);
            Navigator.of(context).pop();
          },
          child: Text(localizations?.confirm ?? '確定'),
        ),
      ],
    );
  }
}
