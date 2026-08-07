/// A single currency/market pair sent to the rates endpoint.
class CurrencyPair {
  const CurrencyPair({required this.currencyId, required this.market});

  final String currencyId;
  final String market;

  Map<String, dynamic> toJson() => {
        'currencyId': currencyId,
        'market': market,
      };
}

/// The default set of currency/market pairs requested when opening the
/// currency screen. `market` is a T24 market identifier string.
const defaultCurrencyPairs = <CurrencyPair>[
  CurrencyPair(currencyId: 'AED', market: '10'),
  CurrencyPair(currencyId: 'BHD', market: '1'),
];

/// A buy/sell rate returned by POST /api/v1/currencies/rates.
class CurrencyRate {
  const CurrencyRate({
    required this.currencyId,
    required this.displayName,
    required this.sellMarket,
    required this.buyMarket,
  });

  final String currencyId;
  final String displayName;
  final double sellMarket;
  final double buyMarket;

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    return CurrencyRate(
      currencyId: json['currencyId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      sellMarket: (json['sellMarket'] as num?)?.toDouble() ?? 0,
      buyMarket: (json['buyMarket'] as num?)?.toDouble() ?? 0,
    );
  }
}