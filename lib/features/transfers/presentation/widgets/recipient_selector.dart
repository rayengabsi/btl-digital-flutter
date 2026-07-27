import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../pages/transfer_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Recipient Selector
// ═══════════════════════════════════════════════════════════════════════════════
class RecipientSelector extends StatelessWidget {
  const RecipientSelector({
    super.key,
    required this.recipients,
    required this.selected,
    required this.onSelect,
  });

  final List<RecipientModel> recipients;
  final RecipientModel? selected;
  final ValueChanged<RecipientModel> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              'Send Money To',
              style: AppTypography.h6.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
              itemCount: recipients.length + 1, // +1 for "Add" button
              itemBuilder: (context, i) {
                if (i == recipients.length) {
                  return _AddRecipientCard();
                }
                final r = recipients[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: RecipientCard(
                    recipient: r,
                    isSelected: selected?.name == r.name,
                    onTap: () => onSelect(r),
                  ),
                );
              },
            ),
          ),

          // Selected recipient info card
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: selected != null
                ? _SelectedRecipientInfo(recipient: selected!)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─── Individual recipient card ────────────────────────────────────────────────
class RecipientCard extends StatefulWidget {
  const RecipientCard({
    super.key,
    required this.recipient,
    required this.isSelected,
    required this.onTap,
  });

  final RecipientModel recipient;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<RecipientCard> createState() => _RecipientCardState();
}

class _RecipientCardState extends State<RecipientCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

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
    _scale = _ctrl;
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
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primaryGreen.withValues(alpha: 0.06)
                : AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primaryGreen
                  : AppColors.borderLight,
              width: widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? AppColors.primaryGreen
                          : AppColors.primaryGreen.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.recipient.initials,
                      style: AppTypography.labelMedium.copyWith(
                        color: widget.isSelected
                            ? AppColors.white
                            : AppColors.primaryGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  // Favorite badge
                  if (widget.recipient.isFavorite)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFC107),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),

                  // Selected checkmark
                  if (widget.isSelected)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Name
              Text(
                widget.recipient.name.split(' ').first,
                style: AppTypography.labelSmall.copyWith(
                  color: widget.isSelected
                      ? AppColors.primaryGreen
                      : AppColors.textPrimary,
                  fontWeight:
                      widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Add recipient card ───────────────────────────────────────────────────────
class _AddRecipientCard extends StatefulWidget {
  @override
  State<_AddRecipientCard> createState() => _AddRecipientCardState();
}

class _AddRecipientCardState extends State<_AddRecipientCard>
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
          width: 80,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: Border.all(
              color: AppColors.borderLight,
              style: BorderStyle.solid,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.primaryGreen,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Selected recipient info ──────────────────────────────────────────────────
class _SelectedRecipientInfo extends StatelessWidget {
  const _SelectedRecipientInfo({required this.recipient});
  final RecipientModel recipient;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                recipient.initials,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipient.name,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (recipient.bank.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      recipient.bank,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (recipient.account.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      _maskAccount(recipient.account),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.primaryGreen,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  String _maskAccount(String account) {
    if (account.length < 8) return account;
    final visible = account.substring(account.length - 6);
    return '•••• •••• $visible';
  }
}
