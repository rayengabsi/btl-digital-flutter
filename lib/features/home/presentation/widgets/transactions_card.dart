import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

// ─── Data model ───────────────────────────────────────────────────────────────
class TransactionItem {
  const TransactionItem({
    required this.title,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.icon,
  });

  final String title;
  final String date;
  final String amount;
  final bool isIncome;
  final IconData icon;
}

// ─── Static mock data ─────────────────────────────────────────────────────────
const List<TransactionItem> _mockTransactions = [
  TransactionItem(
    title: 'Salary',
    date: 'Today, 08:30 AM',
    amount: '+2,500.00 TND',
    isIncome: true,
    icon: Icons.south_rounded,
  ),
  TransactionItem(
    title: 'Netflix Subscription',
    date: 'Yesterday, 10:15 PM',
    amount: '-29.99 TND',
    isIncome: false,
    icon: Icons.receipt_long_outlined,
  ),
  TransactionItem(
    title: 'Carrefour Market',
    date: 'May 17, 2025',
    amount: '-78.60 TND',
    isIncome: false,
    icon: Icons.shopping_cart_outlined,
  ),
  TransactionItem(
    title: 'Ooredoo Recharge',
    date: 'May 16, 2025',
    amount: '-10.00 TND',
    isIncome: false,
    icon: Icons.phone_android_outlined,
  ),
];

// ─── Main widget ──────────────────────────────────────────────────────────────
class TransactionsCard extends StatelessWidget {
  const TransactionsCard({super.key});

  @override
  Widget build(BuildContext context) {
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
            // ─── Header ───────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transactions',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text(
                        'All',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ─── Transaction rows ──────────────────────────────────────
            ..._mockTransactions.asMap().entries.map((entry) {
              final index = entry.key;
              final tx = entry.value;
              return Column(
                children: [
                  const SizedBox(height: 16),
                  _TransactionRow(item: tx),
                  if (index < _mockTransactions.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Divider(
                        height: 1,
                        color: AppColors.divider,
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Single row ───────────────────────────────────────────────────────────────
class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.item});

  final TransactionItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon container
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: item.isIncome
                ? AppColors.primaryGreen.withValues(alpha: 0.08)
                : AppColors.textSecondary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            item.icon,
            size: 22,
            color: item.isIncome
                ? AppColors.primaryGreen
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 14),

        // Title + date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.date,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // Amount
        Text(
          item.amount,
          style: AppTypography.bodyMedium.copyWith(
            color: item.isIncome ? AppColors.primaryGreen : const Color(0xFF111827),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
