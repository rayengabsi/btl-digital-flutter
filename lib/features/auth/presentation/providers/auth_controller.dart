import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../../../../core/router/app_router.dart';
import '../../data/models/login_request.dart';
import '../../data/models/register_request.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_dependencies.dart';
import 'auth_state.dart';

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _wireUp401Handler();
    return const AuthState.initial();
  }

  void _wireUp401Handler() {
    final tokenStorageService = ref.read(tokenStorageServiceProvider);
    final dioClient = ref.read(dioClientProvider);
    final authInterceptor = dioClient.dio.interceptors
        .whereType<AuthInterceptor>()
        .firstOrNull;
    authInterceptor?.onUnauthorized = () async {
      await tokenStorageService.clearAll();
      state = const AuthState.unauthenticated();
      AppRouter.router.goNamed('login');
    };
  }

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();
    try {
      final hasSession = await _authRepository.hasActiveSession();
      if (hasSession) {
        final response = await _authRepository.restoreSession();
        if (response != null) {
          state = AuthState.authenticated(
            email: response.email,
            role: response.role,
          );
          return;
        }
      }
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authRepository.login(request);
      state = AuthState.authenticated(
        email: response.email,
        role: response.role,
      );
    } catch (e) {
      final message = _extractErrorMessage(e);
      state = AuthState.error(message: message);
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    state = const AuthState.loading();
    try {
      final request = RegisterRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );
      await _authRepository.register(request);
      state = const AuthState.registrationSuccess();
    } catch (e) {
      final message = _extractErrorMessage(e);
      state = AuthState.error(message: message);
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState.unauthenticated();
  }

  void reset() {
    state = const AuthState.initial();
  }

  String _extractErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
