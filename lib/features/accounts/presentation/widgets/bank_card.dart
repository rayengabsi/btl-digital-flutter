import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/utils/amount_formatter.dart';
import '../../data/models/payment_card_model.dart';

/// Premium dark-green BTL bank card used on the Cards screen carousel and the
/// Card Details sheet. Fills its parent width; pass [height] when the parent
/// does not enforce a height.
class BankCard extends StatelessWidget {
  const BankCard({
    super.key,
    required this.card,
    this.isFrozen = false,
    this.height,
  });

  final PaymentCard card;
  final bool isFrozen;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isFrozen
              ? const [Color(0xFF4B5563), Color(0xFF1F2937)]
              : const [Color(0xFF0B6B53), Color(0xFF004B3A)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Premium abstract BTL graphic ─────────────────────────
          Positioned(
            right: -40,
            top: -50,
            child: _ArtCircle(size: 170),
          ),
          Positioned(
            right: 70,
            top: -30,
            child: _ArtCircle(size: 90),
          ),
          Positioned(
            right: -20,
            bottom: -70,
            child: _ArtCircle(size: 160),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      card.bankName,
                      style: AppTypography.h6.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      card.cardType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const _Chip(),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.contactless_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  card.maskedNumber,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    decoration: isFrozen ? TextDecoration.lineThrough : null,
                    decorationThickness: 1.5,
                  ),
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardInfo(label: 'CARDHOLDER', value: card.cardHolder),
                    const Spacer(),
                    _CardInfo(label: 'EXPIRY', value: card.expiry),
                  ],
                ),
                const SizedBox(height: 10),
                _CardInfo(
                  label: 'BALANCE',
                  value: '${formatAmountWithComma(card.balance)} ${card.currency}',
                  valueColor: Colors.white,
                ),
              ],
            ),
          ),

          if (isFrozen)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.30),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: const EdgeInsets.all(14),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.ac_unit_rounded,
                            size: 14, color: AppColors.primaryRed),
                        SizedBox(width: 4),
                        Text(
                          'FROZEN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryRed,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ArtCircle extends StatelessWidget {
  const _ArtCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.06),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4E3B2), Color(0xFFD9B96A), Color(0xFFB8933F)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Center(
        child: Container(
          width: 24,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.black.withValues(alpha: 0.18)),
          ),
        ),
      ),
    );
  }
}

class _CardInfo extends StatelessWidget {
  const _CardInfo({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}