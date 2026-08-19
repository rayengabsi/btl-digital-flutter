import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../accounts/data/models/account_transaction_model.dart';
import '../../../accounts/data/models/customer_account_model.dart';
import '../../data/datasources/mock_home_data_source.dart';

/// Backs the Home/Dashboard screen with static demo data while the real
/// banking APIs are not yet integrated. Swap the data source below for the
/// live accounts/transactions repository when wiring up the API.
final mockHomeDataSourceProvider = Provider<MockHomeDataSource>(
  (ref) => const MockHomeDataSource(),
);

final homePrimaryAccountProvider = FutureProvider<CustomerAccount>((ref) async {
  return ref.watch(mockHomeDataSourceProvider).primaryAccount;
});

/// Static recent transactions shown on the dashboard.
final homeRecentTransactionsProvider =
    FutureProvider<List<AccountTransaction>>((ref) async {
  return ref.watch(mockHomeDataSourceProvider).recentTransactions;
});