import 'package:flutter/material.dart';
import '../main.dart';
import 'add_item_screen.dart';
import 'login_screen.dart';
import 'recent_items_screen.dart';
import 'scanner_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> logout(BuildContext context) async {
    await session.logout();
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final user = session.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Magazyn Offline'),
        actions: [IconButton(onPressed: () => logout(context), icon: const Icon(Icons.logout))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Zalogowany: ${user?.fullName ?? '-'}', style: const TextStyle(fontSize: 18)),
            Text('Rola: ${user?.role ?? '-'}'),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Skanuj QR / kod kreskowy'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen())),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.add_box),
              label: const Text('Dodaj przedmiot i wydrukuj etykietę'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddItemScreen())),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.inventory_2),
              label: const Text('Ostatnio dodane przedmioty'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecentItemsScreen())),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text('Ustawienia drukarki Zebra'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
            const Spacer(),
            const Text('Tryb offline: dane są zapisane tylko na tym tablecie.'),
          ],
        ),
      ),
    );
  }
}
