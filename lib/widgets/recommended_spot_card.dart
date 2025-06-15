import 'package:flutter/material.dart';
import '../models/itinerary.dart';
import '../models/recommended_spot.dart';
import '../models/spot.dart';
import 'add_to_day_dialog.dart';

class RecommendedSpotCard extends StatelessWidget {
  final RecommendedSpot spot;
  final Itinerary itinerary;
  final Function(RecommendedSpot) onAddToItinerary;

  const RecommendedSpotCard({
    super.key,
    required this.spot,
    required this.itinerary,
    required this.onAddToItinerary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左側圖片
          Stack(
            children: [
              // 景點圖片
              SizedBox(
                width: 120,
                height: 140,
                child: Image.network(
                  spot.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 40),
                  ),
                ),
              ),
              
              // 區域標籤
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: Text(
                    spot.district,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          
          // 右側信息
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 地點名稱
                  Text(
                    spot.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // 評分
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        spot.rating.toString(),
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // 描述
                  Text(
                    spot.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 加入行程按鈕
                  Align(
                    alignment: Alignment.bottomRight,
                    child: spot.isAdded
                        ? TextButton.icon(
                            onPressed: null,
                            icon: const Icon(
                              Icons.check,
                              color: Colors.green,
                              size: 18,
                            ),
                            label: const Text(
                              '已加入',
                              style: TextStyle(color: Colors.green),
                            ),
                          )
                        : OutlinedButton(
                            onPressed: () => _showAddToItineraryDialog(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blueAccent,
                              side: const BorderSide(color: Colors.blueAccent),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            ),
                            child: const Text('加入行程'),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToItineraryDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddToDayDialog(
        itinerary: itinerary,
        spot: spot,
      ),
    );

    if (result == true) {
      onAddToItinerary(spot);
    }
  }
}