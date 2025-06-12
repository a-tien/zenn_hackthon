import 'package:flutter/material.dart';
import 'widgets/section_title.dart';
import 'widgets/product_card.dart';
import 'pages/home_page.dart';
import 'pages/explore_page.dart';
import 'pages/itinerary_page.dart';
import 'pages/profile_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '旅遊推薦',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          background: Colors.white,
          primary: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'San Francisco', // Apple-like font if available
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // List of pages to display
  final List<Widget> _pages = const [
    HomePage(),
    ExplorePage(),
    ItineraryPage(),
    ProfilePage(),
  ];

  // Page titles
  final List<String> _titles = const [
    '旅遊推薦',
    '探索',
    '行程',
    '我的',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        // Only show app bar for pages other than home
        toolbarHeight: _selectedIndex == 0 ? 0 : kToolbarHeight,
      ),
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.black54,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '主頁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '探索',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '行程',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}