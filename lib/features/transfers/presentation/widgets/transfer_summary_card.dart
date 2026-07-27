import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../pages/transfer_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Transfer Summary Card
// ═══════════════════════════════════════════════════════════════════════════════
class TransferSummaryCard extends StatelessWidget {
  const TransferSummaryCard({
    super.key,
    required this.recipientName,
    required this.bank,
    required this.account,
    required this.transferType,
    required this.amount,
    required this.fee,
    required this.total,
    required this.estimatedArrival,
  });

  final String recipientName;
  final String bank;
  final String account;
  final TransferType transferType;
  final double amount;
  final double fee;
  final double total;
  final String estimatedArrival;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Transfer Summary',
                  style: AppTypography.h6.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    size: 16,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Summary rows
            _SummaryRow(
              label: 'Recipient',
              value: recipientName.isNotEmpty ? recipientName : '—',
              isHighlighted: false,
            ),
            _SummaryRow(
              label: 'Bank',
              value: bank.isNotEmpty ? bank : '—',
              isHighlighted: false,
            ),
            if (account.isNotEmpty)
              _SummaryRow(
                label: 'Account',
                value: _maskAccount(account),
                isHighlighted: false,
              ),
            _SummaryRow(
              label: 'Transfer Type',
              value: _transferTypeLabel(transferType),
              isHighlighted: false,
            ),
            _SummaryRow(
              label: 'Amount',
              value: amount > 0
                  ? 'TND ${amount.toStringAsFixed(2)}'
                  : '—',
              isHighlighted: false,
            ),
            _SummaryRow(
              label: 'Fee',
              value: amount > 0
                  ? 'TND ${fee.toStringAsFixed(3)}'
                  : '—',
              isHighlighted: false,
            ),
            _SummaryRow(
              label: 'Estimated Arrival',
              value: estimatedArrival,
              isHighlighted: false,
            ),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.divider),
            ),

            // Total
            _SummaryRow(
              label: 'Total',
              value: amount > 0
                  ? 'TND ${total.toStringAsFixed(2)}'
                  : '—',
              isHighlighted: true,
            ),
          ],
        ),
      ),
    );
  }

  String _maskAccount(String account) {
    if (account.length < 6) return account;
    return '•••• ${account.substring(account.length - 6)}';
  }

  String _transferTypeLabel(TransferType type) {
    switch (type) {
      case TransferType.instant:
        return 'Instant Transfer';
      case TransferType.scheduled:
        return 'Scheduled Transfer';
      case TransferType.recurring:
        return 'Recurring Transfer';
    }
  }
}

// ─── Single summary row ───────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.isHighlighted,
  });

  final String label;
  final String value;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
              fontSize: 13,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                color: isHighlighted
                    ? AppColors.primaryGreen
                    : AppColors.textPrimary,
                fontWeight:
                    isHighlighted ? FontWeight.w700 : FontWeight.w500,
                fontSize: isHighlighted ? 15 : 13,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
