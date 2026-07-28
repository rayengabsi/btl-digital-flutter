import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/forgot_password_request.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/reset_password_request.dart';
import '../models/reset_password_response.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dioClient.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    return LoginResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<LoginResponse> register(RegisterRequest request) async {
    final response = await _dioClient.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );
    return LoginResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ResetPasswordResponse> forgotPassword(
      ForgotPasswordRequest request) async {
    final response = await _dioClient.post(
      ApiEndpoints.forgotPassword,
      data: request.toJson(),
    );
    return ResetPasswordResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ResetPasswordResponse> resetPassword(
      ResetPasswordRequest request) async {
    final response = await _dioClient.post(
      ApiEndpoints.resetPassword,
      data: request.toJson(),
    );
    return ResetPasswordResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
