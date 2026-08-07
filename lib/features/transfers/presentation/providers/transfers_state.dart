import '../../data/models/transfer_models.dart';

/// Presentation summary of a transfer being initiated, used to render the
/// OTP confirmation and result screens.
class TransferDraft {
  const TransferDraft({
    required this.debitAccountId,
    required this.debitCurrency,
    required this.debitAmount,
    required this.creditAccountId,
    required this.paymentDetail,
    this.debitIban,
    this.debitProductName,
  });

  final String debitAccountId;
  final String debitCurrency;
  final double debitAmount;
  final String creditAccountId;
  final String paymentDetail;
  final String? debitIban;
  final String? debitProductName;

  TransferDraft copyWith({String? debitIban, String? debitProductName}) {
    return TransferDraft(
      debitAccountId: debitAccountId,
      debitCurrency: debitCurrency,
      debitAmount: debitAmount,
      creditAccountId: creditAccountId,
      paymentDetail: paymentDetail,
      debitIban: debitIban ?? this.debitIban,
      debitProductName: debitProductName ?? this.debitProductName,
    );
  }
}

sealed class TransferState {
  const TransferState();
}

/// Idle, ready to show the transfer form.
class TransferIdle extends TransferState {
  const TransferIdle();
}

/// Initiation request in flight.
class TransferInitiating extends TransferState {
  const TransferInitiating();
}

/// Initiation succeeded; OTP is required to confirm the transfer.
class TransferOtpRequired extends TransferState {
  const TransferOtpRequired({
    required this.transferDemandId,
    required this.otpExpiresAt,
    required this.draft,
  });

  final int transferDemandId;
  final String otpExpiresAt;
  final TransferDraft draft;
}

/// OTP confirmation request in flight.
class TransferConfirming extends TransferState {
  const TransferConfirming();
}

/// Transfer confirmed and booked successfully.
class TransferSuccess extends TransferState {
  const TransferSuccess({required this.result, required this.draft});

  final IntraTransferResponse result;
  final TransferDraft draft;
}

/// A recoverable or terminal error during the transfer flow.
class TransferError extends TransferState {
  const TransferError({
    required this.message,
    this.errorCode,
    this.details = const [],
  });

  final String message;
  final String? errorCode;
  final List<String> details;
}

/// History for the authenticated user's transfer demands.
class TransferHistoryState {
  const TransferHistoryState({
    this.demands = const [],
    this.page = 0,
    this.size = 20,
    this.totalElements = 0,
    this.totalPages = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.hasLoaded = false,
  });

  final List<TransferDemand> demands;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool hasLoaded;

  TransferHistoryState copyWith({
    List<TransferDemand>? demands,
    int? page,
    int? size,
    int? totalElements,
    int? totalPages,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    bool? hasLoaded,
  }) {
    return TransferHistoryState(
      demands: demands ?? this.demands,
      page: page ?? this.page,
      size: size ?? this.size,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }

  bool get hasNextPage => demands.length < totalElements;
}