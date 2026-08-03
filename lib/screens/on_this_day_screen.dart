import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/quake.dart';
import '../providers/history_provider.dart';
import '../providers/quake_provider.dart';
import '../widgets/quake_card.dart';
import 'quake_detail_screen.dart';

class OnThisDayScreen extends StatefulWidget {
  const OnThisDayScreen({super.key});

  @override
  State<OnThisDayScreen> createState() => _OnThisDayScreenState();
}

class _OnThisDayScreenState extends State<OnThisDayScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _load(forceRefresh: false);
    }
  }

  Future<void> _load({bool forceRefresh = false}) async {
    final quakeProvider = context.read<QuakeProvider>();
    await context.read<HistoryProvider>().loadOnThisDay(
          lat: quakeProvider.selectedLat,
          lon: quakeProvider.selectedLon,
          forceRefresh: forceRefresh,
        );
  }

  String _sectionTitle(int year, List<Quake> quakes) {
    final now = DateTime.now();
    final date = DateTime(year, now.month, now.day);
    final formatted = DateFormat('MMMM d, yyyy').format(date);
    final count = quakes.length;
    return '$formatted  ($count quake${count == 1 ? '' : 's'})';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('On This Day'),
            Text(
              DateFormat('MMMM d').format(DateTime.now()),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.quakesByYear.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _load(forceRefresh: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.28),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.history_toggle_off,
                              size: 72, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            'No significant earthquakes recorded on this date in the past 10 years for this region.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Sort years descending (most recent first)
          final sortedYears = provider.quakesByYear.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return RefreshIndicator(
            onRefresh: () => _load(forceRefresh: true),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: sortedYears.length,
              itemBuilder: (context, index) {
                final year = sortedYears[index];
                final quakes = provider.quakesByYear[year]!;

                return ExpansionTile(
                  initiallyExpanded: index == 0,
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      '$year',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer,
                      ),
                    ),
                  ),
                  title: Text(
                    _sectionTitle(year, quakes),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  children: quakes
                      .map(
                        (quake) => QuakeCard(
                          quake: quake,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  QuakeDetailScreen(quake: quake),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
