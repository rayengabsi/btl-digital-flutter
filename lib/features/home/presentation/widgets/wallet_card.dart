import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../accounts/presentation/providers/accounts_provider.dart';

class WalletCard extends ConsumerStatefulWidget {
  const WalletCard({super.key, this.onTransfer});

  /// Invoked when the user taps Transfer. If null the buttons are hidden.
  final VoidCallback? onTransfer;

  @override
  ConsumerState<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends ConsumerState<WalletCard> {
  bool _balanceHidden = false;

  void _toggleBalance() {
    setState(() => _balanceHidden = !_balanceHidden);
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(customerAccountsProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
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
            // ─── Header row ───────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Primary Account Balance',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: _toggleBalance,
                  child: Icon(
                    _balanceHidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ─── Balance ──────────────────────────────────────────────
            accountsAsync.when(
              data: (accounts) {
                final primary = accounts.isNotEmpty ? accounts.first : null;
                final currency = primary?.currencyId ?? 'TND';
                final balance = primary?.availableBalance ?? 0.0;
                final wholePart = balance.floor().toString();
                final decimalPart =
                    ((balance - balance.floor()) * 1000).round().toString().padLeft(3, '0');

                if (_balanceHidden) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          currency,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '••••••',
                          style: AppTypography.h1.copyWith(
                            fontSize: 36,
                            letterSpacing: 4,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$currency ',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: wholePart,
                        style: AppTypography.h1.copyWith(
                          fontSize: 44,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: '.$decimalPart',
                        style: AppTypography.h3.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                ),
              ),
              error: (err, stack) => Text(
                'Balance unavailable',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.primaryRed),
              ),

            ),

            const SizedBox(height: 24),

            // ─── Transfer button ─────────────────────────────────────
            GestureDetector(
              onTap: widget.onTransfer ?? () {},
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Transfer',
                  style: AppTypography.buttonLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
