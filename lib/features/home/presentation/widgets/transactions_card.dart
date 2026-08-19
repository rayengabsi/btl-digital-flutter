import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../accounts/data/models/account_transaction_model.dart';
import '../providers/home_providers.dart';
import '../utils/amount_formatter.dart';

// ─── Main widget ──────────────────────────────────────────────────────────────
class TransactionsCard extends ConsumerWidget {
  const TransactionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(homeRecentTransactionsProvider);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transactions',
                  style: AppTypography.h5.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'All',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primaryGreen,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                onRetry: () => ref.invalidate(homeRecentTransactionsProvider),
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
                      const SizedBox(height: 12),
                      _TransactionRow(transaction: transactions[i]),
                      if (i < transactions.length - 1) ...[
                        const SizedBox(height: 12),
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
    final rawAmount = isCredit
        ? (transaction.creditAmount ?? 0.0)
        : (transaction.debitAmount ?? 0.0);
    final sign = isCredit ? '+' : '-';
    final amountText = '$sign${formatAmountWithComma(rawAmount)} TND';
    final title = transaction.narratives.isNotEmpty
        ? transaction.narratives.first
        : transaction.transactionCode;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _iconFor(transaction),
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                transaction.bookingDate,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Text(
          amountText,
          style: AppTypography.bodyMedium.copyWith(
            color: isCredit ? AppColors.primaryGreen : AppColors.primaryRed,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

IconData _iconFor(AccountTransaction transaction) {
  final isCredit =
      transaction.creditAmount != null && transaction.creditAmount! > 0;
  switch (transaction.iconName) {
    case 'salary':
      return Icons.south_west_rounded;
    case 'receipt':
      return Icons.receipt_long_rounded;
    case 'shopping':
      return Icons.shopping_cart_rounded;
    case 'mobile':
      return Icons.phone_android_rounded;
    default:
      return isCredit
          ? Icons.south_west_rounded
          : Icons.north_east_rounded;
  }
}