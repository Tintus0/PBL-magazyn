import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/database_service.dart';
import 'services/session_service.dart';

final db = DatabaseService();
final session = SessionService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await db.init();
  await session.load();
  runApp(const SmartMagazynApp());
}

class SmartMagazynApp extends StatelessWidget {
  const SmartMagazynApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Magazyn Offline',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
