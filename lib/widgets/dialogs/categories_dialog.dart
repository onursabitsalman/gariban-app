import 'package:flutter/material.dart';
import 'package:gariban/models/category.dart';

class CategoriesDialog extends StatelessWidget {
  const CategoriesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Kategoriler'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: Categories.defaultCategories
              .map((category) => ListTile(
                    leading: Icon(category.icon, color: category.color),
                    title: Text(category.name),
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tamam'),
        ),
      ],
    );
  }
} 