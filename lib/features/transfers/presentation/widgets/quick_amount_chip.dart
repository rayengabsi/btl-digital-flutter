import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Quick Amount Chip
// ═══════════════════════════════════════════════════════════════════════════════
class QuickAmountChip extends StatefulWidget {
  const QuickAmountChip({
    super.key,
    required this.amount,
    required this.onTap,
  });

  final double amount;
  final VoidCallback onTap;

  @override
  State<QuickAmountChip> createState() => _QuickAmountChipState();
}

class _QuickAmountChipState extends State<QuickAmountChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.90,
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
      onTapDown: (_) {
        _ctrl.reverse();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        _ctrl.forward();
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        _ctrl.forward();
        setState(() => _pressed = false);
      },
      child: ScaleTransition(
        scale: _ctrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _pressed
                ? AppColors.primaryGreen
                : AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(
              color: AppColors.primaryGreen.withValues(alpha: _pressed ? 1.0 : 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatAmount(widget.amount),
                style: AppTypography.labelLarge.copyWith(
                  color: _pressed
                      ? AppColors.white
                      : AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'TND',
                style: AppTypography.labelSmall.copyWith(
                  color: _pressed
                      ? AppColors.white.withValues(alpha: 0.85)
                      : AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.truncateToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toString();
  }
}
