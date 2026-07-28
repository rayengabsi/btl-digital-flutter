import '../../data/models/login_request.dart';
import '../../data/models/login_response.dart';
import '../../data/models/register_request.dart';

abstract interface class AuthRepository {
  Future<LoginResponse> login(LoginRequest request);
  Future<LoginResponse> register(RegisterRequest request);
  Future<void> logout();
  Future<bool> hasActiveSession();
  Future<LoginResponse?> restoreSession();
}
