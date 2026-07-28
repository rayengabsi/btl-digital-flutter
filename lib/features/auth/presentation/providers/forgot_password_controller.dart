import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/forgot_password_request.dart';
import '../../data/models/reset_password_request.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_dependencies.dart';
import 'forgot_password_state.dart';

class ForgotPasswordController
    extends Notifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordState.initial();

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  Future<void> sendResetLink({required String email}) async {
    state = const ForgotPasswordState.loading();
    try {
      final request = ForgotPasswordRequest(email: email);
      final response = await _authRepository.forgotPassword(request);
      state = ForgotPasswordState.success(message: response.message);
    } catch (e) {
      state = ForgotPasswordState.error(message: _extractMessage(e));
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = const ForgotPasswordState.loading();
    try {
      final request = ResetPasswordRequest(
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      final response = await _authRepository.resetPassword(request);
      state = ForgotPasswordState.success(message: response.message);
    } catch (e) {
      state = ForgotPasswordState.error(message: _extractMessage(e));
    }
  }

  void reset() => state = const ForgotPasswordState.initial();

  String _extractMessage(dynamic error) {
    if (error is ApiException) return error.message;
    return 'An unexpected error occurred. Please try again.';
  }
}