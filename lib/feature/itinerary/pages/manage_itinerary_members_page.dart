import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/itinerary.dart';
import '../models/itinerary_member.dart';
import '../../profile/models/travel_companion.dart';
import '../../profile/services/companion_service.dart';
import 'add_edit_itinerary_member_page.dart';

class ManageItineraryMembersPage extends StatefulWidget {
  final Itinerary itinerary;
  final Function(List<ItineraryMember>) onMembersUpdated;

  const ManageItineraryMembersPage({
    super.key, 
    required this.itinerary, 
    required this.onMembersUpdated
  });

  @override
  State<ManageItineraryMembersPage> createState() => _ManageItineraryMembersPageState();
}

class _ManageItineraryMembersPageState extends State<ManageItineraryMembersPage> {
  late List<ItineraryMember> _members;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _members = List.from(widget.itinerary.members);
  }

  // 添加常用旅伴
  Future<void> _addFromCompanions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 獲取所有常用旅伴
      final companions = await CompanionService.getAllCompanions();
      
      if (!mounted) return;
      
      // 顯示選擇常用旅伴對話框
      final selectedCompanions = await showDialog<List<TravelCompanion>>(
        context: context,
        builder: (context) => CompanionSelectionDialog(
          companions: companions,
          existingMemberIds: _members.map((m) => m.id).toList(),
        ),
      );
      
      if (selectedCompanions != null && selectedCompanions.isNotEmpty) {
        setState(() {
          // 將選擇的常用旅伴轉換為行程成員
          for (final companion in selectedCompanions) {
            // 檢查是否已存在相同ID的成員
            if (!_members.any((m) => m.id == companion.id)) {
              _members.add(ItineraryMember.fromCompanion(companion));
            }
          }
        });
        
        // 通知上層頁面更新成員
        widget.onMembersUpdated(_members);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入常用旅伴失敗：$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 添加新成員
  Future<void> _addNewMember() async {
    final result = await Navigator.push<ItineraryMember>(
      context, 
      MaterialPageRoute(
        builder: (context) => const AddEditItineraryMemberPage(),
      ),
    );
    
    if (result != null) {
      setState(() {
        _members.add(result);
      });
      
      // 通知上層頁面更新成員
      widget.onMembersUpdated(_members);
    }
  }

  // 編輯成員
  Future<void> _editMember(ItineraryMember member, int index) async {
    final result = await Navigator.push<ItineraryMember>(
      context, 
      MaterialPageRoute(
        builder: (context) => AddEditItineraryMemberPage(member: member),
      ),
    );
    
    if (result != null) {
      setState(() {
        _members[index] = result;
      });
      
      // 通知上層頁面更新成員
      widget.onMembersUpdated(_members);
    }
  }

  // 刪除成員
  void _deleteMember(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要將「${_members[index].nickname}」從行程成員中移除嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _members.removeAt(index);
              });
              
              // 通知上層頁面更新成員
              widget.onMembersUpdated(_members);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('行程成員管理'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
            child: Column(
              children: [
                // 常用旅伴按鈕
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addFromCompanions,
                      icon: const Icon(Icons.people),
                      label: const Text('由常用旅伴加入'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),

                // 當前行程成員列表
                Expanded(
                  child: _members.isEmpty 
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline, 
                              size: 64, 
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '目前沒有行程成員',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '點擊下方按鈕來添加成員',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _members.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final member = _members[index];
                          return ListTile(
                            leading: member.getAvatar(),
                            title: Text(
                              member.nickname,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(member.ageGroup),
                                if (member.interests.isNotEmpty)
                                  Text('興趣: ${member.interests.join(", ")}'),
                                if (member.specialNeeds.isNotEmpty)
                                  Text('特殊需求: ${member.specialNeeds.join(", ")}'),
                              ],
                            ),
                            isThreeLine: member.interests.isNotEmpty || member.specialNeeds.isNotEmpty,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editMember(member, index),
                                  tooltip: '編輯',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteMember(index),
                                  tooltip: '刪除',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewMember,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// 常用旅伴選擇對話框
class CompanionSelectionDialog extends StatefulWidget {
  final List<TravelCompanion> companions;
  final List<String> existingMemberIds;

  const CompanionSelectionDialog({
    super.key, 
    required this.companions, 
    required this.existingMemberIds
  });

  @override
  State<CompanionSelectionDialog> createState() => _CompanionSelectionDialogState();
}

class _CompanionSelectionDialogState extends State<CompanionSelectionDialog> {
  final List<TravelCompanion> _selectedCompanions = [];

  @override
  Widget build(BuildContext context) {
    // 過濾已經存在的成員
    final availableCompanions = widget.companions
        .where((c) => !widget.existingMemberIds.contains(c.id))
        .toList();

    return AlertDialog(
      title: const Text('選擇常用旅伴'),
      content: SizedBox(
        width: double.maxFinite,
        child: availableCompanions.isEmpty
            ? const Center(child: Text('沒有可用的常用旅伴'))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: availableCompanions.length,
                itemBuilder: (context, index) {
                  final companion = availableCompanions[index];
                  final isSelected = _selectedCompanions.contains(companion);
                  
                  return CheckboxListTile(
                    title: Text(companion.nickname),
                    subtitle: Text('${companion.ageGroup} • ${companion.interests.join(", ")}'),
                    value: isSelected,
                    onChanged: (_) {
                      setState(() {
                        if (isSelected) {
                          _selectedCompanions.remove(companion);
                        } else {
                          _selectedCompanions.add(companion);
                        }
                      });
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedCompanions),
          child: const Text('確認添加'),
        ),
      ],
    );
  }
}
