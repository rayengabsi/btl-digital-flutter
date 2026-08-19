import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../accounts/data/models/customer_account_model.dart';
import '../../../beneficiaries/data/models/beneficiary_model.dart';
import '../../data/datasources/mock_transfer_data_source.dart';

/// Static demo data for the Transfer form — no backend calls.
final mockTransferDataSourceProvider = Provider<MockTransferDataSource>(
  (ref) => const MockTransferDataSource(),
);

final mockTransferAccountsProvider = Provider<List<CustomerAccount>>(
  (ref) => ref.watch(mockTransferDataSourceProvider).accounts,
);

final mockBeneficiariesProvider = Provider<List<Beneficiary>>(
  (ref) => ref.watch(mockTransferDataSourceProvider).beneficiaries,
);