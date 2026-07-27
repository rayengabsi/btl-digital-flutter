import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../pages/transfer_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Confirmation Bottom Sheet
// ═══════════════════════════════════════════════════════════════════════════════
class ConfirmationBottomSheet extends StatefulWidget {
  const ConfirmationBottomSheet({
    super.key,
    required this.recipientName,
    required this.bank,
    required this.account,
    required this.amount,
    required this.fee,
    required this.total,
    required this.transferType,
    required this.estimatedArrival,
    required this.onConfirm,
  });

  final String recipientName;
  final String bank;
  final String account;
  final double amount;
  final double fee;
  final double total;
  final TransferType transferType;
  final String estimatedArrival;
  final VoidCallback onConfirm;

  @override
  State<ConfirmationBottomSheet> createState() =>
      _ConfirmationBottomSheetState();
}

class _ConfirmationBottomSheetState extends State<ConfirmationBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) widget.onConfirm();
  }

  String _generateRef() {
    final now = DateTime.now();
    return 'BTL${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.millisecond}';
  }

  @override
  Widget build(BuildContext context) {
    final ref = _generateRef();

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXL),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
                    child: Column(
                      children: [
                        // Icon
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: AppColors.primaryGreen,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Confirm Transfer',
                          style: AppTypography.h5.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Please review your transfer details',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Details card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightBackground,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusL),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _ConfirmRow(label: 'Recipient', value: widget.recipientName),
                            _ConfirmRow(label: 'Bank', value: widget.bank),
                            _ConfirmRow(
                              label: 'Account',
                              value: widget.account.isNotEmpty
                                  ? '•••• ${widget.account.length > 6 ? widget.account.substring(widget.account.length - 6) : widget.account}'
                                  : '—',
                            ),
                            _ConfirmRow(
                              label: 'Amount',
                              value: 'TND ${widget.amount.toStringAsFixed(2)}',
                            ),
                            _ConfirmRow(
                              label: 'Fee',
                              value: 'TND ${widget.fee.toStringAsFixed(3)}',
                            ),
                            _ConfirmRow(
                              label: 'Transfer Type',
                              value: _typeLabel(widget.transferType),
                            ),
                            _ConfirmRow(
                              label: 'Estimated Arrival',
                              value: widget.estimatedArrival,
                            ),
                            _ConfirmRow(
                              label: 'Reference',
                              value: ref,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Total banner
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'TND ${widget.total.toStringAsFixed(2)}',
                            style: AppTypography.h5.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      children: [
                        // Cancel
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              height: AppDimensions.buttonHeight,
                              decoration: BoxDecoration(
                                color: AppColors.lightBackground,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusM),
                                border:
                                    Border.all(color: AppColors.borderLight),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Cancel',
                                style: AppTypography.buttonLarge.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Confirm
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: _isLoading ? null : _onConfirm,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: AppDimensions.buttonHeight,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusM),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryGreen
                                        .withValues(alpha: 0.35),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.lock_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Confirm Transfer',
                                          style:
                                              AppTypography.buttonLarge.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _typeLabel(TransferType type) {
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

// ─── Confirm row ──────────────────────────────────────────────────────────────
class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}
