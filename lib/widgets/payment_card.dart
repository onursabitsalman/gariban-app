import 'package:flutter/material.dart';
import 'package:gariban/models/payment.dart';

class PaymentCard extends StatelessWidget {
  final Payment payment;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const PaymentCard({
    super.key, 
    required this.payment,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(payment.id),
      background: Container(
        color: payment.isPaid ? Colors.orange : Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Icon(
          payment.isPaid ? Icons.close : Icons.check_circle,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onTap();
          return false;
        }
        if (direction == DismissDirection.endToStart) {
          onDelete();
          return false;
        }
        return false;
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              ListTile(
                leading: Stack(
                  children: [
                    Icon(payment.category.icon, color: payment.category.color),
                    if (!payment.isPaid && payment.dueDate.isBefore(DateTime.now()))
                      const Positioned(
                        right: -2,
                        top: -2,
                        child: Icon(Icons.warning, color: Colors.red, size: 14),
                      ),
                  ],
                ),
                title: Text(payment.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tarih: ${payment.dueDate.toString().split(' ')[0]}',
                      style: TextStyle(
                        color: !payment.isPaid && payment.dueDate.isBefore(DateTime.now())
                            ? Colors.red
                            : null,
                      ),
                    ),
                    if (payment.parentUid != null || payment.frequency != PaymentFrequency.once)
                      Text(
                        '${payment.frequency == PaymentFrequency.daily 
                            ? 'Günlük' 
                            : payment.frequency == PaymentFrequency.weekly 
                                ? 'Haftalık'
                                : payment.frequency == PaymentFrequency.monthly 
                                    ? 'Aylık'
                                    : 'Yıllık'} Ödeme',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₺${payment.amount % 1 == 0 
                            ? payment.amount.toInt().toString() 
                            : payment.amount.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          payment.isPaid ? 'Ödendi' : 'Ödenmedi',
                          style: TextStyle(
                            color: payment.isPaid ? Colors.green : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          onTap: onEdit,
                          child: const Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Düzenle'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: onDelete,
                          child: const Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Sil', style: TextStyle(color: Colors.red)),
                            ],
                          ),
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
    );
  }
} 