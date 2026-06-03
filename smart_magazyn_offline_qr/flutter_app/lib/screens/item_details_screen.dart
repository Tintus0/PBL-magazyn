import 'package:flutter/material.dart';
import '../main.dart';
import '../models/item.dart';
import '../services/zebra_service.dart';

class ItemDetailsScreen extends StatelessWidget {
  final WarehouseItem item;
  const ItemDetailsScreen({super.key, required this.item});

  Future<void> printAgain(BuildContext context) async {
    try {
      final ip = await db.getSetting('zebra_ip', '192.168.1.50');
      final port = int.tryParse(await db.getSetting('zebra_port', '9100')) ?? 9100;
      await ZebraService.printLabel(host: ip, port: port, item: item);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Etykieta wysłana do drukarki')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 155, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informacje o przedmiocie')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                row('Kod', item.code),
                row('Opis', item.description ?? ''),
                row('Rodzina', item.familyName ?? ''),
                row('Ilość sztuk', item.quantity.toString()),
                row('Ilość pozycji w rodzinie', item.familyCount.toString()),
                row('Właściciel', item.ownerName),
                row('Ostatni użytkownik', item.lastUserName ?? ''),
                row('Lokalizacja', item.location ?? ''),
                row('Status', item.status),
                row('Utworzono', item.createdAt ?? ''),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => printAgain(context),
                  icon: const Icon(Icons.print),
                  label: const Text('Wydrukuj etykietę ponownie'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
