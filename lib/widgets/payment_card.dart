import 'package:flutter/material.dart';
import 'package:gariban/models/payment.dart';
import 'package:gariban/utils/currency_formatter.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
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
                        formatCurrency(payment.amount),
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
                  PopupMenuButton<String>(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    position: PopupMenuPosition.under,
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    itemBuilder: (context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'toggle',
                        onTap: onTap,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              payment.isPaid ? Icons.check_box_outlined : Icons.check_box,
                              color: payment.isPaid ? Colors.grey : Colors.green,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              payment.isPaid ? 'Ödenmedi' : 'Ödendi',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'edit',
                        onTap: onEdit,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.edit),
                            const SizedBox(width: 12),
                            Text(
                              'Düzenle',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: 'delete',
                        onTap: onDelete,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.delete, color: Colors.red),
                            const SizedBox(width: 12),
                            Text(
                              'Sil',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
    );
  }
} 