import 'package:flutter/material.dart';

class DayTransportationDialog extends StatefulWidget {
  final String initialTransportation;
  final Function(String) onSelect;

  const DayTransportationDialog({
    super.key,
    required this.initialTransportation,
    required this.onSelect,
  });

  @override
  State<DayTransportationDialog> createState() => _DayTransportationDialogState();
}

class _DayTransportationDialogState extends State<DayTransportationDialog> {
  late String _selectedTransportation;
  final List<String> _transportationOptions = ['自行安排', '開車', '大眾運輸', '步行', '機車'];

  @override
  void initState() {
    super.initState();
    _selectedTransportation = widget.initialTransportation;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('選擇交通方式'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _transportationOptions.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: _selectedTransportation,
            onChanged: (value) {
              setState(() {
                _selectedTransportation = value!;
              });
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSelect(_selectedTransportation);
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