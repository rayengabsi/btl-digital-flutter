class CustomerAccount {
  const CustomerAccount({
    required this.accountId,
    this.arrangementId,
    required this.productName,
    required this.iban,
    required this.currencyId,
    this.availableBalance,
    this.workingBalance,
  });

  final String accountId;
  final String? arrangementId;
  final String productName;
  final String iban;
  final String currencyId;
  final double? availableBalance;
  final double? workingBalance;

  factory CustomerAccount.fromJson(Map<String, dynamic> json) {
    return CustomerAccount(
      accountId: json['accountId'] as String? ?? '',
      arrangementId: json['arrangementId'] as String?,
      productName: json['productName'] as String? ?? '',
      iban: json['iban'] as String? ?? '',
      currencyId: json['currencyId'] as String? ?? 'TND',
      availableBalance: (json['availableBalance'] as num?)?.toDouble(),
      workingBalance: (json['workingBalance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'arrangementId': arrangementId,
        'productName': productName,
        'iban': iban,
        'currencyId': currencyId,
        'availableBalance': availableBalance,
        'workingBalance': workingBalance,
      };
}
