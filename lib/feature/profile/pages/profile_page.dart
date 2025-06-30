import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../../../utils/app_localizations.dart';
import 'login_page.dart';
import 'companions_page.dart';
import 'travel_quiz_page.dart';
import '../../collection/pages/favorite_page.dart';
import '../../common/widgets/language_settings_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserProfile _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }
  // 加載用戶資料
  Future<void> _loadUserProfile() async {
    // 開始載入
    setState(() {
      _isLoading = true;
    });

    try {
      // 使用超時限制，防止長時間卡住
      final currentUser = await AuthService.getCurrentUser()
          .timeout(const Duration(seconds: 5));
      
      // 確保組件仍然掛載
      if (mounted) {
        setState(() {
          _userProfile = currentUser ?? UserProfile.guest();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e'); // 載入用戶資料時發生錯誤
      // 發生錯誤時使用遊客資料
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.loadUserDataError}，${AppLocalizations.of(context)!.usingGuestMode}')),
        );
        setState(() {
          _userProfile = UserProfile.guest();
          _isLoading = false;
        });
      }
    }
  }

  // 刷新使用者資料
  Future<void> _refreshUserProfile() async {
    if (!_userProfile.isLoggedIn) return;
    
    try {
      final updatedProfile = await AuthService.getCurrentUser();
      if (mounted && updatedProfile != null) {
        setState(() {
          _userProfile = updatedProfile;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.userDataUpdated)),
        );
      }
    } catch (e) {
      print('Failed to refresh user data: $e'); // 刷新使用者資料失敗
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.refreshFailedTryLater)),
        );
      }
    }
  }
  // 顯示設置菜單
  void _showSettingsMenu() {
    final localizations = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            if (_userProfile.isLoggedIn)
              ListTile(
                leading: const Icon(Icons.refresh),
                title: Text(localizations?.refreshData ?? '刷新資料'),
                onTap: () {
                  Navigator.pop(context);
                  _refreshUserProfile();
                },
              ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(localizations?.languageSettings ?? '語言設定'),
              onTap: () {
                Navigator.pop(context);
                _showLanguageSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(localizations?.settings ?? '設定'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 導航到設置頁面
              },
            ),
            if (_userProfile.isLoggedIn)
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(localizations?.logout ?? '登出', style: const TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _handleLogout();
                },
              ),
          ],
        );
      },
    );
  }
  
  // 處理登出
  Future<void> _handleLogout() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await AuthService.logout();
      
      // 重新加載用戶資料
      await _loadUserProfile();
    } catch (e) {
      // 處理錯誤
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.getLogoutError(e.toString()))),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
    // 處理登入按鈕點擊
  void _handleLoginButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    ).then((result) {
      // 無論結果如何，都重新加載用戶資料
      print('Returned from login page, reloading user data'); // 從登入頁面返回，重新載入用戶資料
      _loadUserProfile();
    });
  }

  // 顯示語言設定對話框
  void _showLanguageSettings() {
    showDialog(
      context: context,
      builder: (context) => const LanguageSettingsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.personalPage),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsMenu,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 個人資料卡片
                _buildProfileCard(),

                const SizedBox(height: 32),

                // 功能按鈕
                _buildFunctionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 個人資料卡片
  Widget _buildProfileCard() {
    return SizedBox(
      width: double.infinity, // 確保卡片佔據整個屏幕寬度
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 頭像
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: _userProfile.avatarUrl != null
                    ? NetworkImage(_userProfile.avatarUrl!)
                    : null,
                child: _userProfile.avatarUrl == null
                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
              ),

              const SizedBox(height: 16),

              // 用戶名
              Text(
                _userProfile.isLoggedIn ? AppLocalizations.of(context)!.getGreeting(_userProfile.name) : AppLocalizations.of(context)!.guest,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              // 旅遊類型標籤 (只在登入且travelType不為null時顯示)
              if (_userProfile.isLoggedIn && _userProfile.travelType != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _userProfile.travelType!,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // 旅行足跡 (只在登入時顯示)
              if (_userProfile.isLoggedIn)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.getTravelFootprint(_userProfile.itineraryCount),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 24),              // 登入按鈕 (只在未登入時顯示)
              if (!_userProfile.isLoggedIn)
                SizedBox(
                  width: double.infinity, // 確保按鈕佔據整個卡片寬度
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLoginButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.loginButton,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 功能按鈕
  Widget _buildFunctionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.functions,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // 我的收藏
        _buildFunctionButton(
          icon: Icons.favorite,
          title: AppLocalizations.of(context)!.myFavorites,
          color: Colors.redAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritePage()),
            );
          },
        ),

        const SizedBox(height: 16),

        // 我的旅伴
        _buildFunctionButton(
          icon: Icons.people,
          title: AppLocalizations.of(context)!.myCompanions,
          color: Colors.blueAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CompanionsPage()),
            );
          },
        ),        const SizedBox(height: 16),
        
        // 旅遊類型測驗
        _buildFunctionButton(
          icon: Icons.psychology,
          title: AppLocalizations.of(context)!.travelTypeQuiz,
          color: Colors.purpleAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TravelQuizPage()),
            ).then((_) {
              // 從測驗頁面返回時重新加載用戶資料
              _loadUserProfile();
            });
          },
        ),
      ],
    );
  }

  // 單個功能按鈕
  Widget _buildFunctionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }
}

