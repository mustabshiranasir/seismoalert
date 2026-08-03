import 'package:connectivity_plus/connectivity_plus.dart';
  import 'package:flutter/material.dart';
  import 'package:hive/hive.dart';
  import '../models/quake.dart';
  import '../services/usgs_service.dart';

class QuakeProvider with ChangeNotifier {
  final UsgsService _usgsService = UsgsService();

  List<Quake> _quakes = [];
  bool _isLoading = false;
  bool _isOffline = false;
  String? _errorMessage;
  double _selectedLat = 33.6;
  double _selectedLon = 73.0;
  double _minMagnitudeFilter = 0.0;

  QuakeProvider() {
    fetchQuakes();
  }

  List<Quake> get quakes => _quakes;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String? get errorMessage => _errorMessage;
  double get selectedLat => _selectedLat;
  double get selectedLon => _selectedLon;
  double get minMagnitudeFilter => _minMagnitudeFilter;

  List<Quake> get filteredQuakes {
    return _quakes.where((q) => q.magnitude >= _minMagnitudeFilter).toList();
  }

  Future<void> fetchQuakes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = !connectivityResult.contains(ConnectivityResult.none);

      if (isOnline) {
        try {
          final fetched = await _usgsService.fetchRecentQuakes(
            lat: _selectedLat,
            lon: _selectedLon,
          );
          _quakes = fetched;
          _isOffline = false;
          _errorMessage = null;

          // Cache to Hive
          final box = Hive.box<Quake>('quake_cache');
          await box.clear();
          await box.addAll(_quakes);
        } catch (e) {
          _errorMessage = e is UsgsApiException ? e.message : e.toString();
          _loadCachedQuakes();
          _isOffline = true;
        }
      } else {
        _loadCachedQuakes();
        _isOffline = true;
      }
    } catch (e) {
      _errorMessage = 'Connectivity error: $e';
      _loadCachedQuakes();
      _isOffline = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadCachedQuakes() {
    try {
      final box = Hive.box<Quake>('quake_cache');
      _quakes = box.values.toList();
    } catch (e) {
      _errorMessage = 'Failed to load cached data: $e';
    }
  }

  void setMagnitudeFilter(double value) {
    _minMagnitudeFilter = value;
    notifyListeners();
  }

  Future<void> setRegion(double lat, double lon) async {
    _selectedLat = lat;
    _selectedLon = lon;
    notifyListeners();
    await fetchQuakes();
  }
}
