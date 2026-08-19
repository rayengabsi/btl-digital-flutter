import '../../../accounts/data/models/account_transaction_model.dart';
import '../../../accounts/data/models/customer_account_model.dart';

/// Temporary static demo data for the Home/Dashboard screen.
///
/// This exists only until the real banking APIs are integrated into the Home
/// screen. Replace this source with the live accounts/transactions API later;
/// no widgets or providers need to change, only the backing data.
class MockHomeDataSource {
  const MockHomeDataSource();

  /// Single primary account shown on the Home dashboard.
  CustomerAccount get primaryAccount => const CustomerAccount(
        accountId: 'ACC-TND-0001',
        productName: 'Primary Account',
        iban: 'TN59 1000 6035 1835 9847 8831',
        currencyId: 'TND',
        availableBalance: 12450.80,
        workingBalance: 12450.80,
      );

  /// Static recent transactions, newest first.
  ///
  /// [AccountTransaction.iconName] drives the professional per-transaction
  /// icon shown on the dashboard (e.g. receipt, shopping cart, mobile).
  List<AccountTransaction> get recentTransactions => const [
        AccountTransaction(
          accountId: 'ACC-TND-0001',
          transactionReference: 'TX-SAL-0001',
          transactionCode: 'TRN_SALARY',
          bookingDate: 'Today, 08:30 AM',
          valueDate: 'Today, 08:30 AM',
          creditAmount: 2500.00,
          narratives: ['Salary'],
          iconName: 'salary',
        ),
        AccountTransaction(
          accountId: 'ACC-TND-0001',
          transactionReference: 'TX-NFLX-0002',
          transactionCode: 'TRN_SUBSCRIPTION',
          bookingDate: 'Yesterday, 10:15 PM',
          valueDate: 'Yesterday, 10:15 PM',
          debitAmount: 29.99,
          narratives: ['Netflix Subscription'],
          iconName: 'receipt',
        ),
        AccountTransaction(
          accountId: 'ACC-TND-0001',
          transactionReference: 'TX-CRF-0003',
          transactionCode: 'TRN_POS',
          bookingDate: 'May 17, 2025',
          valueDate: 'May 17, 2025',
          debitAmount: 78.60,
          narratives: ['Carrefour Market'],
          iconName: 'shopping',
        ),
        AccountTransaction(
          accountId: 'ACC-TND-0001',
          transactionReference: 'TX-OOR-0004',
          transactionCode: 'TRN_TOPUP',
          bookingDate: 'May 16, 2025',
          valueDate: 'May 16, 2025',
          debitAmount: 10.00,
          narratives: ['Ooredoo Recharge'],
          iconName: 'mobile',
        ),
      ];
}