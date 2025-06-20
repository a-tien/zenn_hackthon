import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/itinerary_member.dart';
import '../../profile/models/travel_companion.dart';

class AddEditItineraryMemberPage extends StatefulWidget {
  final ItineraryMember? member;

  const AddEditItineraryMemberPage({super.key, this.member});

  @override
  State<AddEditItineraryMemberPage> createState() => _AddEditItineraryMemberPageState();
}

class _AddEditItineraryMemberPageState extends State<AddEditItineraryMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _interestController = TextEditingController();
  final _specialNeedController = TextEditingController();
  
  String _selectedAgeGroup = AgeGroups.values[0];
  List<String> _interests = [];
  List<String> _specialNeeds = [];
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.member != null;
    
    if (_isEditing) {
      _nicknameController.text = widget.member!.nickname;
      _selectedAgeGroup = widget.member!.ageGroup;
      _interests = List.from(widget.member!.interests);
      _specialNeeds = List.from(widget.member!.specialNeeds);
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _interestController.dispose();
    _specialNeedController.dispose();
    super.dispose();
  }

  // 添加興趣標籤
  void _addInterest() {
    final interest = _interestController.text.trim();
    if (interest.isNotEmpty && !_interests.contains(interest)) {
      setState(() {
        _interests.add(interest);
        _interestController.clear();
      });
    }
  }

  // 移除興趣標籤
  void _removeInterest(String interest) {
    setState(() {
      _interests.remove(interest);
    });
  }

  // 添加特殊需求標籤
  void _addSpecialNeed() {
    final need = _specialNeedController.text.trim();
    if (need.isNotEmpty && !_specialNeeds.contains(need)) {
      setState(() {
        _specialNeeds.add(need);
        _specialNeedController.clear();
      });
    }
  }

  // 移除特殊需求標籤
  void _removeSpecialNeed(String need) {
    setState(() {
      _specialNeeds.remove(need);
    });
  }

  // 保存成員
  void _saveMember() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final member = ItineraryMember(
        id: _isEditing ? widget.member!.id : const Uuid().v4(),
        nickname: _nicknameController.text.trim(),
        ageGroup: _selectedAgeGroup,
        interests: _interests,
        specialNeeds: _specialNeeds,
      );

      Navigator.pop(context, member);
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存成員失敗：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '編輯行程成員' : '新增行程成員'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('確認刪除'),
                    content: const Text('確定要刪除此行程成員嗎？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // 關閉對話框
                          Navigator.pop(context, 'delete'); // 返回結果
                        },
                        child: const Text('刪除', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 暱稱輸入
            TextFormField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: '暱稱',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '請輸入暱稱';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 年齡層選擇
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '年齡層',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
              ),
              value: _selectedAgeGroup,
              items: AgeGroups.values.map((ageGroup) {
                return DropdownMenuItem<String>(
                  value: ageGroup,
                  child: Text(ageGroup),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedAgeGroup = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // 興趣標籤
            const Text(
              '興趣',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _interestController,
                    decoration: const InputDecoration(
                      labelText: '添加興趣',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.interests),
                    ),
                    onSubmitted: (_) => _addInterest(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addInterest,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _interests.map((interest) {
                return Chip(
                  label: Text(interest),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeInterest(interest),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 特殊需求標籤
            const Text(
              '特殊需求',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _specialNeedController,
                    decoration: const InputDecoration(
                      labelText: '添加特殊需求',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.accessibility_new),
                    ),
                    onSubmitted: (_) => _addSpecialNeed(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addSpecialNeed,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _specialNeeds.map((need) {
                return Chip(
                  label: Text(need),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeSpecialNeed(need),
                  backgroundColor: Colors.orange.shade100,
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // 保存按鈕
            ElevatedButton(
              onPressed: _isSaving ? null : _saveMember,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('保存', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
