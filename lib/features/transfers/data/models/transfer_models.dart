import 'package:flutter/foundation.dart';

// ─── 1. Initiate Intra Transfer ───────────────────────────────────────────────

class PaymentDetailRequest {
  const PaymentDetailRequest({required this.paymentDetail});

  final String paymentDetail;

  Map<String, dynamic> toJson() => {'paymentDetail': paymentDetail};
}

class IntraTransferRequest {
  const IntraTransferRequest({
    required this.transactionType,
    required this.debitAccountId,
    required this.debitCurrency,
    required this.debitAmount,
    required this.creditAccountId,
    required this.paymentDetails,
  });

  final String transactionType;
  final String debitAccountId;
  final String debitCurrency;
  final double debitAmount;
  final String creditAccountId;
  final List<PaymentDetailRequest> paymentDetails;

  Map<String, dynamic> toJson() => {
        'transactionType': transactionType,
        'debitAccountId': debitAccountId,
        'debitCurrency': debitCurrency,
        'debitAmount': debitAmount,
        'creditAccountId': creditAccountId,
        'paymentDetails': paymentDetails.map((e) => e.toJson()).toList(),
      };
}

class IntraTransferInitiationResponse {
  const IntraTransferInitiationResponse({
    required this.transferDemandId,
    required this.status,
    required this.otpExpiresAt,
  });

  final int transferDemandId;
  final String status;
  final String otpExpiresAt;

  factory IntraTransferInitiationResponse.fromJson(Map<String, dynamic> json) {
    return IntraTransferInitiationResponse(
      transferDemandId: json['transferDemandId'] as int? ?? 0,
      status: json['status'] as String? ?? 'PENDING',
      otpExpiresAt: json['otpExpiresAt'] as String? ?? '',
    );
  }
}

// ─── 2. Confirm Intra Transfer ────────────────────────────────────────────────

class ConfirmIntraTransferRequest {
  const ConfirmIntraTransferRequest({
    required this.transferDemandId,
    required this.otp,
  });

  final int transferDemandId;
  final String otp;

  Map<String, dynamic> toJson() => {
        'transferDemandId': transferDemandId,
        'otp': otp,
      };
}

class PaymentDetailResponse {
  const PaymentDetailResponse({required this.paymentDetail});

  final String paymentDetail;

  factory PaymentDetailResponse.fromJson(Map<String, dynamic> json) {
    return PaymentDetailResponse(
      paymentDetail: json['paymentDetail'] as String? ?? '',
    );
  }
}

class OverrideDetailResponse {
  const OverrideDetailResponse({
    required this.code,
    required this.id,
    required this.type,
    required this.description,
    required this.options,
  });

  final String code;
  final String id;
  final String type;
  final String description;
  final List<String> options;

  factory OverrideDetailResponse.fromJson(Map<String, dynamic> json) {
    final opts = json['options'] as List? ?? [];
    return OverrideDetailResponse(
      code: json['code'] as String? ?? '',
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      options: opts.map((e) => e.toString()).toList(),
    );
  }
}

class IntraTransferResponse {
  const IntraTransferResponse({
    required this.transactionId,
    required this.status,
    required this.transactionStatus,
    required this.transactionType,
    required this.debitAccountId,
    required this.debitAccountIban,
    required this.debitCurrency,
    required this.debitAmount,
    required this.debitValueDate,
    required this.creditAccountId,
    required this.creditAccountIban,
    required this.creditCurrencyId,
    required this.creditValueDate,
    required this.commissionCode,
    required this.profitCentreCustomer,
    required this.paymentDetails,
    required this.overrideDetails,
  });

  final String transactionId;
  final String status;
  final String transactionStatus;
  final String transactionType;
  final String debitAccountId;
  final String debitAccountIban;
  final String debitCurrency;
  final double debitAmount;
  final String debitValueDate;
  final String creditAccountId;
  final String creditAccountIban;
  final String creditCurrencyId;
  final String creditValueDate;
  final String commissionCode;
  final String profitCentreCustomer;
  final List<PaymentDetailResponse> paymentDetails;
  final List<OverrideDetailResponse> overrideDetails;

  factory IntraTransferResponse.fromJson(Map<String, dynamic> json) {
    final paymentList = json['paymentDetails'] as List? ?? [];
    final overrideList = json['overrideDetails'] as List? ?? [];
    return IntraTransferResponse(
      transactionId: json['transactionId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      transactionStatus: json['transactionStatus'] as String? ?? '',
      transactionType: json['transactionType'] as String? ?? '',
      debitAccountId: json['debitAccountId'] as String? ?? '',
      debitAccountIban: json['debitAccountIban'] as String? ?? '',
      debitCurrency: json['debitCurrency'] as String? ?? '',
      debitAmount: (json['debitAmount'] as num?)?.toDouble() ?? 0,
      debitValueDate: json['debitValueDate'] as String? ?? '',
      creditAccountId: json['creditAccountId'] as String? ?? '',
      creditAccountIban: json['creditAccountIban'] as String? ?? '',
      creditCurrencyId: json['creditCurrencyId'] as String? ?? '',
      creditValueDate: json['creditValueDate'] as String? ?? '',
      commissionCode: json['commissionCode'] as String? ?? '',
      profitCentreCustomer: json['profitCentreCustomer'] as String? ?? '',
      paymentDetails: paymentList
          .map((e) => PaymentDetailResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      overrideDetails: overrideList
          .map((e) => OverrideDetailResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─── 3 & 4. Transfer Demands (history) ────────────────────────────────────────

enum TransferDemandStatus {
  pending('PENDING'),
  successful('SUCCESSFUL'),
  failed('FAILED'),
  unknown('UNKNOWN');

  const TransferDemandStatus(this.value);

  final String value;

  static TransferDemandStatus from(String? raw) {
    switch (raw) {
      case 'PENDING':
        return pending;
      case 'SUCCESSFUL':
        return successful;
      case 'FAILED':
        return failed;
      default:
        return unknown;
    }
  }
}

class TransferDemand {
  const TransferDemand({
    required this.id,
    required this.clientUserId,
    required this.amount,
    required this.transactionType,
    required this.debitAccountId,
    required this.debitCurrency,
    required this.creditAccountId,
    required this.paymentDetails,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  final int id;
  final int clientUserId;
  final double amount;
  final String transactionType;
  final String debitAccountId;
  final String debitCurrency;
  final String creditAccountId;
  final List<String> paymentDetails;
  final TransferDemandStatus status;
  final String createdAt;
  final String? completedAt;

  factory TransferDemand.fromJson(Map<String, dynamic> json) {
    final details = json['paymentDetails'] as List? ?? [];
    return TransferDemand(
      id: json['id'] as int? ?? 0,
      clientUserId: json['clientUserId'] as int? ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      transactionType: json['transactionType'] as String? ?? '',
      debitAccountId: json['debitAccountId'] as String? ?? '',
      debitCurrency: json['debitCurrency'] as String? ?? '',
      creditAccountId: json['creditAccountId'] as String? ?? '',
      paymentDetails: details.map((e) => e.toString()).toList(),
      status: TransferDemandStatus.from(json['status'] as String?),
      createdAt: json['createdAt'] as String? ?? '',
      completedAt: json['completedAt'] as String?,
    );
  }
}

class PageResponse<T> {
  const PageResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
  });

  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    final contentList = json['content'] as List? ?? [];
    return PageResponse<T>(
      content: contentList.map((e) => fromJsonT(e)).toList(),
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      first: json['first'] as bool? ?? false,
      last: json['last'] as bool? ?? false,
    );
  }
}

@immutable
class TransferDemandQuery {
  const TransferDemandQuery({
    this.page = 0,
    this.size = 20,
    this.from,
    this.to,
  });

  final int page;
  final int size;
  final String? from; // yyyy-MM-dd, inclusive
  final String? to; // yyyy-MM-dd, inclusive

  TransferDemandQuery copyWith({int? page, int? size, String? from, String? to}) {
    return TransferDemandQuery(
      page: page ?? this.page,
      size: size ?? this.size,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final map = <String, dynamic>{
      'page': page,
      'size': size,
    };
    if (from != null && from!.isNotEmpty) map['from'] = from;
    if (to != null && to!.isNotEmpty) map['to'] = to;
    return map;
  }
}