import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Amount Card
// ═══════════════════════════════════════════════════════════════════════════════
class AmountCard extends StatefulWidget {
  const AmountCard({
    super.key,
    required this.amountCtrl,
    required this.balance,
    required this.amount,
  });

  final TextEditingController amountCtrl;
  final double balance;
  final double amount;

  @override
  State<AmountCard> createState() => _AmountCardState();
}

class _AmountCardState extends State<AmountCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _errorCtrl;
  late Animation<double> _errorShake;
  bool _isExceeded = false;

  @override
  void initState() {
    super.initState();
    _errorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _errorShake = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _errorCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _errorCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AmountCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final exceeded = widget.amount > widget.balance;
    if (exceeded && !_isExceeded) {
      _errorCtrl.forward(from: 0);
    }
    _isExceeded = exceeded;
  }

  bool get _exceedsBalance => widget.amount > widget.balance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _errorShake,
      builder: (context, child) {
        final shake =
            _exceedsBalance ? 4.0 * (0.5 - (_errorShake.value - 0.5).abs()) : 0.0;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          border: Border.all(
            color: _exceedsBalance
                ? AppColors.primaryRed.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _exceedsBalance
                  ? AppColors.primaryRed.withValues(alpha: 0.10)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: label + input
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You Send',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'TND',
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: IntrinsicWidth(
                                child: TextField(
                                  controller: widget.amountCtrl,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[\d.]')),
                                  ],
                                  style: AppTypography.h1.copyWith(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700,
                                    color: _exceedsBalance
                                        ? AppColors.primaryRed
                                        : AppColors.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0.00',
                                    hintStyle: AppTypography.h1.copyWith(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary
                                          .withValues(alpha: 0.4),
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Right: currency selector
                  _CurrencySelector(),
                ],
              ),

              const SizedBox(height: 16),

              // ── Divider ─────────────────────────────────────────────
              Container(
                height: 1,
                color: AppColors.divider,
              ),

              const SizedBox(height: 14),

              // ── Balance row ─────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 18,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Wallet Balance: ',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'TND ',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: '12,450.80',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Error message ────────────────────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: _exceedsBalance
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: AppColors.primaryRed,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Amount exceeds available balance',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primaryRed,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Currency selector ────────────────────────────────────────────────────────
class _CurrencySelector extends StatefulWidget {
  @override
  State<_CurrencySelector> createState() => _CurrencySelectorState();
}

class _CurrencySelectorState extends State<_CurrencySelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tunisia flag emoji
              const Text('🇹🇳', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                'TND',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
