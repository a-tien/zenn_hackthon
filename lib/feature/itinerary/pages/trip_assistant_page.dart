import 'package:flutter/material.dart';
import '../models/itinerary.dart';
import 'recommend_spots_page.dart';
import 'trip_pre_planning_page.dart';
import '../../../utils/app_localizations.dart';

class TripAssistantPage extends StatelessWidget {
  final Itinerary itinerary;

  const TripAssistantPage({
    super.key,
    required this.itinerary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.tripAssistant),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 歡迎標題
              Text(
                AppLocalizations.of(context)!.welcomeToTripAssistant,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // 歡迎文字
              Text(
                AppLocalizations.of(context)!.tripAssistantDescription,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // 推薦景點按鈕
              _buildOptionCard(
                context,
                title: AppLocalizations.of(context)!.recommendSpots,
                description: AppLocalizations.of(context)!.recommendSpotsDescription,
                icon: Icons.place,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecommendSpotsPage(
                        itinerary: itinerary,
                      ),
                    ),
                  );
                },
              ),
              

              const SizedBox(height: 20),
              
              // 完整規劃按鈕
              _buildOptionCard(
                context,
                title: AppLocalizations.of(context)!.completePlanning,
                description: AppLocalizations.of(context)!.completePlanningDescription,
                icon: Icons.schedule,
                color: Colors.amber,
                onTap: () {
                  _showPlanningOptions(context);
                },
              ),
              
              const Spacer(),
              
              // 關閉按鈕
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(AppLocalizations.of(context)!.close),
              ),
            ],
          ),
        ),
      ),
    );
  }  // 顯示規劃選項對話框
  void _showPlanningOptions(BuildContext context) {
    print('Showing planning options dialog'); // 添加日誌
    
    // 覆蓋現有行程
    void _navigateToPrePlanning(bool preserveExisting) {
      print('Navigating to pre-planning with preserveExisting=$preserveExisting'); // 添加日誌
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripPrePlanningPage(
            itinerary: itinerary,
            preserveExisting: preserveExisting,
          ),
        ),
      );
    }
    
    // 顯示選項對話框
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.choosePlanningMethod),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 覆蓋現有行程選項
              ListTile(
                leading: const Icon(Icons.refresh, color: Colors.blue),
                title: Text(AppLocalizations.of(context)!.overwriteExistingItinerary),
                subtitle: Text(AppLocalizations.of(context)!.overwriteDescription),
                onTap: () {
                  print('Dialog: selected overwrite'); // 添加日誌
                  Navigator.pop(dialogContext);
                  _navigateToPrePlanning(false);
                },
              ),
              // 保留已選行程選項
              ListTile(
                leading: const Icon(Icons.add_circle, color: Colors.green),
                title: Text(AppLocalizations.of(context)!.keepSelectedItinerary),
                subtitle: Text(AppLocalizations.of(context)!.preserveDescription),
                onTap: () {
                  print('Dialog: selected preserve'); // 添加日誌
                  Navigator.pop(dialogContext);
                  _navigateToPrePlanning(true);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
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
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}