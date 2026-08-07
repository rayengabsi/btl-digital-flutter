import '../../data/models/currency_rate_model.dart';

abstract interface class CurrenciesRepository {
  /// Fetches buy/sell rates for the given currency/market pairs.
  Future<List<CurrencyRate>> getRates(List<CurrencyPair> pairs);
}