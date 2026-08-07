import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/choose_mfa_models.dart';
import '../models/login_challenge_response.dart';
import '../models/login_request.dart';
import '../models/registration_models.dart';
import '../models/verify_otp_models.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  // ─── LOGIN FLOW ────────────────────────────────────────────────────────────

  /// Step 1: Verify Login Credentials
  Future<LoginChallengeResponse> login(LoginRequest request) async {
    final response = await _dioClient.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    final apiResponse = ApiResponse<LoginChallengeResponse>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => LoginChallengeResponse.fromJson(data as Map<String, dynamic>),
    );
    if (apiResponse.data == null) {
      throw Exception('Missing login challenge data');
    }
    return apiResponse.data!;
  }

  /// Step 2: Choose MFA Channel
  Future<ChooseMfaResponse> chooseMfa(ChooseMfaRequest request) async {
    final response = await _dioClient.post(
      ApiEndpoints.chooseMfa,
      data: request.toJson(),
    );
    final apiResponse = ApiResponse<ChooseMfaResponse>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => ChooseMfaResponse.fromJson(data as Map<String, dynamic>),
    );
    if (apiResponse.data == null) {
      throw Exception('Missing MFA selection response data');
    }
    return apiResponse.data!;
  }

  /// Step 3: Verify Login OTP & Obtain Access Token
  Future<AuthTokenResponse> verifyLoginOtp(VerifyLoginOtpRequest request) async {
    final response = await _dioClient.post(
      ApiEndpoints.verifyLoginOtp,
      data: request.toJson(),
    );
    final apiResponse = ApiResponse<AuthTokenResponse>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => AuthTokenResponse.fromJson(data as Map<String, dynamic>),
    );
    if (apiResponse.data == null) {
      throw Exception('Missing token response data');
    }
    return apiResponse.data!;
  }

  // ─── REGISTRATION FLOW ──────────────────────────────────────────────────────

  /// Step 1: Verify Client
  Future<VerifyClientResponse> verifyClient(VerifyClientRequest request) async {
    final response = await _dioClient.post(
      ApiEndpoints.verifyClient,
      data: request.toJson(),
    );
    final apiResponse = ApiResponse<VerifyClientResponse>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => VerifyClientResponse.fromJson(data as Map<String, dynamic>),
    );
    if (apiResponse.data == null) {
      throw Exception('Missing registration session token');
    }
    return apiResponse.data!;
  }

  /// Step 2: Verify Phone OTP
  Future<void> verifyPhoneOtp(VerifyPhoneOtpRequest request) async {
    await _dioClient.post(
      ApiEndpoints.verifyPhoneOtp,
      data: request.toJson(),
    );
  }

  /// Step 3: Send Email Verification
  Future<void> sendEmailVerification(SendEmailVerificationRequest request) async {
    await _dioClient.post(
      ApiEndpoints.sendEmailVerification,
      data: request.toJson(),
    );
  }

  /// Step 4: Verify Email Code
  Future<void> verifyEmailCode(VerifyEmailCodeRequest request) async {
    await _dioClient.post(
      ApiEndpoints.verifyEmail,
      data: request.toJson(),
    );
  }

  /// Step 5: Complete Registration
  Future<RegistrationSuccessData> completeRegistration(
      CompleteRegistrationRequest request) async {
    final response = await _dioClient.post(
      ApiEndpoints.completeRegistration,
      data: request.toJson(),
    );
    final apiResponse = ApiResponse<RegistrationSuccessData>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => RegistrationSuccessData.fromJson(data as Map<String, dynamic>),
    );
    if (apiResponse.data == null) {
      throw Exception('Missing registration completion data');
    }
    return apiResponse.data!;
  }
}
