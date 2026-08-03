import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/quake.dart';
import 'models/emergency_contact.dart';
import 'providers/quake_provider.dart';
import 'providers/aftershock_provider.dart';
import 'providers/history_provider.dart';
import 'providers/contacts_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'services/notification_service.dart';

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
  await Hive.openBox('history_cache'); // generic box for JSON + settings

  // Initialize local notifications
  await NotificationService().initialize();

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
        ChangeNotifierProvider(create: (_) => ContactsProvider()),
      ],
      child: MaterialApp(
        title: 'SeismoAlert',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00796B), // deep teal
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const _AppRoot(),
      ),
    );
  }
}

/// Wrapper that listens to QuakeProvider.errorMessage and shows a SnackBar.
class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // React to provider error changes after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenForErrors();
    });
  }

  void _listenForErrors() {
    final quakeProvider = context.read<QuakeProvider>();
    quakeProvider.addListener(() {
      final msg = quakeProvider.errorMessage;
      if (msg != null && mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () =>
                  ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MainNavigationScreen();
  }
}
