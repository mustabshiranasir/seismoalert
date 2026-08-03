import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quake.dart';

class UsgsApiException implements Exception {
  final String message;
  UsgsApiException(this.message);

  @override
  String toString() => 'UsgsApiException: $message';
}

class UsgsService {
  static const String _baseUrl = 'https://earthquake.usgs.gov/fdsnws/event/1/query';

  Future<List<Quake>> fetchRecentQuakes({
    required double lat,
    required double lon,
    double radiusKm = 1000,
    int limit = 50,
  }) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'format': 'geojson',
        'latitude': lat.toString(),
        'longitude': lon.toString(),
        'maxradiuskm': radiusKm.toString(),
        'limit': limit.toString(),
        'orderby': 'time',
      });

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw UsgsApiException('Failed to fetch recent earthquakes. Server responded with status code ${response.statusCode}.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>? ?? [];

      return features.map((f) => Quake.fromJson(f as Map<String, dynamic>)).toList();
    } on http.ClientException catch (e) {
      throw UsgsApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is UsgsApiException) rethrow;
      throw UsgsApiException('An unexpected error occurred: $e');
    }
  }

  Future<List<Quake>> fetchQuakesOnDate({
    required DateTime date,
    required double lat,
    required double lon,
    double radiusKm = 1000,
  }) async {
    try {
      final start = DateTime(date.year, date.month, date.day);
      final end = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'format': 'geojson',
        'latitude': lat.toString(),
        'longitude': lon.toString(),
        'maxradiuskm': radiusKm.toString(),
        'starttime': start.toUtc().toIso8601String(),
        'endtime': end.toUtc().toIso8601String(),
        'orderby': 'time',
      });

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw UsgsApiException('Failed to fetch earthquakes on date. Server responded with status code ${response.statusCode}.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>? ?? [];

      return features.map((f) => Quake.fromJson(f as Map<String, dynamic>)).toList();
    } on http.ClientException catch (e) {
      throw UsgsApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is UsgsApiException) rethrow;
      throw UsgsApiException('An unexpected error occurred: $e');
    }
  }

  Future<List<Quake>> fetchAftershocks({
    required Quake mainQuake,
    int windowDays = 7,
    double radiusKm = 200,
  }) async {
    try {
      final endtime = mainQuake.time.add(Duration(days: windowDays));

      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'format': 'geojson',
        'latitude': mainQuake.lat.toString(),
        'longitude': mainQuake.lon.toString(),
        'maxradiuskm': radiusKm.toString(),
        'starttime': mainQuake.time.toUtc().toIso8601String(),
        'endtime': endtime.toUtc().toIso8601String(),
      });

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw UsgsApiException('Failed to fetch aftershocks. Server responded with status code ${response.statusCode}.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>? ?? [];

      return features
          .map((f) => Quake.fromJson(f as Map<String, dynamic>))
          .where((q) => q.id != mainQuake.id)
          .map((q) => q.copyWith(isPossibleAftershock: true))
          .toList();
    } on http.ClientException catch (e) {
      throw UsgsApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is UsgsApiException) rethrow;
      throw UsgsApiException('An unexpected error occurred: $e');
    }
  }
}
