class AccountStatementSummary {
  const AccountStatementSummary({
    this.startDate,
    this.endDate,
    this.todayDate,
    this.accountTitle,
    this.accountType,
    this.currency,
    this.totalAmount,
    this.totalCredits,
    this.totalDebits,
    this.street,
    this.addressLine1,
    this.addressLine2,
    this.postCode,
  });

  final String? startDate;
  final String? endDate;
  final String? todayDate;
  final String? accountTitle;
  final String? accountType;
  final String? currency;
  final double? totalAmount;
  final double? totalCredits;
  final double? totalDebits;
  final String? street;
  final String? addressLine1;
  final String? addressLine2;
  final String? postCode;

  factory AccountStatementSummary.fromJson(Map<String, dynamic> json) {
    return AccountStatementSummary(
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      todayDate: json['todayDate'] as String?,
      accountTitle: json['accountTitle'] as String?,
      accountType: json['accountType'] as String?,
      currency: json['currency'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      totalCredits: (json['totalCredits'] as num?)?.toDouble(),
      totalDebits: (json['totalDebits'] as num?)?.toDouble(),
      street: json['street'] as String?,
      addressLine1: json['addressLine1'] as String?,
      addressLine2: json['addressLine2'] as String?,
      postCode: json['postCode'] as String?,
    );
  }
}

class AccountTransactionPagination {
  const AccountTransactionPagination({
    this.pageStart,
    this.pageSize,
    this.totalSize,
    this.pageToken,
  });

  final int? pageStart;
  final int? pageSize;
  final int? totalSize;
  final String? pageToken;

  factory AccountTransactionPagination.fromJson(Map<String, dynamic> json) {
    return AccountTransactionPagination(
      pageStart: json['pageStart'] as int?,
      pageSize: json['pageSize'] as int?,
      totalSize: json['totalSize'] as int?,
      pageToken: json['pageToken'] as String?,
    );
  }
}

class AccountTransaction {
  const AccountTransaction({
    required this.accountId,
    required this.transactionReference,
    required this.transactionCode,
    required this.bookingDate,
    required this.valueDate,
    this.closingBalance,
    this.debitAmount,
    this.creditAmount,
    required this.narratives,
  });

  final String accountId;
  final String transactionReference;
  final String transactionCode;
  final String bookingDate;
  final String valueDate;
  final double? closingBalance;
  final double? debitAmount;
  final double? creditAmount;
  final List<String> narratives;

  factory AccountTransaction.fromJson(Map<String, dynamic> json) {
    final list = json['narratives'] as List? ?? [];
    return AccountTransaction(
      accountId: json['accountId'] as String? ?? '',
      transactionReference: json['transactionReference'] as String? ?? '',
      transactionCode: json['transactionCode'] as String? ?? '',
      bookingDate: json['bookingDate'] as String? ?? '',
      valueDate: json['valueDate'] as String? ?? '',
      closingBalance: (json['closingBalance'] as num?)?.toDouble(),
      debitAmount: (json['debitAmount'] as num?)?.toDouble(),
      creditAmount: (json['creditAmount'] as num?)?.toDouble(),
      narratives: list.map((e) => e.toString()).toList(),
    );
  }
}

class AccountTransactionsResponse {
  const AccountTransactionsResponse({
    this.summary,
    required this.pagination,
    required this.transactions,
  });

  final AccountStatementSummary? summary;
  final AccountTransactionPagination pagination;
  final List<AccountTransaction> transactions;

  factory AccountTransactionsResponse.fromJson(Map<String, dynamic> json) {
    final summaryJson = json['summary'] as Map<String, dynamic>?;
    final paginationJson = json['pagination'] as Map<String, dynamic>? ?? {};
    final txList = json['transactions'] as List? ?? [];

    return AccountTransactionsResponse(
      summary: summaryJson != null ? AccountStatementSummary.fromJson(summaryJson) : null,
      pagination: AccountTransactionPagination.fromJson(paginationJson),
      transactions: txList
          .map((e) => AccountTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AccountTransactionQuery {
  const AccountTransactionQuery({
    required this.fromDate,
    required this.toDate,
    this.pageSize = 20,
    this.pageStart,
    this.pageToken,
  });

  final String fromDate; // 'yyyy-MM-dd'
  final String toDate; // 'yyyy-MM-dd'
  final int? pageSize;
  final int? pageStart;
  final String? pageToken;

  Map<String, dynamic> toQueryParams() {
    final map = <String, dynamic>{
      'fromDate': fromDate,
      'toDate': toDate,
    };
    if (pageSize != null) map['pageSize'] = pageSize;
    if (pageStart != null) map['pageStart'] = pageStart;
    if (pageToken != null && pageToken!.isNotEmpty) {
      map['pageToken'] = pageToken;
    }
    return map;
  }
}
