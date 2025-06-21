import 'package:flutter/material.dart';
import '../components/home_product_card.dart';
import '../model/home_item_model.dart';
import '../page/home_detail_page.dart';
import 'package:my_app_1/feature/itinerary/models/itinerary.dart';
import 'package:my_app_1/feature/itinerary/models/itinerary_day.dart';
import 'package:my_app_1/feature/itinerary/models/destination.dart';

class HomeProductSlider extends StatefulWidget {
  final List<HomeItemModel> items;

  const HomeProductSlider({super.key, required this.items});

  @override
  State<HomeProductSlider> createState() => _HomeProductSliderState();
}

class _HomeProductSliderState extends State<HomeProductSlider> {
  bool isLoading = true;  List<Itinerary> itineraries = [
  Itinerary(
    name: '預設旅程',
    useDateRange: true,
    days: 3,
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 2)),
    destinations: [
      Destination(
        id: 'tokyo',
        name: '東京',
        country: '日本',
        prefecture: '東京都',
        type: 'domestic',
      ),
    ],
    transportation: '電車',
    travelType: '自由行',
    itineraryDays: [
      ItineraryDay(
        dayNumber: 1,
        transportation: '電車',
        spots: [],
      ),
      ItineraryDay(
        dayNumber: 2,
        transportation: '電車',
        spots: [],
      ),
      ItineraryDay(
        dayNumber: 3,
        transportation: '電車',
        spots: [],
      ),
    ],
  ),
];
  
  @override
  void initState() {
    super.initState();
    // _loadItineraries();
  }

  // Future<void> _loadItineraries() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     isLoading = true;
  //   });
    
  //   final itinerariesJson = prefs.getStringList('itineraries') ?? [];
    
  //   setState(() {
  //     itineraries = itinerariesJson
  //         .map((json) => Itinerary.fromJson(jsonDecode(json)))
  //         .toList();
  //     isLoading = false;
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final itinerary = itineraries[0];
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
                    itinerary: itinerary,
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
