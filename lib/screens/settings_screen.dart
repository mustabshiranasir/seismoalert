import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quake_provider.dart';

class _PakistanCity {
  final String name;
  final double lat;
  final double lon;
  const _PakistanCity(this.name, this.lat, this.lon);
}

const _cities = [
  _PakistanCity('Islamabad', 33.6844, 73.0479),
  _PakistanCity('Karachi', 24.8607, 67.0011),
  _PakistanCity('Lahore', 31.5204, 74.3587),
  _PakistanCity('Peshawar', 34.0150, 71.5249),
  _PakistanCity('Quetta', 30.1798, 66.9750),
];

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<QuakeProvider>(
        builder: (context, provider, _) {
          // Identify active city (if any matches current coords)
          _PakistanCity? activeCity;
          for (final city in _cities) {
            if ((city.lat - provider.selectedLat).abs() < 0.01 &&
                (city.lon - provider.selectedLon).abs() < 0.01) {
              activeCity = city;
              break;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Region Selection ────────────────────────────────────
              _SectionHeader(
                icon: Icons.location_on_outlined,
                title: 'Region',
                subtitle: 'Select a city to load nearby earthquakes',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _cities.map((city) {
                  final isSelected = city == activeCity;
                  return ChoiceChip(
                    label: Text(city.name),
                    selected: isSelected,
                    selectedColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    onSelected: (_) async {
                      await provider.setRegion(city.lat, city.lon);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Region switched to ${city.name}. Fetching quakes…'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
              if (activeCity == null) ...[
                const SizedBox(height: 8),
                Text(
                  'Current: ${provider.selectedLat.toStringAsFixed(3)}°N, '
                  '${provider.selectedLon.toStringAsFixed(3)}°E (Custom)',
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontStyle: FontStyle.italic),
                ),
              ],
              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 16),

              // ── Notification Threshold ──────────────────────────────
              _SectionHeader(
                icon: Icons.notifications_outlined,
                title: 'Alert Threshold',
                subtitle:
                    'Send a notification when a new quake equals or exceeds this magnitude',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('2.5', style: TextStyle(fontSize: 13)),
                  Expanded(
                    child: Slider(
                      value: provider.alertThreshold,
                      min: 2.5,
                      max: 7.0,
                      divisions: 18, // 0.25 steps
                      label: 'M ${provider.alertThreshold.toStringAsFixed(2)}',
                      onChanged: (val) => provider.setAlertThreshold(val),
                    ),
                  ),
                  const Text('7.0', style: TextStyle(fontSize: 13)),
                ],
              ),
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Alert at M ${provider.alertThreshold.toStringAsFixed(2)}+',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 16),

              // ── About ───────────────────────────────────────────────
              _SectionHeader(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'App information',
              ),
              const SizedBox(height: 12),
              _InfoTile(
                icon: Icons.public,
                title: 'Data Source',
                value: 'USGS Earthquake Hazards Program',
              ),
              _InfoTile(
                icon: Icons.map_outlined,
                title: 'Maps',
                value: 'OpenStreetMap via flutter_map',
              ),
              _InfoTile(
                icon: Icons.storage_outlined,
                title: 'Offline Caching',
                value: 'Hive (local key-value store)',
              ),
              _InfoTile(
                icon: Icons.verified_outlined,
                title: 'Version',
                value: '1.0.0',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade500),
          const SizedBox(width: 14),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
