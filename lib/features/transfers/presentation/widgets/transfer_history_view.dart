import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/transfer_models.dart';
import '../providers/transfers_provider.dart';

class TransferHistoryView extends ConsumerStatefulWidget {
  const TransferHistoryView({super.key});

  @override
  ConsumerState<TransferHistoryView> createState() => _TransferHistoryViewState();
}

class _TransferHistoryViewState extends ConsumerState<TransferHistoryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(transferHistoryControllerProvider);
      if (!state.hasLoaded) {
        ref.read(transferHistoryControllerProvider.notifier).loadFirstPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transferHistoryControllerProvider);

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () => ref
          .read(transferHistoryControllerProvider.notifier)
          .loadFirstPage(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Transfer History',
                style: AppTypography.h5.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (state.isLoading && !state.hasLoaded)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
            )
          else if (state.errorMessage != null && state.demands.isEmpty)
            SliverToBoxAdapter(
              child: _ErrorState(
                message: state.errorMessage!,
                onRetry: () => ref
                    .read(transferHistoryControllerProvider.notifier)
                    .loadFirstPage(),
              ),
            )
          else if (state.demands.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              sliver: SliverList.separated(
                itemCount: state.demands.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final demand = state.demands[index];
                  return _DemandCard(
                    demand: demand,
                    trailing: index == state.demands.length - 1 &&
                            state.hasNextPage
                        ? _LoadMoreIndicator(
                            loading: state.isLoadingMore,
                            onTap: () => ref
                                .read(transferHistoryControllerProvider.notifier)
                                .loadNextPage(),
                          )
                        : null,
                  );
                },
              ),
            ),
            if (state.hasNextPage)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Center(
                    child: state.isLoadingMore
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryGreen,
                            ),
                          )
                        : TextButton(
                            onPressed: () => ref
                                .read(transferHistoryControllerProvider.notifier)
                                .loadNextPage(),
                            child: const Text('Load More'),
                          ),
                  ),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ],
      ),
    );
  }
}

class _DemandCard extends StatelessWidget {
  const _DemandCard({required this.demand, this.trailing});

  final TransferDemand demand;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(demand.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_statusIcon(demand.status), color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title(demand),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle(demand),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing! else const SizedBox(width: 0),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${demand.amount.toStringAsFixed(3)} ${demand.debitCurrency}',
                style: AppTypography.h5.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  _statusLabel(demand.status),
                  style: AppTypography.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _title(TransferDemand d) {
    if (d.paymentDetails.isNotEmpty) return d.paymentDetails.first;
    return 'Transfer #${d.id}';
  }

  String _subtitle(TransferDemand d) {
    final date = _formatTimestamp(d.createdAt);
    return 'REF #${d.id} • $date';
  }

  IconData _statusIcon(TransferDemandStatus status) {
    switch (status) {
      case TransferDemandStatus.successful:
        return Icons.check_circle_outline_rounded;
      case TransferDemandStatus.failed:
        return Icons.cancel_outlined;
      case TransferDemandStatus.pending:
        return Icons.schedule_rounded;
      case TransferDemandStatus.unknown:
        return Icons.help_outline_rounded;
    }
  }

  String _statusLabel(TransferDemandStatus status) {
    switch (status) {
      case TransferDemandStatus.successful:
        return 'SUCCESSFUL';
      case TransferDemandStatus.failed:
        return 'FAILED';
      case TransferDemandStatus.pending:
        return 'PENDING';
      case TransferDemandStatus.unknown:
        return 'UNKNOWN';
    }
  }

  String _formatTimestamp(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return '${_two(dt.day)}-${_two(dt.month)}-${dt.year} '
        '${_two(dt.hour)}:${_two(dt.minute)}';
  }

  String _two(int v) => v.toString().padLeft(2, '0');
}

Color _statusColor(TransferDemandStatus status) {
  switch (status) {
    case TransferDemandStatus.successful:
      return AppColors.primaryGreen;
    case TransferDemandStatus.failed:
      return AppColors.primaryRed;
    case TransferDemandStatus.pending:
      return AppColors.warning;
    case TransferDemandStatus.unknown:
      return AppColors.textSecondary;
  }
}

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator({required this.loading, required this.onTap});

  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Text(
          'Load More',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.primaryRed),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: AppTypography.bodyMedium),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 44,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            Text('No Transfers Yet', style: AppTypography.h3),
            const SizedBox(height: 8),
            Text(
              'Your transfer history will appear here.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}