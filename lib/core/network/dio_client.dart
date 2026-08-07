import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'api_exception.dart';
import 'auth_interceptor.dart';

class DioClient {
  DioClient({required AuthInterceptor authInterceptor}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final interceptors = <Interceptor>[
      _RetryInterceptor(),
      authInterceptor,
    ];

    if (kDebugMode) {
      interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: true,
          logPrint: (obj) {
            if (obj.toString().contains('Authorization')) return;
            debugPrint(obj.toString());
          },
        ),
      );
    }

    _dio.interceptors.addAll(interceptors);
  }

  late final Dio _dio;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ApiException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message:
              'Connection timed out. Please check your internet connection.',
          statusCode: 408,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message:
              'No internet connection. Please check your network settings.',
          statusCode: 0,
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 500;
        if (statusCode == 429) {
          return _handleRateLimit(e);
        }
        final body = e.response?.data;
        return ApiException.fromResponse(statusCode, body);
      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request was cancelled.',
          statusCode: 499,
        );
      case DioExceptionType.unknown:
        if (e.message?.contains('SocketException') == true) {
          return const ApiException(
            message:
                'No internet connection. Please check your network settings.',
            statusCode: 0,
          );
        }
        return const ApiException(
          message: 'An unexpected error occurred.',
          statusCode: 500,
        );
      default:
        return const ApiException(
          message: 'An unexpected error occurred.',
          statusCode: 500,
        );
    }
  }

  ApiException _handleRateLimit(DioException e) {
    final statusCode = e.response?.statusCode ?? 429;
    final retryAfterRaw = e.response?.headers.value('retry-after');
    final retryAfterSeconds =
        retryAfterRaw != null ? _parseRetryAfter(retryAfterRaw) : null;

    final message = retryAfterSeconds != null && retryAfterSeconds > 0
        ? 'Too many requests. Please try again in '
            '${retryAfterSeconds == 1 ? '1 second' : '$retryAfterSeconds seconds'}.'
        : 'Too many requests. Please try again shortly.';

    return ApiException(
      message: message,
      statusCode: statusCode,
      errorCode: 'RATE_LIMIT_EXCEEDED',
    );
  }

  /// Parses a `Retry-After` header that is either an integer number of seconds
  /// or an HTTP-date. Returns `null` when neither format matches.
  int? _parseRetryAfter(String raw) {
    final seconds = int.tryParse(raw.trim());
    if (seconds != null && seconds >= 0) return seconds;
    final date = DateTime.tryParse(raw.trim());
    if (date != null) {
      return date.difference(DateTime.now()).inSeconds.clamp(0, 3600);
    }
    return null;
  }
}

class _RetryInterceptor extends Interceptor {
  _RetryInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_isTransient(err) && !_hasRetried(err)) {
      err.requestOptions.headers['_retry_count'] = '1';
      try {
        final response = await Dio().fetch<void>(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (_) {}
    }
    handler.next(err);
  }

  bool _isTransient(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.type == DioExceptionType.unknown &&
            err.message?.contains('SocketException') == true);
  }

  bool _hasRetried(DioException err) {
    return err.requestOptions.headers['_retry_count'] == '1';
  }
}