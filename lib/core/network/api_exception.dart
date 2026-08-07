class ApiException implements Exception {
  const ApiException({
    required this.message,
    required this.statusCode,
    this.errorCode,
    this.details = const [],
    this.body,
  });

  final String message;
  final int statusCode;
  final String? errorCode;
  final List<String> details;
  final dynamic body;

  @override
  String toString() =>
      'ApiException($statusCode, code: ${errorCode ?? 'NONE'}): $message ${details.isNotEmpty ? details.join(', ') : ''}';

  factory ApiException.fromResponse(int statusCode, dynamic body) {
    final message = _extractMessage(body, statusCode);
    String? errorCode;
    List<String> details = [];

    if (body is Map<String, dynamic>) {
      if (body['errorCode'] != null) {
        errorCode = body['errorCode'].toString();
      }
      if (body['details'] is List) {
        details = (body['details'] as List).map((e) => e.toString()).toList();
      }
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
      details: details,
      body: body,
    );
  }

  static String _extractMessage(dynamic body, int statusCode) {
    if (body is Map<String, dynamic>) {
      if (body.containsKey('message') && body['message'] != null) {
        return body['message'].toString();
      }
      if (body.containsKey('error') && body['error'] != null) {
        return body['error'].toString();
      }
    }
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Invalid credentials. Please try again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 500:
        return 'A server error occurred. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

