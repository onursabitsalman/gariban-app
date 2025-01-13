import 'package:gariban/models/category.dart';

enum PaymentFrequency {
  once('Bir Kerelik'),
  daily('Günlük'),
  weekly('Haftalık'),
  monthly('Aylık'),
  yearly('Yıllık');

  final String label;
  const PaymentFrequency(this.label);
}

class Payment {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final Category category;
  final PaymentFrequency frequency;
  final String? parentUid;
  bool isPaid;

  Payment({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.category,
    this.frequency = PaymentFrequency.once,
    this.parentUid,
    this.isPaid = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'categoryId': category.id,
      'frequency': frequency.name,
      'parentUid': parentUid,
      'isPaid': isPaid ? 1 : 0,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: map['amount'] as double,
      dueDate: DateTime.parse(map['dueDate'] as String),
      category: Categories.defaultCategories.firstWhere(
        (cat) => cat.id == map['categoryId'],
      ),
      frequency: PaymentFrequency.values.firstWhere(
        (f) => f.name == map['frequency'],
      ),
      parentUid: map['parentUid'] as String?,
      isPaid: map['isPaid'] == 1,
    );
  }
} 