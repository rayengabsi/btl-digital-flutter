import '../models/account_transaction_model.dart';
import '../models/payment_card_model.dart';

/// Temporary static demo data for the Cards screen.
///
/// This exists only until the real card/account APIs are integrated into the
/// Cards screen. Replace this source with the live API later; no widgets or
/// providers need to change, only the backing data.
class MockCardsDataSource {
  const MockCardsDataSource();

  List<PaymentCard> get cards => const [
        PaymentCard(
          id: 'CARD-4821',
          bankName: 'BTL Bank',
          cardType: 'VISA',
          cardHolder: 'RAYEN GABSI',
          maskedNumber: '•••• •••• •••• 4821',
          fullNumber: '4929 1456 8790 4821',
          expiry: '12/29',
          balance: 12450.80,
          currency: 'TND',
          imagePath: 'assets/images/Cards/card_first.png',
        ),
        PaymentCard(
          id: 'CARD-7294',
          bankName: 'BTL Bank',
          cardType: 'VISA',
          cardHolder: 'RAYEN GABSI',
          maskedNumber: '•••• •••• •••• 7294',
          fullNumber: '4929 1456 8790 7294',
          expiry: '08/28',
          balance: 27000.00,
          currency: 'TND',
          imagePath: 'assets/images/Cards/card_second.png',
        ),
      ];

  /// Static recent transactions, newest first.
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