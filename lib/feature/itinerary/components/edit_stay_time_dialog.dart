import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/spot.dart';

class EditStayTimeDialog extends StatefulWidget {
  final Spot spot;
  final Function(int hours, int minutes) onUpdate;

  const EditStayTimeDialog({
    super.key,
    required this.spot,
    required this.onUpdate,
  });

  @override
  State<EditStayTimeDialog> createState() => _EditStayTimeDialogState();
}

class _EditStayTimeDialogState extends State<EditStayTimeDialog> {
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;

  @override
  void initState() {
    super.initState();
    _hoursController = TextEditingController(text: widget.spot.stayHours.toString());
    _minutesController = TextEditingController(text: widget.spot.stayMinutes.toString());
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('編輯停留時間 - ${widget.spot.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 景點資訊
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.place, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.spot.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '開始時間: ${widget.spot.startTime}',
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
          
          const SizedBox(height: 20),
          
          // 時間設置
          Row(
            children: [
              const Text(
                '停留時間: ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              
              // 小時
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _hoursController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              
              const Text(' 時 ', style: TextStyle(fontSize: 16)),
              
              // 分鐘
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              
              const Text(' 分', style: TextStyle(fontSize: 16)),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 快速選擇按鈕
          const Text(
            '快速選擇:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildQuickSelectChip('30分', 0, 30),
              _buildQuickSelectChip('1小時', 1, 0),
              _buildQuickSelectChip('1.5小時', 1, 30),
              _buildQuickSelectChip('2小時', 2, 0),
              _buildQuickSelectChip('3小時', 3, 0),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            final hours = int.tryParse(_hoursController.text) ?? 0;
            final minutes = int.tryParse(_minutesController.text) ?? 0;
            
            // 驗證輸入
            if (hours < 0 || hours > 23) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('小時必須在 0-23 之間')),
              );
              return;
            }
            
            if (minutes < 0 || minutes > 59) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('分鐘必須在 0-59 之間')),
              );
              return;
            }
            
            if (hours == 0 && minutes == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('停留時間不能為 0')),
              );
              return;
            }
            
            widget.onUpdate(hours, minutes);
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

  Widget _buildQuickSelectChip(String label, int hours, int minutes) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      onPressed: () {
        setState(() {
          _hoursController.text = hours.toString();
          _minutesController.text = minutes.toString();
        });
      },
      backgroundColor: Colors.grey[100],
      side: BorderSide(color: Colors.grey[300]!),
    );
  }
}
