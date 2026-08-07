import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/transfer_models.dart';
import '../providers/transfers_state.dart';

class TransferResultView extends StatelessWidget {
  const TransferResultView({
    super.key,
    required this.result,
    required this.draft,
    required this.onDone,
  });

  final IntraTransferResponse result;
  final TransferDraft draft;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final success = result.status != 'FAILED';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
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
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: (success ? AppColors.primaryGreen : AppColors.primaryRed)
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      success
                          ? Icons.check_rounded
                          : Icons.close_rounded,
                      color: success
                          ? AppColors.primaryGreen
                          : AppColors.primaryRed,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    success ? 'Transfer Successful' : 'Transfer Failed',
                    textAlign: TextAlign.center,
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    success
                        ? 'Your transfer of ${draft.debitAmount.toStringAsFixed(3)} ${draft.debitCurrency} was completed.'
                        : result.status,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (result.transactionId.isNotEmpty)
                    _InfoRow(label: 'Transaction ID', value: result.transactionId),
                  if (result.transactionStatus.isNotEmpty)
                    _InfoRow(label: 'Status', value: result.transactionStatus),
                  _InfoRow(
                    label: 'Amount',
                    value:
                        '${draft.debitAmount.toStringAsFixed(3)} ${draft.debitCurrency}',
                  ),
                  if (result.debitAccountIban.isNotEmpty)
                    _InfoRow(label: 'From', value: result.debitAccountIban),
                  if (result.creditAccountIban.isNotEmpty)
                    _InfoRow(label: 'To', value: result.creditAccountIban),
                  if (result.paymentDetails.isNotEmpty)
                    _InfoRow(
                      label: 'Payment details',
                      value: result.paymentDetails.first.paymentDetail,
                    ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            child: SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeight,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                ),
                child: Text(
                  success ? 'Done' : 'Back to Transfer',
                  style: AppTypography.buttonLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}