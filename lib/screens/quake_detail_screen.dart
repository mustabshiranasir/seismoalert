import 'package:flutter/material.dart';
import '../models/quake.dart';

class QuakeDetailScreen extends StatelessWidget {
  final Quake quake;

  const QuakeDetailScreen({super.key, required this.quake});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earthquake Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Magnitude ${quake.magnitude.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: quake.magnitude >= 6.0
                          ? Colors.red
                          : quake.magnitude >= 4.0
                              ? Colors.orange
                              : Colors.green,
                    ),
              ),
              const SizedBox(height: 24),
              Text(
                quake.place,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Time: ${quake.time.toLocal()}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                'Coordinates: ${quake.lat}, ${quake.lon}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                'Depth: ${quake.depth} km',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
