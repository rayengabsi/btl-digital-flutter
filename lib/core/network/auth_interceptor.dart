import 'package:dio/dio.dart';

import '../services/token_storage_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenStorageService,
    this.onUnauthorized,
  });

  final TokenStorageService tokenStorageService;
  Future<void> Function()? onUnauthorized;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorageService.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await tokenStorageService.clearAll();
      await onUnauthorized?.call();
    }

    handler.next(err);
  }
}