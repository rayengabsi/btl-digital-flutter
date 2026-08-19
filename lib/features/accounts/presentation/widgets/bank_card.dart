import 'package:flutter/material.dart';

import '../../data/models/payment_card_model.dart';

/// Displays the existing BTL card artwork as a clean image.
///
/// The image already contains the complete card design (logo, number, chip,
/// graphics). No widgets or text are drawn on top of it. The card keeps its
/// original artwork, colors, proportions and rounded corners.
class BankCard extends StatelessWidget {
  const BankCard({
    super.key,
    required this.card,
    this.isFrozen = false,
  });

  final PaymentCard card;
  final bool isFrozen;

  static const double _aspectRatio = 1500 / 1000;

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      card.imagePath,
      key: ValueKey('bank-card-image-${card.id}'),
      fit: BoxFit.cover,
      width: double.infinity,
    );

    if (isFrozen) {
      image = ColorFiltered(colorFilter: _grayscale, child: image);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: _aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: image,
        ),
      ),
    );
  }

  static const ColorFilter _grayscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0,
  ]);
}