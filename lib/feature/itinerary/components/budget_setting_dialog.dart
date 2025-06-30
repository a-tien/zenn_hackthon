import 'package:flutter/material.dart';
import '../../../utils/app_localizations.dart';

class BudgetSettingDialog extends StatefulWidget {
  final bool hasBudget;
  final double minBudget;
  final double maxBudget;
  final Function(bool, double, double) onUpdate;

  const BudgetSettingDialog({
    super.key,
    this.hasBudget = true,
    this.minBudget = 0,
    this.maxBudget = 20000,
    required this.onUpdate,
  });

  @override
  State<BudgetSettingDialog> createState() => _BudgetSettingDialogState();
}

class _BudgetSettingDialogState extends State<BudgetSettingDialog> {
  late bool _hasBudget;
  late RangeValues _budgetRange;
  
  @override
  void initState() {
    super.initState();
    _hasBudget = widget.hasBudget;
    _budgetRange = RangeValues(
      widget.minBudget, 
      widget.maxBudget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
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
            Text(
              localizations?.setBudgetTitle ?? '設定行程預算',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 是否設定預算
            Row(
              children: [
                Checkbox(
                  value: _hasBudget,
                  onChanged: (value) {
                    setState(() {
                      _hasBudget = value ?? false;
                    });
                  },
                ),
                Text(localizations?.setBudgetPerPerson ?? '設定每人預算'),
                
                const Spacer(),
                
                TextButton(
                  onPressed: () {
                    setState(() {
                      _hasBudget = false;
                    });
                    widget.onUpdate(false, 0, 0);
                    Navigator.pop(context);
                  },
                  child: Text(localizations?.noSetting ?? '不設定'),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 預算範圍顯示
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${localizations?.minimum ?? '最低'}: ${_budgetRange.start.toInt()} ${localizations?.currency ?? '元'}',
                  style: TextStyle(
                    fontSize: 16,
                    color: _hasBudget ? Colors.black : Colors.grey,
                  ),
                ),
                Text(
                  '${localizations?.maximum ?? '最高'}: ${_budgetRange.end.toInt()} ${localizations?.currency ?? '元'}',
                  style: TextStyle(
                    fontSize: 16,
                    color: _hasBudget ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // 預算滑動條
            RangeSlider(
              values: _budgetRange,
              min: 0,
              max: 100000,
              divisions: 100,
              labels: RangeLabels(
                '${_budgetRange.start.toInt()}',
                '${_budgetRange.end.toInt()}',
              ),
              onChanged: _hasBudget ? (RangeValues values) {
                setState(() {
                  _budgetRange = values;
                });
              } : null,
              activeColor: Colors.blueAccent,
              inactiveColor: Colors.grey.withOpacity(0.3),
            ),
            
            const SizedBox(height: 20),
            
            // 確認按鈕
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onUpdate(
                    _hasBudget, 
                    _budgetRange.start, 
                    _budgetRange.end,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(localizations?.confirm ?? '確認'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
