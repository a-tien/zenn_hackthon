import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/itinerary.dart';
import '../models/itinerary_member.dart';
import '../components/edit_itinerary_dialog.dart';
import '../components/budget_setting_dialog.dart';
import '../components/additional_requirements_dialog.dart';
import '../services/api_service.dart'; // 新增的API服務
import 'update_firestore.dart';
import 'manage_itinerary_members_page.dart';
import 'ai_planning_result_page.dart';

class TripPrePlanningPage extends StatefulWidget {
  final Itinerary itinerary;
  final bool preserveExisting;

  const TripPrePlanningPage({
    super.key,
    required this.itinerary,
    required this.preserveExisting,
  });

  @override
  State<TripPrePlanningPage> createState() => _TripPrePlanningPageState();
}

class _TripPrePlanningPageState extends State<TripPrePlanningPage> {
  late Itinerary _itinerary;
  bool _hasBudget = false;
  double _minBudget = 0;
  double _maxBudget = 20000;
  String _additionalRequirements = '';
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _itinerary = widget.itinerary;
  }
  
  // 更新行程日期和信息
  Future<void> _updateItineraryInfo() async {
    final updatedItinerary = await showDialog<Itinerary>(
      context: context,
      builder: (context) => EditItineraryDialog(
        itinerary: _itinerary,
        onUpdate: (itinerary) {
          Navigator.pop(context, itinerary);
        },
      ),
    );
    
    if (updatedItinerary != null) {
      setState(() {
        _itinerary = updatedItinerary;
      });
    }
  }
  
  // 管理行程成員
  Future<void> _manageMembers() async {
    final result = await Navigator.push<List<dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ManageItineraryMembersPage(
          itinerary: _itinerary,
          onMembersUpdated: (updatedMembers) {
            setState(() {
              _itinerary.members = updatedMembers;
            });
          },
        ),
      ),
    );
    
    if (result != null) {
      setState(() {
        _itinerary.members = List<ItineraryMember>.from(result);
      });
    }
  }
  
  // 設定行程預算
  void _setBudget() {
    showDialog(
      context: context,
      builder: (context) => BudgetSettingDialog(
        hasBudget: _hasBudget,
        minBudget: _minBudget,
        maxBudget: _maxBudget,
        onUpdate: (hasBudget, min, max) {
          setState(() {
            _hasBudget = hasBudget;
            _minBudget = min;
            _maxBudget = max;
          });
        },
      ),
    );
  }
  
  // 設定其他需求
  void _setAdditionalRequirements() {
    showDialog(
      context: context,
      builder: (context) => AdditionalRequirementsDialog(
        initialRequirements: _additionalRequirements,
        onUpdate: (requirements) {
          setState(() {
            _additionalRequirements = requirements;
          });
        },
      ),
    );
  }
  
  // 開始智能規劃
  Future<void> _startPlanning() async {
    if (_itinerary.members.isEmpty) {
      _showSnackBar('請設定行程成員');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 使用新的API服務
      final jsonResult = await ApiService.planItinerary(
        hasBudget: _hasBudget,
        minBudget: _minBudget,
        maxBudget: _maxBudget,
        additionalRequirements: _additionalRequirements,
        itinerary: _itinerary, // 傳入完整的itinerary物件
        preserveExisting: widget.preserveExisting,
      );

      // 取得userId與itineraryId
      // final userId = FirebaseAuth.instance.currentUser?.uid;
      // final itineraryId = _itinerary.id;

      // if (userId == null || itineraryId == null) {
      //   throw Exception('使用者ID或行程ID為空，無法更新Firestore');
      // }

      // 更新Firestore
      // await updateItineraryPartial(userId, itineraryId, jsonResult);
      // print('成功寫入 Firestore 的資料: $jsonResult');

      // 跳轉到結果頁面
      if (!mounted) return;
      
      final resultItinerary = Itinerary.fromJson(jsonResult);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AIPlanningResultPage(
            originalItinerary: _itinerary,
            resultItinerary: resultItinerary,
            preserveExisting: widget.preserveExisting,
            itineraryId: _itinerary.id, // 傳入行程ID
          ),
        ),
      );
      
    } on ApiException catch (e) {
      _showSnackBar('API錯誤: ${e.message}');
    } catch (e) {
      _showSnackBar('規劃失敗: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 顯示SnackBar的輔助方法
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('行程規劃前準備'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 主要內容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '請確認以下信息',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  '為了給您提供最佳的行程規劃，請確認以下設定',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // 行程設定
                        _buildSettingItem(
                          icon: Icons.calendar_today,
                          title: '行程設定',
                          subtitle: _itinerary.useDateRange
                              ? '${_formatDate(_itinerary.startDate)} - ${_formatDate(_itinerary.endDate)} (${_itinerary.days}天)'
                              : '共${_itinerary.days}天',
                          color: Colors.blue,
                          onTap: _updateItineraryInfo,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 成員設定
                        _buildSettingItem(
                          icon: Icons.people,
                          title: '成員設定',
                          subtitle: _itinerary.members.isEmpty
                              ? '尚未設定行程成員'
                              : '共${_itinerary.members.length}位成員',
                          color: Colors.orange,
                          onTap: _manageMembers,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 行程預算
                        _buildSettingItem(
                          icon: Icons.account_balance_wallet,
                          title: '行程預算',
                          subtitle: _hasBudget
                              ? '每人 ${_minBudget.toInt()} - ${_maxBudget.toInt()} 元'
                              : '尚未設定預算',
                          color: Colors.green,
                          onTap: _setBudget,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 其他需求
                        _buildSettingItem(
                          icon: Icons.edit_note,
                          title: '其他需求',
                          subtitle: _additionalRequirements.isEmpty
                              ? '點擊添加其他需求'
                              : _additionalRequirements.length > 30
                                  ? '${_additionalRequirements.substring(0, 30)}...'
                                  : _additionalRequirements,
                          color: Colors.purple,
                          onTap: _setAdditionalRequirements,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 開始規劃按鈕
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _startPlanning,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: Colors.amber.withOpacity(0.5),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text(
                            '進行智能行程規劃',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
          
          // 載入中遮罩
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      '正在生成您的行程...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  // 構建設定項目
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
              const SizedBox(width: 16),
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
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
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