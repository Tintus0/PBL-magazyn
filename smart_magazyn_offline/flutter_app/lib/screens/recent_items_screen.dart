import 'package:flutter/material.dart';
import '../main.dart';
import '../models/item.dart';
import 'item_details_screen.dart';

class RecentItemsScreen extends StatefulWidget {
  const RecentItemsScreen({super.key});

  @override
  State<RecentItemsScreen> createState() => _RecentItemsScreenState();
}

class _RecentItemsScreenState extends State<RecentItemsScreen> {
  late Future<List<WarehouseItem>> futureItems;

  @override
  void initState() {
    super.initState();
    futureItems = db.getRecentItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ostatnie przedmioty')),
      body: FutureBuilder<List<WarehouseItem>>(
        future: futureItems,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          if (items.isEmpty) return const Center(child: Text('Brak przedmiotów w bazie'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('${item.code} | ${item.familyName ?? 'Brak rodziny'} | ${item.location ?? '-'}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailsScreen(item: item))),
              );
            },
          );
        },
      ),
    );
  }
}
