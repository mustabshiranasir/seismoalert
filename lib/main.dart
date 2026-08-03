import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/quake.dart';
import 'models/emergency_contact.dart';
import 'providers/quake_provider.dart';
import 'providers/aftershock_provider.dart';
import 'providers/history_provider.dart';
import 'screens/main_navigation_screen.dart';

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
  await Hive.openBox('history_cache'); // generic box for JSON-encoded history

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuakeProvider()),
        ChangeNotifierProvider(create: (_) => AftershockProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        // Placeholders to add more providers in later phases:
        // ChangeNotifierProvider(create: (_) => EmergencyContactProvider()),
      ],
      child: MaterialApp(
        title: 'SeismoAlert',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const MainNavigationScreen(),
      ),
    );
  }
}
