import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/account_transaction_model.dart';
import '../models/customer_account_model.dart';

class AccountsRemoteDataSource {
  AccountsRemoteDataSource({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  /// Fetch authenticated customer accounts
  Future<List<CustomerAccount>> getAccounts() async {
    final response = await _dioClient.get(ApiEndpoints.accounts);
    final apiResponse = ApiResponse<List<CustomerAccount>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) {
        final list = data as List? ?? [];
        return list
            .map((e) => CustomerAccount.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return apiResponse.data ?? [];
  }

  /// Get account statement transactions with query filters & page token
  Future<AccountTransactionsResponse> getTransactions(
    String iban,
    AccountTransactionQuery query,
  ) async {
    final response = await _dioClient.get(
      ApiEndpoints.accountTransactions(iban),
      queryParameters: query.toQueryParams(),
    );
    final apiResponse = ApiResponse<AccountTransactionsResponse>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => AccountTransactionsResponse.fromJson(data as Map<String, dynamic>),
    );
    if (apiResponse.data == null) {
      throw Exception('Failed to parse account transactions data');
    }
    return apiResponse.data!;
  }
}
