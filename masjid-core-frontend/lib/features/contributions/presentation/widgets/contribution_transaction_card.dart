import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/shared/widgets/app_card.dart';

class ContributionTransactionCard extends StatelessWidget {
  const ContributionTransactionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.amount,
    required this.paymentMode,
    this.paidAt,
    required this.collectedByName,
    this.note,
  });

  final String title;
  final String? subtitle;
  final double amount;
  final String paymentMode;
  final DateTime? paidAt;
  final String collectedByName;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final paidOn = paidAt == null ? 'Not available' : AppFormat.date(paidAt!);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                AppFormat.rupees(amount),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (subtitle?.isNotEmpty ?? false) Text(subtitle!),
          Text('$paymentMode • $paidOn'),
          Text('Collected by $collectedByName'),
          if (note != null) Text(note!),
        ],
      ),
    );
  }
}
