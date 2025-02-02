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
  late Category _selectedCategory;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.payment != null) {
      titleController.text = widget.payment!.title;
      amountController.text = widget.payment!.amount.toString();
      _selectedCategory = widget.payment!.category;
      selectedDate = widget.payment!.dueDate;
    } else {
      _selectedCategory = Categories.defaultCategories.first;
      selectedDate = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.payment != null ? 'Ödemeyi Düzenle' : 'Yeni Ödeme',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  splashRadius: 24,
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Başlık',
                prefixIcon: const Icon(Icons.title),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
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
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                errorText: amountController.text.isNotEmpty && 
                          double.tryParse(amountController.text.replaceAll(',', '.')) == 0 
                    ? 'Geçerli bir tutar giriniz' 
                    : null,
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  amountController.text = '';
                  return;
                }

                final validFormat = RegExp(r'^\d*[,.]?\d{0,2}$');
                
                if (!validFormat.hasMatch(value)) {
                  String cleanValue = value.replaceAll(RegExp(r'[^\d,.]'), '');
                  
                  final separators = cleanValue.replaceAll(RegExp(r'[^\d]'), '');
                  if (separators.length > 1) {
                    int firstSepIndex = cleanValue.indexOf(RegExp(r'[,.]'));
                    cleanValue = cleanValue.substring(0, firstSepIndex + 1) +
                        cleanValue.substring(firstSepIndex + 1).replaceAll(RegExp(r'[,.]'), '');
                  }
                  
                  final parts = cleanValue.split(RegExp(r'[,.]'));
                  if (parts.length > 1 && parts[1].length > 2) {
                    cleanValue = '${parts[0]},${parts[1].substring(0, 2)}';
                  }
                  
                  amountController.value = TextEditingValue(
                    text: cleanValue,
                    selection: TextSelection.collapsed(offset: cleanValue.length),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Category>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: Categories.defaultCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(category.icon, color: category.color),
                          const SizedBox(width: 12),
                          Text(
                            category.name,
                            style: const TextStyle(fontSize: 16),
                          ),
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
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Son Ödeme: ${selectedDate.toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                      String amountText = amountController.text.replaceAll(',', '.');
                      final amount = double.tryParse(amountText) ?? 0.0;
                      if (amount > 0) {
                        final payment = Payment(
                          id: widget.payment?.id ?? DateTime.now().toString(),
                          title: titleController.text,
                          amount: amount,
                          dueDate: selectedDate,
                          category: _selectedCategory,
                          isPaid: widget.payment?.isPaid ?? false,
                        );
                        Navigator.pop(context, payment);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.payment != null ? 'Güncelle' : 'Ekle',
                    style: const TextStyle(fontSize: 16),
                  ),
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
    super.dispose();
  }
} 