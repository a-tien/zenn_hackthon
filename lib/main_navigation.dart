import 'package:flutter/material.dart';
import 'feature/itinerary/models/destination.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '旅行プランナー', // 改為日文標題
      locale: const Locale('en', 'US'), // 暫時使用英文避免本地化衝突
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ja', ''),
        Locale('zh', 'TW'),
      ],
      // localizationsDelegates: const [
      //   AppLocalizations.delegate,
      // ],
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          background: Colors.white,
          primary: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'San Francisco',
      ),
      // 定義路由
      routes: {
        '/': (context) => const MainNavigation(),
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
    final List<Widget> pages = [
      const Center(child: Text('ホーム', style: TextStyle(fontSize: 24))),
      const Center(child: Text('発見', style: TextStyle(fontSize: 24))),
      const Center(child: Text('マイプラン', style: TextStyle(fontSize: 24))),
      const Center(child: Text('プロフィール', style: TextStyle(fontSize: 24))),
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home), 
            label: 'ホーム'
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search), 
            label: '発見'
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today), 
            label: 'マイプラン'
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person), 
            label: 'プロフィール'
          ),
        ],
      ),
    );
  }
}




