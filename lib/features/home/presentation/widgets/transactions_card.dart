import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../accounts/data/models/account_transaction_model.dart';
import '../../../accounts/presentation/providers/accounts_provider.dart';

// ─── Main widget ──────────────────────────────────────────────────────────────
class TransactionsCard extends ConsumerWidget {
  const TransactionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(recentTransactionsProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Transactions',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            txAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
              error: (err, stack) => _ErrorState(
                onRetry: () => ref.invalidate(recentTransactionsProvider),
              ),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No recent transactions.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < transactions.length; i++) ...[
                      const SizedBox(height: 16),
                      _TransactionRow(transaction: transactions[i]),
                      if (i < transactions.length - 1) ...[
                        const SizedBox(height: 16),
                        Divider(height: 1, color: AppColors.divider),
                      ],
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          children: [
            Text(
              'Unable to load recent transactions.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

// ─── Single row ───────────────────────────────────────────────────────────────
class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});

  final AccountTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit =
        transaction.creditAmount != null && transaction.creditAmount! > 0;
    final amountText = isCredit
        ? '+${transaction.creditAmount!.toStringAsFixed(3)}'
        : transaction.debitAmount != null
            ? '-${transaction.debitAmount!.toStringAsFixed(3)}'
            : '0.000';
    final title = transaction.narratives.isNotEmpty
        ? transaction.narratives.first
        : transaction.transactionCode;

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: isCredit
                ? AppColors.primaryGreen.withValues(alpha: 0.08)
                : AppColors.textSecondary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            isCredit ? Icons.south_west_rounded : Icons.north_east_rounded,
            size: 22,
            color: isCredit ? AppColors.primaryGreen : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                transaction.bookingDate,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Text(
          amountText,
          style: AppTypography.bodyMedium.copyWith(
            color: isCredit
                ? AppColors.primaryGreen
                : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}