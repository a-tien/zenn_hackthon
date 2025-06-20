import 'package:flutter/material.dart';

class AdditionalRequirementsDialog extends StatefulWidget {
  final String initialRequirements;
  final Function(String) onUpdate;

  const AdditionalRequirementsDialog({
    super.key,
    this.initialRequirements = '',
    required this.onUpdate,
  });

  @override
  State<AdditionalRequirementsDialog> createState() => _AdditionalRequirementsDialogState();
}

class _AdditionalRequirementsDialogState extends State<AdditionalRequirementsDialog> {
  late TextEditingController _requirementsController;
  
  @override
  void initState() {
    super.initState();
    _requirementsController = TextEditingController(text: widget.initialRequirements);
  }
  
  @override
  void dispose() {
    _requirementsController.dispose();
    super.dispose();
  }

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '其他需求',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              '請告訴我們您在行程規劃中的其他需求或偏好',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 需求文本輸入
            TextField(
              controller: _requirementsController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '例如：希望有親子活動、室內活動為主、避免人潮、需要提前預約的景點...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 確認按鈕
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onUpdate(_requirementsController.text);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('確認'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
