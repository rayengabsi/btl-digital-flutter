import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../auth/presentation/providers/auth_dependencies.dart';
import '../../data/datasources/accounts_remote_data_source.dart';
import '../../data/models/account_transaction_model.dart';
import '../../data/models/customer_account_model.dart';
import '../../data/repositories/accounts_repository_impl.dart';
import '../../domain/repositories/accounts_repository.dart';


final accountsRemoteDataSourceProvider = Provider<AccountsRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AccountsRemoteDataSource(dioClient: dioClient);
});

final accountsRepositoryProvider = Provider<AccountsRepository>((ref) {
  final remoteDataSource = ref.watch(accountsRemoteDataSourceProvider);
  return AccountsRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Fetches customer bank accounts list
final customerAccountsProvider = FutureProvider<List<CustomerAccount>>((ref) async {
  final repository = ref.watch(accountsRepositoryProvider);
  return repository.getAccounts();
});

/// Transaction pagination state model
class TransactionSearchState {
  const TransactionSearchState({
    required this.iban,
    required this.fromDate,
    required this.toDate,
    this.pageSize = 20,
    this.nextPageToken,
    this.transactions = const [],
    this.summary,
    this.totalSize = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  final String iban;
  final String fromDate;
  final String toDate;
  final int pageSize;
  final String? nextPageToken;
  final List<AccountTransaction> transactions;
  final AccountStatementSummary? summary;
  final int totalSize;
  final bool isLoading;
  final String? errorMessage;

  TransactionSearchState copyWith({
    String? iban,
    String? fromDate,
    String? toDate,
    int? pageSize,
    String? nextPageToken,
    bool clearToken = false,
    List<AccountTransaction>? transactions,
    AccountStatementSummary? summary,
    int? totalSize,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TransactionSearchState(
      iban: iban ?? this.iban,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      pageSize: pageSize ?? this.pageSize,
      nextPageToken: clearToken ? null : (nextPageToken ?? this.nextPageToken),
      transactions: transactions ?? this.transactions,
      summary: summary ?? this.summary,
      totalSize: totalSize ?? this.totalSize,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class TransactionSearchNotifier extends Notifier<TransactionSearchState> {
  @override
  TransactionSearchState build() {
    return const TransactionSearchState(
      iban: '',
      fromDate: '',
      toDate: '',
    );
  }

  void startSearch({
    required String iban,
    required String fromDate,
    required String toDate,
    int pageSize = 20,
  }) {
    state = TransactionSearchState(
      iban: iban,
      fromDate: fromDate,
      toDate: toDate,
      pageSize: pageSize,
      nextPageToken: null,
      transactions: const [],
      totalSize: 0,
      isLoading: false,
    );

    loadNextPage();
  }

  Future<void> loadNextPage() async {
    if (state.iban.isEmpty || state.fromDate.isEmpty || state.toDate.isEmpty) return;
    if (state.isLoading) return;

    // Check stop condition: loaded records >= totalSize
    if (state.transactions.isNotEmpty && state.transactions.length >= state.totalSize) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repository = ref.read(accountsRepositoryProvider);
      final query = AccountTransactionQuery(
        fromDate: state.fromDate,
        toDate: state.toDate,
        pageSize: state.pageSize,
        pageToken: state.nextPageToken,
      );

      final response = await repository.getTransactions(state.iban, query);

      final updatedTransactions = [...state.transactions, ...response.transactions];
      final totalSize = response.pagination.totalSize ?? updatedTransactions.length;
      final hasNext = updatedTransactions.length < totalSize;

      state = state.copyWith(
        isLoading: false,
        transactions: updatedTransactions,
        summary: response.summary ?? state.summary,
        totalSize: totalSize,
        nextPageToken: hasNext ? response.pagination.pageToken : null,
        clearToken: !hasNext,
      );
    } catch (e) {
      if (e is ApiException && e.errorCode == 'INVALID_PAGE_TOKEN') {
        // Restart from page 1 on invalid page token
        startSearch(
          iban: state.iban,
          fromDate: state.fromDate,
          toDate: state.toDate,
          pageSize: state.pageSize,
        );
        return;
      }
      final msg = e is ApiException ? e.message : 'Failed to load transactions';
      state = state.copyWith(isLoading: false, errorMessage: msg);
    }
  }
}

final transactionSearchNotifierProvider =
    NotifierProvider<TransactionSearchNotifier, TransactionSearchState>(
  TransactionSearchNotifier.new,
);

/// Recent transactions for the user's primary account, shown on the dashboard.
/// Scoped separately from [transactionSearchNotifierProvider] to avoid
/// interfering with the account/cards screen's paginated search.
final recentTransactionsProvider =
    AsyncNotifierProvider<RecentTransactionsNotifier, List<AccountTransaction>>(
  RecentTransactionsNotifier.new,
);

class RecentTransactionsNotifier extends AsyncNotifier<List<AccountTransaction>> {
  @override
  Future<List<AccountTransaction>> build() async {
    final accounts = await ref.watch(customerAccountsProvider.future);
    if (accounts.isEmpty) return const [];
    final primary = accounts.first;
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 90));

    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final repository = ref.watch(accountsRepositoryProvider);
    final response = await repository.getTransactions(
      primary.iban,
      AccountTransactionQuery(
        fromDate: fmt(from),
        toDate: fmt(now),
        pageSize: 20,
      ),
    );
    return response.transactions;
  }
}
