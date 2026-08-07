import '../../data/models/choose_mfa_models.dart';
import '../../data/models/login_challenge_response.dart';
import '../../data/models/login_request.dart';
import '../../data/models/registration_models.dart';
import '../../data/models/verify_otp_models.dart';

abstract interface class AuthRepository {
  // Login flow
  Future<LoginChallengeResponse> login(LoginRequest request);
  Future<ChooseMfaResponse> chooseMfa(ChooseMfaRequest request);
  Future<AuthTokenResponse> verifyLoginOtp(VerifyLoginOtpRequest request);

  // Registration flow
  Future<VerifyClientResponse> verifyClient(VerifyClientRequest request);
  Future<void> verifyPhoneOtp(VerifyPhoneOtpRequest request);
  Future<void> sendEmailVerification(SendEmailVerificationRequest request);
  Future<void> verifyEmailCode(VerifyEmailCodeRequest request);
  Future<RegistrationSuccessData> completeRegistration(
      CompleteRegistrationRequest request);

  // Session & Logout
  Future<bool> hasActiveSession();
  Future<AuthTokenResponse?> restoreSession();
  Future<void> logout();
}
