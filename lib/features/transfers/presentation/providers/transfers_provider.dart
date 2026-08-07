import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../auth/presentation/providers/auth_dependencies.dart';
import '../../data/datasources/transfers_remote_data_source.dart';
import '../../data/models/transfer_models.dart';
import '../../data/repositories/transfers_repository_impl.dart';
import '../../domain/repositories/transfers_repository.dart';
import 'transfers_state.dart';

// ─── Dependency injection ─────────────────────────────────────────────────────

final transfersRemoteDataSourceProvider = Provider<TransfersRemoteDataSource>(
  (ref) {
    final dioClient = ref.watch(dioClientProvider);
    return TransfersRemoteDataSource(dioClient: dioClient);
  },
);

final transfersRepositoryProvider = Provider<TransfersRepository>(
  (ref) {
    final remoteDataSource = ref.watch(transfersRemoteDataSourceProvider);
    return TransfersRepositoryImpl(remoteDataSource: remoteDataSource);
  },
);

// ─── Transfer flow controller ─────────────────────────────────────────────────

final transferControllerProvider =
    NotifierProvider<TransferController, TransferState>(TransferController.new);

class TransferController extends Notifier<TransferState> {
  @override
  TransferState build() => const TransferIdle();

  TransfersRepository get _repository => ref.read(transfersRepositoryProvider);

  /// Initiate an intra transfer: validates server-side and requests an OTP.
  Future<void> initiate(TransferDraft draft) async {
    state = const TransferInitiating();
    try {
      final request = IntraTransferRequest(
        transactionType: 'AC',
        debitAccountId: draft.debitAccountId,
        debitCurrency: draft.debitCurrency,
        debitAmount: draft.debitAmount,
        creditAccountId: draft.creditAccountId,
        paymentDetails: [
          PaymentDetailRequest(paymentDetail: draft.paymentDetail),
        ],
      );
      final response = await _repository.initiateIntraTransfer(request);
      state = TransferOtpRequired(
        transferDemandId: response.transferDemandId,
        otpExpiresAt: response.otpExpiresAt,
        draft: draft,
      );
    } catch (e) {
      _handleError(e);
    }
  }

  /// Confirm the pending transfer with the received OTP.
  Future<void> confirm(int transferDemandId, String otp) async {
    state = const TransferConfirming();
    try {
      final request = ConfirmIntraTransferRequest(
        transferDemandId: transferDemandId,
        otp: otp.trim(),
      );
      final result = await _repository.confirmIntraTransfer(request);
      final current = state;
      final draft = (current is TransferOtpRequired) ? current.draft : null;
      state = TransferSuccess(
        result: result,
        draft: draft ??
            TransferDraft(
              debitAccountId: result.debitAccountId,
              debitCurrency: result.debitCurrency,
              debitAmount: result.debitAmount,
              creditAccountId: result.creditAccountId,
              paymentDetail: _paymentDetailFrom(result),
            ),
      );
    } catch (e) {
      _handleError(e);
    }
  }

  String _paymentDetailFrom(IntraTransferResponse result) {
    if (result.paymentDetails.isNotEmpty) {
      return result.paymentDetails.first.paymentDetail;
    }
    return '';
  }

  void reset() {
    state = const TransferIdle();
  }

  void _handleError(dynamic error) {
    if (error is ApiException) {
      state = TransferError(
        message: error.message,
        errorCode: error.errorCode,
        details: error.details,
      );
    } else {
      state = const TransferError(
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }
}

// ─── Transfer demand history ──────────────────────────────────────────────────

final transferHistoryControllerProvider =
    NotifierProvider<TransferHistoryController, TransferHistoryState>(
  TransferHistoryController.new,
);

class TransferHistoryController extends Notifier<TransferHistoryState> {
  @override
  TransferHistoryState build() => const TransferHistoryState();

  TransfersRepository get _repository => ref.read(transfersRepositoryProvider);

  Future<void> loadFirstPage({String? from, String? to}) async {
    final prev = state;
    state = prev.copyWith(
      isLoading: true,
      clearError: true,
      page: 0,
      demands: const [],
      from: from,
      to: to,
    );
    try {
      final page = await _repository.getTransferDemands(
        TransferDemandQuery(page: 0, size: prev.size, from: from, to: to),
      );
      state = TransferHistoryState(
        demands: page.content,
        page: page.page,
        size: page.size,
        totalElements: page.totalElements,
        totalPages: page.totalPages,
        hasLoaded: true,
        from: from,
        to: to,
      );
    } catch (e) {
      state = prev.copyWith(isLoading: false, errorMessage: _message(e));
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingMore || !state.hasNextPage) return;
    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final page =
          await _repository.getTransferDemands(
            TransferDemandQuery(
              page: nextPage,
              size: state.size,
              from: state.from,
              to: state.to,
            ),
          );
      final merged = [...state.demands, ...page.content];
      state = TransferHistoryState(
        demands: merged,
        page: page.page,
        size: page.size,
        totalElements: page.totalElements,
        totalPages: page.totalPages,
        hasLoaded: true,
        from: state.from,
        to: state.to,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, errorMessage: _message(e));
    }
  }

  String _message(dynamic e) {
    if (e is ApiException) return e.message;
    return 'Failed to load transfer history. Please try again.';
  }
}