import 'package:flutter/material.dart';
import 'package:gariban/models/payment.dart';
import 'package:gariban/widgets/payment_card.dart';
import 'package:gariban/widgets/dialogs/add_payment_dialog.dart';
import 'package:gariban/services/database_service.dart';
import 'package:gariban/models/category.dart';
import 'package:gariban/screens/statistics_screen.dart';
import 'package:gariban/widgets/month_year_picker.dart';
import 'package:gariban/utils/currency_formatter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Payment> payments = [];
  final DatabaseService _databaseService = DatabaseService.instance;
  Category? _selectedFilterCategory;
  DateTime _selectedMonth = DateTime.now();
  bool _showOverdueOnly = false;
  double _monthlyIncome = 0; // Varsayılan değer 0 olarak güncellendi

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final loadedPayments = await _databaseService.getAllPayments();
    setState(() {
      payments.clear();
      payments.addAll(loadedPayments);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Payment> filteredPayments = payments.where((payment) {
      bool sameMonth = payment.dueDate.month == _selectedMonth.month &&
          payment.dueDate.year == _selectedMonth.year;
      bool matchesCategory = _selectedFilterCategory == null ||
          payment.category.id == _selectedFilterCategory!.id;
      bool isOverdue = _showOverdueOnly
          ? !payment.isPaid && payment.dueDate.isBefore(DateTime.now())
          : true;
      
      return sameMonth && matchesCategory && isOverdue;
    }).toList();

    filteredPayments.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final double monthlyTotal = filteredPayments.fold(0, (sum, payment) => sum + payment.amount);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Gariban',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.filter_list, color: Colors.white.withAlpha(230)),
              onPressed: _showFilterDialog,
              tooltip: 'Filtrele',
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.bar_chart, color: Colors.white.withAlpha(230)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatisticsScreen(
                      payments: payments,
                      selectedMonth: _selectedMonth,
                      monthlyIncome: _monthlyIncome,
                    ),
                  ),
                );
              },
              tooltip: 'İstatistikler',
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.settings, color: Colors.white.withAlpha(230)),
              onPressed: _showSettingsDialog,
              tooltip: 'Ayarlar',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            child: Column(
              children: [
                MonthYearPicker(
                  selectedDate: _selectedMonth,
                  onChanged: (date) {
                    setState(() {
                      _selectedMonth = date;
                    });
                  },
                ),
                if (filteredPayments.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Aylık Kazanç',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  formatCurrency(_monthlyIncome),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Toplam Ödeme',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  formatCurrency(monthlyTotal),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (_selectedFilterCategory != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: Text('Kategori: ${_selectedFilterCategory!.name}'),
                deleteIcon: const Icon(Icons.close),
                onDeleted: () {
                  setState(() {
                    _selectedFilterCategory = null;
                  });
                },
              ),
            ),
          Expanded(
            child: filteredPayments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payment_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}\niçin ödeme bulunamadı',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredPayments.length,
                    itemBuilder: (context, index) {
                      return PaymentCard(
                        payment: filteredPayments[index],
                        onTap: () => _togglePaymentStatus(filteredPayments[index]),
                        onDelete: () => _deletePayment(filteredPayments[index]),
                        onEdit: () => _editPayment(filteredPayments[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPaymentDialog,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Ödeme'),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return months[month - 1];
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrele'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gecikmiş ödemeler filtresi
              ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: const Text('Geciken Ödemeler'),
                trailing: Switch(
                  value: _showOverdueOnly,
                  onChanged: (value) {
                    setState(() {
                      _showOverdueOnly = value;
                      _selectedFilterCategory = null;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              const Divider(),
              // Kategori listesi
              ...Categories.defaultCategories.map((category) => ListTile(
                    leading: Icon(category.icon, color: category.color),
                    title: Text(category.name),
                    onTap: () {
                      setState(() {
                        _selectedFilterCategory = category;
                        _showOverdueOnly = false;
                      });
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _togglePaymentStatus(Payment payment) async {
    final updatedPayment = Payment(
      id: payment.id,
      title: payment.title,
      amount: payment.amount,
      dueDate: payment.dueDate,
      category: payment.category,
      isPaid: !payment.isPaid,
    );
    await _databaseService.updatePayment(updatedPayment);
    await _loadPayments();
  }

  void _deletePayment(Payment payment) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödemeyi Sil'),
        content: Text('Bu ödemeyi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      await _databaseService.deletePayment(payment.id);
      await _loadPayments();
    }
  }

  void _editPayment(Payment payment) async {
    final Payment? updatedPayment = await showDialog<Payment>(
      context: context,
      builder: (context) => AddPaymentDialog(payment: payment),
    );

    if (updatedPayment != null) {
      await _databaseService.updatePayment(updatedPayment);
      await _loadPayments();
    }
  }

  void _showAddPaymentDialog() async {
    final payment = await showDialog<Payment>(
      context: context,
      builder: (context) => const AddPaymentDialog(),
    );

    if (payment != null) {
      await _databaseService.insertPayment(payment);
      await _loadPayments();
    }
  }

  void _showSettingsDialog() {
    final controller = TextEditingController(
      text: _monthlyIncome % 1 == 0 
        ? _monthlyIncome.toInt().toString() 
        : _monthlyIncome.toString()
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayarlar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Aylık Kazanç',
                prefixIcon: const Icon(Icons.account_balance_wallet),
                suffixText: '₺',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: controller.text.isNotEmpty && double.tryParse(controller.text.replaceAll(',', '.')) == 0 
                  ? 'Geçerli bir tutar giriniz' 
                  : null,
              ),
              onChanged: (value) {
                // Boş değer kontrolü
                if (value.isEmpty) {
                  controller.text = '';
                  return;
                }

                // Geçerli para formatı kontrolü
                final validFormat = RegExp(r'^\d*[,.]?\d{0,2}$');
                
                if (!validFormat.hasMatch(value)) {
                  // Geçersiz karakterleri temizle
                  String cleanValue = value.replaceAll(RegExp(r'[^\d,.]'), '');
                  
                  // Birden fazla ayraç varsa ilkini al
                  final separators = cleanValue.replaceAll(RegExp(r'[^\d]'), '');
                  if (separators.length > 1) {
                    int firstSepIndex = cleanValue.indexOf(RegExp(r'[,.]'));
                    cleanValue = cleanValue.substring(0, firstSepIndex + 1) +
                        cleanValue.substring(firstSepIndex + 1).replaceAll(RegExp(r'[,.]'), '');
                  }
                  
                  // Ondalık kısmı 2 basamakla sınırla
                  final parts = cleanValue.split(RegExp(r'[,.]'));
                  if (parts.length > 1 && parts[1].length > 2) {
                    cleanValue = '${parts[0]},${parts[1].substring(0, 2)}';
                  }
                  
                  controller.value = TextEditingValue(
                    text: cleanValue,
                    selection: TextSelection.collapsed(offset: cleanValue.length),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text.replaceAll(',', '.'));
              if (amount != null && amount > 0) {
                setState(() {
                  _monthlyIncome = amount;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
