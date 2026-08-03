import 'package:flutter/material.dart';
import '../models/quake.dart';
import '../services/usgs_service.dart';

class AftershockProvider with ChangeNotifier {
  final UsgsService _usgsService = UsgsService();

  List<Quake> _aftershocks = [];
  bool _isLoading = false;

  List<Quake> get aftershocks => _aftershocks;
  bool get isLoading => _isLoading;

  Future<void> loadAftershocks(Quake mainQuake) async {
    _isLoading = true;
    _aftershocks = [];
    notifyListeners();

    try {
      _aftershocks = await _usgsService.fetchAftershocks(
        mainQuake: mainQuake,
        windowDays: 7,
        radiusKm: 200,
      );
    } catch (e) {
      debugPrint('Error loading aftershocks: $e');
      _aftershocks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _aftershocks = [];
    _isLoading = false;
    notifyListeners();
  }
}
