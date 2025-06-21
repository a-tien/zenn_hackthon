import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/destination_service.dart';

class SelectDestinationsPage extends StatefulWidget {
  final List<Destination> initialSelectedDestinations;

  const SelectDestinationsPage({
    super.key,
    this.initialSelectedDestinations = const [],
  });

  @override
  State<SelectDestinationsPage> createState() => _SelectDestinationsPageState();
}

class _SelectDestinationsPageState extends State<SelectDestinationsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _popularTabController;
  final TextEditingController _searchController = TextEditingController();
  
  List<Destination> _selectedDestinations = [];
  List<Destination> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _popularTabController = TabController(length: 2, vsync: this);
    _selectedDestinations = List.from(widget.initialSelectedDestinations);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _popularTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        _searchResults = DestinationService.searchDestinations(query);
      }
    });
  }

  void _toggleDestination(Destination destination) {
    setState(() {
      if (_selectedDestinations.contains(destination)) {
        _selectedDestinations.remove(destination);
      } else {
        _selectedDestinations.add(destination);
      }
    });
  }

  void _removeDestination(Destination destination) {
    setState(() {
      _selectedDestinations.remove(destination);
    });
  }

  void _saveAndReturn() {
    Navigator.pop(context, _selectedDestinations);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('選擇目的地'),
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
          // 搜尋框
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜尋目的地...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),

          // 內容區域
          Expanded(
            child: _isSearching ? _buildSearchResults() : _buildTabContent(),
          ),

          // 已選擇的目的地標籤
          if (_selectedDestinations.isNotEmpty) _buildSelectedDestinations(),

          // 儲存按鈕
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAndReturn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '儲存 (${_selectedDestinations.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return Column(
      children: [
        // 主要頁籤列
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blueAccent,
            tabs: const [
              Tab(text: '熱門地點'),
              Tab(text: '探索地點'),
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
          final isSelected = _selectedDestinations.contains(destination);
          
          return GestureDetector(
            onTap: () => _toggleDestination(destination),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.blueAccent : Colors.transparent,
                  width: 2,
                ),
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
                  
                  // 選中指示器
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
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
          final isSelected = _selectedDestinations.contains(destination);
          
          return GestureDetector(
            onTap: () => _toggleDestination(destination),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.blueAccent : Colors.transparent,
                  width: 2,
                ),
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
                  
                  // 選中指示器
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
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
              final isSelected = _selectedDestinations.contains(destination);
              return ListTile(
                title: Text(destination.name),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.blueAccent)
                    : null,
                onTap: () => _toggleDestination(destination),
                tileColor: isSelected ? Colors.blue[50] : null,
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
              final isSelected = _selectedDestinations.contains(destination);
              return ListTile(
                title: Text(destination.name),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.blueAccent)
                    : null,
                onTap: () => _toggleDestination(destination),
                tileColor: isSelected ? Colors.blue[50] : null,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final destination = _searchResults[index];
        final isSelected = _selectedDestinations.contains(destination);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(destination.name),
            subtitle: Text(destination.displayName),
            trailing: isSelected
                ? const Icon(Icons.check, color: Colors.blueAccent)
                : null,
            onTap: () => _toggleDestination(destination),
            tileColor: isSelected ? Colors.blue[50] : null,
          ),
        );
      },
    );
  }

  Widget _buildSelectedDestinations() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '已選擇的目的地 (${_selectedDestinations.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedDestinations.map((destination) {
              return Chip(
                label: Text(destination.name),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeDestination(destination),
                backgroundColor: Colors.blue[50],
                deleteIconColor: Colors.grey[600],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
