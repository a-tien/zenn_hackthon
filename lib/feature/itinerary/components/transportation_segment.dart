import 'package:flutter/material.dart';

class TransportationSegment extends StatelessWidget {
  final String transportType;
  final int duration;
  final VoidCallback onTap;
  final VoidCallback onAddSpot;

  const TransportationSegment({
    super.key,
    required this.transportType,
    required this.duration,
    required this.onTap,
    required this.onAddSpot,
  });

  @override
  Widget build(BuildContext context) {
    // 根據交通方式選擇圖標
    IconData transportIcon;
    switch (transportType.toLowerCase()) {
      case '步行':
        transportIcon = Icons.directions_walk;
        break;
      case '大眾運輸':
      case '地鐵':
      case '捷運':
        transportIcon = Icons.directions_subway;
        break;
      case '自行車':
        transportIcon = Icons.directions_bike;
        break;
      case '機車':
        transportIcon = Icons.motorcycle;
        break;
      default:
        transportIcon = Icons.directions_car;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 垂直連接線
        SizedBox(
          width: 52,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 2,
                height: 60,
                color: Colors.grey[300],
              ),
            ],
          ),
        ),
        
        // 交通信息
        Expanded(
          child: InkWell(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(transportIcon, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    transportType,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(duration),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // 插入景點按鈕
        IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.amber),
          onPressed: onAddSpot,
        ),
      ],
    );
  }

  // 格式化時長
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes 分鐘';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours 小時';
      } else {
        return '$hours 小時 $remainingMinutes 分鐘';
      }
    }
  }
}