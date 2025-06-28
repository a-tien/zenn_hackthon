import 'package:flutter/material.dart';
import '../models/itinerary.dart';
import '../services/itinerary_service.dart';
import '../../common/widgets/login_required_dialog.dart';
import 'add_itinerary_page.dart';
import 'itinerary_detail_page.dart';
import '../components/itinerary_card.dart';

class ItineraryPage extends StatefulWidget {
  const ItineraryPage({super.key});

  @override
  State<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> with WidgetsBindingObserver {
  List<Itinerary> itineraries = [];
  bool isLoading = true;
  final ItineraryService _itineraryService = ItineraryService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadItineraries();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 當應用回到前台時刷新數據
    if (state == AppLifecycleState.resumed) {
      _loadItineraries();
    }
  }

  // 公開的刷新方法，供外部調用
  void refreshItineraries() {
    _loadItineraries();
  }
  Future<void> _loadItineraries() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final loadedItineraries = await _itineraryService.getAllItineraries();
      
      setState(() {
        itineraries = loadedItineraries;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      if (e.toString().contains('需要登入')) {
        // 顯示登入提示對話框
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => LoginRequiredDialog(
              feature: '查看行程列表',
              onLoginPressed: () {
                Navigator.of(context).pop();
                // 重新載入資料
                _loadItineraries();
              },
            ),
          );
        }
        return;
      }
      
      print('載入行程列表時出錯: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入失敗: $e')),
        );
      }
    }
  }

  void _navigateToAddItinerary() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddItineraryPage()),
    );
    
    if (result == true) {
      _loadItineraries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // 行程列表或空狀態
                itineraries.isEmpty
                    ? _buildEmptyState()
                    : _buildItinerariesList(),
                    
                // 若有行程，在底部顯示固定的按鈕
                if (!isLoading && itineraries.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildCreateButton(),
                  ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, size: 80, color: Colors.blueGrey),
          const SizedBox(height: 16),
          const Text(
            "您的行程",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "目前尚無行程喔！點擊下方按鈕新增您的第一個行程。",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueGrey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 空狀態下的新增按鈕
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToAddItinerary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '建立新行程',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _navigateToAddItinerary,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '建立新行程',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildItinerariesList() {
  return ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // 底部留出空間給固定按鈕
    itemCount: itineraries.length,
    itemBuilder: (context, index) {
      final itinerary = itineraries[index];
      return ItineraryCard(
        itinerary: itinerary,
        onTap: () async {
          // 導航到行程詳情頁面
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItineraryDetailPage(itinerary: itinerary),
            ),
          );
          
          // 如果返回結果為true，則刷新行程列表
          if (result == true) {
            _loadItineraries();
          }
        },
      );
    },
  );
}
}