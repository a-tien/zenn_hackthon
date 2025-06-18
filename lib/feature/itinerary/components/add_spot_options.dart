import 'package:flutter/material.dart';

class AddSpotOptions extends StatelessWidget {
  final bool isInsert;

  const AddSpotOptions({
    super.key,
    this.isInsert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isInsert ? '插入新景點' : '添加景點',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // 選項按鈕
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOptionButton(
                context,
                Icons.map,
                '從地圖搜尋',
                Colors.green.shade700,
                () => Navigator.pop(context),
              ),
              _buildOptionButton(
                context,
                Icons.search,
                '區域搜尋',
                Colors.blue.shade700,
                () => Navigator.pop(context),
              ),
              _buildOptionButton(
                context,
                Icons.bookmark,
                '從收藏選擇',
                Colors.orange.shade700,
                () => Navigator.pop(context),
              ),
              _buildOptionButton(
                context,
                Icons.auto_awesome,
                '智慧推薦',
                Colors.purple.shade700,
                () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}