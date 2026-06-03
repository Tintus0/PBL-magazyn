import 'dart:math';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/item.dart';
import '../models/item_family.dart';
import '../models/user.dart';
import 'hash_service.dart';

class DatabaseService {
  late Database _database;

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smart_magazyn_offline.db');
    _database = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await _createSchema(db);
        await _seed(db);
      },
    );
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'worker',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
)''');

    await db.execute('''
CREATE TABLE item_families (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  description TEXT
)''');

    await db.execute('''
CREATE TABLE items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  family_id INTEGER,
  owner_user_id INTEGER NOT NULL,
  last_user_id INTEGER,
  location TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  created_by INTEGER,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (family_id) REFERENCES item_families(id),
  FOREIGN KEY (owner_user_id) REFERENCES users(id),
  FOREIGN KEY (last_user_id) REFERENCES users(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
)''');

    await db.execute('''
CREATE TABLE scan_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  item_id INTEGER NOT NULL,
  scanned_by INTEGER NOT NULL,
  action TEXT NOT NULL DEFAULT 'scan',
  scanned_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (item_id) REFERENCES items(id),
  FOREIGN KEY (scanned_by) REFERENCES users(id)
)''');

    await db.execute('''
CREATE TABLE app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
)''');

    await db.execute('CREATE INDEX idx_items_code ON items(code)');
    await db.execute('CREATE INDEX idx_items_family ON items(family_id)');
  }

  Future<void> _seed(Database db) async {
    await db.insert('users', {
      'username': 'admin',
      'password_hash': hashPassword('admin123'),
      'full_name': 'Administrator',
      'role': 'admin',
    });
    await db.insert('users', {
      'username': 'pracownik',
      'password_hash': hashPassword('pracownik123'),
      'full_name': 'Pracownik magazynu',
      'role': 'worker',
    });
    await db.insert('item_families', {'name': 'Elektronika', 'description': 'Urządzenia i części elektroniczne'});
    await db.insert('item_families', {'name': 'Narzędzia', 'description': 'Narzędzia warsztatowe i magazynowe'});
    await db.insert('app_settings', {'key': 'zebra_ip', 'value': '192.168.1.50'});
    await db.insert('app_settings', {'key': 'zebra_port', 'value': '9100'});
  }

  Future<AppUser> login(String username, String password) async {
    final rows = await _database.query(
      'users',
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username, hashPassword(password)],
      limit: 1,
    );
    if (rows.isEmpty) throw Exception('Błędny login lub hasło');
    return AppUser.fromMap(rows.first);
  }

  Future<List<AppUser>> getUsers() async {
    final rows = await _database.query('users', orderBy: 'full_name');
    return rows.map(AppUser.fromMap).toList();
  }

  Future<int> addUser({required String username, required String password, required String fullName, String role = 'worker'}) async {
    return _database.insert('users', {
      'username': username,
      'password_hash': hashPassword(password),
      'full_name': fullName,
      'role': role,
    });
  }

  Future<List<ItemFamily>> getFamilies() async {
    final rows = await _database.query('item_families', orderBy: 'name');
    return rows.map(ItemFamily.fromMap).toList();
  }

  Future<int> addFamily(String name, String? description) async {
    return _database.insert('item_families', {'name': name, 'description': description});
  }

  Future<String> getSetting(String key, String fallback) async {
    final rows = await _database.query('app_settings', where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return fallback;
    return rows.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    await _database.insert('app_settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  String makeCode() {
    final random = Random.secure();
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final suffix = List.generate(10, (_) => chars[random.nextInt(chars.length)]).join();
    return 'SM-$suffix';
  }

  Future<WarehouseItem> addItem({
    required String name,
    String? description,
    int? familyId,
    required int ownerUserId,
    String? location,
    required int createdBy,
    String? customCode,
  }) async {
    final preparedCustomCode = customCode?.trim();
    String code;
    if (preparedCustomCode != null && preparedCustomCode.isNotEmpty) {
      code = preparedCustomCode;
      if (await codeExists(code)) {
        throw Exception('Kod już istnieje w bazie: $code');
      }
    } else {
      do {
        code = makeCode();
      } while (await codeExists(code));
    }

    await _database.insert('items', {
      'code': code,
      'name': name,
      'description': description,
      'family_id': familyId,
      'owner_user_id': ownerUserId,
      'last_user_id': ownerUserId,
      'location': location,
      'created_by': createdBy,
    });

    final item = await getItemByCode(code, scannedByUserId: null);
    if (item == null) throw Exception('Dodano przedmiot, ale nie udało się go odczytać');
    return item;
  }

  Future<bool> codeExists(String code) async {
    final rows = await _database.query('items', where: 'code = ?', whereArgs: [code], limit: 1);
    return rows.isNotEmpty;
  }

  Future<WarehouseItem?> getItemByCode(String code, {int? scannedByUserId}) async {
    final rows = await _database.rawQuery('''
SELECT i.id, i.code, i.name, i.description, i.family_id, i.owner_user_id, i.last_user_id,
       i.location, i.status, i.created_at,
       f.name AS family_name,
       owner.full_name AS owner_name,
       lastu.full_name AS last_user_name,
       (SELECT COUNT(*) FROM items x WHERE (x.family_id = i.family_id OR (x.family_id IS NULL AND i.family_id IS NULL))) AS family_count
FROM items i
LEFT JOIN item_families f ON f.id = i.family_id
LEFT JOIN users owner ON owner.id = i.owner_user_id
LEFT JOIN users lastu ON lastu.id = i.last_user_id
WHERE i.code = ?
LIMIT 1
''', [code]);

    if (rows.isEmpty) return null;
    final item = WarehouseItem.fromMap(rows.first);

    if (scannedByUserId != null) {
      await _database.insert('scan_history', {'item_id': item.id, 'scanned_by': scannedByUserId, 'action': 'scan'});
      await _database.update('items', {
        'last_user_id': scannedByUserId,
        'updated_at': DateTime.now().toIso8601String(),
      }, where: 'id = ?', whereArgs: [item.id]);
      return getItemByCode(code, scannedByUserId: null);
    }

    return item;
  }

  Future<List<WarehouseItem>> getRecentItems() async {
    final rows = await _database.rawQuery('''
SELECT i.id, i.code, i.name, i.description, i.family_id, i.owner_user_id, i.last_user_id,
       i.location, i.status, i.created_at,
       f.name AS family_name,
       owner.full_name AS owner_name,
       lastu.full_name AS last_user_name,
       (SELECT COUNT(*) FROM items x WHERE (x.family_id = i.family_id OR (x.family_id IS NULL AND i.family_id IS NULL))) AS family_count
FROM items i
LEFT JOIN item_families f ON f.id = i.family_id
LEFT JOIN users owner ON owner.id = i.owner_user_id
LEFT JOIN users lastu ON lastu.id = i.last_user_id
ORDER BY i.created_at DESC
LIMIT 100
''');
    return rows.map(WarehouseItem.fromMap).toList();
  }
}
