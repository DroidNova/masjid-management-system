import 'package:flutter/material.dart';
import 'package:platform_core_frontend/core/errors/error_message_helper.dart';
import 'package:platform_core_frontend/features/contributions/data/contributions_repository.dart';
import 'package:platform_core_frontend/features/contributions/models/my_imam_salary_payment_model.dart';
import 'package:platform_core_frontend/features/contributions/presentation/widgets/payment_transaction_card.dart';
import 'package:platform_core_frontend/shared/utils/paginated_list_controller.dart';
import 'package:platform_core_frontend/shared/widgets/app_card.dart';

class ImamSalaryPaymentHistoryScreen extends StatefulWidget {
  const ImamSalaryPaymentHistoryScreen({
    super.key,
    required this.month,
    required this.year,
    ContributionsRepository? repository,
  }) : _repository = repository;

  final int month;
  final int year;
  final ContributionsRepository? _repository;

  @override
  State<ImamSalaryPaymentHistoryScreen> createState() =>
      _ImamSalaryPaymentHistoryScreenState();
}

class _ImamSalaryPaymentHistoryScreenState
    extends State<ImamSalaryPaymentHistoryScreen> {
  late final ContributionsRepository _repository =
      widget._repository ?? ContributionsRepository();
  late final PaginatedListController<MyImamSalaryPaymentModel> _payments;
  final ScrollController _scrollController = ScrollController();

  static const monthNames = <String>[
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _payments = PaginatedListController<MyImamSalaryPaymentModel>(
      errorMapper: getReadableErrorMessage,
      loader: (page, limit) => _repository.getMyImamSalaryPayments(
        month: widget.month,
        year: widget.year,
        page: page,
        limit: limit,
      ),
    )..addListener(_onChanged);
    _scrollController.addListener(_loadMoreNearBottom);
    _payments.refresh();
  }

  @override
  void dispose() {
    _payments.removeListener(_onChanged);
    _payments.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _loadMoreNearBottom() {
    if (_scrollController.position.extentAfter < 300) {
      _payments.loadNext();
    }
  }

  String get _period {
    final month = widget.month >= 1 && widget.month <= 12
        ? monthNames[widget.month - 1]
        : 'Month ${widget.month}';
    return '$month ${widget.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Imam Salary Payments')),
      body: RefreshIndicator(
        onRefresh: _payments.refresh,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(_period, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            if (_payments.items.isEmpty && !_payments.isLoading)
              const AppCard(
                child: Text(
                  'No payments found for this month.',
                  textAlign: TextAlign.center,
                ),
              )
            else
              ..._payments.items.map(
                (payment) => PaymentTransactionCard(payment: payment),
              ),
            if (_payments.isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_payments.error != null)
              AppCard(
                child: Column(
                  children: <Widget>[
                    Text(_payments.error!, textAlign: TextAlign.center),
                    TextButton(
                      onPressed: _payments.loadNext,
                      child: const Text('Retry'),
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
