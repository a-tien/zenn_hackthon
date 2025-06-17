import 'package:flutter/material.dart';
import 'package:my_app_1/feature/discover/models/spot.dart';

class SpotDetailPage extends StatelessWidget {
  final Spot spot;

  const SpotDetailPage({super.key, required this.spot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(spot.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${spot.area}・${spot.name}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Image.asset(spot.image, height: 200, fit: BoxFit.cover),
          const SizedBox(height: 8),
          Text(spot.address),
          const SizedBox(height: 8),
          Text('Google 評價 ${spot.rating}'),
          const SizedBox(height: 16),
          const Text('簡介說明文字…………'),
          const SizedBox(height: 16),
          const Text('網址\n電話\n營業時間'),
        ],
      ),
    );
  }
}
