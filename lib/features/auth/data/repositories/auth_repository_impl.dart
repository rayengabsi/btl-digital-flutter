import '../../../../core/network/api_exception.dart';
import '../../../../core/services/token_storage_service.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/choose_mfa_models.dart';
import '../models/login_challenge_response.dart';
import '../models/login_request.dart';
import '../models/registration_models.dart';
import '../models/verify_otp_models.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorageService tokenStorageService,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorageService = tokenStorageService;

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorageService _tokenStorageService;

  @override
  Future<LoginChallengeResponse> login(LoginRequest request) async {
    try {
      return await _remoteDataSource.login(request);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Failed to verify login credentials. Please try again.',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ChooseMfaResponse> chooseMfa(ChooseMfaRequest request) async {
    try {
      return await _remoteDataSource.chooseMfa(request);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Failed to send MFA code. Please try again.',
        statusCode: 500,
      );
    }
  }

  @override
  Future<AuthTokenResponse> verifyLoginOtp(VerifyLoginOtpRequest request) async {
    try {
      final tokenResponse = await _remoteDataSource.verifyLoginOtp(request);
      await _tokenStorageService.saveAuthData(
        token: tokenResponse.accessToken,
        userId: tokenResponse.userId,
        email: tokenResponse.email,
        firstName: tokenResponse.firstName,
        lastName: tokenResponse.lastName,
        accountStatus: tokenResponse.accountStatus,
      );
      return tokenResponse;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Failed to verify OTP. Please try again.',
        statusCode: 500,
      );
    }
  }

  @override
  Future<VerifyClientResponse> verifyClient(VerifyClientRequest request) async {
    try {
      return await _remoteDataSource.verifyClient(request);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Failed to verify client info. Please try again.',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> verifyPhoneOtp(VerifyPhoneOtpRequest request) async {
    try {
      await _remoteDataSource.verifyPhoneOtp(request);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Failed to verify phone OTP. Please try again.',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> sendEmailVerification(SendEmailVerificationRequest request) async {
    try {
      await _remoteDataSource.sendEmailVerification(request);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Failed to send email verification code. Please try again.',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> verifyEmailCode(VerifyEmailCodeRequest request) async {
    try {
      await _remoteDataSource.verifyEmailCode(request);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Failed to verify email code. Please try again.',
        statusCode: 500,
      );
    }
  }

  @override
  Future<RegistrationSuccessData> completeRegistration(
      CompleteRegistrationRequest request) async {
    try {
      return await _remoteDataSource.completeRegistration(request);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Failed to complete registration. Please try again.',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> logout() async {
    await _tokenStorageService.clearAll();
  }

  @override
  Future<bool> hasActiveSession() async {
    return _tokenStorageService.hasToken();
  }

  @override
  Future<AuthTokenResponse?> restoreSession() async {
    final token = await _tokenStorageService.getToken();
    if (token == null || token.isEmpty) return null;

    final userId = await _tokenStorageService.getUserId();
    final email = await _tokenStorageService.getUserEmail();

    if (userId == null || userId <= 0 || email == null || email.isEmpty) {
      return null;
    }

    final firstName = await _tokenStorageService.getUserFirstName();
    final lastName = await _tokenStorageService.getUserLastName();
    final accountStatus = await _tokenStorageService.getUserAccountStatus();

    return AuthTokenResponse(
      accessToken: token,
      tokenType: 'Bearer',
      expiresInSeconds: 900,
      userId: userId,
      email: email,
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      accountStatus: accountStatus ?? 'ACTIVE',
    );
  }
}
