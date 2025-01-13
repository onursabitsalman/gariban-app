import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:gariban/models/payment.dart';
import 'package:gariban/models/category.dart';
import 'package:uuid/uuid.dart';

final _uuid = const Uuid();

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

    return await openDatabase(
      path,
      version: 3,
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
        frequency TEXT NOT NULL,
        parentUid TEXT,
        isPaid INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
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
        'frequency': payment.frequency.name,
        'parentUid': payment.parentUid,
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
        amount: map['amount'] as double,
        dueDate: DateTime.parse(map['dueDate'] as String),
        category: category,
        frequency: PaymentFrequency.values.firstWhere(
          (f) => f.name == map['frequency'] as String,
        ),
        parentUid: map['parentUid'] as String?,
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
        'frequency': payment.frequency.name,
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

  Future<void> insertPaymentWithRecurrence(Payment payment, {int repeatCount = 0}) async {
    if (payment.frequency == PaymentFrequency.once) {
      await insertPayment(payment);
      return;
    }

    final String recurringUid = _uuid.v4();

    final mainPayment = Payment(
      id: payment.id,
      title: payment.title,
      amount: payment.amount,
      dueDate: payment.dueDate,
      category: payment.category,
      frequency: payment.frequency,
      isPaid: payment.isPaid,
      parentUid: recurringUid,
    );
    await insertPayment(mainPayment);

    final payments = _generateRecurringPayments(mainPayment, repeatCount);
    for (var recurringPayment in payments) {
      final paymentWithParent = Payment(
        id: recurringPayment.id,
        title: recurringPayment.title,
        amount: recurringPayment.amount,
        dueDate: recurringPayment.dueDate,
        category: recurringPayment.category,
        frequency: recurringPayment.frequency,
        isPaid: recurringPayment.isPaid,
        parentUid: recurringUid,
      );
      await insertPayment(paymentWithParent);
    }

    // Tekrarlı ödemeler için bildirimleri planla
    if (repeatCount > 0) {
      final payments = _generateRecurringPayments(payment, repeatCount);
      for (var nextPayment in payments) {
        await insertPayment(nextPayment);
      }
    }
  }

  List<Payment> _generateRecurringPayments(Payment payment, int repeatCount) {
    final List<Payment> payments = [];
    var nextDate = payment.dueDate;

    for (int i = 1; i <= repeatCount; i++) {
      switch (payment.frequency) {
        case PaymentFrequency.daily:
          nextDate = nextDate.add(const Duration(days: 1));
          break;
        case PaymentFrequency.weekly:
          nextDate = nextDate.add(const Duration(days: 7));
          break;
        case PaymentFrequency.monthly:
          nextDate = DateTime(
            nextDate.year + (nextDate.month == 12 ? 1 : 0),
            nextDate.month == 12 ? 1 : nextDate.month + 1,
            nextDate.day,
          );
          break;
        case PaymentFrequency.yearly:
          nextDate = DateTime(nextDate.year + 1, nextDate.month, nextDate.day);
          break;
        case PaymentFrequency.once:
          continue;
      }

      payments.add(Payment(
        id: '${payment.id}_${i + 1}',
        title: payment.title,
        amount: payment.amount,
        dueDate: nextDate,
        category: payment.category,
        frequency: payment.frequency,
        isPaid: false,
      ));

      // Yıllık ödemeler için sadece bir sonraki yılı ekle
      if (payment.frequency == PaymentFrequency.yearly) {
        break;
      }
    }

    return payments;
  }

  Future<void> deleteRecurringPayments(String parentUid) async {
    final db = await database;
    await db.delete(
      'payments',
      where: 'parentUid = ? OR id = ?',
      whereArgs: [parentUid, parentUid],
    );
  }

  Future<void> updateRecurringPayment(String parentUid, Payment payment) async {
    final db = await database;

    if (payment.frequency == PaymentFrequency.once) {
      await updatePayment(payment);
      return;
    }

    await db.transaction((txn) async {
      await txn.update(
        'payments',
        {
          'title': payment.title,
          'amount': payment.amount,
          'categoryId': payment.category.id,
        },
        where: 'parentUid = ? AND dueDate >= ?',
        whereArgs: [parentUid, payment.dueDate.toIso8601String()],
      );
    });
  }
}
