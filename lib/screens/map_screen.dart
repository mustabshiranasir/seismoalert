import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/quake_provider.dart';
import '../models/quake.dart';
import 'quake_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  double? _lastLat;
  double? _lastLon;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Color _getMarkerColor(double magnitude) {
    if (magnitude < 4.0) {
      return Colors.green.shade600;
    } else if (magnitude < 6.0) {
      return Colors.orange.shade600;
    } else {
      return Colors.red.shade600;
    }
  }

  void _showQuakeDetailsBottomSheet(BuildContext context, Quake quake) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getMarkerColor(quake.magnitude),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'M ${quake.magnitude.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Earthquake Alert',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  quake.place,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Time: ${DateFormat.yMMMd().add_jm().format(quake.time.toLocal())}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Depth: ${quake.depth.toStringAsFixed(1)} km',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close bottom sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuakeDetailScreen(quake: quake),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earthquake Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              final provider = Provider.of<QuakeProvider>(context, listen: false);
              _mapController.move(
                LatLng(provider.selectedLat, provider.selectedLon),
                6.0,
              );
            },
            tooltip: 'Center on Selected Region',
          ),
        ],
      ),
      body: Consumer<QuakeProvider>(
        builder: (context, provider, child) {
          final quakes = provider.filteredQuakes;

          // Sync controller movement post-frame if region changes
          if (_lastLat != provider.selectedLat || _lastLon != provider.selectedLon) {
            _lastLat = provider.selectedLat;
            _lastLon = provider.selectedLon;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _mapController.move(
                LatLng(provider.selectedLat, provider.selectedLon),
                6.0,
              );
            });
          }

          final markers = quakes.map((quake) {
            final double size = 24.0 + (quake.magnitude * 5.0);
            return Marker(
              point: LatLng(quake.lat, quake.lon),
              width: size,
              height: size,
              child: GestureDetector(
                onTap: () => _showQuakeDetailsBottomSheet(context, quake),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getMarkerColor(quake.magnitude).withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      quake.magnitude.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList();

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(provider.selectedLat, provider.selectedLon),
                  initialZoom: 6.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.seismoalert',
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),
              if (provider.isOffline)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Material(
                      elevation: 4,
                      child: Row(
                        children: [
                          Expanded(
                            child: ColoredBox(
                              color: Colors.orange,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.wifi_off, color: Colors.white, size: 16),
                                    SizedBox(width: 8),
                                    Text(
                                      "Offline Mode — Map tiles & data may not load",
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (provider.isLoading)
                const Positioned(
                  top: 16,
                  right: 16,
                  child: SafeArea(
                    bottom: false,
                    child: Card(
                      elevation: 4,
                      shape: CircleBorder(),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
