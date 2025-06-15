import 'package:flutter/material.dart';
import '../components/home_product_card.dart';
import '../model/home_item_model.dart';
import '../page/home_detail_page.dart';

class HomeProductSlider extends StatelessWidget {
  final List<HomeItemModel> items;

  const HomeProductSlider({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = items[index];
          return HomeProductCard(
            imageUrl: item.imageUrl,
            title: item.title,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeDetailPage(
                    imageUrl: item.imageUrl,
                    title: item.title,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
