import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../pos/models/pos_models.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;
  static Completer<Database>? _initCompleter;

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (_initCompleter != null) return _initCompleter!.future;
    
    _initCompleter = Completer<Database>();
    try {
      final db = await _initDB('pharmatrack.db');
      _database = db;
      _initCompleter!.complete(db);
      return db;
    } catch (e) {
      _initCompleter!.completeError(e);
      _initCompleter = null;
      rethrow;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 5, 
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await _createTables(db);
    await _seedData(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createTables(db);
      await _seedData(db);
    }
    if (oldVersion < 3) {
      try { await db.execute('ALTER TABLE invoice_items ADD COLUMN medicine_id TEXT'); } catch (e) {}
    }
    if (oldVersion < 5) {
      try { await db.execute('ALTER TABLE invoices ADD COLUMN customer_id INTEGER'); } catch (e) {}
    }
  }

  Future _createTables(Database db) async {
    await db.execute('CREATE TABLE IF NOT EXISTS customers (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone TEXT UNIQUE, address TEXT, created_at INTEGER)');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medicines (
        id TEXT PRIMARY KEY,
        name TEXT,
        category TEXT,
        manufacturer TEXT,
        stock INTEGER,
        reorder_level INTEGER,
        price REAL,
        expiry_date INTEGER,
        status INTEGER,
        description TEXT,
        batch_number TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_number TEXT,
        created_at INTEGER,
        customer_phone TEXT,
        customer_id INTEGER,
        payment_method TEXT,
        amount_paid REAL,
        change REAL,
        subtotal REAL,
        tax REAL,
        total REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER,
        medicine_id TEXT,
        name TEXT,
        quantity INTEGER,
        price REAL,
        total REAL,
        FOREIGN KEY(invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
        FOREIGN KEY(medicine_id) REFERENCES medicines(id) ON DELETE SET NULL
      )
    ''');
  }

  Future _seedData(Database db) async {
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM medicines'));
    if (count == 0) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final mockMedicines = [
        ['1', 'Paracetamol 500mg', 'Analgesic', 'ABC Pharma', 100, 20, 5.0, now + 31536000000],
        ['2', 'Amoxicillin 250mg', 'Antibiotic', 'XYZ Labs', 50, 10, 15.0, now + 15768000000],
        ['3', 'Metformin 500mg', 'Antidiabetic', 'JKL Pharma', 80, 15, 8.0, now + 47304000000],
      ];
      for (var m in mockMedicines) {
        await db.insert('medicines', {
          'id': m[0], 'name': m[1], 'category': m[2], 'manufacturer': m[3],
          'stock': m[4], 'reorder_level': m[5], 'price': m[6], 'expiry_date': m[7],
          'status': 0, 'created_at': now, 'updated_at': now
        });
      }
    }
  }

  // Medicine Methods
  Future<int> insertMedicine(Map<String, dynamic> m) async {
    final db = await database;
    return await db.insert('medicines', m);
  }

  Future<int> updateMedicine(String id, Map<String, dynamic> m) async {
    final db = await database;
    return await db.update('medicines', m, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteMedicine(String id) async {
    final db = await database;
    return await db.delete('medicines', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getMedicines() async {
    final db = await database;
    return await db.query('medicines', orderBy: 'name ASC');
  }

  Future<List<Map<String, dynamic>>> getMedicinesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final db = await database;
    return await db.rawQuery('SELECT * FROM medicines WHERE id IN (${List.filled(ids.length, '?').join(',')})', ids);
  }

  // Customer Methods
  Future<int> upsertCustomer(String name, String? phone, String? address) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (phone != null && phone.isNotEmpty) {
      final existing = await db.query('customers', where: 'phone = ?', whereArgs: [phone]);
      if (existing.isNotEmpty) {
        final id = existing.first['id'] as int;
        await db.update('customers', {'name': name, 'address': address}, where: 'id = ?', whereArgs: [id]);
        return id;
      }
    } else {
      final existingByName = await db.query('customers', where: 'name = ? AND (phone IS NULL OR phone = ?)', whereArgs: [name, '']);
      if (existingByName.isNotEmpty) return existingByName.first['id'] as int;
    }
    return await db.insert('customers', {'name': name, 'phone': (phone?.isEmpty ?? true) ? null : phone, 'address': address, 'created_at': now});
  }

  Future<int> saveInvoice(Invoice invoice) async {
    final db = await database;
    final customerPhone = (invoice.cartSummary.customer.phone?.isEmpty ?? true) ? null : invoice.cartSummary.customer.phone;
    int? customerId;
    if (invoice.cartSummary.customer.name != null && invoice.cartSummary.customer.name!.isNotEmpty) {
      customerId = await upsertCustomer(invoice.cartSummary.customer.name!, customerPhone, invoice.cartSummary.customer.address);
    }
    return await db.transaction<int>((txn) async {
      final id = await txn.insert('invoices', {
        'invoice_number': invoice.invoiceNumber, 
        'created_at': invoice.createdAt.millisecondsSinceEpoch,
        'customer_phone': customerPhone, 
        'customer_id': customerId,
        'payment_method': invoice.paymentMethod,
        'amount_paid': invoice.amountPaid, 
        'change': invoice.change,
        'subtotal': invoice.cartSummary.subtotal, 
        'tax': invoice.cartSummary.tax, 
        'total': invoice.cartSummary.total,
      });
      for (final item in invoice.cartSummary.items) {
        await txn.insert('invoice_items', {
          'invoice_id': id, 'medicine_id': item.id, 'name': item.name, 'quantity': item.quantity, 'price': item.price, 'total': item.totalPrice,
        });
        final rows = await txn.query('medicines', where: 'id = ?', whereArgs: [item.id]);
        if (rows.isNotEmpty) {
          final newStock = ((rows.first['stock'] as int) - item.quantity).clamp(0, 999999);
          await txn.update('medicines', {'stock': newStock, 'updated_at': DateTime.now().millisecondsSinceEpoch}, where: 'id = ?', whereArgs: [item.id]);
        }
      }
      return id;
    });
  }

  Future<void> deleteInvoice(int invoiceId) async {
    final db = await database;
    await db.transaction((txn) async {
      // 1. Restore stock
      final items = await txn.query('invoice_items', where: 'invoice_id = ?', whereArgs: [invoiceId]);
      for (var item in items) {
        final medicineId = item['medicine_id'] as String?;
        final quantity = item['quantity'] as int;
        if (medicineId != null) {
          final medRows = await txn.query('medicines', where: 'id = ?', whereArgs: [medicineId]);
          if (medRows.isNotEmpty) {
            final currentStock = medRows.first['stock'] as int;
            await txn.update('medicines', {'stock': currentStock + quantity, 'updated_at': DateTime.now().millisecondsSinceEpoch}, where: 'id = ?', whereArgs: [medicineId]);
          }
        }
      }
      // 2. Remove records
      await txn.delete('invoice_items', where: 'invoice_id = ?', whereArgs: [invoiceId]);
      await txn.delete('invoices', where: 'id = ?', whereArgs: [invoiceId]);
    });
  }

  // Analytics & Search Methods
  Future<List<Map<String, dynamic>>> getCustomerSummaries(String period) async {
    final db = await database;
    final now = DateTime.now();
    DateTime start = period == 'daily' ? DateTime(now.year, now.month, now.day) :
                    period == 'weekly' ? DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1)) :
                    period == 'monthly' ? DateTime(now.year, now.month, 1) : DateTime(0);
    final since = start.millisecondsSinceEpoch;
    return await db.rawQuery('''
      SELECT c.id, c.name, c.phone, c.address, 
        (SELECT COUNT(*) FROM invoices WHERE customer_id = c.id AND created_at >= ?) as orders_count,
        (SELECT IFNULL(SUM(total), 0) FROM invoices WHERE customer_id = c.id AND created_at >= ?) as total_spent
      FROM customers c
      ORDER BY total_spent DESC
    ''', [since, since]);
  }

  Future<List<Map<String, dynamic>>> getInvoicesForCustomer(int customerId, String period) async {
    final db = await database;
    final now = DateTime.now();
    DateTime start = period == 'daily' ? DateTime(now.year, now.month, now.day) :
                    period == 'weekly' ? DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1)) :
                    period == 'monthly' ? DateTime(now.year, now.month, 1) : DateTime(0);
    final invoices = await db.query('invoices', where: 'customer_id = ? AND created_at >= ?', whereArgs: [customerId, start.millisecondsSinceEpoch], orderBy: 'created_at DESC');
    List<Map<String, dynamic>> res = [];
    for (final inv in invoices) {
      final items = await db.query('invoice_items', where: 'invoice_id = ?', whereArgs: [inv['id']]);
      res.add({'invoice': inv, 'items': items});
    }
    return res;
  }

  Future<List<Map<String, dynamic>>> getInvoicesWithItems(int sinceMs) async {
    final db = await database;
    final invoices = await db.query('invoices', where: 'created_at >= ?', whereArgs: [sinceMs], orderBy: 'created_at DESC');
    List<Map<String, dynamic>> res = [];
    for (final inv in invoices) {
      final items = await db.query('invoice_items', where: 'invoice_id = ?', whereArgs: [inv['id']]);
      res.add({'invoice': inv, 'items': items});
    }
    return res;
  }

  Future<Map<String, dynamic>> getSalesSummary(int sinceMs) async {
    final db = await database;
    final row = await db.rawQuery('SELECT IFNULL(SUM(total),0) as total_sales, COUNT(DISTINCT id) as transactions FROM invoices WHERE created_at >= ?', [sinceMs]);
    return row.isNotEmpty ? row.first : {'total_sales': 0, 'transactions': 0};
  }

  Future<List<Map<String, dynamic>>> getSalesTrend(int sinceMs, String groupBy) async {
    final db = await database;
    String format = groupBy == 'month' ? '%Y-%m' : '%Y-%m-%d';
    return await db.rawQuery('''
      SELECT STRFTIME('$format', created_at / 1000, 'unixepoch') as period, SUM(total) as amount 
      FROM invoices 
      WHERE created_at >= ? 
      GROUP BY period 
      ORDER BY period ASC
    ''', [sinceMs]);
  }

  Future<List<Map<String, dynamic>>> getCategoryRevenue(int sinceMs) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT m.category, SUM(ii.total) as amount
      FROM invoice_items ii
      JOIN medicines m ON ii.medicine_id = m.id
      JOIN invoices i ON ii.invoice_id = i.id
      WHERE i.created_at >= ?
      GROUP BY m.category
    ''', [sinceMs]);
  }

  Future<List<Map<String, dynamic>>> getTopSellingMedicines(int sinceMs, {int limit = 10}) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT ii.medicine_id as id, ii.name as name, m.category as category, SUM(ii.quantity) as quantity_sold, SUM(ii.total) as revenue, m.stock as stock, m.reorder_level as reorder_level
      FROM invoice_items ii
      LEFT JOIN invoices i ON ii.invoice_id = i.id
      LEFT JOIN medicines m ON m.id = ii.medicine_id
      WHERE i.created_at >= ?
      GROUP BY ii.medicine_id, ii.name ORDER BY quantity_sold DESC LIMIT ?
    ''', [sinceMs, limit]);
  }
}
