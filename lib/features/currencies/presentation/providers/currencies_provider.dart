import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_dependencies.dart';
import '../../data/datasources/currencies_remote_data_source.dart';
import '../../data/models/currency_rate_model.dart';
import '../../data/repositories/currencies_repository_impl.dart';
import '../../domain/repositories/currencies_repository.dart';

// ─── Dependency injection ─────────────────────────────────────────────────────

final currenciesRemoteDataSourceProvider = Provider<CurrenciesRemoteDataSource>(
  (ref) {
    final dioClient = ref.watch(dioClientProvider);
    return CurrenciesRemoteDataSource(dioClient: dioClient);
  },
);

final currenciesRepositoryProvider = Provider<CurrenciesRepository>(
  (ref) {
    final remoteDataSource = ref.watch(currenciesRemoteDataSourceProvider);
    return CurrenciesRepositoryImpl(remoteDataSource: remoteDataSource);
  },
);

// ─── Rates state ──────────────────────────────────────────────────────────────

final currenciesProvider =
    AsyncNotifierProvider<CurrenciesNotifier, List<CurrencyRate>>(
  CurrenciesNotifier.new,
);

class CurrenciesNotifier extends AsyncNotifier<List<CurrencyRate>> {
  @override
  Future<List<CurrencyRate>> build() async {
    final repository = ref.read(currenciesRepositoryProvider);
    return repository.getRates(defaultCurrencyPairs);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}