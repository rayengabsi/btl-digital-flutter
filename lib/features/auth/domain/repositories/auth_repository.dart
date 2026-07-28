import '../../data/models/forgot_password_request.dart';
import '../../data/models/login_request.dart';
import '../../data/models/login_response.dart';
import '../../data/models/register_request.dart';
import '../../data/models/reset_password_request.dart';
import '../../data/models/reset_password_response.dart';

abstract interface class AuthRepository {
  Future<LoginResponse> login(LoginRequest request);
  Future<LoginResponse> register(RegisterRequest request);
  Future<void> logout();
  Future<bool> hasActiveSession();
  Future<LoginResponse?> restoreSession();
  Future<ResetPasswordResponse> forgotPassword(ForgotPasswordRequest request);
  Future<ResetPasswordResponse> resetPassword(ResetPasswordRequest request);
}
