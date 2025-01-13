import 'package:flutter/material.dart';

class MonthYearPicker extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  const MonthYearPicker({
    super.key,
    required this.selectedDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () {
              final previousMonth = DateTime(
                selectedDate.year,
                selectedDate.month - 1,
                1,
              );
              onChanged(previousMonth);
            },
          ),
          TextButton(
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDatePickerMode: DatePickerMode.year,
              );
              if (picked != null) {
                onChanged(DateTime(picked.year, picked.month));
              }
            },
            child: Text(
              '${_getMonthName(selectedDate.month)} ${selectedDate.year}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: () {
              final nextMonth = DateTime(
                selectedDate.year,
                selectedDate.month + 1,
                1,
              );
              onChanged(nextMonth);
            },
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return months[month - 1];
  }
} 