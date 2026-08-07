import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/transfers_provider.dart';
import '../providers/transfers_state.dart';

class TransferOtpView extends ConsumerStatefulWidget {
  const TransferOtpView({
    super.key,
    required this.transferDemandId,
    required this.otpExpiresAt,
    required this.draft,
    required this.onBack,
  });

  final int transferDemandId;
  final String otpExpiresAt;
  final TransferDraft draft;
  final VoidCallback onBack;

  @override
  ConsumerState<TransferOtpView> createState() => _TransferOtpViewState();
}

class _TransferOtpViewState extends ConsumerState<TransferOtpView> {
  final _otpCtrl = TextEditingController();
  Timer? _timer;
  Duration _remaining = const Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    final expiresAt = DateTime.tryParse(widget.otpExpiresAt);
    if (expiresAt != null) {
      _remaining = expiresAt.difference(DateTime.now());
      if (_remaining.isNegative) _remaining = Duration.zero;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final delta = expiresAt?.difference(DateTime.now());
      setState(() {
        _remaining = delta == null || delta.isNegative
            ? Duration.zero
            : delta;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    super.dispose();
  }

  String get _countdown {
    final m = _remaining.inMinutes.toString().padLeft(2, '0');
    final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _onConfirm() {
    final otp = _otpCtrl.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 6-digit OTP code'),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ref
        .read(transferControllerProvider.notifier)
        .confirm(widget.transferDemandId, otp);
  }

  @override
  Widget build(BuildContext context) {
    final stillConfirming =
        ref.watch(transferControllerProvider) is TransferConfirming;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Text(
              'Confirm Transfer',
              style: AppTypography.h5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: _SummaryCard(draft: widget.draft),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Security Code',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'We sent a 6-digit OTP to verify this transfer.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _otpCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: AppTypography.h2.copyWith(letterSpacing: 10),
                    decoration: const InputDecoration(
                      hintText: '123456',
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.lightBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Code expires in $_countdown',
                        style: AppTypography.bodySmall.copyWith(
                          color: _remaining.inSeconds <= 60
                              ? AppColors.primaryRed
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeight,
              child: ElevatedButton(
                onPressed: stillConfirming ? null : _onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                ),
                child: stillConfirming
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Verify & Transfer',
                        style: AppTypography.buttonLarge.copyWith(color: Colors.white),
                      ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            child: TextButton(
              onPressed: stillConfirming ? null : widget.onBack,
              child: const Text('Cancel'),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.draft});

  final TransferDraft draft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _row('You send', '${draft.debitAmount.toStringAsFixed(3)} ${draft.debitCurrency}', bold: true),
          const Divider(height: 20, color: AppColors.divider),
          _row('Debit account', draft.debitProductName ?? draft.debitAccountId),
          _row('Recipient account', draft.creditAccountId),
          _row('Payment details', draft.paymentDetail),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}