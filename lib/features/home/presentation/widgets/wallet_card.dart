import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class WalletCard extends StatefulWidget {
  const WalletCard({super.key});

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard>
    with SingleTickerProviderStateMixin {
  bool _balanceHidden = false;
  late AnimationController _depositController;
  late Animation<double> _depositScale;

  @override
  void initState() {
    super.initState();
    _depositController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _depositScale = _depositController;
  }

  @override
  void dispose() {
    _depositController.dispose();
    super.dispose();
  }

  void _toggleBalance() {
    setState(() => _balanceHidden = !_balanceHidden);
  }

  @override
  Widget build(BuildContext context) {
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
                  'Wallet Balance',
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
            _balanceHidden
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
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
                  )
                : RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'TND ',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: '12,450',
                          style: AppTypography.h1.copyWith(
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: '.80',
                          style: AppTypography.h3.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

            const SizedBox(height: 24),

            // ─── Quick actions ────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _QuickAction(
                  icon: Icons.north_east_rounded,
                  label: 'Send',
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.south_west_rounded,
                  label: 'Request',
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.smartphone_outlined,
                  label: 'Top Up',
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Scan',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ─── Deposit button ───────────────────────────────────────
            ScaleTransition(
              scale: _depositScale,
              child: GestureDetector(
                onTapDown: (_) => _depositController.reverse(),
                onTapUp: (_) => _depositController.forward(),
                onTapCancel: () => _depositController.forward(),
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Deposit',
                    style: AppTypography.buttonLarge.copyWith(
                      color: Colors.white,
                    ),
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

// ─── Quick Action Item ────────────────────────────────────────────────────────
class _QuickAction extends StatefulWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.88,
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
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                widget.icon,
                color: AppColors.primaryGreen,
                size: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
