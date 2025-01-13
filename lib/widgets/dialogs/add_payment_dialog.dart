import 'package:flutter/material.dart';
import 'package:gariban/models/category.dart';
import 'package:gariban/models/payment.dart';

class AddPaymentDialog extends StatefulWidget {
  final Payment? payment;

  const AddPaymentDialog({super.key, this.payment});

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final repeatCountController = TextEditingController(text: '12');
  late Category _selectedCategory;
  late PaymentFrequency _selectedFrequency;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.payment != null) {
      titleController.text = widget.payment!.title;
      amountController.text = widget.payment!.amount.toString();
      _selectedCategory = widget.payment!.category;
      _selectedFrequency = widget.payment!.frequency;
      selectedDate = widget.payment!.dueDate;
    } else {
      _selectedCategory = Categories.defaultCategories.first;
      _selectedFrequency = PaymentFrequency.once;
      selectedDate = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.deepPurple[50],
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.payment != null ? 'Ödemeyi Düzenle' : 'Yeni Ödeme Ekle',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Başlık',
                prefixIcon: const Icon(Icons.title),
                filled: true,
                fillColor: Colors.deepPurple[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.deepPurple[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.deepPurple[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Tutar',
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: '₺',
                filled: true,
                fillColor: Colors.deepPurple[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.deepPurple[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.deepPurple[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
              ),
              onChanged: (value) {
                amountController.text = value.replaceAll(',', '.');
                amountController.selection = TextSelection.fromPosition(
                  TextPosition(offset: amountController.text.length),
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<Category>(
                value: _selectedCategory,
                isExpanded: true,
                underline: const SizedBox(),
                items: Categories.defaultCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category.icon, color: category.color),
                        const SizedBox(width: 12),
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            if (widget.payment == null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<PaymentFrequency>(
                  value: _selectedFrequency,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: PaymentFrequency.values.map((frequency) {
                    return DropdownMenuItem(
                      value: frequency,
                      child: Text(frequency.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedFrequency = value);
                    }
                  },
                ),
              ),
              if (_selectedFrequency != PaymentFrequency.once) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: repeatCountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Kaç Kez Tekrarlanacak',
                    prefixIcon: const Icon(Icons.repeat),
                    filled: true,
                    fillColor: Colors.deepPurple[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepPurple[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepPurple[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.deepPurple),
                    ),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text('Son Ödeme: ${selectedDate.toString().split(' ')[0]}'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                      final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0.0;
                      final payment = Payment(
                        id: widget.payment?.id ?? DateTime.now().toString(),
                        title: titleController.text,
                        amount: amount,
                        dueDate: selectedDate,
                        category: _selectedCategory,
                        frequency: _selectedFrequency,
                        isPaid: widget.payment?.isPaid ?? false,
                      );
                      Navigator.pop(context, {
                        'payment': payment,
                        'repeatCount': _selectedFrequency == PaymentFrequency.once 
                          ? 0 
                          : int.tryParse(repeatCountController.text) ?? 12,
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(widget.payment != null ? 'Güncelle' : 'Ekle'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    repeatCountController.dispose();
    super.dispose();
  }
} 