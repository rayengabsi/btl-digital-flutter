import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/widgets/btl_bottom_nav.dart';
import '../providers/transfers_provider.dart';
import '../providers/transfers_state.dart';
import '../widgets/transfer_form_view.dart';
import '../widgets/transfer_history_view.dart';
import '../widgets/transfer_otp_view.dart';
import '../widgets/transfer_result_view.dart';

enum _TransferMode { transfer, history }

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key, this.onNavTap});

  final ValueChanged<int>? onNavTap;

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  int _navIndex = 2;
  _TransferMode _mode = _TransferMode.transfer;

  void _reset() => ref.read(transferControllerProvider.notifier).reset();

  @override
  Widget build(BuildContext context) {
    final transferState = ref.watch(transferControllerProvider);
    final inFlow = transferState is! TransferIdle;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/dashboard_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(inFlow: inFlow),
                Expanded(child: _buildBody(transferState)),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BtlBottomNav(
              currentIndex: _navIndex,
              onTap: (i) {
                if (widget.onNavTap != null) {
                  widget.onNavTap!(i);
                } else {
                  setState(() => _navIndex = i);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar({required bool inFlow}) {
    if (!inFlow) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        child: _ModeToggle(mode: _mode, onToggle: _setMode),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: _reset,
            child: const CircleAvatar(
              radius: 23,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Transfers',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 46),
        ],
      ),
    );
  }

  void _setMode(_TransferMode mode) {
    setState(() => _mode = mode);
  }

  Widget _buildBody(TransferState transferState) {
    if (transferState is! TransferIdle) {
      return switch (transferState) {
        TransferSuccess(:final result, :final draft) => TransferResultView(
            result: result,
            draft: draft,
            onDone: _reset,
          ),
        TransferOtpRequired(
          :final transferDemandId,
          :final otpExpiresAt,
          :final draft,
        ) =>
          TransferOtpView(
            transferDemandId: transferDemandId,
            otpExpiresAt: otpExpiresAt,
            draft: draft,
            onBack: _reset,
          ),
        TransferInitiating() || TransferConfirming() => const _LoadingBody(),
        TransferError(:final message, :final errorCode, :final details) =>
          _TransferErrorBody(
            message: message,
            errorCode: errorCode,
            details: details,
            onRetry: _reset,
          ),
        TransferIdle() => const SizedBox.shrink(),
      };
    }

    if (_mode == _TransferMode.history) {
      return const TransferHistoryView();
    }
    return const TransferFormView();
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onToggle});

  final _TransferMode mode;
  final ValueChanged<_TransferMode> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          height: 46,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _Segment(
                  label: 'New Transfer',
                  selected: mode == _TransferMode.transfer,
                  onTap: () => onToggle(_TransferMode.transfer),
                ),
              ),
              Expanded(
                child: _Segment(
                  label: 'History',
                  selected: mode == _TransferMode.history,
                  onTap: () => onToggle(_TransferMode.history),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryGreen),
    );
  }
}

class _TransferErrorBody extends StatelessWidget {
  const _TransferErrorBody({
    required this.message,
    required this.errorCode,
    required this.details,
    required this.onRetry,
  });

  final String message;
  final String? errorCode;
  final List<String> details;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final text = details.isNotEmpty ? '$message\n${details.join('\n')}' : message;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.primaryRed,
            ),
            const SizedBox(height: 12),
            Text(
              'Transfer Unsuccessful',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Back to Transfer'),
            ),
          ],
        ),
      ),
    );
  }
}