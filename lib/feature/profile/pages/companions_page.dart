import 'package:flutter/material.dart';
import '../models/travel_companion.dart';
import '../services/companion_service.dart';
import '../../common/widgets/login_required_dialog.dart';
import 'add_edit_companion_page.dart';
import '../../../utils/app_localizations.dart';

class CompanionsPage extends StatefulWidget {
  const CompanionsPage({super.key});

  @override
  State<CompanionsPage> createState() => _CompanionsPageState();
}

class _CompanionsPageState extends State<CompanionsPage> {
  List<TravelCompanion> _companions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanions();
  }

  // 加載旅伴數據
  Future<void> _loadCompanions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final companions = await CompanionService.getAllCompanions();
      setState(() {
        _companions = companions;
        _isLoading = false;
      });    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (e.toString().contains('需要登入')) {
        // 顯示登入提示對話框
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => LoginRequiredDialog(
              feature: '管理旅伴',
              onLoginPressed: () {
                Navigator.of(context).pop();
                // 重新載入資料
                _loadCompanions();
              },
            ),
          );
        }
        return;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.getLoadCompanionDataFailed(e.toString()) ?? '載入旅伴資料失敗：$e')),
        );
      }
    }
  }

  // 前往新增旅伴頁面
  void _navigateToAddCompanion() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditCompanionPage(),
      ),
    );

    if (result == true && mounted) {
      _loadCompanions();
    }
  }

  // 前往編輯旅伴頁面
  void _navigateToEditCompanion(TravelCompanion companion) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditCompanionPage(companion: companion),
      ),
    );

    if (result == true && mounted) {
      _loadCompanions();
    }
  }

  // 刪除旅伴
  Future<void> _deleteCompanion(TravelCompanion companion) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除旅伴 "${companion.nickname}" 嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('刪除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await CompanionService.deleteCompanion(companion.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)?.companionDeleted ?? '旅伴已刪除')),
          );
          _loadCompanions();
        }      } catch (e) {
        if (e.toString().contains('需要登入')) {
          // 顯示登入提示對話框
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => const LoginRequiredDialog(feature: '刪除旅伴'),
            );
          }
          return;
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)?.getDeleteCompanionFailed(e.toString()) ?? '刪除旅伴失敗：$e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的旅伴'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddCompanion,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    if (_companions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              '還沒有旅伴',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '點擊右下角的按鈕添加新旅伴',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToAddCompanion,
              icon: const Icon(Icons.add),
              label: const Text('新增旅伴'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _companions.length,
      itemBuilder: (context, index) {
        final companion = _companions[index];
        return _buildCompanionCard(companion);
      },
    );
  }

  Widget _buildCompanionCard(TravelCompanion companion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    companion.nickname.isNotEmpty
                        ? companion.nickname[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companion.nickname,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        companion.ageGroup,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _navigateToEditCompanion(companion),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCompanion(companion),
                ),
              ],
            ),
            if (companion.interests.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                '興趣:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: companion.interests.map((interest) {
                  return Chip(
                    label: Text(interest),
                    backgroundColor: Colors.blue.shade50,
                    labelStyle: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
