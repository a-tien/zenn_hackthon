import 'package:flutter/material.dart';
import '../../../utils/app_localizations.dart';
import '../models/favorite_spot.dart';

class FavoriteSpotCard extends StatelessWidget {
  final FavoriteSpot spot;
  final VoidCallback onDetailTap;
  final VoidCallback onAddToItinerary;
  final VoidCallback? onRemove; // 可選的移除回調

  const FavoriteSpotCard({
    super.key,
    required this.spot,
    required this.onDetailTap,
    required this.onAddToItinerary,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onDetailTap, // 點擊卡片查看詳情
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 景點圖片和位置
            Stack(
              children: [
                // 景點圖片
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    spot.imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                // 位置標籤
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.place,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            spot.address,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // 景點信息
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 景點名稱
                  Text(
                    spot.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // 評分
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < spot.rating.floor()
                                ? Icons.star
                                : (index < spot.rating
                                    ? Icons.star_half
                                    : Icons.star_border),
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${spot.rating}',
                        style: const TextStyle(
                          fontSize: 14,                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),                  const SizedBox(height: 8),
                  // 地址
                  Text(
                    spot.address,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),// 按鈕
                  Row(
                    children: [
                      // 詳細信息按鈕
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onDetailTap,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blueAccent,
                            side: const BorderSide(color: Colors.blueAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(AppLocalizations.of(context)!.detailedIntroduction),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 加入行程按鈕
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAddToItinerary,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(AppLocalizations.of(context)!.addToItinerary),
                        ),
                      ),
                      // 移除按鈕（如果提供了回調）
                      if (onRemove != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: onRemove,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: Colors.red,
                          tooltip: AppLocalizations.of(context)!.removeFromCollectionTooltip,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}