import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/quake.dart';
import '../services/usgs_service.dart';
import '../services/notification_service.dart';

class QuakeProvider with ChangeNotifier {
  final UsgsService _usgsService = UsgsService();
  final NotificationService _notificationService = NotificationService();

  List<Quake> _quakes = [];
  bool _isLoading = false;
  bool _isOffline = false;
  String? _errorMessage;
  double _selectedLat = 33.6;
  double _selectedLon = 73.0;
  double _minMagnitudeFilter = 0.0;
  double _alertThreshold = 5.0;

  QuakeProvider() {
    _loadPersistedSettings();
    fetchQuakes();
  }

  List<Quake> get quakes => _quakes;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String? get errorMessage => _errorMessage;
  double get selectedLat => _selectedLat;
  double get selectedLon => _selectedLon;
  double get minMagnitudeFilter => _minMagnitudeFilter;
  double get alertThreshold => _alertThreshold;

  List<Quake> get filteredQuakes {
    return _quakes.where((q) => q.magnitude >= _minMagnitudeFilter).toList();
  }

  void _loadPersistedSettings() {
    try {
      final box = Hive.box('history_cache');
      final savedThreshold = box.get('alert_threshold') as double?;
      if (savedThreshold != null) {
        _alertThreshold = savedThreshold;
      }
      final savedLat = box.get('selected_lat') as double?;
      final savedLon = box.get('selected_lon') as double?;
      if (savedLat != null && savedLon != null) {
        _selectedLat = savedLat;
        _selectedLon = savedLon;
      }
    } catch (e) {
      debugPrint('Error loading persisted settings: $e');
    }
  }

  Future<void> _persistSettings() async {
    try {
      final box = Hive.box('history_cache');
      await box.put('alert_threshold', _alertThreshold);
      await box.put('selected_lat', _selectedLat);
      await box.put('selected_lon', _selectedLon);
    } catch (e) {
      debugPrint('Error persisting settings: $e');
    }
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
          // Capture previously known IDs before fetching
          final previousIds = _quakes.map((q) => q.id).toSet();

          final fetched = await _usgsService.fetchRecentQuakes(
            lat: _selectedLat,
            lon: _selectedLon,
          );
          _isOffline = false;
          _errorMessage = null;

          // Detect new quakes and fire notifications
          if (previousIds.isNotEmpty) {
            for (final quake in fetched) {
              if (!previousIds.contains(quake.id) &&
                  quake.magnitude >= _alertThreshold) {
                _notificationService.showQuakeAlert(quake);
              }
            }
          }

          _quakes = fetched;

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

  void setAlertThreshold(double value) {
    _alertThreshold = value;
    _persistSettings();
    notifyListeners();
  }

  Future<void> setRegion(double lat, double lon) async {
    _selectedLat = lat;
    _selectedLon = lon;
    await _persistSettings();
    notifyListeners();
    await fetchQuakes();
  }
}
