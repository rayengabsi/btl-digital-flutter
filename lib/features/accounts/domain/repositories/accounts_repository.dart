import '../../data/models/account_transaction_model.dart';
import '../../data/models/customer_account_model.dart';

abstract interface class AccountsRepository {
  Future<List<CustomerAccount>> getAccounts();
  Future<AccountTransactionsResponse> getTransactions(
    String iban,
    AccountTransactionQuery query,
  );
}
