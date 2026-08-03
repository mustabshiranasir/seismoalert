import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/quake.dart';
import '../services/usgs_service.dart';

class HistoryProvider with ChangeNotifier {
  final UsgsService _usgsService = UsgsService();

  Map<int, List<Quake>> _quakesByYear = {};
  bool _isLoading = false;

  Map<int, List<Quake>> get quakesByYear => _quakesByYear;
  bool get isLoading => _isLoading;

  Future<void> loadOnThisDay({
    required double lat,
    required double lon,
    int yearsBack = 10,
    bool forceRefresh = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final cacheKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final box = Hive.box('history_cache');

      if (!forceRefresh) {
        final cachedJson = box.get(cacheKey) as String?;
        if (cachedJson != null) {
          final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
          _quakesByYear = decoded.map((yearStr, listDynamic) {
            final list = (listDynamic as List<dynamic>)
                .map((item) => Quake.fromJson(item as Map<String, dynamic>))
                .toList();
            return MapEntry(int.parse(yearStr), list);
          });
          _isLoading = false;
          notifyListeners();
          return;
        }
      } else {
        await box.delete(cacheKey);
      }

      final currentYear = DateTime.now().year;
      final today = DateTime.now();

      final futures = <Future<List<Quake>>>[];
      final years = <int>[];

      for (int i = 1; i <= yearsBack; i++) {
        final targetYear = currentYear - i;
        final targetDate = DateTime(targetYear, today.month, today.day);
        years.add(targetYear);
        futures.add(
          _usgsService
              .fetchQuakesOnDate(
            date: targetDate,
            lat: lat,
            lon: lon,
          )
              .catchError((e) {
            debugPrint('Error fetching history for $targetYear: $e');
            return <Quake>[];
          }),
        );
      }

      final results = await Future.wait(futures);

      final Map<int, List<Quake>> fetchedMap = {};
      for (int i = 0; i < years.length; i++) {
        final list = results[i];
        if (list.isNotEmpty) {
          fetchedMap[years[i]] = list;
        }
      }

      _quakesByYear = fetchedMap;

      // Cache the results
      final mapToCache = _quakesByYear.map((year, list) => MapEntry(
            year.toString(),
            list.map((q) => q.toJson()).toList(),
          ));
      await box.put(cacheKey, jsonEncode(mapToCache));
    } catch (e) {
      debugPrint('Error loading historical quakes: $e');
      _quakesByYear = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
