import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:gariban/models/payment.dart';
import 'package:gariban/models/category.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('payments.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Delete the database file
    //await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE payments(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        dueDate TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        isPaid INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS payments');
      await _createDB(db, newVersion);
    }
  }

  Future<void> insertPayment(Payment payment) async {
    final db = await database;
    await db.insert(
      'payments',
      {
        'id': payment.id,
        'title': payment.title,
        'amount': payment.amount,
        'dueDate': payment.dueDate.toIso8601String(),
        'categoryId': payment.category.id,
        'isPaid': payment.isPaid ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Payment>> getAllPayments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('payments');

    return maps.map((map) {
      final categoryId = map['categoryId'] as String;
      final category = Categories.defaultCategories.firstWhere(
        (cat) => cat.id == categoryId,
      );

      return Payment(
        id: map['id'] as String,
        title: map['title'] as String,
        amount: (map['amount'] as num).toDouble(),
        dueDate: DateTime.parse(map['dueDate'] as String),
        category: category,
        isPaid: map['isPaid'] == 1,
      );
    }).toList();
  }

  Future<void> updatePayment(Payment payment) async {
    final db = await database;
    await db.update(
      'payments',
      {
        'title': payment.title,
        'amount': payment.amount,
        'dueDate': payment.dueDate.toIso8601String(),
        'categoryId': payment.category.id,
        'isPaid': payment.isPaid ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  Future<void> deletePayment(String id) async {
    final db = await database;
    await db.delete(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
