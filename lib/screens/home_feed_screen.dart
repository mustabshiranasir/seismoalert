import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quake_provider.dart';
import '../widgets/quake_card.dart';
import '../widgets/offline_banner.dart';
import 'quake_detail_screen.dart';

class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SeismoAlert',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<QuakeProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, size: 20),
                    const SizedBox(width: 4),
                    DropdownButton<double>(
                      value: provider.minMagnitudeFilter,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      items: const [
                        DropdownMenuItem(value: 0.0, child: Text('All')),
                        DropdownMenuItem(value: 2.5, child: Text('M2.5+')),
                        DropdownMenuItem(value: 4.0, child: Text('M4.0+')),
                        DropdownMenuItem(value: 5.5, child: Text('M5.5+')),
                        DropdownMenuItem(value: 7.0, child: Text('M7.0+')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          provider.setMagnitudeFilter(val);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<QuakeProvider>(
        builder: (context, provider, child) {
          final quakes = provider.filteredQuakes;

          return Column(
            children: [
              if (provider.isOffline) const OfflineBanner(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.fetchQuakes(),
                  child: _buildContent(context, provider, quakes),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    QuakeProvider provider,
    List<dynamic> quakes,
  ) {
    if (provider.isLoading && quakes.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (quakes.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No earthquakes found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try changing the filters or retry later.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (provider.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: quakes.length,
      itemBuilder: (context, index) {
        final quake = quakes[index];
        return QuakeCard(
          quake: quake,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuakeDetailScreen(quake: quake),
              ),
            );
          },
        );
      },
    );
  }
}
