import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gariban/models/payment.dart';
import 'package:gariban/models/category.dart';
import 'package:gariban/utils/currency_formatter.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Payment> payments;
  final DateTime selectedMonth;
  final double monthlyIncome;

  const StatisticsScreen({
    super.key, 
    required this.payments,
    required this.selectedMonth,
    required this.monthlyIncome,
  });

  List<Payment> get _filteredPayments => payments.where((payment) {
    return payment.dueDate.month == selectedMonth.month &&
           payment.dueDate.year == selectedMonth.year;
  }).toList();

  String _getMonthName(int month) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${_getMonthName(selectedMonth.month)} ${selectedMonth.year} İstatistikleri'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Durum'),
              Tab(text: 'Kategoriler'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _PaymentStatusChart(payments: _filteredPayments, monthlyIncome: monthlyIncome),
            _CategoryPieChart(payments: _filteredPayments),
          ],
        ),
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final List<Payment> payments;

  const _CategoryPieChart({required this.payments});

  @override
  Widget build(BuildContext context) {
    final categoryData = _calculateCategoryData();
    final total = categoryData.values.fold(0.0, (sum, amount) => sum + amount);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Kategori Dağılımı',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 300,
                    child: PieChart(
                      PieChartData(
                        sections: categoryData.entries.map((entry) {
                          final percentage = (entry.value / total * 100);
                          return PieChartSectionData(
                            value: entry.value,
                            title: '${percentage.toStringAsFixed(1)}%',
                            color: entry.key.color,
                            radius: 100,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            badgeWidget: _Badge(
                              entry.key.icon,
                              entry.key.color,
                            ),
                            badgePositionPercentageOffset: 1.2,
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...categoryData.entries.map((entry) {
                          final percentage = (entry.value / total * 100);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: entry.key.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${entry.key.name} (%${percentage.toStringAsFixed(1)})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  formatCurrency(entry.value),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Toplam:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              formatCurrency(total),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<Category, double> _calculateCategoryData() {
    final Map<Category, double> categoryTotals = {};
    for (var payment in payments) {
      categoryTotals[payment.category] = (categoryTotals[payment.category] ?? 0) + payment.amount;
    }
    return Map.fromEntries(
      categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _Badge(this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(
        icon,
        size: 16,
        color: Colors.white,
      ),
    );
  }
}

class _PaymentStatusChart extends StatelessWidget {
  final List<Payment> payments;
  final double monthlyIncome;

  const _PaymentStatusChart({required this.payments, required this.monthlyIncome});

  @override
  Widget build(BuildContext context) {
    final statusData = _calculateStatusData();
    final total = statusData['paid']! + statusData['unpaid']!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Ödeme Durumu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: statusData['paid']!,
                          title: 'Ödendi\n%${((statusData['paid']! / total) * 100).toStringAsFixed(1)}',
                          color: Colors.green,
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: statusData['unpaid']!,
                          title: 'Ödenmedi\n%${((statusData['unpaid']! / total) * 100).toStringAsFixed(1)}',
                          color: Colors.red,
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Ödenen:'),
                            ],
                          ),
                          Text(
                            formatCurrency(statusData['paid']!),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Ödenecek:'),
                            ],
                          ),
                          Text(
                            formatCurrency(statusData['unpaid']!),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Aylık Kazanç:'),
                            ],
                          ),
                          Text(
                            formatCurrency(statusData['income']!),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Toplam:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            formatCurrency(total),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateStatusData() {
    double paid = 0;
    double unpaid = 0;
    for (var payment in payments) {
      if (payment.isPaid) {
        paid += payment.amount;
      } else {
        unpaid += payment.amount;
      }
    }
    return {
      'paid': paid,
      'unpaid': unpaid,
      'income': monthlyIncome,
    };
  }
} 