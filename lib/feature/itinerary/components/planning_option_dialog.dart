import 'package:flutter/material.dart';
import '../../../utils/app_localizations.dart';

enum PlanningOption {
  overwrite,
  preserve,
}

class PlanningOptionDialog extends StatelessWidget {
  final Function(PlanningOption) onOptionSelected;

  const PlanningOptionDialog({
    super.key,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.planningOptionTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            
            // 選項1：覆蓋現有行程
            _buildOptionButton(
              context,
              icon: Icons.refresh,
              title: AppLocalizations.of(context)!.overwriteOption,
              description: AppLocalizations.of(context)!.overwriteDescription,
              color: Colors.blueAccent,              onTap: () {
                print('Option selected: overwrite'); // 添加日誌
                onOptionSelected(PlanningOption.overwrite);
                // Navigator.pop(context); // 由父元件關閉對話框
              },
            ),
            
            const SizedBox(height: 12),
            
            // 選項2：保留已選行程
            _buildOptionButton(
              context,
              icon: Icons.add_circle,
              title: AppLocalizations.of(context)!.preserveOption,
              description: AppLocalizations.of(context)!.preserveDescription,
              color: Colors.green,              onTap: () {
                print('Option selected: preserve'); // 添加日誌
                onOptionSelected(PlanningOption.preserve);
                // Navigator.pop(context); // 由父元件關閉對話框
              },
            ),
            
            const SizedBox(height: 12),
            
            // 取消按鈕
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        ),
      ),
    );
  }

  // 構建選項按鈕
  Widget _buildOptionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
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
}
