import 'package:flutter/material.dart';

class RecommendationTabs extends StatelessWidget {
  final TabController tabController;

  const RecommendationTabs({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: tabController,
        labelColor: Colors.blueAccent,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blueAccent,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: '景點'),
          Tab(text: '美食'),
        ],
      ),
    );
  }
}