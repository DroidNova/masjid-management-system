import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_imam_salary_payment.dart';
import 'package:masjid_core_frontend/shared/widgets/app_card.dart';

class PaymentTransactionCard extends StatelessWidget {
  const PaymentTransactionCard({super.key, required this.payment});

  final MyImamSalaryPayment payment;

  @override
  Widget build(BuildContext context) {
    final paidOn = payment.paidAt == null
        ? 'Not available'
        : AppFormat.date(payment.paidAt!);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  AppFormat.rupees(payment.amount),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Chip(
                label: Text(payment.paymentMode),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Text('Paid on $paidOn'),
          Text('Collected by ${payment.collectedByName}'),
          if (payment.note != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(payment.note!),
          ],
        ],
      ),
    );
  }
}
