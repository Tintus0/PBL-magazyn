import 'package:flutter/material.dart';
import '../main.dart';
import '../models/item_family.dart';
import '../models/user.dart';
import '../services/zebra_service.dart';
import 'item_details_screen.dart';

class AddItemScreen extends StatefulWidget {
  final String? initialCode;

  const AddItemScreen({super.key, this.initialCode});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final name = TextEditingController();
  final description = TextEditingController();
  final location = TextEditingController();
  final code = TextEditingController();
  final newFamily = TextEditingController();
  List<AppUser> users = [];
  List<ItemFamily> families = [];
  int? ownerUserId;
  int? familyId;
  bool printAfterAdd = true;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialCode != null && widget.initialCode!.trim().isNotEmpty) {
      code.text = widget.initialCode!.trim();
    }
    loadData();
  }

  Future<void> loadData() async {
    final loadedUsers = await db.getUsers();
    final loadedFamilies = await db.getFamilies();
    setState(() {
      users = loadedUsers;
      families = loadedFamilies;
      ownerUserId = session.currentUser?.id ?? (users.isNotEmpty ? users.first.id : null);
      loading = false;
    });
  }

  Future<void> createFamily() async {
    final value = newFamily.text.trim();
    if (value.isEmpty) return;
    try {
      final id = await db.addFamily(value, null);
      newFamily.clear();
      await loadData();
      setState(() => familyId = id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> saveItem() async {
    final user = session.currentUser;
    if (user == null) return;
    if (name.text.trim().isEmpty || ownerUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nazwa i właściciel są wymagane')));
      return;
    }

    setState(() => loading = true);
    try {
      final item = await db.addItem(
        name: name.text.trim(),
        description: description.text.trim().isEmpty ? null : description.text.trim(),
        familyId: familyId,
        ownerUserId: ownerUserId!,
        location: location.text.trim().isEmpty ? null : location.text.trim(),
        createdBy: user.id,
        customCode: code.text.trim().isEmpty ? null : code.text.trim(),
      );

      String? warning;
      if (printAfterAdd) {
        try {
          final ip = await db.getSetting('zebra_ip', '192.168.1.50');
          final port = int.tryParse(await db.getSetting('zebra_port', '9100')) ?? 9100;
          await ZebraService.printLabel(host: ip, port: port, item: item);
        } catch (e) {
          warning = 'Przedmiot dodany, ale drukowanie nie wyszło: $e';
        }
      }

      if (!mounted) return;
      if (warning != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(warning)));
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ItemDetailsScreen(item: item)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    location.dispose();
    code.dispose();
    newFamily.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading && users.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dodaj przedmiot')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Nazwa przedmiotu *')),
          const SizedBox(height: 12),
          TextField(
            controller: code,
            decoration: const InputDecoration(
              labelText: 'Kod z QR / kod kreskowy',
              helperText: 'Zostaw puste, jeśli aplikacja ma wygenerować kod automatycznie',
            ),
          ),
          const SizedBox(height: 12),
          TextField(controller: description, decoration: const InputDecoration(labelText: 'Opis')),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            value: familyId,
            decoration: const InputDecoration(labelText: 'Rodzina / typ przedmiotu'),
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('Brak rodziny')),
              ...families.map((f) => DropdownMenuItem<int?>(value: f.id, child: Text(f.name))),
            ],
            onChanged: (v) => setState(() => familyId = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: newFamily, decoration: const InputDecoration(labelText: 'Nowa rodzina'))),
              const SizedBox(width: 8),
              FilledButton.tonal(onPressed: createFamily, child: const Text('Dodaj')),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: ownerUserId,
            decoration: const InputDecoration(labelText: 'Właściciel *'),
            items: users.map((u) => DropdownMenuItem(value: u.id, child: Text(u.fullName))).toList(),
            onChanged: (v) => setState(() => ownerUserId = v),
          ),
          const SizedBox(height: 12),
          TextField(controller: location, decoration: const InputDecoration(labelText: 'Lokalizacja, np. regał A-02')),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: printAfterAdd,
            title: const Text('Wydrukuj etykietę po dodaniu'),
            onChanged: (v) => setState(() => printAfterAdd = v),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: loading ? null : saveItem,
            icon: const Icon(Icons.save),
            label: Text(loading ? 'Zapisywanie...' : 'Zapisz przedmiot'),
          ),
        ],
      ),
    );
  }
}
