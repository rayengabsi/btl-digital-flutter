class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.timestamp,
  });

  final bool success;
  final String message;
  final T? data;
  final String? timestamp;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      timestamp: json['timestamp'] as String?,
    );
  }
}
