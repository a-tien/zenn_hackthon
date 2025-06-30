import 'package:flutter/material.dart';
import '../../itinerary/models/destination.dart';
import '../../itinerary/services/destination_service.dart';
import '../../../utils/app_localizations.dart';

class DiscoverDestinationsPage extends StatefulWidget {
  const DiscoverDestinationsPage({super.key});

  @override
  State<DiscoverDestinationsPage> createState() => _DiscoverDestinationsPageState();
}

class _DiscoverDestinationsPageState extends State<DiscoverDestinationsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _popularTabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _popularTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _popularTabController.dispose();
    super.dispose();
  }

  void _selectDestination(Destination destination) {
    print('🏛️ 用戶點擊了區域: ${destination.name}');
    print('📱 Widget mounted 狀態: $mounted');
    
    if (!mounted) {
      print('❌ Widget 已經被銷毀，無法返回結果');
      return;
    }
    
    print('✅ 正在返回選擇的區域...');
    Navigator.pop(context, destination);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(localizations?.selectArea ?? 'エリア選択'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 主要頁籤列
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blueAccent,
              tabs: [
                Tab(text: localizations?.popularDestinations ?? '人気の場所'),
                Tab(text: localizations?.exploreNewPlaces ?? '場所を探索'),
              ],
            ),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPopularTab(),
                _buildExploreTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularTab() {
    return Column(
      children: [
        // 國內/國外頁籤
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _popularTabController,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blueAccent,
            tabs: const [
              Tab(text: '國內'),
              Tab(text: '國外'),
            ],
          ),
        ),
        
        Expanded(
          child: TabBarView(
            controller: _popularTabController,
            children: [
              _buildPopularDomesticGrid(),
              _buildPopularInternationalGrid(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPopularDomesticGrid() {
    final destinations = DestinationService.getPopularDomesticDestinations();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: destinations.length,
        itemBuilder: (context, index) {
          final destination = destinations[index];
          
          return GestureDetector(
            onTap: () => _selectDestination(destination),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Stack(
                children: [
                  // 背景圖片
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: destination.imageUrl != null
                          ? Image.network(
                              destination.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.location_city,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.location_city,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                    ),
                  ),
                  
                  // 漸層覆蓋層
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  
                  // 城市名稱
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Text(
                      destination.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularInternationalGrid() {
    final destinations = DestinationService.getPopularInternationalDestinations();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: destinations.length,
        itemBuilder: (context, index) {
          final destination = destinations[index];
          
          return GestureDetector(
            onTap: () => _selectDestination(destination),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Stack(
                children: [
                  // 背景圖片
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: destination.imageUrl != null
                          ? Image.network(
                              destination.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.location_city,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.location_city,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                    ),
                  ),
                  
                  // 漸層覆蓋層
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  
                  // 城市名稱
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Text(
                      destination.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExploreTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // 國內/國外頁籤
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blueAccent,
              tabs: [
                Tab(text: '日本國內'),
                Tab(text: '國外'),
              ],
            ),
          ),
          
          Expanded(
            child: TabBarView(
              children: [
                _buildDomesticExploreList(),
                _buildInternationalExploreList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDomesticExploreList() {
    final destinations = DestinationService.getDomesticDestinations();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: destinations.keys.length,
      itemBuilder: (context, index) {
        final prefecture = destinations.keys.elementAt(index);
        final cities = destinations[prefecture]!;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Text(
              prefecture,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            children: cities.map((destination) {
              return ListTile(
                title: Text(destination.name),
                onTap: () => _selectDestination(destination),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildInternationalExploreList() {
    final destinations = DestinationService.getInternationalDestinations();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: destinations.keys.length,
      itemBuilder: (context, index) {
        final country = destinations.keys.elementAt(index);
        final cities = destinations[country]!;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Text(
              country,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            children: cities.map((destination) {
              return ListTile(
                title: Text(destination.name),
                onTap: () => _selectDestination(destination),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
