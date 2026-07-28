class ApiException implements Exception {
  const ApiException({
    required this.message,
    required this.statusCode,
    this.body,
  });

  final String message;
  final int statusCode;
  final dynamic body;

  @override
  String toString() => 'ApiException($statusCode): $message';

  factory ApiException.fromResponse(int statusCode, dynamic body) {
    final message = _extractMessage(body, statusCode);

    return ApiException(
      message: message,
      statusCode: statusCode,
      body: body,
    );
  }

  static String _extractMessage(dynamic body, int statusCode) {
    if (body is Map<String, dynamic>) {
      if (body.containsKey('message')) {
        return body['message'] as String;
      }
      if (body.containsKey('error')) {
        return body['error'] as String;
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
