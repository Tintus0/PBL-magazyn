import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../main.dart';
import 'add_item_screen.dart';
import 'item_details_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool processing = false;
  final controller = MobileScannerController();

  Future<void> handleCode(String raw) async {
    if (processing) return;
    final user = session.currentUser;
    if (user == null) return;
    setState(() => processing = true);
    try {
      final code = raw.trim();
      final item = await db.getItemByCode(code, scannedByUserId: user.id);
      await controller.stop();
      if (!mounted) return;

      if (item == null) {
        await showUnknownCodeDialog(code);
        return;
      }

      await Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ItemDetailsScreen(item: item)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => processing = false);
    }
  }

  Future<void> showUnknownCodeDialog(String code) async {
    final add = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Nie znaleziono kodu'),
        content: Text('Kod "$code" nie istnieje w lokalnej bazie. Czy dodać nowy przedmiot z tym kodem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.add),
            label: const Text('Dodaj'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (add == true) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AddItemScreen(initialCode: code)),
      );
    } else {
      await controller.start();
      if (mounted) setState(() => processing = false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skanowanie')),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final codes = capture.barcodes;
              if (codes.isNotEmpty && codes.first.rawValue != null) {
                handleCode(codes.first.rawValue!);
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black54,
              child: Text(
                processing ? 'Sprawdzam kod w lokalnej bazie...' : 'Nakieruj kamerę na QR albo kod kreskowy',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
