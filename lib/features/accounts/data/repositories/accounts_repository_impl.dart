import '../../../../core/network/api_exception.dart';
import '../datasources/accounts_remote_data_source.dart';
import '../models/account_transaction_model.dart';
import '../models/customer_account_model.dart';
import '../../domain/repositories/accounts_repository.dart';

class AccountsRepositoryImpl implements AccountsRepository {
  AccountsRepositoryImpl({required AccountsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final AccountsRemoteDataSource _remoteDataSource;

  @override
  Future<List<CustomerAccount>> getAccounts() async {
    try {
      return await _remoteDataSource.getAccounts();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Unable to fetch accounts. Please try again.',
        statusCode: 500,
      );
    }
  }

  @override
  Future<AccountTransactionsResponse> getTransactions(
    String iban,
    AccountTransactionQuery query,
  ) async {
    try {
      return await _remoteDataSource.getTransactions(iban, query);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Unable to fetch account transactions. Please try again.',
        statusCode: 500,
      );
    }
  }
}
