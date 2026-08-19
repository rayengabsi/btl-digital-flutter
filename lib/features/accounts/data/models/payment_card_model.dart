/// A bank card shown on the Cards screen / card details.
///
/// These cards carry STATIC demo data — the [fullNumber] is a fake number
/// used only for local "show/hide" previews and is never exposed as a real
/// card.
class PaymentCard {
  const PaymentCard({
    required this.id,
    required this.bankName,
    required this.cardType,
    required this.cardHolder,
    required this.maskedNumber,
    required this.fullNumber,
    required this.expiry,
    required this.balance,
    required this.imagePath,
    this.currency = 'TND',
  });

  final String id;
  final String bankName;
  final String cardType;
  final String cardHolder;

  /// Existing card artwork asset (the image already contains the full card
  /// design — no widget text is drawn on top of it).
  final String imagePath;

  /// Display value, e.g. '•••• •••• •••• 4821'.
  final String maskedNumber;

  /// Fake demo number used only for local show/hide previews.
  final String fullNumber;

  final String expiry;
  final double balance;
  final String currency;
}