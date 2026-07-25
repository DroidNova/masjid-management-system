import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/errors/error_message_helper.dart';
import 'package:platform_core_frontend/features/contributions/data/contributions_repository.dart';
import 'package:platform_core_frontend/features/contributions/models/collection_contribution_model.dart';
import 'package:platform_core_frontend/features/contributions/models/project_contribution_model.dart';
import 'package:platform_core_frontend/features/contributions/models/my_contribution_summary_model.dart';
import 'package:platform_core_frontend/features/contributions/models/my_imam_salary_contribution_model.dart';
import 'package:platform_core_frontend/features/contributions/presentation/widgets/contribution_summary_card.dart';
import 'package:platform_core_frontend/features/contributions/presentation/widgets/imam_salary_month_card.dart';
import 'package:platform_core_frontend/features/contributions/presentation/widgets/contribution_transaction_card.dart';
import 'package:platform_core_frontend/features/finance/presentation/widgets/finance_labels.dart';
import 'package:platform_core_frontend/shared/utils/paginated_list_controller.dart';
import 'package:platform_core_frontend/shared/widgets/app_card.dart';

class MyContributionsScreen extends StatefulWidget {
  const MyContributionsScreen({super.key, ContributionsRepository? repository})
      : _repository = repository;

  final ContributionsRepository? _repository;

  @override
  State<MyContributionsScreen> createState() => _MyContributionsScreenState();
}

class _MyContributionsScreenState extends State<MyContributionsScreen> {
  late final ContributionsRepository _repository =
      widget._repository ?? ContributionsRepository();
  late final PaginatedListController<MyImamSalaryContributionModel> _history;
  late final PaginatedListController<ProjectContributionModel> _projects;
  late final PaginatedListController<CollectionContributionModel> _collections;
  final ScrollController _scrollController = ScrollController();
  MyContributionSummaryModel? _summary;
  bool _loadingSummary = true;
  String? _summaryError;

  @override
  void initState() {
    super.initState();
    _history = PaginatedListController<MyImamSalaryContributionModel>(
      errorMapper: getReadableErrorMessage,
      loader: (page, limit) => _repository.getMyImamSalaryContributions(
        monthsBack: 6,
        page: page,
        limit: limit,
      ),
    )..addListener(_onHistoryChanged);
    _projects = PaginatedListController<ProjectContributionModel>(
      errorMapper: getReadableErrorMessage,
      loader: (page, limit) => _repository.getMyProjectContributions(page: page, limit: limit),
    )..addListener(_onHistoryChanged);
    _collections = PaginatedListController<CollectionContributionModel>(
      errorMapper: getReadableErrorMessage,
      loader: (page, limit) => _repository.getMyCollectionContributions(page: page, limit: limit),
    )..addListener(_onHistoryChanged);
    _scrollController.addListener(_loadMoreNearBottom);
    _refresh();
  }

  @override
  void dispose() {
    for (final controller in [_history, _projects, _collections]) {
      controller.removeListener(_onHistoryChanged);
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _onHistoryChanged() {
    if (mounted) setState(() {});
  }

  void _loadMoreNearBottom() {
    if (_scrollController.position.extentAfter < 300) {
      _history.loadNext();
      _projects.loadNext();
      _collections.loadNext();
    }
  }

  Future<void> _refresh() async {
    if (mounted) {
      setState(() {
        _loadingSummary = true;
        _summaryError = null;
      });
    }
    try {
      final results = await Future.wait<dynamic>([
        _repository.getMySummary(),
        _history.refresh(),
        _projects.refresh(),
        _collections.refresh(),
      ]);
      if (!mounted) return;
      setState(() => _summary = results.first as MyContributionSummaryModel);
    } catch (error) {
      if (!mounted) return;
      setState(() => _summaryError = getReadableErrorMessage(error));
    } finally {
      if (mounted) setState(() => _loadingSummary = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Contributions')),
      body: _loadingSummary && _summary == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  if (_summaryError != null)
                    _ErrorCard(message: _summaryError!, onRetry: _refresh)
                  else if (_summary != null) ...<Widget>[
                    _UserCard(user: _summary!.user),
                    const SizedBox(height: 12),
                    ContributionSummaryCard(summary: _summary!.imamSalary),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 8,
                        children: <Widget>[
                          Text('Projects ${formatRupees(_summary!.projectContributionTotal)}'),
                          Text('Collections ${formatRupees(_summary!.collectionContributionTotal)}'),
                          Text('All paid contributions ${formatRupees(_summary!.totalContributionAmount)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    'Last 6 Months Imam Salary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  if (_history.items.isEmpty && !_history.isLoading)
                    const AppCard(
                      child: Text(
                        'No salary dues are assigned to your account yet.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ..._history.items.map(
                      (item) => ImamSalaryMonthCard(
                        item: item,
                        onViewPayments: () => context.push(
                          '/contributions/imam-salary/${item.month}/${item.year}/payments',
                        ),
                      ),
                    ),
                  if (_history.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (_history.error != null)
                    _ErrorCard(
                      message: _history.error!,
                      onRetry: _history.loadNext,
                    ),
                  const SizedBox(height: 20),
                  Text('Project Contributions', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  if (_projects.items.isEmpty && !_projects.isLoading)
                    const AppCard(child: Text('No project contributions yet.', textAlign: TextAlign.center))
                  else
                    ..._projects.items.map((item) => ContributionTransactionCard(title: item.projectTitle ?? item.contributorName, subtitle: item.note, amount: item.amount, paymentMode: item.paymentMode, paidAt: item.paidAt, collectedByName: item.collectedByName)),
                  const SizedBox(height: 20),
                  Text('General Collections', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  if (_collections.items.isEmpty && !_collections.isLoading)
                    const AppCard(child: Text('No collection contributions yet.', textAlign: TextAlign.center))
                  else
                    ..._collections.items.map((item) => ContributionTransactionCard(title: item.collectionType.replaceAll('_', ' '), subtitle: item.note, amount: item.amount, paymentMode: item.paymentMode, paidAt: item.paidAt, collectedByName: item.collectedByName)),
                  if (_projects.isLoading || _collections.isLoading)
                    const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
                ],
              ),
            ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});
  final MyContributionUserModel user;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: <Widget>[
          const CircleAvatar(child: Icon(Icons.person_outline)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user.fullName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(user.phone ?? 'Phone not available'),
              ],
            ),
          ),
          if (user.isFamilyHead) const Chip(label: Text('Family Head')),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: <Widget>[
          Text(message, textAlign: TextAlign.center),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
