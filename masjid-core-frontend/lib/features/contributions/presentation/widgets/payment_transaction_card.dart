import 'package:flutter/material.dart';
import 'package:platform_core_frontend/features/contributions/models/my_imam_salary_payment_model.dart';
import 'package:platform_core_frontend/features/finance/presentation/widgets/finance_labels.dart';
import 'package:platform_core_frontend/shared/utils/date_format_utils.dart';
import 'package:platform_core_frontend/shared/widgets/app_card.dart';

class PaymentTransactionCard extends StatelessWidget {
  const PaymentTransactionCard({super.key, required this.payment});
  final MyImamSalaryPaymentModel payment;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Row(children: <Widget>[
          Expanded(child: Text(formatRupees(payment.amount), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
          Chip(label: Text(payment.paymentMode), visualDensity: VisualDensity.compact),
        ]),
        Text('Paid on ${formatReadableDate(payment.paidAt, nullText: 'Not available')}'),
        Text('Collected by ${payment.collectedByName}'),
        if (payment.note != null) ...<Widget>[const SizedBox(height: 6), Text(payment.note!)],
      ]),
    );
  }
}
