import '../../../accounts/data/models/customer_account_model.dart';
import '../../../beneficiaries/data/models/beneficiary_model.dart';

/// Temporary static demo data for the Transfers screen.
///
/// This exists only until the real account/beneficiary APIs are integrated
/// into the Transfer form. Replace this source with the live APIs later; no
/// widgets need to change, only the backing data.
class MockTransferDataSource {
  const MockTransferDataSource();

  List<CustomerAccount> get accounts => const [
        CustomerAccount(
          accountId: 'ACC-PRIMARY-001',
          productName: 'Primary Account',
          iban: 'TN5926028000890207513565',
          currencyId: 'TND',
          availableBalance: 12450.80,
          workingBalance: 12450.80,
        ),
      ];

  List<Beneficiary> get beneficiaries => const [
        Beneficiary(
          id: 1,
          beneficiaryName: 'Ahmed Ben Ali',
          ribNumber: 'TN5926028000890207513565',
        ),
        Beneficiary(
          id: 2,
          beneficiaryName: 'Sarah Trabelsi',
          ribNumber: 'TN5926028000890212345678',
        ),
        Beneficiary(
          id: 3,
          beneficiaryName: 'Mohamed Haddad',
          ribNumber: 'TN5926028000890234567890',
        ),
      ];
}