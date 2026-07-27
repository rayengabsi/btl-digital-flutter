import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Transfer Method Card
// ═══════════════════════════════════════════════════════════════════════════════
class TransferMethodCard extends StatefulWidget {
  const TransferMethodCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.isFullWidth = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isFullWidth;

  @override
  State<TransferMethodCard> createState() => _TransferMethodCardState();
}

class _TransferMethodCardState extends State<TransferMethodCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
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
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primaryGreen.withValues(alpha: 0.06)
                : AppColors.lightBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primaryGreen
                  : AppColors.borderLight,
              width: widget.isSelected ? 1.5 : 1,
            ),
          ),
          child: widget.isFullWidth
              ? _FullWidthContent(
                  icon: widget.icon,
                  title: widget.title,
                  subtitle: widget.subtitle,
                  isSelected: widget.isSelected,
                )
              : _CompactContent(
                  icon: widget.icon,
                  title: widget.title,
                  subtitle: widget.subtitle,
                  isSelected: widget.isSelected,
                ),
        ),
      ),
    );
  }
}

// ─── Compact layout (for side-by-side cards) ──────────────────────────────────
class _CompactContent extends StatelessWidget {
  const _CompactContent({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.primaryGreen.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected
                    ? AppColors.white
                    : AppColors.primaryGreen,
              ),
            ),
            const Spacer(),
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.borderLight,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: AppColors.white,
                    )
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─── Full-width layout (for recurring card) ───────────────────────────────────
class _FullWidthContent extends StatelessWidget {
  const _FullWidthContent({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryGreen
                : AppColors.primaryGreen.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected ? AppColors.white : AppColors.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            border: Border.all(
              color:
                  isSelected ? AppColors.primaryGreen : AppColors.borderLight,
              width: 1.5,
            ),
          ),
          child: isSelected
              ? const Icon(Icons.check_rounded, size: 12, color: AppColors.white)
              : null,
        ),
      ],
    );
  }
}
