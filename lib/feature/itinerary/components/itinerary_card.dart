import 'package:flutter/material.dart';
import '../models/itinerary.dart';
import '../../../utils/app_localizations.dart';

class ItineraryCard extends StatelessWidget {
  final Itinerary itinerary;
  final VoidCallback? onTap;

  const ItineraryCard({
    super.key,
    required this.itinerary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              "https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=800&q=80",
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itinerary.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    itinerary.useDateRange 
                        ? "${_formatDate(itinerary.startDate)}-${_formatDate(itinerary.endDate)} (${_calculateDays(itinerary)}${localizations?.days ?? '日'})"
                        : "${itinerary.days}${localizations?.days ?? '日'}",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return "${date.year}/${date.month}/${date.day}";
  }
  
  int _calculateDays(Itinerary itinerary) {
    if (itinerary.useDateRange) {
      return itinerary.endDate.difference(itinerary.startDate).inDays + 1;
    }
    return itinerary.days;
  }
}