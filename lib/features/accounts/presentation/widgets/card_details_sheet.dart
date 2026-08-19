import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/utils/amount_formatter.dart';
import '../../data/models/payment_card_model.dart';
import '../providers/cards_providers.dart';
import 'bank_card.dart';

/// Premium Card Details bottom sheet. Uses static demo data only — the
/// "full" card number is a fake value for local show/hide previews.
class CardDetailsSheet extends ConsumerStatefulWidget {
  const CardDetailsSheet({super.key, required this.card});

  final PaymentCard card;

  @override
  ConsumerState<CardDetailsSheet> createState() => _CardDetailsSheetState();
}

class _CardDetailsSheetState extends ConsumerState<CardDetailsSheet> {
  bool _revealed = false;

  void _copyNumber() {
    final value = _revealed ? widget.card.fullNumber : widget.card.maskedNumber;
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Card number copied')),
    );
  }

  void _toggleFreeze() {
    toggleFrozenCard(ref, widget.card.id);
  }

  @override
  Widget build(BuildContext context) {
    final isFrozen = ref.watch(frozenCardsProvider).contains(widget.card.id);
    final number = _revealed ? widget.card.fullNumber : widget.card.maskedNumber;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Card Details',
                      style: AppTypography.h5.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                BankCard(card: widget.card, isFrozen: isFrozen),
                const SizedBox(height: 20),
                _DetailRow(
                  title: 'Cardholder',
                  value: widget.card.cardHolder,
                ),
                _DetailRow(
                  title: 'Card Number',
                  valueWidget: Text(
                    number,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _DetailRow(title: 'Expiry Date', value: widget.card.expiry),
                _DetailRow(title: 'Card Type', value: widget.card.cardType),
                _DetailRow(title: 'Currency', value: widget.card.currency),
                _DetailRow(
                  title: 'Status',
                  value: isFrozen ? 'Frozen' : 'Active',
                  valueColor:
                      isFrozen ? AppColors.primaryRed : AppColors.primaryGreen,
                ),
                _DetailRow(
                  title: 'Available Balance',
                  value:
                      '${formatAmountWithComma(widget.card.balance)} ${widget.card.currency}',
                  valueColor: AppColors.primaryGreen,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _SheetAction(
                      icon: Icons.copy_rounded,
                      label: 'Copy',
                      onTap: _copyNumber,
                    ),
                    const SizedBox(width: 10),
                    _SheetAction(
                      icon: _revealed
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      label: _revealed ? 'Hide' : 'Show',
                      onTap: () => setState(() => _revealed = !_revealed),
                    ),
                    const SizedBox(width: 10),
                    _SheetAction(
                      icon: Icons.ac_unit_rounded,
                      label: isFrozen ? 'Unfreeze' : 'Freeze',
                      destructive: !isFrozen,
                      onTap: _toggleFreeze,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.title,
    this.value,
    this.valueWidget,
    this.valueColor,
  });

  final String title;
  final String? value;
  final Widget? valueWidget;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: valueWidget ??
                Text(
                  value ?? '',
                  style: AppTypography.bodyMedium.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
          ),
        ],
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.primaryRed : AppColors.primaryGreen;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}