import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/quake.dart';
import 'models/emergency_contact.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(QuakeAdapter());
  Hive.registerAdapter(EmergencyContactAdapter());

  // Open Hive boxes
  await Hive.openBox<Quake>('quake_cache');
  await Hive.openBox<EmergencyContact>('emergency_contacts');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeismoAlert',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SetupCompleteScreen(),
    );
  }
}

class SetupCompleteScreen extends StatelessWidget {
  const SetupCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SeismoAlert'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.teal,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'SeismoAlert - Setup Complete',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
