import 'package:flutter/material.dart';
import '../../../utils/app_localizations.dart';
import '../../../main.dart';

class LanguageSettingsDialog extends StatelessWidget {
  const LanguageSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return AlertDialog(
      title: Text(localizations?.languageSettings ?? '語言設定'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Text('🇯🇵'),
            title: Text(localizations?.japanese ?? '日文'),
            trailing: _getCurrentLocale(context) == const Locale('ja') ? 
              const Icon(Icons.check, color: Colors.green) : null,
            onTap: () => _changeLanguage(context, const Locale('ja')),
          ),
          ListTile(
            leading: const Text('🇹🇼'),
            title: Text(localizations?.chinese ?? '繁體中文'),
            trailing: _getCurrentLocale(context) == const Locale('zh', 'TW') ? 
              const Icon(Icons.check, color: Colors.green) : null,
            onTap: () => _changeLanguage(context, const Locale('zh', 'TW')),
          ),
          ListTile(
            leading: const Text('🇺🇸'),
            title: Text(localizations?.english ?? '英文'),
            trailing: _getCurrentLocale(context) == const Locale('en') ? 
              const Icon(Icons.check, color: Colors.green) : null,
            onTap: () => _changeLanguage(context, const Locale('en')),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations?.close ?? '關閉'),
        ),
      ],
    );
  }

  Locale _getCurrentLocale(BuildContext context) {
    return Localizations.localeOf(context);
  }

  void _changeLanguage(BuildContext context, Locale locale) {
    // 使用 MyApp 的 key 來更新語言
    MyApp.setLocale(context, locale);
    Navigator.of(context).pop();
    
    // 顯示語言更改成功的訊息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getSuccessMessage(locale)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getSuccessMessage(Locale locale) {
    switch (locale.languageCode) {
      case 'ja':
        return '言語が日本語に変更されました';
      case 'zh':
        return '語言已更改為繁體中文';
      case 'en':
        return 'Language changed to English';
      default:
        return 'Language changed';
    }
  }
}
