import 'package:flutter/material.dart';
import '../models/spot.dart';

class SpotCard extends StatelessWidget {
  final Spot spot;
  final VoidCallback onNavigate;
  final VoidCallback? onTap;
  final VoidCallback? onEditStayTime; // 新增編輯停留時間回調

  const SpotCard({
    super.key,
    required this.spot,
    required this.onNavigate,
    this.onTap,
    this.onEditStayTime,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // 順序指示器
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${spot.order}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          
          // 景點圖片
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            child: Image.network(
              spot.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                );
              },
            ),
          ),
          
          // 景點信息
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 開始時間
                  Text(
                    spot.startTime,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // 景點名稱
                  Text(
                    spot.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 4),                  // 停留時間 (可點擊編輯)
                  GestureDetector(
                    onTap: onEditStayTime != null ? () {
                      onEditStayTime!();
                    } : null,
                    behavior: HitTestBehavior.opaque, // 阻止事件冒泡
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey[300]!),
                      ),                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            spot.getFormattedStayTime(),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),          ),
          
          // 導航按鈕
          IconButton(
            icon: const Icon(Icons.directions, color: Colors.blueAccent),
            onPressed: onNavigate,
          ),
        ],
        ),
      ),
    );
  }
}