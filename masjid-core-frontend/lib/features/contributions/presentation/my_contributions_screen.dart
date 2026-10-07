import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/contributions/application/my_contributions_controllers.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_contribution_summary.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/widgets/contribution_summary_card.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/widgets/contribution_transaction_card.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/widgets/imam_salary_month_card.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/widgets/paged_list_parts.dart';
import 'package:masjid_core_frontend/shared/widgets/app_card.dart';

/// The signed-in member's own contributions: summary, imam salary months,
/// project contributions and general collections.
class MyContributionsScreen extends ConsumerStatefulWidget {
  const MyContributionsScreen({super.key});

  @override
  ConsumerState<MyContributionsScreen> createState() =>
      _MyContributionsScreenState();
}

class _MyContributionsScreenState extends ConsumerState<MyContributionsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    listenNearEnd(_scrollController, () {
      ref.read(myImamSalaryMonthsProvider.notifier).loadMore();
      ref.read(myProjectContributionsProvider.notifier).loadMore();
      ref.read(myCollectionContributionsProvider.notifier).loadMore();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref
      ..invalidate(myContributionSummaryProvider)
      ..invalidate(myImamSalaryMonthsProvider)
      ..invalidate(myProjectContributionsProvider)
      ..invalidate(myCollectionContributionsProvider);
    try {
      await ref.read(myContributionSummaryProvider.future);
    } catch (_) {
      // Shown by the error card; the refresh indicator just stops.
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(myContributionSummaryProvider);
    final months = ref.watch(myImamSalaryMonthsProvider);
    final projects = ref.watch(myProjectContributionsProvider);
    final collections = ref.watch(myCollectionContributionsProvider);
    final titleStyle = Theme.of(context).textTheme.titleLarge;

    return Scaffold(
      appBar: AppBar(title: const Text('My Contributions')),
      body: summary.isLoading && !summary.hasValue && !summary.hasError
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  if (summary.hasError && !summary.hasValue)
                    ErrorCard(
                      message: userMessage(summary.error!),
                      onRetry: _refresh,
                    )
                  else if (summary.valueOrNull case final data?) ...<Widget>[
                    _UserCard(user: data.user),
                    const SizedBox(height: 12),
                    ContributionSummaryCard(summary: data.imamSalary),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 8,
                        children: <Widget>[
                          Text(
                            'Projects ${AppFormat.rupees(data.projectContributionTotal)}',
                          ),
                          Text(
                            'Collections ${AppFormat.rupees(data.collectionContributionTotal)}',
                          ),
                          Text(
                            'All paid contributions ${AppFormat.rupees(data.totalContributionAmount)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text('Last 6 Months Imam Salary', style: titleStyle),
                  const SizedBox(height: 10),
                  ...pagedSection(
                    value: months,
                    empty: const AppCard(
                      child: Text(
                        'No salary dues are assigned to your account yet.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onRetry: () => ref.invalidate(myImamSalaryMonthsProvider),
                    onLoadMore: () => ref
                        .read(myImamSalaryMonthsProvider.notifier)
                        .loadMore(),
                    itemBuilder: (item) => ImamSalaryMonthCard(
                      item: item,
                      onViewPayments: () => context.push(
                        '/contributions/imam-salary/${item.month}/${item.year}/payments',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Project Contributions', style: titleStyle),
                  const SizedBox(height: 10),
                  ...pagedSection(
                    value: projects,
                    empty: const AppCard(
                      child: Text(
                        'No project contributions yet.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onRetry: () =>
                        ref.invalidate(myProjectContributionsProvider),
                    onLoadMore: () => ref
                        .read(myProjectContributionsProvider.notifier)
                        .loadMore(),
                    itemBuilder: (item) => ContributionTransactionCard(
                      title: item.projectTitle ?? item.contributorName,
                      subtitle: item.note,
                      amount: item.amount,
                      paymentMode: item.paymentMode,
                      paidAt: item.paidAt,
                      collectedByName: item.collectedByName,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('General Collections', style: titleStyle),
                  const SizedBox(height: 10),
                  ...pagedSection(
                    value: collections,
                    empty: const AppCard(
                      child: Text(
                        'No collection contributions yet.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onRetry: () =>
                        ref.invalidate(myCollectionContributionsProvider),
                    onLoadMore: () => ref
                        .read(myCollectionContributionsProvider.notifier)
                        .loadMore(),
                    itemBuilder: (item) => ContributionTransactionCard(
                      title: item.collectionType.replaceAll('_', ' '),
                      subtitle: item.note,
                      amount: item.amount,
                      paymentMode: item.paymentMode,
                      paidAt: item.paidAt,
                      collectedByName: item.collectedByName,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});

  final MyContributionUser user;

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
