import 'package:flutter/material.dart';
import 'feature/home/page/home_page.dart';
import 'feature/discover/page/discover_page.dart';
import 'feature/itinerary/pages/itinerary_page.dart';
import 'feature/profile/pages/profile_page.dart';
import 'feature/profile/pages/login_page.dart'; // 導入登入頁面
import 'feature/collection/services/favorite_service.dart';
import 'feature/itinerary/models/destination.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // 確保 Flutter 引擎初始化完成
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 先初始化 Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase 初始化成功');
    
    // 遷移收藏資料到新格式
    await FavoriteService.migrateLegacyFavorites();
    print('✅ 收藏資料遷移完成');
    
    print('🚀 應用程式準備啟動');
  } catch (e) {
    print('❌ 初始化失敗: $e');
    // 即使初始化失敗，也要啟動應用程式
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '旅遊推薦',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          background: Colors.white,
          primary: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'San Francisco',
      ),      // 定義路由
      routes: {
        '/': (context) => const MainNavigation(),
        '/login': (context) => const LoginPage(),
      },
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigation extends StatefulWidget {
  final int initialTab;
  final Destination? initialDestination;
  
  const MainNavigation({super.key, this.initialTab = 1, this.initialDestination});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    // 如果有初始目的地且當前選中探索標籤，傳遞給 DiscoverPage
    final shouldPassDestination = _selectedIndex == 1 && widget.initialDestination != null;
    
    if (shouldPassDestination) {
      print('🏠 MainNavigation 正在建立 DiscoverPage，傳遞目的地: ${widget.initialDestination!.name}');
    }
    
    final List<Widget> pages = [
      MyHomePage(),     // 你可以換成 HomePage()
      DiscoverPage(
        initialDestination: shouldPassDestination ? widget.initialDestination : null,
        key: shouldPassDestination 
            ? ValueKey('discover_${widget.initialDestination!.id}') 
            : const ValueKey('discover_default'),
      ),            // 探索頁（地圖頁）
      ItineraryPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 73, 138, 179),
        unselectedItemColor: Colors.black54,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '主頁'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '探索'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '行程'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}




