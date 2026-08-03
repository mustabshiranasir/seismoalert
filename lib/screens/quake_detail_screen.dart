import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/quake.dart';
import '../providers/aftershock_provider.dart';
import '../widgets/magnitude_badge.dart';
import '../widgets/quake_card.dart';

class QuakeDetailScreen extends StatefulWidget {
  final Quake quake;

  const QuakeDetailScreen({super.key, required this.quake});

  @override
  State<QuakeDetailScreen> createState() => _QuakeDetailScreenState();
}

class _QuakeDetailScreenState extends State<QuakeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AftershockProvider>().loadAftershocks(widget.quake);
      }
    });
  }

  @override
  void dispose() {
    context.read<AftershockProvider>().clear();
    super.dispose();
  }

  Color _getMagnitudeColor(double magnitude) {
    if (magnitude < 4.0) return Colors.green.shade600;
    if (magnitude < 6.0) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link in browser.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quake = widget.quake;
    final color = _getMagnitudeColor(quake.magnitude);
    final formattedTime =
        DateFormat('EEEE, MMMM d, yyyy — h:mm a').format(quake.time.toLocal());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earthquake Details'),
      ),
      body: ListView(
        children: [
          // ── Hero header ──────────────────────────────────────────
          Container(
            color: color.withValues(alpha: 0.12),
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            child: Column(
              children: [
                MagnitudeBadge(magnitude: quake.magnitude),
                const SizedBox(height: 16),
                Text(
                  'Magnitude ${quake.magnitude.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  quake.place,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),

          // ── Info rows ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow(
                        icon: Icons.access_time,
                        label: 'Date & Time',
                        value: formattedTime),
                    const Divider(height: 24),
                    _InfoRow(
                        icon: Icons.vertical_align_bottom,
                        label: 'Depth',
                        value: '${quake.depth.toStringAsFixed(1)} km'),
                    const Divider(height: 24),
                    _InfoRow(
                        icon: Icons.place,
                        label: 'Coordinates',
                        value:
                            '${quake.lat.toStringAsFixed(4)}, ${quake.lon.toStringAsFixed(4)}'),
                  ],
                ),
              ),
            ),
          ),

          // ── USGS button ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed:
                  quake.url.isNotEmpty ? () => _launchUrl(quake.url) : null,
              icon: const Icon(Icons.open_in_browser),
              label: const Text('View on USGS'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Mini map ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 220,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(quake.lat, quake.lon),
                    initialZoom: 7.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.seismoalert',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(quake.lat, quake.lon),
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 6,
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                quake.magnitude.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Aftershock section ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Possible Aftershocks (within 7 days)',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Consumer<AftershockProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (provider.aftershocks.isEmpty) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: Colors.green.shade600),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'No significant aftershocks detected.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: provider.aftershocks
                    .map(
                      (aftershock) => QuakeCard(
                        quake: aftershock,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  QuakeDetailScreen(quake: aftershock),
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Helper widget ─────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
