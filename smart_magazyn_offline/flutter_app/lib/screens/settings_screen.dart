import 'package:flutter/material.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final zebraIp = TextEditingController();
  final zebraPort = TextEditingController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    zebraIp.text = await db.getSetting('zebra_ip', '192.168.1.50');
    zebraPort.text = await db.getSetting('zebra_port', '9100');
    setState(() => loading = false);
  }

  Future<void> save() async {
    await db.setSetting('zebra_ip', zebraIp.text.trim());
    await db.setSetting('zebra_port', zebraPort.text.trim().isEmpty ? '9100' : zebraPort.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zapisano ustawienia drukarki')));
  }

  @override
  void dispose() {
    zebraIp.dispose();
    zebraPort.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Ustawienia Zebra')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Drukowanie działa lokalnie po Wi-Fi/LAN. Internet nie jest wymagany, ale tablet musi widzieć drukarkę w tej samej sieci.'),
          const SizedBox(height: 20),
          TextField(controller: zebraIp, decoration: const InputDecoration(labelText: 'IP drukarki Zebra, np. 192.168.1.50')),
          const SizedBox(height: 12),
          TextField(controller: zebraPort, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Port TCP, zwykle 9100')),
          const SizedBox(height: 20),
          FilledButton.icon(onPressed: save, icon: const Icon(Icons.save), label: const Text('Zapisz')),
          const SizedBox(height: 24),
          const Text('Uwaga: przy połączeniu USB/Bluetooth trzeba dopisać osobny moduł drukowania. Ta wersja jest pod najprostszy i najczęstszy wariant Zebra po IP/ZPL.'),
        ],
      ),
    );
  }
}
