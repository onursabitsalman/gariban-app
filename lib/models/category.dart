import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

// Öntanımlı kategoriler
class Categories {
  static final List<Category> defaultCategories = [
    Category(
      id: 'bills',
      name: 'Faturalar',
      icon: Icons.receipt_long,
      color: Colors.blue,
    ),
    Category(
      id: 'rent',
      name: 'Kira',
      icon: Icons.home,
      color: Colors.green,
    ),
    Category(
      id: 'credit_card',
      name: 'Kredi Kartı',
      icon: Icons.credit_card,
      color: Colors.red,
    ),
    Category(
      id: 'subscriptions',
      name: 'Abonelikler',
      icon: Icons.subscriptions,
      color: Colors.purple,
    ),
    Category(
      id: 'other',
      name: 'Diğer',
      icon: Icons.payments,
      color: Colors.orange,
    ),
  ];
} 