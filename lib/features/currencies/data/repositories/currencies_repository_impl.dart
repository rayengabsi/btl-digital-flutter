import '../../domain/repositories/currencies_repository.dart';
import '../datasources/currencies_remote_data_source.dart';
import '../models/currency_rate_model.dart';

class CurrenciesRepositoryImpl implements CurrenciesRepository {
  CurrenciesRepositoryImpl({required CurrenciesRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final CurrenciesRemoteDataSource _remoteDataSource;

  @override
  Future<List<CurrencyRate>> getRates(List<CurrencyPair> pairs) {
    // ApiException raised by the network layer carries a user-friendly
    // message and errorCode, so it is forwarded unchanged to the UI.
    return _remoteDataSource.fetchRates(pairs);
  }
}