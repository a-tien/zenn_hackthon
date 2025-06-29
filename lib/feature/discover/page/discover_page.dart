import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:math' as math;
import 'discover_destinations_page.dart';
import '../../collection/pages/spot_detail_page.dart';
import '../../collection/models/favorite_spot.dart';
import '../../collection/components/add_to_itinerary_dialog.dart';
import '../../itinerary/models/destination.dart';
import '../components/add_to_collection_dialog.dart';
import '../services/places_api_service.dart';

enum SortType {
  rating,
  distance,
}

class _SpotType {
  final String label;
  final IconData icon;
  final String markerAsset;
  final List<String> keywords;
  
  const _SpotType(this.label, this.icon, this.markerAsset, this.keywords);
}

class DiscoverPage extends StatefulWidget {
  final Destination? initialDestination;

  const DiscoverPage({super.key, this.initialDestination});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  SortType _selectedSort = SortType.rating;
  bool _isMapView = true;
  Destination? _selectedDestination;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<FavoriteSpot> _currentSpots = [];
  bool _isLoadingSpots = false;
  LatLng? _currentLocation;
  Circle? _currentLocationCircle;
  final TextEditingController _searchController = TextEditingController();
  List<FavoriteSpot> _searchResults = [];  LatLng? _lastMapCenter;
  Map<String, BitmapDescriptor> _customMarkers = {};
    // 控制"探索這個區域"按鈕的顯示
  bool _showExploreButton = false;
  // 景點類型定義
  final List<_SpotType> _spotTypes = [
    _SpotType('全選', Icons.select_all, '', []),
    _SpotType('景點/觀光', Icons.location_on, 'data:image/svg+xml;base64,PCEtLSDmma/pu54v6KeA5YWJIGljb24gLS0+DQo8c3ZnIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPg0KICA8Y2lyY2xlIGN4PSIxMiIgY3k9IjEyIiByPSIxMCIgZmlsbD0iI0ZGNTcyMiIvPg0KICA8cGF0aCBkPSJNMTIgOEMxMy4xMDQ2IDggMTQgOC44OTU0MyAxNCAxMEMxNCAxMS4xMDQ2IDEzLjEwNDYgMTIgMTIgMTJDMTAuODk1NCAxMiAxMCAxMS4xMDQ2IDEwIDEwQzEwIDguODk1NDMgMTAuODk1NCA4IDEyIDhaIiBmaWxsPSJ3aGl0ZSIvPg0KICA8cGF0aCBkPSJNMTIgMTRDMTQuMjA5MSAxNCAxNiAxMi4yMDkxIDE2IDEwQzE2IDcuNzkwODYgMTQuMjA5MSA2IDEyIDZDOS43OTA4NiA2IDggNy43OTA4NiA4IDEwQzggMTIuMjA5MSA5Ljc5MDg2IDE0IDEyIDE0WiIgc3Ryb2tlPSJ3aGl0ZSIgc3Ryb2tlLXdpZHRoPSIyIiBmaWxsPSJub25lIi8+DQo8L3N2Zz4NCg==', ['tourist_attraction', 'museum', 'art_gallery', 'aquarium', 'zoo', 'stadium']),
    _SpotType('美食/餐廳', Icons.restaurant, 'data:image/svg+xml;base64,PCEtLSDppJDlu7Mv576O6aOfIGljb24gLS0+DQo8c3ZnIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPg0KICA8Y2lyY2xlIGN4PSIxMiIgY3k9IjEyIiByPSIxMCIgZmlsbD0iI0ZGQzEwNyIvPg0KICA8cGF0aCBkPSJNOC41IDlWNkM4LjUgNS43MjM4NiA4LjcyMzg2IDUuNSA5IDUuNUM5LjI3NjE0IDUuNSA5LjUgNS43MjM4NiA5LjUgNlY5SDguNVoiIGZpbGw9IndoaXRlIi8+DQogIDxwYXRoIGQ9Ik0xMC41IDlWNkMxMC41IDUuNzIzODYgMTAuNzIzOSA1LjUgMTEgNS41QzExLjI3NjEgNS41IDExLjUgNS43MjM4NiAxMS41IDZWOUgxMC41WiIgZmlsbD0id2hpdGUiLz4NCiAgPHBhdGggZD0iTTEyLjUgOVY2QzEyLjUgNS43MjM4NiAxMi43MjM5IDUuNSAxMyA1LjVDMTMuMjc2MSA1LjUgMTMuNSA1LjcyMzg2IDEzLjUgNlY5SDEyLjVaIiBmaWxsPSJ3aGl0ZSIvPg0KICA8cmVjdCB4PSI4IiB5PSI5IiB3aWR0aD0iNiIgaGVpZ2h0PSIxIiBmaWxsPSJ3aGl0ZSIvPg0KICA8cmVjdCB4PSIxMC41IiB5PSIxMCIgd2lkdGg9IjEiIGhlaWdodD0iOCIgZmlsbD0id2hpdGUiLz4NCiAgPHJlY3QgeD0iMTQuNSIgeT0iNiIgd2lkdGg9IjEiIGhlaWdodD0iNCIgZmlsbD0id2hpdGUiLz4NCiAgPHJlY3QgeD0iMTQiIHk9IjEwIiB3aWR0aD0iMiIgaGVpZ2h0PSIxIiBmaWxsPSJ3aGl0ZSIvPg0KICA8cmVjdCB4PSIxNSIgeT0iMTEiIHdpZHRoPSIxIiBoZWlnaHQ9IjciIGZpbGw9IndoaXRlIi8+DQo8L3N2Zz4NCg==', ['restaurant', 'cafe', 'bakery', 'bar', 'meal_takeaway', 'meal_delivery']),
    _SpotType('購物', Icons.shopping_bag, 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODEiIGhlaWdodD0iODMiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHhtbDpzcGFjZT0icHJlc2VydmUiIG92ZXJmbG93PSJoaWRkZW4iPjxkZWZzPjxjbGlwUGF0aCBpZD0iY2xpcDAiPjxyZWN0IHg9IjI0OTAiIHk9IjExMTAiIHdpZHRoPSI4MSIgaGVpZ2h0PSI4MyIvPjwvY2xpcFBhdGg+PC9kZWZzPjxnIGNsaXAtcGF0aD0idXJsKCNjbGlwMCkiIHRyYW5zZm9ybT0idHJhbnNsYXRlKC0yNDkwIC0xMTEwKSI+PHBhdGggZD0iTTI0OTAgMTE1MS41QzI0OTAgMTEyOC41OCAyNTA4LjEzIDExMTAgMjUzMC41IDExMTAgMjU1Mi44NyAxMTEwIDI1NzEgMTEyOC41OCAyNTcxIDExNTEuNSAyNTcxIDExNzQuNDIgMjU1Mi44NyAxMTkzIDI1MzAuNSAxMTkzIDI1MDguMTMgMTE5MyAyNDkwIDExNzQuNDIgMjQ5MCAxMTUxLjVaIiBmaWxsPSIjNzgyMDZFIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz48Zz48Zz48Zz48cGF0aCBkPSJNMzcuNzA3MiA0NS45MzMzIDM5LjE5NzkgMjIuNDE0NiA0MC43NDM3IDQyLjg5NjggMzcuNzA3MiA0NS45MzMzWk0zNC4yODQzIDQ3LjQ3OTEgMTIuMjAxIDQ3LjQ3OTEgMTQuMTMzMyAxNi41NjI1IDE2LjU2MjUgMTYuNTYyNSAxNi41NjI1IDIwLjk3OTFDMTYuNTYyNSAyMS41ODY0IDE3LjA1OTQgMjIuMDgzMyAxNy42NjY2IDIyLjA4MzMgMTguMjczOSAyMi4wODMzIDE4Ljc3MDggMjEuNTg2NCAxOC43NzA4IDIwLjk3OTFMMTguNzcwOCAxNi41NjI1IDI5LjgxMjUgMTYuNTYyNSAyOS44MTI1IDIwLjk3OTFDMjkuODEyNSAyMS41ODY0IDMwLjMwOTMgMjIuMDgzMyAzMC45MTY2IDIyLjA4MzMgMzEuNTIzOSAyMi4wODMzIDMyLjAyMDggMjEuNTg2NCAzMi4wMjA4IDIwLjk3OTFMMzIuMDIwOCAxNi41NjI1IDM2LjIxNjYgMTYuNTYyNSAzNC4yODQzIDQ3LjQ3OTFaTTE4Ljc3MDggMTEuMDQxN0MxOC43NzA4IDguNTAyMDcgMjAuNDgyMyA2LjQwNDE2IDIyLjgwMSA1Ljc0MTY2IDIxLjk3MjkgNi45NTYyNCAyMS41MzEyIDguMzkxNjYgMjEuNTMxMiA5LjkzNzQ5TDIxLjUzMTIgMTMuMjUgMTguNzcwOCAxMy4yNSAxOC43NzA4IDExLjA0MTdaTTI1LjcyNzEgNS42ODY0NUMyOC4xMDEgNi4yOTM3NCAyOS44MTI1IDguNDQ2ODcgMjkuODEyNSAxMS4wNDE3TDI5LjgxMjUgMTMuMjUgMjMuNzM5NiAxMy4yNSAyMy43Mzk2IDkuOTM3NDlDMjMuNzM5NiA4LjIyNjAzIDI0LjUxMjUgNi43MzU0MSAyNS43MjcxIDUuNjg2NDVaTTI5LjI2MDQgNC40MTY2NkMzMi4yOTY4IDQuNDE2NjYgMzQuNzgxMiA2LjkwMTAzIDM0Ljc4MTIgOS45Mzc0OUwzNC43ODEyIDEzLjI1IDMyLjAyMDggMTMuMjUgMzIuMDIwOCAxMS4wNDE3QzMyLjAyMDggOC4yODEyNCAzMC41ODU0IDUuODUyMDggMjguMzc3MSA0LjQ3MTg3IDI4LjY1MzEgNC40NzE4NyAyOC45ODQzIDQuNDE2NjYgMjkuMjYwNCA0LjQxNjY2Wk00MS45NTgzIDE1LjM0NzlDNDEuOTAzMSAxNC4xODg1IDQwLjkwOTMgMTMuMjUgMzkuNzUgMTMuMjVMMzcuMzc2IDEzLjI1QzM4LjQ4MDIgMTMuMjUgMzkuNDE4NyAxNC4wNzgxIDM5LjU4NDMgMTUuMTI3MSAzOS40MTg3IDE0LjA3ODEgMzguNTM1NCAxMy4yNSAzNy4zNzYgMTMuMjVMMzYuOTg5NSAxMy4yNSAzNi45ODk1IDkuOTM3NDlDMzYuOTg5NSA1LjY4NjQ1IDMzLjUxMTQgMi4yMDgzMyAyOS4yNjA0IDIuMjA4MzMgMjcuNzY5OCAyLjIwODMzIDI2LjM4OTYgMi42NSAyNS4yMzAyIDMuMzY3NyAyNC44OTg5IDMuMzEyNSAyNC42MjI5IDMuMzEyNSAyNC4yOTE2IDMuMzEyNSAyMC4wNDA2IDMuMzEyNSAxNi41NjI1IDYuNzkwNjIgMTYuNTYyNSAxMS4wNDE3TDE2LjU2MjUgMTMuMjUgMTMuMTM5NiAxMy4yNUMxMS45ODAyIDEzLjI1IDEwLjk4NjQgMTQuMTMzMyAxMC45MzEyIDE1LjM0NzlMOC44ODg1MyA0OC40NzI5QzguODMzMzIgNDkuNzQyNiA5LjgyNzA3IDUwLjc5MTYgMTEuMDk2OSA1MC43OTE2TDM1LjM4ODUgNTAuNzkxNiAzNi42NTgzIDUwLjc5MTZDMzcuMjY1NiA1MC43OTE2IDM3Ljg3MjkgNTAuNTE1NiAzOC4yNTkzIDUwLjA3MzlMNDMuNTA0MSA0NC44ODQzQzQzLjk0NTggNDQuNDQyNyA0NC4yMjE4IDQzLjc4MDIgNDQuMTY2NiA0My4xNzI5TDQxLjk1ODMgMTUuMzQ3OVoiIGZpbGw9IiNGRkZGRkYiIHRyYW5zZm9ybT0ibWF0cml4KDEuMDAwMDEgMCAwIDEgMjUwNCAxMTIxKSIvPjwvZz48L2c+PC9nPjwvZz48L3N2Zz4=', ['shopping_mall', 'store', 'clothing_store', 'electronics_store', 'book_store', 'jewelry_store', 'shoe_store', 'supermarket', 'convenience_store', 'department_store']),
    _SpotType('住宿', Icons.hotel, 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODIiIGhlaWdodD0iODMiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHhtbDpzcGFjZT0icHJlc2VydmUiIG92ZXJmbG93PSJoaWRkZW4iPjxkZWZzPjxjbGlwUGF0aCBpZD0iY2xpcDAiPjxyZWN0IHg9Ijk0NSIgeT0iMTA4NiIgd2lkdGg9IjgyIiBoZWlnaHQ9IjgzIi8+PC9jbGlwUGF0aD48L2RlZnM+PGcgY2xpcC1wYXRoPSJ1cmwoI2NsaXAwKSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoLTk0NSAtMTA4NikiPjxwYXRoIGQ9Ik05NDUgMTEyNy41Qzk0NSAxMTA0LjU4IDk2My4zNTYgMTA4NiA5ODYgMTA4NiAxMDA4LjY0IDEwODYgMTAyNyAxMTA0LjU4IDEwMjcgMTEyNy41IDEwMjcgMTE1MC40MiAxMDA4LjY0IDExNjkgOTg2IDExNjkgOTYzLjM1NiAxMTY5IDk0NSAxMTUwLjQyIDk0NSAxMTI3LjVaIiBmaWxsPSIjQzYyQzJDIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz48Zz48Zz48Zz48cGF0aCBkPSJNMTIuNzI5MSAyMS4wNTJDMTIuNzI5MSAyMi42NzQzIDExLjQxMzkgMjMuOTg5NCA5Ljc5MTYxIDIzLjk4OTQgOC4xNjkyOCAyMy45ODk0IDYuODU0MTMgMjIuNjc0MyA2Ljg1NDEzIDIxLjA1MiA2Ljg1NDEzIDE5LjQyOTYgOC4xNjkyOCAxOC4xMTQ1IDkuNzkxNjEgMTguMTE0NSAxMS40MTM5IDE4LjExNDUgMTIuNzI5MSAxOS40Mjk2IDEyLjcyOTEgMjEuMDUyWiIgZmlsbD0iI0ZGRkZGRiIgdHJhbnNmb3JtPSJtYXRyaXgoMS4wMjEyOSAwIDAgMSA5NjMgMTEwMykiLz48cGF0aCBkPSJNMTMuMjE4NyAyMy45ODk0IDE5LjA5MzYgMjMuOTg5NCAxOS4wOTM2IDE5LjA5MzYgMTguMTE0NSAxOS4wOTM2QzE1LjQyMTggMTkuMDkzNiAxMy4yMTg3IDIxLjI5NjggMTMuMjE4NyAyMy45ODk0WiIgZmlsbD0iI0ZGRkZGRiIgdHJhbnNmb3JtPSJtYXRyaXgoMS4wMjEyOSAwIDAgMSA5NjMgMTEwMykiLz48cGF0aCBkPSJNNDMuMDgzMSAxOS4wOTM2IDIwLjU2MjQgMTkuMDkzNiAyMC41NjI0IDMwLjg0MzZDMjAuNTYyNCAzMS45MjA3IDIxLjQ0MzYgMzIuODAxOSAyMi41MjA3IDMyLjgwMTlMNDIuMTAzOSAzMi44MDE5IDQyLjEwMzkgMzUuMjQ5OCA0NS4wNDE0IDM1LjI0OTggNDUuMDQxNCAyMS4wNTJDNDUuMDQxNCAxOS45NzQ5IDQ0LjE2MDIgMTkuMDkzNiA0My4wODMxIDE5LjA5MzZaIiBmaWxsPSIjRkZGRkZGIiB0cmFuc2Zvcm09Im1hdHJpeCgxLjAyMTI5IDAgMCAxIDk2MyAxMTAzKSIvPjxwYXRoIGQ9Ik00Ljg5NTgxIDEzLjIxODdDNC44OTU4MSAxMi4zODY0IDQuMjU5MzUgMTEuNzQ5OSAzLjQyNzA2IDExLjc0OTkgMi41OTQ3OCAxMS43NDk5IDEuOTU4MzIgMTIuMzg2NCAxLjk1ODMyIDEzLjIxODdMMS45NTgzMiAzNS4yNDk4IDQuODk1ODEgMzUuMjQ5OCA0Ljg5NTgxIDMwLjM1NCAxOS4wOTM2IDMwLjM1NCAxOS4wOTM2IDI1LjQ1ODIgNC44OTU4MSAyNS40NTgyIDQuODk1ODEgMTMuMjE4N1oiIGZpbGw9IiNGRkZGRkYiIHRyYW5zZm9ybT0ibWF0cml4KDEuMDIxMjkgMCAwIDEgOTYzIDExMDMpIi8+PC9nPjwvZz48L2c+PC9nPjwvc3ZnPg==', ['lodging', 'rv_park', 'campground']),
    _SpotType('交通', Icons.train, 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODIiIGhlaWdodD0iODMiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHhtbDpzcGFjZT0icHJlc2VydmUiIG92ZXJmbG93PSJoaWRkZW4iPjxkZWZzPjxjbGlwUGF0aCBpZD0iY2xpcDAiPjxyZWN0IHg9IjMyNDkiIHk9IjExMTAiIHdpZHRoPSI4MiIgaGVpZ2h0PSI4MyIvPjwvY2xpcFBhdGg+PC9kZWZzPjxnIGNsaXAtcGF0aD0idXJsKCNjbGlwMCkiIHRyYW5zZm9ybT0idHJhbnNsYXRlKC0zMjQ5IC0xMTEwKSI+PHBhdGggZD0iTTMyNDkgMTE1MS41QzMyNDkgMTEyOC41OCAzMjY3LjM2IDExMTAgMzI5MCAxMTEwIDMzMTIuNjQgMTExMCAzMzMxIDExMjguNTggMzMzMSAxMTUxLjUgMzMzMSAxMTc0LjQyIDMzMTIuNjQgMTE5MyAzMjkwIDExOTMgMzI2Ny4zNiAxMTkzIDMyNDkgMTE3NC40MiAzMjQ5IDExNTEuNVoiIGZpbGw9IiM0NkIxRTEiIGZpbGwtcnVsZT0iZXZlbm9kZCIvPjxnPjxnPjxnPjxwYXRoIGQ9Ik0zMzAyLjY5IDExNDcuNUMzMzAyLjY5IDExNDguMjQgMzMwMi4wOCAxMTQ4Ljg1IDMzMDEuMzMgMTE0OC44NUwzMjc5LjY3IDExNDguODVDMzI3OC45MiAxMTQ4Ljg1IDMyNzguMzEgMTE0OC4yNCAzMjc4LjMxIDExNDcuNUwzMjc4LjMxIDExMzMuOTZDMzI3OC4zMSAxMTMyLjQ3IDMyNzkuNTMgMTEzMS4yNSAzMjgxLjAyIDExMzEuMjVMMzI4Ni40NCAxMTMxLjI1QzMyODYuNDQgMTEzMC41MSAzMjg3LjA1IDExMjkuOSAzMjg3Ljc5IDExMjkuOUwzMjkzLjIxIDExMjkuOUMzMjkzLjk1IDExMjkuOSAzMjk0LjU2IDExMzAuNTEgMzI5NC41NiAxMTMxLjI1TDMyOTkuOTggMTEzMS4yNUMzMzAxLjQ3IDExMzEuMjUgMzMwMi42OSAxMTMyLjQ3IDMzMDIuNjkgMTEzMy45NkwzMzAyLjY5IDExNDcuNVpNMzMwMC42NiAxMTYzLjc1QzMyOTkuNTEgMTE2My43NSAzMjk4LjYyIDExNjIuODcgMzI5OC42MiAxMTYxLjcyIDMyOTguNjIgMTE2MC41NyAzMjk5LjUxIDExNTkuNjkgMzMwMC42NiAxMTU5LjY5IDMzMDEuODEgMTE1OS42OSAzMzAyLjY5IDExNjAuNTcgMzMwMi42OSAxMTYxLjcyIDMzMDIuNjkgMTE2Mi44NyAzMzAxLjgxIDExNjMuNzUgMzMwMC42NiAxMTYzLjc1Wk0zMjgwLjM0IDExNjMuNzVDMzI3OS4xOSAxMTYzLjc1IDMyNzguMzEgMTE2Mi44NyAzMjc4LjMxIDExNjEuNzIgMzI3OC4zMSAxMTYwLjU3IDMyNzkuMTkgMTE1OS42OSAzMjgwLjM0IDExNTkuNjkgMzI4MS40OSAxMTU5LjY5IDMyODIuMzggMTE2MC41NyAzMjgyLjM4IDExNjEuNzIgMzI4Mi4zOCAxMTYyLjg3IDMyODEuNDkgMTE2My43NSAzMjgwLjM0IDExNjMuNzVaTTMzMDEuMzMgMTEyNy4xOSAzMjkxLjg1IDExMjcuMTkgMzI5MS44NSAxMTIzLjEzIDMyOTguNjIgMTEyMy4xMyAzMjk4LjYyIDExMjAuNDIgMzI4Mi4zOCAxMTIwLjQyIDMyODIuMzggMTEyMy4xMyAzMjg5LjE1IDExMjMuMTMgMzI4OS4xNSAxMTI3LjE5IDMyNzkuNjcgMTEyNy4xOUMzMjc2LjY5IDExMjcuMTkgMzI3NC4yNSAxMTI5LjYzIDMyNzQuMjUgMTEzMi42TDMyNzQuMjUgMTE2My43NUMzMjc0LjI1IDExNjUuOTggMzI3Ni4wOCAxMTY3LjgxIDMyNzguMzEgMTE2Ny44MUwzMjc4LjkyIDExNjcuODEgMzI3NS44OCAxMTc0LjU4IDMyNzguODUgMTE3NC41OCAzMjgxLjkgMTE2Ny44MSAzMjk5LjEgMTE2Ny44MSAzMzAyLjE1IDExNzQuNTggMzMwNS4xMiAxMTc0LjU4IDMzMDIuMDggMTE2Ny44MSAzMzAyLjY5IDExNjcuODFDMzMwNC45MiAxMTY3LjgxIDMzMDYuNzUgMTE2NS45OCAzMzA2Ljc1IDExNjMuNzVMMzMwNi43NSAxMTMyLjZDMzMwNi43NSAxMTI5LjYzIDMzMDQuMzEgMTEyNy4xOSAzMzAxLjMzIDExMjcuMTlaIiBmaWxsPSIjRkZGRkZGIi8+PC9nPjwvZz48L2c+PC9nPjwvc3ZnPg==', ['train_station', 'subway_station', 'bus_station', 'light_rail_station', 'transit_station', 'airport', 'taxi_stand']),
    _SpotType('醫療/健康', Icons.local_hospital, 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODEiIGhlaWdodD0iODMiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHhtbDpzcGFjZT0icHJlc2VydmUiIG92ZXJmbG93PSJoaWRkZW4iPjxkZWZzPjxjbGlwUGF0aCBpZD0iY2xpcDAiPjxyZWN0IHg9IjE0MSIgeT0iMTA4NiIgd2lkdGg9IjgxIiBoZWlnaHQ9IjgzIi8+PC9jbGlwUGF0aD48L2RlZnM+PGcgY2xpcC1wYXRoPSJ1cmwoI2NsaXAwKSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoLTE0MSAtMTA4NikiPjxwYXRoIGQ9Ik0xNDEgMTEyNy41QzE0MSAxMTA0LjU4IDE1OS4xMzIgMTA4NiAxODEuNSAxMDg2IDIwMy44NjggMTA4NiAyMjIgMTEwNC41OCAyMjIgMTEyNy41IDIyMiAxMTUwLjQyIDIwMy44NjggMTE2OSAxODEuNSAxMTY5IDE1OS4xMzIgMTE2OSAxNDEgMTE1MC40MiAxNDEgMTEyNy41WiIgZmlsbD0iI0ZGNUQ2MSIgZmlsbC1ydWxlPSJldmVub2RkIi8+PGc+PGc+PGc+PHBhdGggZD0iTTIzLjUwMDggNS44NzQ5NyAyMy40OTk5IDUuODc0OTcgMi45Mzg0NiAyNS40MzUyIDUuMTYxMTYgMjcuMzM0OCAyMy40OTk5IDkuOTE0MDEgMjMuNTAwOCA5LjkxNDAxIDQxLjgzOTYgMjcuMzM0OCA0NC4wNjIzIDI1LjQzNTIgMjMuNTAwOCA1Ljg3NDk3WiIgZmlsbD0iI0ZGRkZGRiIgdHJhbnNmb3JtPSJtYXRyaXgoMSAwIDAgMS4wMDAwMSAxNTkgMTA5OCkiLz48cGF0aCBkPSJNMjMuNDk5OSAxMi42MTQ1IDguODEyNDUgMjYuNTY3NiA4LjgxMjQ1IDQxLjEyNDggMzguMTg3MyA0MS4xMjQ4IDM4LjE4NzMgMjYuNTY2NlpNMjMuNDk5OSAzNi45NzhDMjMuNDk5OSAzNi45NzggMTYuNjQ1NyAzMS43MzY2IDE2LjY0NTcgMjcuNTAzMiAxNi42NDU3IDI0LjY4MDcgMjAuOTU5NCAyMS42NTcxIDIzLjQ5OTkgMjYuNjk2OCAyNi4wMzk4IDIxLjY1NzEgMzAuMzU0IDI0LjY4MDcgMzAuMzU0IDI3LjUwMzIgMzAuMzU0IDMxLjczNjYgMjMuNDk5OSAzNi45NzggMjMuNDk5OSAzNi45NzhaIiBmaWxsPSIjRkZGRkZGIiB0cmFuc2Zvcm09Im1hdHJpeCgxIDAgMCAxLjAwMDAxIDE1OSAxMDk4KSIvPjwvZz48L2c+PC9nPjwvZz48L3N2Zz4=', ['hospital', 'doctor', 'dentist', 'pharmacy', 'physiotherapist', 'veterinary_care', 'beauty_salon', 'hair_care', 'spa', 'gym']),
    _SpotType('教育/宗教', Icons.school, 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODEiIGhlaWdodD0iODMiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHhtbDpzcGFjZT0icHJlc2VydmUiIG92ZXJmbG93PSJoaWRkZW4iPjxkZWZzPjxjbGlwUGF0aCBpZD0iY2xpcDAiPjxyZWN0IHg9IjI0NDYiIHk9IjI2MiIgd2lkdGg9IjgxIiBoZWlnaHQ9IjgzIi8+PC9jbGlwUGF0aD48L2RlZnM+PGcgY2xpcC1wYXRoPSJ1cmwoI2NsaXAwKSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoLTI0NDYgLTI2MikiPjxwYXRoIGQ9Ik0yNDQ2IDMwMy41QzI0NDYgMjgwLjU4IDI0NjQuMTMgMjYyIDI0ODYuNSAyNjIgMjUwOC44NyAyNjIgMjUyNyAyODAuNTggMjUyNyAzMDMuNSAyNTI3IDMyNi40MiAyNTA4Ljg3IDM0NSAyNDg2LjUgMzQ1IDI0NjQuMTMgMzQ1IDI0NDYgMzI2LjQyIDI0NDYgMzAzLjVaIiBmaWxsPSIjQzA0RjE1IiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz48Zz48Zz48Zz48cGF0aCBkPSJNMjQ3My44MyAzMDMuNzA0IDI0NzMuODMgMzEwLjA0MkMyNDczLjgzIDMxMy4wMjEgMjQ4MC42IDMxNiAyNDg5IDMxNiAyNDk3LjQgMzE2IDI1MDQuMTcgMzEzLjAyMSAyNTA0LjE3IDMxMC4wNDJMMjUwNC4xNyAzMDMuNzA0IDI0ODkgMzA5LjA2NyAyNDczLjgzIDMwMy43MDRaIiBmaWxsPSIjRkZGRkZGIi8+PHBhdGggZD0iTTI0ODkgMzA2LjczOCAyNTEyLjYyIDI5OC40NSAyNDg5IDI5MCAyNDY1LjM4IDI5OC40NSAyNDY4LjQyIDI5OS41MzMgMjQ2OC40MiAzMDkuNUMyNDY4LjQyIDMxMC4wOTYgMjQ2OC45IDMxMC41ODMgMjQ2OS41IDMxMC41ODMgMjQ3MC4xIDMxMC41ODMgMjQ3MC41OCAzMTAuMDk2IDI0NzAuNTggMzA5LjVMMjQ3MC41OCAzMDAuMjkyIDI0ODkgMzA2LjczOFoiIGZpbGw9IiNGRkZGRkYiLz48L2c+PC9nPjwvZz48L2c+PC9zdmc+', ['school', 'primary_school', 'secondary_school', 'university', 'library', 'church', 'mosque', 'synagogue', 'hindu_temple']),
    _SpotType('服務/金融', Icons.business, 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODEiIGhlaWdodD0iODMiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHhtbDpzcGFjZT0icHJlc2VydmUiIG92ZXJmbG93PSJoaWRkZW4iPjxkZWZzPjxjbGlwUGF0aCBpZD0iY2xpcDAiPjxyZWN0IHg9IjE2ODUiIHk9IjExMTAiIHdpZHRoPSI4MSIgaGVpZ2h0PSI4MyIvPjwvY2xpcFBhdGg+PC9kZWZzPjxnIGNsaXAtcGF0aD0idXJsKCNjbGlwMCkiIHRyYW5zZm9ybT0idHJhbnNsYXRlKC0xNjg1IC0xMTEwKSI+PHBhdGggZD0iTTE2ODUgMTE1MS41QzE2ODUgMTEyOC41OCAxNzAzLjEzIDExMTAgMTcyNS41IDExMTAgMTc0Ny44NyAxMTEwIDE3NjYgMTEyOC41OCAxNzY2IDExNTEuNSAxNzY2IDExNzQuNDIgMTc0Ny44NyAxMTkzIDE3MjUuNSAxMTkzIDE3MDMuMTMgMTE5MyAxNjg1IDExNzQuNDIgMTY4NSAxMTUxLjVaIiBmaWxsPSIjOEVEOTczIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz48Zz48Zz48Zz48cGF0aCBkPSJNMTcyMy4wNSAxMTM3LjcxQzE3MjMuMDUgMTEzNi4zNCAxNzI0LjEzIDExMzUuMjYgMTcyNS41IDExMzUuMjYgMTcyNi44NyAxMTM1LjI2IDE3MjcuOTUgMTEzNi4zNCAxNzI3Ljk1IDExMzcuNzEgMTcyNy45NSAxMTM3Ljc2IDE3MjcuOTUgMTEzNy44MSAxNzI3Ljk1IDExMzcuODYgMTcyNy4xNiAxMTM3Ljc2IDE3MjYuMzMgMTEzNy43MSAxNzI1LjUgMTEzNy43MSAxNzI0LjY3IDExMzcuNzEgMTcyMy44OCAxMTM3Ljc2IDE3MjMuMDUgMTEzNy44NiAxNzIzLjA1IDExMzcuODEgMTcyMy4wNSAxMTM3Ljc2IDE3MjMuMDUgMTEzNy43MVpNMTcyOS44NiAxMTM4LjI1QzE3MjkuODYgMTEzOC4wNSAxNzI5LjkxIDExMzcuOSAxNzI5LjkxIDExMzcuNzEgMTcyOS45MSAxMTM1LjI2IDE3MjcuOTUgMTEzMy4zIDE3MjUuNSAxMTMzLjMgMTcyMy4wNSAxMTMzLjMgMTcyMS4wOSAxMTM1LjI2IDE3MjEuMDkgMTEzNy43MSAxNzIxLjA5IDExMzcuOSAxNzIxLjA5IDExMzguMDUgMTcyMS4xNCAxMTM4LjI1IDE3MTIuOTcgMTE0MC4yMSAxNzA2LjkgMTE0Ny41NSAxNzA2LjkgMTE1Ni4zMUwxNzQ0LjEgMTE1Ni4zMUMxNzQ0LjEgMTE0Ny41NSAxNzM4LjAzIDExNDAuMjEgMTcyOS44NiAxMTM4LjI1WiIgZmlsbD0iI0ZGRkZGRiIvPjxwYXRoIGQ9Ik0xNzA1LjkyIDExNTguMjcgMTcwNS45MiAxMTU5LjI1QzE3MDUuOTIgMTE2MC4zMyAxNzA2LjggMTE2MS4yMSAxNzA3Ljg3IDExNjEuMjFMMTc0My4xMiAxMTYxLjIxQzE3NDQuMiAxMTYxLjIxIDE3NDUuMDggMTE2MC4zMyAxNzQ1LjA4IDExNTkuMjVMMTc0NS4wOCAxMTU4LjI3IDE3MDUuOTIgMTE1OC4yN1oiIGZpbGw9IiNGRkZGRkYiLz48L2c+PC9nPjwvZz48L2c+PC9zdmc+', ['bank', 'atm', 'post_office', 'insurance_agency', 'real_estate_agency', 'lawyer', 'travel_agency']),
    _SpotType('娛樂/夜生活', Icons.nightlife, 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODIiIGhlaWdodD0iODMiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHhtbDpzcGFjZT0icHJlc2VydmUiIG92ZXJmbG93PSJoaWRkZW4iPjxnIHRyYW5zZm9ybT0idHJhbnNsYXRlKC0zMjQ5IC0yNjUpIj48cGF0aCBkPSJNMzI0OSAzMDYuNUMzMjQ5IDI4My41OCAzMjY3LjM2IDI2NSAzMjkwIDI2NSAzMzEyLjY0IDI2NSAzMzMxIDI4My41OCAzMzMxIDMwNi41IDMzMzEgMzI5LjQyIDMzMTIuNjQgMzQ4IDMyOTAgMzQ4IDMyNjcuMzYgMzQ4IDMyNDkgMzI5LjQyIDMyNDkgMzA2LjVaIiBmaWxsPSIjRDg2RUNDIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz48Zz48Zz48Zz48cGF0aCBkPSJNMzI4MC45MyAyOTkuNjA0IDMzMDkuMTMgMjk0LjYxIDMzMDcuNzYgMjg2Ljg3NSAzMjY5LjIzIDI5My43MjkgMzI3MC41IDMwMC45MjYgMzI3MC42IDMyMC4xNjdDMzI3MC42IDMyMS4yNDQgMzI3MS40OCAzMjIuMTI1IDMyNzIuNTYgMzIyLjEyNUwzMzA3LjgxIDMyMi4xMjVDMzMwOC44OSAzMjIuMTI1IDMzMDkuNzcgMzIxLjI0NCAzMzA5Ljc3IDMyMC4xNjdMMzMwOS43NyAyOTkuNjA0IDMyODAuOTMgMjk5LjYwNFpNMzMwMi45MSAyODkuNzE0IDMzMDYuMTkgMjg5LjEyNyAzMzA2LjI5IDI4OS43MTQgMzMwMy42IDI5My41MzMgMzI5OS43OCAyOTQuMjY4IDMzMDIuOTEgMjg5LjcxNFpNMzI5NC45OCAyOTEuMTM0IDMyOTguODUgMjkwLjQ0OSAzMjk1LjY3IDI5NS4wMDIgMzI5MS44IDI5NS42ODcgMzI5NC45OCAyOTEuMTM0Wk0zMjg3IDI5Mi41NTQgMzI5MC44NyAyOTEuODY5IDMyODcuNjkgMjk2LjQyMiAzMjgzLjgyIDI5Ny4xMDcgMzI4NyAyOTIuNTU0Wk0zMjc5LjA3IDI5My45NzQgMzI4Mi45NCAyOTMuMjg4IDMyNzkuNzYgMjk3Ljg0MiAzMjc1Ljg5IDI5OC41MjcgMzI3OS4wNyAyOTMuOTc0Wk0zMjc0Ljk2IDI5NC43MDggMzI3Mi4xMiAyOTguNzcyIDMyNzEuNDggMjk1LjI5NiAzMjc0Ljk2IDI5NC43MDhaTTMzMDEuOTQgMzExLjg0NCAzMjc4LjQ0IDMxMS44NDQgMzI3OC40NCAzMDUuOTY5IDMzMDEuOTQgMzA1Ljk2OSAzMzAxLjk0IDMxMS44NDRaIiBmaWxsPSIjRkZGRkZGIi8+PC9nPjwvZz48L2c+PC9nPjwvc3ZnPg==', ['movie_theater', 'night_club', 'casino', 'bowling_alley']),
    _SpotType('汽車服務', Icons.car_repair, 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODEiIGhlaWdodD0iODMiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHhtbDpzcGFjZT0icHJlc2VydmUiIG92ZXJmbG93PSJoaWRkZW4iPjxnIHRyYW5zZm9ybT0idHJhbnNsYXRlKC0xNjg1IC0yNjUpIj48cGF0aCBkPSJNMTY4NSAzMDYuNUMxNjg1IDI4My41OCAxNzAzLjEzIDI2NSAxNzI1LjUgMjY1IDE3NDcuODcgMjY1IDE3NjYgMjgzLjU4IDE3NjYgMzA2LjUgMTc2NiAzMjkuNDIgMTc0Ny44NyAzNDggMTcyNS41IDM0OCAxNzAzLjEzIDM0OCAxNjg1IDMyOS40MiAxNjg1IDMwNi41WiIgZmlsbD0iIzAwQjA1MCIgZmlsbC1ydWxlPSJldmVub2RkIi8+PGc+PGc+PGc+PHBhdGggZD0iTTE3MzYuMDcgMjg5LjE4NSAxNzM3LjA5IDI4Ny40MTcgMTc0MC42MyAyODcuNDE3QzE3MzkuNjcgMjg1LjI4MyAxNzM3LjE2IDI4NC4zMyAxNzM1LjAzIDI4NS4yODggMTczNC4yMSAyODUuNjU2IDE3MzMuNTMgMjg2LjI3NiAxNzMzLjA4IDI4Ny4wNTdMMTcxNy44MiAyODcuMDU3QzE3MTYuNjUgMjg1LjAzNCAxNzE0LjA2IDI4NC4zNDQgMTcxMi4wMyAyODUuNTE2IDE3MTEuMjcgMjg1Ljk1OCAxNzEwLjY3IDI4Ni42MjYgMTcxMC4zIDI4Ny40MjdMMTcxMy44MyAyODcuNDE3IDE3MTQuODMgMjg5LjE4NSAxNzEzLjgxIDI5MC45NTIgMTcxMC4yNyAyOTAuOTUyQzE3MTEuMjMgMjkzLjA4NiAxNzEzLjc0IDI5NC4wMzkgMTcxNS44NyAyOTMuMDgxIDE3MTYuNjkgMjkyLjcxMyAxNzE3LjM3IDI5Mi4wOTMgMTcxNy44MiAyOTEuMzEyTDE3MzMuMDggMjkxLjMxMkMxNzM0LjI2IDI5My4zMzYgMTczNi44NSAyOTQuMDI1IDE3MzguODcgMjkyLjg1MiAxNzM5LjYzIDI5Mi40MTEgMTc0MC4yNCAyOTEuNzQzIDE3NDAuNiAyOTAuOTQyTDE3MzcuMDYgMjkwLjk0MloiIGZpbGw9IiNGRkZGRkYiLz48cGF0aCBkPSJNMTczOS4xMiAzMTEuMzkyQzE3MzkuMTIgMzExLjkzIDE3MzguNjggMzEyLjM2NyAxNzM4LjE0IDMxMi4zNjhMMTczNS4yMiAzMTIuMzY4QzE3MzQuNjggMzEyLjM2OCAxNzM0LjI0IDMxMS45MzEgMTczNC4yNCAzMTEuMzkyTDE3MzQuMjQgMzEwLjQxNkMxNzM0LjI0IDMwOS44NzYgMTczNC42OCAzMDkuNDM5IDE3MzUuMjIgMzA5LjQzOUwxNzM4LjE0IDMwOS40MzlDMTczOC42OCAzMDkuNDQxIDE3MzkuMTIgMzA5Ljg3NyAxNzM5LjEyIDMxMC40MTZMMTczOS4xMiAzMTEuMzkyWk0xNzEzLjg4IDMwNi41MSAxNzE2LjcxIDI5OS43NzNDMTcxNi44NiAyOTkuNDE5IDE3MTcuMjEgMjk5LjE4OCAxNzE3LjYgMjk5LjE4NUwxNzMzLjIxIDI5OS4xODVDMTczMy42IDI5OS4xODggMTczMy45NSAyOTkuNDE5IDE3MzQuMSAyOTkuNzczTDE3MzcuMDIgMzA2LjUxWk0xNzE2LjY2IDMxMS4zOTJDMTcxNi42NiAzMTEuOTMgMTcxNi4yMyAzMTIuMzY2IDE3MTUuNjkgMzEyLjM2OEwxNzEyLjc2IDMxMi4zNjhDMTcxMi4yMiAzMTIuMzY2IDE3MTEuNzggMzExLjkzIDE3MTEuNzggMzExLjM5MkwxNzExLjc4IDMxMC40MTZDMTcxMS43OCAzMDkuODc3IDE3MTIuMjIgMzA5LjQ0MSAxNzEyLjc2IDMwOS40MzlMMTcxNS42OSAzMDkuNDM5QzE3MTYuMjMgMzA5LjQ0MSAxNzE2LjY2IDMwOS44NzcgMTcxNi42NiAzMTAuNDE2TDE3MTYuNjYgMzExLjM5MlpNMTcxNy42NCAyOTcuMjM0QzE3MTYuNDYgMjk3LjIyMiAxNzE1LjM5IDI5Ny45NDEgMTcxNC45NiAyOTkuMDQxTDE3MTEuNzggMzA2LjUxQzE3MTAuMTcgMzA2LjUxNSAxNzA4Ljg2IDMwNy44MjMgMTcwOC44NSAzMDkuNDM5TDE3MDguODUgMzE3LjI1QzE3MDguODYgMzE4LjMyNyAxNzA5LjczIDMxOS4yIDE3MTAuODEgMzE5LjIwM0wxNzExLjc4IDMxOS4yMDMgMTcxMS43OCAzMjIuNjJDMTcxMS43OSAzMjMuNjk3IDE3MTIuNjYgMzI0LjU3IDE3MTMuNzQgMzI0LjU3M0wxNzE0LjcxIDMyNC41NzNDMTcxNS43OSAzMjQuNTcgMTcxNi42NiAzMjMuNjk3IDE3MTYuNjcgMzIyLjYyTDE3MTYuNjcgMzE5LjIwMyAxNzM0LjI0IDMxOS4yMDMgMTczNC4yNCAzMjIuNjJDMTczNC4yNSAzMjMuNjk2IDE3MzUuMTIgMzI0LjU2OCAxNzM2LjE5IDMyNC41NzNMMTczNy4xNyAzMjQuNTczQzE3MzguMjUgMzI0LjU3IDE3MzkuMTIgMzIzLjY5NyAxNzM5LjEyIDMyMi42MkwxNzM5LjEyIDMxOS4yMDMgMTc0MC4xIDMxOS4yMDNDMTc0MS4xOCAzMTkuMiAxNzQyLjA1IDMxOC4zMjcgMTc0Mi4wNSAzMTcuMjVMMTc0Mi4wNSAzMDkuNDM5QzE3NDIuMDUgMzA3LjgyMyAxNzQwLjc0IDMwNi41MTUgMTczOS4xMiAzMDYuNTFMMTczOS4xMiAzMDYuNTEgMTczNS45NSAyOTkuMDQxQzE3MzUuNTEgMjk3Ljk0MSAxNzM0LjQ1IDI5Ny4yMjIgMTczMy4yNiAyOTcuMjM0WiIgZmlsbD0iI0ZGRkZGRiIvPjwvZz48L2c+PC9nPjwvZz48L3N2Zz4=', ['gas_station', 'car_dealer', 'car_rental', 'car_repair', 'car_wash', 'parking']),
    _SpotType('其他服務', Icons.build, 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODMiIGhlaWdodD0iODMiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHhtbDpzcGFjZT0icHJlc2VydmUiIG92ZXJmbG93PSJoaWRkZW4iPjxnIHRyYW5zZm9ybT0idHJhbnNsYXRlKC0xMjQ1IC0xMzEzKSI+PHBhdGggZD0iTTEzMjggMTM1NC41QzEzMjggMTM3Ny40MiAxMzA5LjQyIDEzOTYgMTI4Ni41IDEzOTYgMTI2My41OCAxMzk2IDEyNDUgMTM3Ny40MiAxMjQ1IDEzNTQuNSAxMjQ1IDEzMzEuNTggMTI2My41OCAxMzEzIDEyODYuNSAxMzEzIDEzMDkuNDIgMTMxMyAxMzI4IDEzMzEuNTggMTMyOCAxMzU0LjVaIiBmaWxsPSIjN0Y3RjdGIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz48Zz48Zz48Zz48cGF0aCBkPSJNMjkuOTg2OCA2LjI0OTk4QzE2Ljg3NjkgNi4yNDk2NCA2LjI0OTA3IDE2Ljg3NjkgNi4yNDg3MyAyOS45ODY4IDYuMjQ4MzkgNDMuMDk2NiAxNi44NzU3IDUzLjcyNDQgMjkuOTg1NSA1My43MjQ4IDQzLjA5NTQgNTMuNzI1MSA1My43MjMzIDQzLjA5NzkgNTMuNzIzNiAyOS45ODggNTMuNzIzNiAyOS45ODcyIDUzLjcyMzYgMjkuOTg2MyA1My43MjM2IDI5Ljk4NTUgNTMuNzI4OCAxNi44ODE5IDQzLjExMDQgNi4yNTUxNyAzMC4wMDY4IDYuMjQ5OTggMzAuMDAwMSA2LjI0OTk3IDI5Ljk5MzUgNi4yNDk5NyAyOS45ODY4IDYuMjQ5OThaTTMyLjQ0MyA0Mi43OTc0QzMyLjE3ODYgNDMuNDE1NSAzMS42ODYxIDQzLjkwOCAzMS4wNjggNDQuMTcyNCAzMC43NTAxIDQ0LjMwNzYgMzAuNDA3OSA0NC4zNzY1IDMwLjA2MjQgNDQuMzc0OSAyOS4zNzI2IDQ0LjM3NjIgMjguNzEwNSA0NC4xMDM1IDI4LjIyMTggNDMuNjE2NyAyNy45ODYgNDMuMzgwNiAyNy43OTc1IDQzLjEwMTcgMjcuNjY2MiA0Mi43OTQ5IDI3LjUzMDIgNDIuNDc2NyAyNy40NjExIDQyLjEzNCAyNy40NjMgNDEuNzg4IDI3LjQ2MTMgNDEuMDk3OCAyNy43MzQzIDQwLjQzNTQgMjguMjIxOCAzOS45NDY3IDI5LjIzMjQgMzguOTMzNSAzMC44NzMxIDM4LjkzMTMgMzEuODg2MyAzOS45NDE5IDMxLjg4OCAzOS45NDM2IDMxLjg4OTUgMzkuOTQ1MSAzMS44OTExIDM5Ljk0NjdMMzEuODkxMSAzOS45NDY3QzMyLjEyODIgNDAuMTg0NyAzMi4zMTY5IDQwLjQ2NjQgMzIuNDQ2OCA0MC43NzYxIDMyLjU4MjEgNDEuMDk2MiAzMi42NTEzIDQxLjQ0MDQgMzIuNjQ5OSA0MS43ODggMzIuNjUwNyA0Mi4xMzQ3IDMyLjU4MDMgNDIuNDc3OCAzMi40NDMgNDIuNzk2MVpNMzQuNjQ5OSAzMS44MjI0QzMyLjk0MjYgMzIuODUxOSAzMS44ODgzIDM0LjY5MDIgMzEuODYxOCAzNi42ODM2TDI4LjExMTggMzYuNjgzNkMyOC4xMzQxIDMzLjQgMjkuODUxNSAzMC4zNjEgMzIuNjUzIDI4LjY0OCAzNS4wMDE1IDI3LjE3NTggMzUuNzExOSAyNC4wNzg2IDM0LjIzOTcgMjEuNzMwMSAzMi43Njc1IDE5LjM4MTYgMjkuNjcwMyAxOC42NzEzIDI3LjMyMTggMjAuMTQzNCAyNS44NTcgMjEuMDYxNyAyNC45Njc5IDIyLjY2OTIgMjQuOTY4NyAyNC4zOThMMjEuMjE4NyAyNC4zOThDMjEuMjE2OSAxOS41NTUyIDI1LjE0MTIgMTUuNjI3OCAyOS45ODQxIDE1LjYyNiAzNC44MjY5IDE1LjYyNDIgMzguNzU0MyAxOS41NDg2IDM4Ljc1NjEgMjQuMzkxNCAzOC43NTcyIDI3LjQwOTcgMzcuMjA2MSAzMC4yMTYzIDM0LjY0OTkgMzEuODIxMVoiIGZpbGw9IiNGRkZGRkYiIHRyYW5zZm9ybT0ibWF0cml4KDEuMDE2NjcgMCAwIDEgMTI1NyAxMzI1KSIvPjwvZz48L2c+PC9nPjwvZz48L3N2Zz4=', ['electrician', 'plumber', 'locksmith', 'painter', 'roofing_contractor', 'moving_company', 'storage', 'laundry']),  ];
  
  Set<int> _selectedTypeIndexes = {1, 2}; // 預設選擇前兩個：景點/觀光、美食/餐廳

  // 預設位置：札幌市中心
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(43.0642, 141.3469),
    zoom: 12.0,
  );
  @override
  void initState() {
    super.initState();
    
    // 設置初始目的地（如果有提供）
    if (widget.initialDestination != null) {
      print('🎯 DiscoverPage 收到初始目的地: ${widget.initialDestination!.name}');
      _selectedDestination = widget.initialDestination;
      
      // 延遲移動到目的地，確保地圖控制器已初始化
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _waitForMapAndMoveToDestination();
      });
    } else {
      print('🗺️ DiscoverPage 沒有收到初始目的地，使用預設位置');
    }
    
    _loadCustomMarkers();
    _loadSpots();
  }
  
  // 等待地圖控制器初始化並移動到目的地
  void _waitForMapAndMoveToDestination() async {
    if (_selectedDestination != null) {
      // 等待地圖控制器初始化
      while (_mapController == null) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // 額外延遲確保地圖完全載入
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (_mapController != null && _selectedDestination != null) {
        _moveToDestination(_selectedDestination!);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 根據類別獲取對應圖標
  IconData _getIconForCategory(String category) {
    String lowerCategory = category.toLowerCase();
    
    for (int i = 1; i < _spotTypes.length; i++) {
      final spotType = _spotTypes[i];
      if (spotType.keywords.any((keyword) => lowerCategory.contains(keyword.toLowerCase()))) {
        return spotType.icon;
      }
    }
    return Icons.location_on; // 預設圖標
  }

  // 根據類別獲取對應的 marker asset 路徑
  String _getMarkerAssetForCategory(String category) {
    String lowerCategory = category.toLowerCase();
    
    for (int i = 1; i < _spotTypes.length; i++) {
      final spotType = _spotTypes[i];
      if (spotType.keywords.any((keyword) => lowerCategory.contains(keyword.toLowerCase()))) {
        return spotType.markerAsset;
      }
    }
    return 'icons/attraction_marker.svg'; // 預設圖標
  }

  // 獲取過濾後的景點列表
  List<FavoriteSpot> get _filteredSpots {
    final spots = _searchResults.isNotEmpty ? _searchResults : _currentSpots;
    print('[DEBUG] 所有景點類型:');
    for (var s in spots) {
      print('${s.name} - ${s.category}');
    }
    // 如果選中全選，返回所有景點
    if (_selectedTypeIndexes.contains(0)) {
      return spots;
    }
    
    // 獲取所有選中類型的關鍵字
    Set<String> selectedKeywords = {};
    for (int index in _selectedTypeIndexes) {
      if (index < _spotTypes.length) {
        selectedKeywords.addAll(_spotTypes[index].keywords);
      }
    }

    print('選取類型: $selectedKeywords');
    print('景點類型: ${spots.map((e) => e.category).toList()}');

    
    // 過濾景點
    return spots.where((spot) {
      String lowerCategory = spot.category.toLowerCase();
      return selectedKeywords.any((keyword) => lowerCategory.contains(keyword.toLowerCase()));    }).toList();
  }

  Future<void> _loadCustomMarkers() async {
    for (final spotType in _spotTypes) {
      if (spotType.markerAsset.isNotEmpty) {
        try {
          final markerIcon = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(48, 48)),
            spotType.markerAsset,
          );
          _customMarkers[spotType.markerAsset] = markerIcon;
        } catch (e) {
          print('Error loading marker asset ${spotType.markerAsset}: $e');
        }
      }
    }
    // 確保預設 marker 也被加載
    if (!_customMarkers.containsKey('icons/attraction_marker.svg')) {
       try {
          final defaultIcon = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(48, 48)),
            'icons/attraction_marker.svg',
          );
          _customMarkers['icons/attraction_marker.svg'] = defaultIcon;
        } catch (e) {
          print('Error loading default marker asset: $e');
        }
    }
  }  void _loadSpots() async {
    setState(() {
      _isLoadingSpots = true;
    });

    try {
      // 根據選中的類別獲取要查詢的類型
      List<String> selectedTypes = [];
      
      if (_selectedTypeIndexes.contains(0)) {
        // 如果選中全選，獲取所有類型
        selectedTypes = _spotTypes
            .skip(1) // 跳過「全選」
            .expand((type) => type.keywords)
            .where((keyword) => [
              'tourist_attraction', 'restaurant', 'cafe', 'shopping_mall',
              'hospital', 'bank', 'gas_station', 'hotel', 'museum',
              'store', 'lodging', 'train_station', 'subway_station',
              'bus_station', 'airport', 'doctor', 'dentist', 'pharmacy',
              'school', 'university', 'library', 'church', 'atm',
              'post_office', 'movie_theater', 'night_club', 'car_dealer',
              'car_rental', 'car_repair', 'car_wash', 'parking'
            ].contains(keyword))
            .toSet()
            .toList();
      } else {
        // 根據選中的類別獲取對應的關鍵字
        for (int index in _selectedTypeIndexes) {
          if (index < _spotTypes.length) {
            final spotType = _spotTypes[index];
            final validKeywords = spotType.keywords.where((keyword) => [
              'tourist_attraction', 'restaurant', 'cafe', 'shopping_mall',
              'hospital', 'bank', 'gas_station', 'hotel', 'museum',
              'store', 'lodging', 'train_station', 'subway_station',
              'bus_station', 'airport', 'doctor', 'dentist', 'pharmacy',
              'school', 'university', 'library', 'church', 'atm',
              'post_office', 'movie_theater', 'night_club', 'car_dealer',
              'car_rental', 'car_repair', 'car_wash', 'parking'
            ].contains(keyword)).toList();
            selectedTypes.addAll(validKeywords);
          }
        }
        selectedTypes = selectedTypes.toSet().toList(); // 去重
      }
      
      List<FavoriteSpot> spots = [];
        if (_selectedDestination != null && 
          _selectedDestination!.latitude != null && 
          _selectedDestination!.longitude != null) {
        // 使用 API 獲取該地區的指定類型景點
        print('🌍 正在從API獲取 ${_selectedDestination!.name} 附近的景點...');
        print('🎯 搜尋類型: $selectedTypes');
        
        // 如果有地圖控制器，使用可見範圍計算半徑，否則使用固定半徑
        final radius = _mapController != null 
            ? (await getRadiusFromVisibleRegion()).round()
            : 15000;
            
        spots = await PlacesApiService.searchNearbyPlacesMultipleTypes(
          latitude: _selectedDestination!.latitude!,
          longitude: _selectedDestination!.longitude!,
          radius: radius,
          types: selectedTypes,
        );
        print('📍 API 返回 ${spots.length} 個景點，搜尋半徑: ${radius}m');
      } else {
        // 沒有選擇目的地時，使用預設位置（札幌）搜尋
        print('🌍 正在從API獲取札幌附近的景點...');
        print('🎯 搜尋類型: $selectedTypes');
        
        // 如果有地圖控制器，使用可見範圍計算半徑，否則使用固定半徑
        final radius = _mapController != null 
            ? (await getRadiusFromVisibleRegion()).round()
            : 15000;
            
        spots = await PlacesApiService.searchNearbyPlacesMultipleTypes(
          latitude: 43.0642, // 札幌市中心
          longitude: 141.3469,
          radius: radius,
          types: selectedTypes,
        );        
        print('📍 API 返回 ${spots.length} 個景點，搜尋半徑: ${radius}m');
      }

      setState(() {
        _currentSpots = spots;
        _isLoadingSpots = false;
        _showExploreButton = false; // 重置探索按鈕狀態
      });
      
      _initializeMarkers();
    } catch (e) {
      print('❌ 載入景點時發生錯誤: $e');      setState(() {
        _currentSpots = [];
        _isLoadingSpots = false;
        _showExploreButton = false; // 重置探索按鈕狀態
      });
      _initializeMarkers();
      
      // 顯示錯誤訊息給用戶
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('載入景點失敗，請檢查網路連線'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  void _initializeMarkers() {
    final filteredSpots = _filteredSpots;
  
    setState(() {
      _markers = filteredSpots.map((spot) {
        final markerAsset = _getMarkerAssetForCategory(spot.category);
        final customIcon = _customMarkers[markerAsset];

        return Marker(
          markerId: MarkerId(spot.id),
          position: LatLng(spot.latitude, spot.longitude),
          icon: customIcon ?? BitmapDescriptor.defaultMarker, // 如果自訂圖標加載失敗，使用預設圖標
          infoWindow: InfoWindow(
            title: spot.name,
            snippet: '⭐ ${spot.rating}\n點擊查看詳細資訊',
            onTap: () {
              _showSpotDetailsWithApi(spot);
            },
          ),
        );
      }).toSet();
    });
    
  }

  // void _showSpotDetails(FavoriteSpot spot) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => DraggableScrollableSheet(
  //       initialChildSize: 0.4,
  //       minChildSize: 0.2,
  //       maxChildSize: 0.8,
  //       builder: (context, scrollController) => Container(
  //         decoration: const BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //         ),
  //         child: SingleChildScrollView(
  //           controller: scrollController,
  //           child: Padding(
  //             padding: const EdgeInsets.all(16),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // 拖拽指示器
  //                 Center(
  //                   child: Container(
  //                     width: 40,
  //                     height: 4,
  //                     decoration: BoxDecoration(
  //                       color: Colors.grey[300],
  //                       borderRadius: BorderRadius.circular(2),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 16),
                  
  //                 // 景點信息
  //                 Row(
  //                   children: [
  //                     Expanded(
  //                       child: Text(
  //                         spot.name,
  //                         style: const TextStyle(
  //                           fontSize: 20,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ),
  //                     Row(
  //                       children: [
  //                         const Icon(Icons.star, color: Colors.amber, size: 18),
  //                         const SizedBox(width: 4),
  //                         Text(
  //                           spot.rating.toString(),
  //                           style: const TextStyle(fontWeight: FontWeight.w600),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
                  
  //                 const SizedBox(height: 8),
                  
  //                 Text(
  //                   spot.address,
  //                   style: TextStyle(
  //                     color: Colors.grey[600],
  //                     fontSize: 14,
  //                   ),
  //                 ),
                  
  //                 const SizedBox(height: 12),
                  
  //                 Text(
  //                   spot.description,
  //                   style: const TextStyle(fontSize: 14),
  //                   maxLines: 3,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
                  
  //                 const SizedBox(height: 16),
                  
  //                 // 按鈕
  //                 Row(
  //                   children: [
  //                     Expanded(
  //                       child: OutlinedButton.icon(
  //                         onPressed: () {
  //                           Navigator.pop(context);
  //                           showDialog(
  //                             context: context,
  //                             builder: (context) => AddToCollectionDialog(spot: spot),
  //                           );
  //                         },
  //                         icon: const Icon(Icons.bookmark_add, size: 16),
  //                         label: const Text('加入收藏'),
  //                         style: OutlinedButton.styleFrom(
  //                           foregroundColor: Colors.blueAccent,
  //                           side: const BorderSide(color: Colors.blueAccent),
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 12),
  //                     Expanded(
  //                       child: ElevatedButton.icon(
  //                         onPressed: () {
  //                           Navigator.pop(context);
  //                           showDialog(
  //                             context: context,
  //                             builder: (context) => AddToItineraryDialog(spot: spot),
  //                           );
  //                         },
  //                         icon: const Icon(Icons.add, size: 16),
  //                         label: const Text('加入行程'),
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.blueAccent,
  //                           foregroundColor: Colors.white,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
                  
  //                 const SizedBox(height: 8),
                  
  //                 // 查看詳情按鈕
  //                 SizedBox(
  //                   width: double.infinity,
  //                   child: TextButton(
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                       Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                           builder: (context) => SpotDetailPage(spot: spot),
  //                         ),
  //                       );
  //                     },
  //                     child: const Text('查看詳細資訊'),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),          ),
  //       ),
  //     ),
  //   );
  // }

  void _navigateToSelectArea() async {
    final result = await Navigator.push<Destination>(
      context,
      MaterialPageRoute(builder: (context) => const DiscoverDestinationsPage()),
    );

    if (result != null) {
      setState(() {
        _selectedDestination = result;
      });
      
      // 重新加載該地區的景點
      _loadSpots();
      
      // 如果在地圖視圖，移動到選擇的目的地
      if (_isMapView && _mapController != null) {
        _moveToDestination(result);
      }
    }
  }
  void _moveToDestination(Destination destination) {
    if (destination.latitude != null && destination.longitude != null) {
      final position = CameraPosition(
        target: LatLng(destination.latitude!, destination.longitude!),
        zoom: 12.0,
      );
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(position),
      );
    }
  }

  void _showSortOptions() async {
    SortType tempSort = _selectedSort;
    SortType? result = await showDialog<SortType>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('推薦排序'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<SortType>(
                title: const Text('評論 (高→低)'),
                value: SortType.rating,
                groupValue: tempSort,
                onChanged: (value) {
                  setState(() {
                    tempSort = value!;
                  });
                },
              ),
              RadioListTile<SortType>(
                title: const Text('距離 (近→遠)'),
                value: SortType.distance,
                groupValue: tempSort,
                onChanged: (value) {
                  setState(() {
                    tempSort = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, tempSort),
              child: const Text('確定'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedSort = result;
      });
    }
  }
  // 獲取示例景點數據
  // List<FavoriteSpot> _getExampleSpots() {
  //   // 所有景點的完整列表
  //   final allSpots = [
  //     // 札幌景點
  //     FavoriteSpot(
  //       id: 'spot_hokudai_001',
  //       name: '北海道大學',
  //       imageUrl: 'https://images.weserv.nl/?url=daigakujc.jp/smart_phone/top_img/00038/2.jpg',
  //       address: '日本北海道札幌市北區北8条西5丁目',
  //       rating: 4.5,
  //       reviewCount: 1250,        description: '北海道大學是日本最著名的大學之一，校園內有美麗的白樺林道和古色古香的建築。秋季時紅葉環繞，景色特別美麗。',
  //       category: 'tourist_attraction',
  //       openingHours: '全天開放，建築內部需遵守各建築開放時間',
  //       website: 'https://www.hokudai.ac.jp/',
  //       phone: '+81-11-716-2111',
  //       latitude: 43.0770474,
  //       longitude: 141.3408576,
  //       addedAt: DateTime.now(),
  //     ),
  //     FavoriteSpot(
  //       id: 'spot_sapporo_tv_tower',
  //       name: '札幌電視塔',
  //       imageUrl: 'https://images.unsplash.com/photo-1610948237719-5386e03f6d65?auto=format&fit=crop&w=300&q=80',
  //       address: '日本北海道札幌市中央區大通西1丁目',
  //       rating: 4.2,
  //       reviewCount: 890,        description: '札幌的地標建築，可以俯瞰整個大通公園和札幌市區的美景。',
  //       category: 'tourist_attraction',
  //       openingHours: '09:00-22:00',
  //       website: 'https://www.tv-tower.co.jp/',
  //       phone: '+81-11-241-1131',
  //       latitude: 43.0609,
  //       longitude: 141.3565,
  //       addedAt: DateTime.now(),
  //     ),      FavoriteSpot(
  //       id: 'spot_sapporo_ramen',
  //       name: '拉麵橫丁',
  //       imageUrl: 'https://images.unsplash.com/photo-1584858574980-cee28babf9cb?auto=format&fit=crop&w=300&q=80',
  //       address: '日本北海道札幌市中央區薄野',
  //       rating: 4.6,
  //       reviewCount: 2100,
  //       description: '札幌著名的拉麵街，匯集了多家知名拉麵店。',
  //       category: 'restaurant',
  //       openingHours: '11:00-02:00（各店舖時間不同）',
  //       website: '',
  //       phone: '',
  //       latitude: 43.0546,
  //       longitude: 141.3534,
  //       addedAt: DateTime.now(),
  //     ),
      
  //     // 東京景點
  //     FavoriteSpot(
  //       id: 'spot_tokyo_tower',
  //       name: '東京鐵塔',
  //       imageUrl: 'https://images.unsplash.com/photo-1513407030348-c983a97b98d8?auto=format&fit=crop&w=300&q=80',
  //       address: '日本東京都港區芝公園4丁目2-8',
  //       rating: 4.4,
  //       reviewCount: 2150,
  //       description: '東京的象徵性地標，高333公尺的紅白色鐵塔，可俯瞰東京全景。',
  //       category: '景點',
  //       openingHours: '09:00-23:00',
  //       website: 'https://www.tokyotower.co.jp/',
  //       phone: '+81-3-3433-5111',
  //       latitude: 35.6586,
  //       longitude: 139.7454,
  //       addedAt: DateTime.now(),
  //     ),
  //     FavoriteSpot(
  //       id: 'spot_senso_ji',
  //       name: '淺草寺',
  //       imageUrl: 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?auto=format&fit=crop&w=300&q=80',
  //       address: '日本東京都台東區淺草2丁目3-1',
  //       rating: 4.6,
  //       reviewCount: 3200,
  //       description: '東京最古老的佛教寺廟，擁有千年歷史，雷門和仲見世通商店街聞名於世。',
  //       category: '景點',
  //       openingHours: '06:00-17:00',
  //       website: '',
  //       phone: '',
  //       latitude: 35.7148,
  //       longitude: 139.7967,
  //       addedAt: DateTime.now(),
  //     ),
      
  //     // 大阪景點
  //     FavoriteSpot(
  //       id: 'spot_osaka_castle',
  //       name: '大阪城',
  //       imageUrl: 'https://images.unsplash.com/photo-1590736969955-71cc94901144?auto=format&fit=crop&w=300&q=80',
  //       address: '日本大阪府大阪市中央區大阪城1-1',
  //       rating: 4.5,
  //       reviewCount: 1890,
  //       description: '日本三大名城之一，豐臣秀吉建造的歷史名城，櫻花季節尤其美麗。',
  //       category: '景點',
  //       openingHours: '09:00-17:00',
  //       website: 'https://www.osakacastle.net/',
  //       phone: '+81-6-6941-3044',
  //       latitude: 34.6873,
  //       longitude: 135.5262,
  //       addedAt: DateTime.now(),
  //     ),
  //     FavoriteSpot(
  //       id: 'spot_dotonbori',
  //       name: '道頓堀',
  //       imageUrl: 'https://images.unsplash.com/photo-1589452271712-64b8a66c7b64?auto=format&fit=crop&w=300&q=80',
  //       address: '日本大阪府大阪市中央區道頓堀',
  //       rating: 4.3,
  //       reviewCount: 2450,
  //       description: '大阪最熱鬧的商業區，以美食和霓虹燈招牌聞名，是體驗大阪夜生活的絕佳地點。',
  //       category: '景點',
  //       openingHours: '全天開放',
  //       website: '',
  //       phone: '',
  //       latitude: 34.6688,
  //       longitude: 135.5017,
  //       addedAt: DateTime.now(),
  //     ),
  //     FavoriteSpot(
  //       id: 'spot_tanuki_shopping',
  //       name: '狸小路商店街',
  //       imageUrl: 'https://images.unsplash.com/photo-1591793826788-ae2ce68cca7c?auto=format&fit=crop&w=300&q=80',
  //       address: '日本北海道札幌市中央區南2条西～南3条西',
  //       rating: 4.1,
  //       reviewCount: 850,
  //       description: '札幌最古老的商店街，有各種商店和美食。',
  //       category: 'shopping_mall',
  //       openingHours: '10:00-22:00（各店舖時間不同）',
  //       website: '',
  //       phone: '',
  //       latitude: 43.0570,
  //       longitude: 141.3538,
  //       addedAt: DateTime.now(),
  //     ),
  //     FavoriteSpot(
  //       id: 'spot_maruyama_park',
  //       name: '圓山公園',
  //       imageUrl: 'https://images.unsplash.com/photo-1522383225653-ed111181a951?auto=format&fit=crop&w=300&q=80',
  //       address: '日本北海道札幌市中央區宮之森',
  //       rating: 4.4,
  //       reviewCount: 1200,
  //       description: '札幌著名的櫻花賞花地點，春季時滿山櫻花盛開。',
  //       category: 'park',
  //       openingHours: '全天開放',
  //       website: '',
  //       phone: '',
  //       latitude: 43.0540,
  //       longitude: 141.3180,
  //       addedAt: DateTime.now(),
  //     ),
  //     FavoriteSpot(
  //       id: 'spot_hokkaido_museum',
  //       name: '北海道博物館',
  //       imageUrl: 'https://images.unsplash.com/photo-1566127992631-137a642a90f4?auto=format&fit=crop&w=300&q=80',
  //       address: '日本北海道札幌市厚別區厚別町小野幌53-2',
  //       rating: 4.2,
  //       reviewCount: 650,
  //       description: '展示北海道的自然與歷史文化的綜合博物館。',
  //       category: 'museum',
  //       openingHours: '09:30-17:00（週一休館）',
  //       website: 'http://www.hm.pref.hokkaido.lg.jp/',
  //       phone: '+81-11-898-0466',
  //       latitude: 43.0205,
  //       longitude: 141.4619,
  //       addedAt: DateTime.now(),
  //     ),
  //     FavoriteSpot(
  //       id: 'spot_sapporo_station',
  //       name: '札幌車站',
  //       imageUrl: 'https://images.unsplash.com/photo-1544640647-1f040a83de37?auto=format&fit=crop&w=300&q=80',
  //       address: '日本北海道札幌市北區北6条西4丁目',
  //       rating: 4.0,
  //       reviewCount: 2500,
  //       description: '札幌的主要交通樞紐，連接JR線和地下鐵。',
  //       category: 'train_station',
  //       openingHours: '全天開放',
  //       website: '',
  //       phone: '',
  //       latitude: 43.0683,
  //       longitude: 141.3507,
  //       addedAt: DateTime.now(),
  //     ),
  //     FavoriteSpot(
  //       id: 'spot_sapporo_cafe',
  //       name: '札幌咖啡館',
  //       imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=300&q=80',
  //       address: '日本北海道札幌市中央區大通西3丁目',
  //       rating: 4.3,
  //       reviewCount: 420,        description: '溫馨的咖啡館，提供精品咖啡和手工甜點。',
  //       category: 'cafe',
  //       openingHours: '08:00-20:00',
  //       website: '',
  //       phone: '+81-11-222-3333',
  //       latitude: 43.0595,
  //       longitude: 141.3520,
  //       addedAt: DateTime.now(),
  //     ),
  //     FavoriteSpot(
  //       id: 'spot_sushi_restaurant',
  //       name: '札幌壽司店',
  //       imageUrl: 'https://images.unsplash.com/photo-1559925393-8be0ec4767c8?auto=format&fit=crop&w=300&q=80',
  //       address: '日本北海道札幌市中央區薄野南4丁目',
  //       rating: 4.7,
  //       reviewCount: 890,
  //       description: '新鮮的北海道海鮮壽司，品質優良。',
  //       category: 'restaurant',
  //       openingHours: '17:00-23:00',
  //       website: '',
  //       phone: '+81-11-555-7777',
  //       latitude: 43.0520,
  //       longitude: 141.3560,
  //       addedAt: DateTime.now(),
  //     ),
  //     FavoriteSpot(
  //       id: 'spot_sapporo_hospital',
  //       name: '札幌市立醫院',
  //       imageUrl: 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=300&q=80',
  //       address: '日本北海道札幌市中央區北11条西13丁目',
  //       rating: 4.0,
  //       reviewCount: 150,
  //       description: '札幌主要的綜合醫院，提供全面的醫療服務。',
  //       category: 'hospital',
  //       openingHours: '08:00-17:00（急診24小時）',
  //       website: '',
  //       phone: '+81-11-726-2211',
  //       latitude: 43.0745,
  //       longitude: 141.3350,
  //       addedAt: DateTime.now(),
  //     ),
  //     FavoriteSpot(
  //       id: 'spot_sapporo_bank',
  //       name: '北洋銀行本店',
  //       imageUrl: 'https://images.unsplash.com/photo-1541354329998-f4d9a9f9297f?auto=format&fit=crop&w=300&q=80',
  //       address: '日本北海道札幌市中央區大通西3丁目',
  //       rating: 3.8,
  //       reviewCount: 85,
  //       description: '北海道地區主要銀行之一。',
  //       category: 'bank',
  //       openingHours: '09:00-15:00（週末休息）',
  //       website: '',
  //       phone: '+81-11-261-1311',
  //       latitude: 43.0610,
  //       longitude: 141.3530,
  //       addedAt: DateTime.now(),
  //     ),
  //     FavoriteSpot(
  //       id: 'spot_gas_station',
  //       name: 'ENEOS加油站',
  //       imageUrl: 'https://images.unsplash.com/photo-1545558014-8692077e9b5c?auto=format&fit=crop&w=300&q=80',
  //       address: '日本北海道札幌市中央區南1条西10丁目',
  //       rating: 3.5,
  //       reviewCount: 45,
  //       description: '24小時營業的加油站，提供各種汽車服務。',
  //       category: 'gas_station',
  //       openingHours: '24小時營業',
  //       website: '',
  //       phone: '+81-11-222-3344',
  //       latitude: 43.0580,
  //       longitude: 141.3450,
  //       addedAt: DateTime.now(),
  //     ),
  //   ];

  //   // 根據選擇的目的地過濾景點
  //   if (_selectedDestination == null) {
  //     return allSpots; // 顯示所有景點
  //   }

  //   // 根據目的地過濾景點
  //   switch (_selectedDestination!.id) {
  //     case 'sapporo':
  //       return allSpots.where((spot) => 
  //         spot.address.contains('札幌') || spot.address.contains('北海道')).toList();
  //     case 'tokyo':
  //       return allSpots.where((spot) => 
  //         spot.address.contains('東京')).toList();
  //     case 'osaka':
  //       return allSpots.where((spot) => 
  //         spot.address.contains('大阪')).toList();
  //     default:
  //       return allSpots; // 其他地區暫時顯示所有景點
  //   }
  // }

  Future<void> _showCurrentLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    if (_locationData.latitude != null && _locationData.longitude != null) {
      setState(() {
        _currentLocation = LatLng(_locationData.latitude!, _locationData.longitude!);
        _currentLocationCircle = Circle(
          circleId: const CircleId('current_location'),
          center: _currentLocation!,
          radius: 30,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        );
      });
      if (_isMapView && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentLocation!),
        );
      }
    }
  }
  // 根據地圖可見範圍計算搜尋半徑
  Future<double> getRadiusFromVisibleRegion() async {
    if (_mapController == null) return 3000;
    
    try {
      final visibleRegion = await _mapController!.getVisibleRegion();
      
      // 計算可見區域的對角線距離
      final northEast = visibleRegion.northeast;
      final southWest = visibleRegion.southwest;
      
      // 使用 Haversine 公式計算距離（公里）
      final distance = _calculateDistance(
        southWest.latitude, southWest.longitude,
        northEast.latitude, northEast.longitude,
      );
      
      // 取可見區域對角線的一半作為搜尋半徑，轉換為公尺
      // 限制最小 500m，最大 50km
      final radiusKm = (distance / 2).clamp(0.5, 50.0);
      final radiusMeters = radiusKm * 1000;
      
      print('🗺️ 可見區域對角線: ${distance.toStringAsFixed(2)}km, 搜尋半徑: ${radiusMeters.toInt()}m');
      
      return radiusMeters;
    } catch (e) {
      print('❌ 計算可見區域失敗: $e');
      // 降級使用 zoom level
      final zoom = await _mapController!.getZoomLevel();
      return getRadiusFromZoom(zoom);
    }
  }

  // 降級方案：根據 zoom level 計算半徑
  double getRadiusFromZoom(double zoom) {
    if (zoom >= 16) return 500;
    if (zoom >= 14) return 1000;
    if (zoom >= 12) return 2000;
    if (zoom >= 10) return 5000;
    if (zoom >= 8) return 10000;
    return 20000; // 更大的視圖範圍
  }

  // Haversine 公式計算兩點間距離（公里）
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // 地球半徑（公里）
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  void _onMapCameraIdle() async {
    if (_mapController == null) return;

    final size = MediaQuery.of(context).size;
    final screenCenter = ScreenCoordinate(
      x: (size.width / 2).round(),
      y: (size.height / 2).round(),
    );

    final center = await _mapController!.getLatLng(screenCenter);

    // 避免重複處理相同位置
    if (_lastMapCenter != null &&
        (center.latitude - _lastMapCenter!.latitude).abs() < 0.001 &&
        (center.longitude - _lastMapCenter!.longitude).abs() < 0.001) {
      return;
    }

    // 如果已經加載過數據且移動了地圖，顯示探索按鈕
    if (_currentSpots.isNotEmpty && _lastMapCenter != null) {
      setState(() {
        _showExploreButton = true;
      });
    }    _lastMapCenter = center;
  }  // 新增方法：探索當前區域
  void _exploreCurrentArea() async {
    if (_mapController == null || _lastMapCenter == null) return;

    // 優先使用可見區域計算半徑，降級使用 zoom level
    final radius = await getRadiusFromVisibleRegion();

    setState(() {
      _isLoadingSpots = true;
      _showExploreButton = false; // 隱藏按鈕
    });// 依據使用者選擇的類別，決定要查詢的 Google types
    List<String> selectedTypes = [];
    
    if (_selectedTypeIndexes.contains(0)) {
      // 如果選中全選，獲取所有類型
      selectedTypes = _spotTypes
          .skip(1) // 跳過「全選」
          .expand((type) => type.keywords)
          .where((keyword) => [
            'tourist_attraction', 'restaurant', 'cafe', 'shopping_mall',
            'hospital', 'bank', 'gas_station', 'hotel', 'museum',
            'store', 'lodging', 'train_station', 'subway_station',
            'bus_station', 'airport', 'doctor', 'dentist', 'pharmacy',
            'school', 'university', 'library', 'church', 'atm',
            'post_office', 'movie_theater', 'night_club', 'car_dealer',
            'car_rental', 'car_repair', 'car_wash', 'parking'
          ].contains(keyword))
          .toSet()
          .toList();
    } else {
      // 根據選中的類別獲取對應的關鍵字
      for (int index in _selectedTypeIndexes) {
        if (index < _spotTypes.length) {
          final spotType = _spotTypes[index];
          final validKeywords = spotType.keywords.where((keyword) => [
            'tourist_attraction', 'restaurant', 'cafe', 'shopping_mall',
            'hospital', 'bank', 'gas_station', 'hotel', 'museum',
            'store', 'lodging', 'train_station', 'subway_station',
            'bus_station', 'airport', 'doctor', 'dentist', 'pharmacy',
            'school', 'university', 'library', 'church', 'atm',
            'post_office', 'movie_theater', 'night_club', 'car_dealer',
            'car_rental', 'car_repair', 'car_wash', 'parking'
          ].contains(keyword)).toList();
          selectedTypes.addAll(validKeywords);
        }
      }
      selectedTypes = selectedTypes.toSet().toList(); // 去重
    }
    
    print('🎯 將搜尋 ${selectedTypes.length} 種類型: $selectedTypes');

    try {      final spots = await PlacesApiService.searchNearbyPlacesMultipleTypes(
        latitude: _lastMapCenter!.latitude,
        longitude: _lastMapCenter!.longitude,
        radius: radius.round(),
        types: selectedTypes,
      );

      setState(() {
        _currentSpots = spots;
        _isLoadingSpots = false;
      });

      _initializeMarkers();
      
      // 顯示成功訊息
      if (mounted && spots.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('找到 ${spots.length} 個景點'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error fetching nearby places: $e');
      setState(() => _isLoadingSpots = false);
      
      // 顯示錯誤訊息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('載入景點失敗，請檢查網路連線或稍後再試'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _onSearchChanged(String value) async {
    if (value.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showExploreButton = false; // 重置探索按鈕狀態
      });
      return;
    }
    final spots = await PlacesApiService.searchPlacesByText(
      query: value,
      latitude: _currentLocation?.latitude,
      longitude: _currentLocation?.longitude,
      radius: 3000,
    );
    setState(() {
      _searchResults = spots;
      _showExploreButton = false; // 重置探索按鈕狀態
    });
  }
  Future<void> _showSpotDetailsWithApi(FavoriteSpot spot) async {
    // 直接導航到景點詳細頁面，而不是使用 modal
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpotDetailPage(spot: spot),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 主內容區 - 全螢幕，移除top padding
          Positioned.fill(
            child: _isMapView ? _buildMapView() : _buildListView(),
          ),

          // 搜尋欄 - 懸浮在地圖上
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: _buildSearchBar(),
          ),

          // 地圖/列表切換按鈕
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(              onPressed: () {
                setState(() {
                  _isMapView = !_isMapView;
                });
                
                // 如果切換到地圖視圖且有選擇目的地，稍後移動到該位置
                if (_isMapView && _selectedDestination != null) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (_mapController != null) {
                      _moveToDestination(_selectedDestination!);
                    }
                  });
                }
              },
              backgroundColor: Colors.blueAccent,
              child: Icon(_isMapView ? Icons.list : Icons.map),
            ),
          ),

          // 現在地點按鈕（在切換按鈕上方）
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'current_location_btn',
              onPressed: _showCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blueAccent),
            ),
          ),
        ],      ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Row(
            children: [
              // 地區選擇按鈕（左邊）
              TextButton.icon(
                onPressed: _navigateToSelectArea,
                icon: const Icon(Icons.place, color: Colors.blueAccent),
                label: Text(
                  _selectedDestination?.name ?? '選地區',
                  style: const TextStyle(color: Colors.blueAccent),
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              // 搜尋框（右邊）
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: '搜尋地點、美食、景點',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),        ),
        const SizedBox(height: 12),
        _buildTypeSelector(),        // 探索這個區域按鈕
        if (_showExploreButton && _isMapView)
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _isLoadingSpots ? null : _exploreCurrentArea,
                icon: _isLoadingSpots 
                    ? const SizedBox(
                        width: 18, 
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.explore, size: 18),
                label: Text(_isLoadingSpots ? '載入中...' : '探索這個區域'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLoadingSpots ? Colors.grey : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ),
      ],
    );
  }
  Widget _buildTypeSelector() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.transparent, // 移除白色背景
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _spotTypes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final spotType = _spotTypes[index];
          final isSelected = _selectedTypeIndexes.contains(index);
          
          return GestureDetector(
            onTap: () {              setState(() {
                if (index == 0) {
                  // 點擊全選
                  _selectedTypeIndexes = {0};
                } else {
                  // 點擊其他類型
                  if (_selectedTypeIndexes.contains(index)) {
                    _selectedTypeIndexes.remove(index);
                    if (_selectedTypeIndexes.isEmpty) {
                      _selectedTypeIndexes = {0};
                    }
                  } else {
                    _selectedTypeIndexes.remove(0);
                    _selectedTypeIndexes.add(index);
                  }
                }
                _showExploreButton = false; // 重置探索按鈕狀態
              });
              _initializeMarkers(); // 更新地圖標記
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    spotType.icon,
                    color: isSelected ? Colors.white : Colors.blueAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    spotType.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
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

  Widget _buildMapView() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        
        // 如果選擇了特定目的地，移動到該位置
        if (_selectedDestination != null) {
          _moveToDestination(_selectedDestination!);
        }
      },
      initialCameraPosition: _selectedDestination != null &&
              _selectedDestination!.latitude != null &&
              _selectedDestination!.longitude != null
          ? CameraPosition(
              target: LatLng(_selectedDestination!.latitude!, _selectedDestination!.longitude!),
              zoom: 12.0,
            )
          : _initialPosition,
      markers: _markers,
      circles: _currentLocationCircle != null ? {_currentLocationCircle!} : {},
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      mapType: MapType.normal,
      zoomControlsEnabled: false,
      compassEnabled: false,
      trafficEnabled: false,      buildingsEnabled: true,
      onCameraIdle: _onMapCameraIdle,
    );
  }

  Widget _buildListView() {
    // 使用過濾後的景點
    final spots = _filteredSpots;
    if (_selectedSort == SortType.rating) {
      spots.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      // 這裡可以根據實際距離排序，暫時使用名稱排序
      spots.sort((a, b) => a.name.compareTo(b.name));
    }

    return SafeArea(
      child: _isLoadingSpots
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(top: 140, left: 16, right: 16, bottom: 16), // 增加top padding避免被搜尋欄遮擋
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDestination != null 
                        ? "${_selectedDestination!.name}推薦景點"
                        : "推薦景點",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                    ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showSortOptions,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...spots.map((spot) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildSpotCard(spot),
          )),
          if (spots.isEmpty)
            const Center(
              child: Text('沒有推薦的景點', style: TextStyle(color: Colors.grey)),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSpotCard(FavoriteSpot spot) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _showSpotDetailsWithApi(spot);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 圖片
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  spot.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    );
                  },
                ),
              ),
            ),
            
            // 內容
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [                  // 標題和評分
                  Row(
                    children: [
                      Icon(
                        _getIconForCategory(spot.category),
                        color: Colors.blueAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          spot.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            spot.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // 地址
                  Text(
                    spot.address,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                    const SizedBox(height: 8),
                  
                  // 分類
                  Text(
                    spot.category,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 按鈕
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddToCollectionDialog(spot: spot),
                            );
                          },
                          icon: const Icon(Icons.bookmark_add, size: 16),
                          label: const Text('加入收藏'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blueAccent,
                            side: const BorderSide(color: Colors.blueAccent),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddToItineraryDialog(spot: spot),
                            );
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('加入行程'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
