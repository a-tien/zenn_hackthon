import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/travel_companion.dart';
import '../services/companion_service.dart';

class AddEditCompanionPage extends StatefulWidget {
  final TravelCompanion? companion;

  const AddEditCompanionPage({super.key, this.companion});

  @override
  State<AddEditCompanionPage> createState() => _AddEditCompanionPageState();
}

class _AddEditCompanionPageState extends State<AddEditCompanionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _interestController = TextEditingController();
  
  String _selectedAgeGroup = AgeGroups.values[0];
  List<String> _interests = [];
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.companion != null;
    
    if (_isEditing) {
      _nicknameController.text = widget.companion!.nickname;
      _selectedAgeGroup = widget.companion!.ageGroup;
      _interests = List.from(widget.companion!.interests);
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _interestController.dispose();
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

  // 保存旅伴
  Future<void> _saveCompanion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final companion = TravelCompanion(
        id: _isEditing ? widget.companion!.id : const Uuid().v4(),
        nickname: _nicknameController.text.trim(),
        ageGroup: _selectedAgeGroup,
        interests: _interests,
      );

      if (_isEditing) {
        await CompanionService.updateCompanion(companion);
      } else {
        await CompanionService.addCompanion(companion);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存旅伴失敗：$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '編輯旅伴' : '新增旅伴'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 暱稱
                const Text(
                  '暱稱',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    hintText: '請輸入旅伴暱稱',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '請輸入暱稱';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // 年齡層
                const Text(
                  '年齡層',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedAgeGroup,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      border: InputBorder.none,
                    ),
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
                ),
                const SizedBox(height: 24),

                // 興趣
                const Text(
                  '興趣',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _interestController,
                        decoration: const InputDecoration(
                          hintText: '請輸入興趣標籤',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _addInterest(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addInterest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('添加'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 已添加的興趣標籤
                if (_interests.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '已添加興趣:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _interests.map((interest) {
                            return Chip(
                              label: Text(interest),
                              backgroundColor: Colors.blue.shade50,
                              deleteIcon: const Icon(
                                Icons.close,
                                size: 18,
                              ),
                              onDeleted: () => _removeInterest(interest),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),

                // 保存按鈕
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveCompanion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isEditing ? '更新旅伴' : '新增旅伴',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
