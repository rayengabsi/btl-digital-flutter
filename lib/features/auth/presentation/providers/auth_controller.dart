import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../../../../core/router/app_router.dart';
import '../../../../features/accounts/presentation/providers/accounts_provider.dart';
import '../../../../features/beneficiaries/presentation/providers/beneficiaries_provider.dart';
import '../../../../features/currencies/presentation/providers/currencies_provider.dart';
import '../../../../features/transfers/presentation/providers/transfers_provider.dart';
import '../../data/models/choose_mfa_models.dart';
import '../../data/models/login_request.dart';
import '../../data/models/registration_models.dart';
import '../../data/models/verify_otp_models.dart';
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
      _clearCachedData();
      await tokenStorageService.clearAll();
      state = const AuthState.unauthenticated();
      AppRouter.router.goNamed('login');
    };
  }

  /// Drops all cached, user-scoped data so that a subsequent login (possibly by
  /// a different user) starts from a clean slate instead of showing stale data.
  void _clearCachedData() {
    ref.invalidate(customerAccountsProvider);
    ref.invalidate(recentTransactionsProvider);
    ref.invalidate(transactionSearchNotifierProvider);
    ref.invalidate(beneficiariesListProvider);
    ref.invalidate(currenciesProvider);
    ref.invalidate(transferHistoryControllerProvider);
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
            userId: response.userId,
            email: response.email,
            firstName: response.firstName,
            lastName: response.lastName,
            accountStatus: response.accountStatus,
          );
          return;
        }
      }
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  // ─── LOGIN FLOW ────────────────────────────────────────────────────────────

  /// Step 1: Login with credentials
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final request = LoginRequest(email: email.trim(), password: password);
      final response = await _authRepository.login(request);
      state = AuthState.credentialsVerified(
        challengeId: response.challengeId,
        challengeToken: response.challengeToken,
        availableChannels: response.availableChannels,
      );
    } catch (e) {
      _handleError(e);
    }
  }

  /// Step 2: Choose MFA Channel
  Future<void> chooseMfa({
    required int challengeId,
    required String challengeToken,
    required String mfaChannel,
  }) async {
    state = const AuthState.loading();
    try {
      final request = ChooseMfaRequest(
        challengeId: challengeId,
        challengeToken: challengeToken,
        mfaChannel: mfaChannel,
      );
      final response = await _authRepository.chooseMfa(request);
      state = AuthState.mfaOtpSent(
        challengeId: response.challengeId,
        challengeToken: challengeToken,
        channel: response.channel,
        maskedDestination: response.maskedDestination,
      );
    } catch (e) {
      _handleError(e);
    }
  }

  /// Step 3: Verify Login OTP
  Future<void> verifyLoginOtp({
    required int challengeId,
    required String challengeToken,
    required String otp,
  }) async {
    state = const AuthState.loading();
    try {
      final request = VerifyLoginOtpRequest(
        challengeId: challengeId,
        challengeToken: challengeToken,
        otp: otp.trim(),
      );
      final response = await _authRepository.verifyLoginOtp(request);
      state = AuthState.authenticated(
        userId: response.userId,
        email: response.email,
        firstName: response.firstName,
        lastName: response.lastName,
        accountStatus: response.accountStatus,
      );
    } catch (e) {
      _handleError(e);
    }
  }

  // ─── REGISTRATION FLOW ──────────────────────────────────────────────────────

  /// Registration Step 1: Verify Client
  Future<void> verifyClient({
    required String firstName,
    required String lastName,
    required String idType,
    required String idNumber,
    required String dateOfBirth,
    required String phoneNumber,
  }) async {
    state = const AuthState.loading();
    try {
      final request = VerifyClientRequest(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        idType: idType,
        idNumber: idNumber.trim(),
        dateOfBirth: dateOfBirth.trim(),
        phoneNumber: phoneNumber.replaceAll(RegExp(r'\D'), ''),
      );
      final response = await _authRepository.verifyClient(request);
      state = AuthState.registrationStep(
        step: 2,
        sessionToken: response.registrationSessionToken,
        phone: phoneNumber,
      );
    } catch (e) {
      _handleError(e);
    }
  }

  /// Registration Step 2: Verify Phone OTP
  Future<void> verifyPhoneOtp({
    required String sessionToken,
    required String otp,
  }) async {
    final currentPhone = (state is AuthRegistrationStep)
        ? (state as AuthRegistrationStep).phone
        : null;
    state = const AuthState.loading();
    try {
      final request = VerifyPhoneOtpRequest(
        registrationSessionToken: sessionToken,
        otp: otp.trim(),
      );
      await _authRepository.verifyPhoneOtp(request);
      state = AuthState.registrationStep(
        step: 3,
        sessionToken: sessionToken,
        phone: currentPhone,
      );
    } catch (e) {
      _handleError(e);
    }
  }

  /// Registration Step 3: Send Email Verification
  Future<void> sendEmailVerification({
    required String sessionToken,
    required String email,
  }) async {
    final currentPhone = (state is AuthRegistrationStep)
        ? (state as AuthRegistrationStep).phone
        : null;
    state = const AuthState.loading();
    try {
      final request = SendEmailVerificationRequest(
        registrationSessionToken: sessionToken,
        email: email.trim(),
      );
      await _authRepository.sendEmailVerification(request);
      state = AuthState.registrationStep(
        step: 4,
        sessionToken: sessionToken,
        phone: currentPhone,
        email: email.trim(),
      );
    } catch (e) {
      _handleError(e);
    }
  }

  /// Registration Step 4: Verify Email Code
  Future<void> verifyEmailCode({
    required String sessionToken,
    required String code,
  }) async {
    final currentPhone = (state is AuthRegistrationStep)
        ? (state as AuthRegistrationStep).phone
        : null;
    final currentEmail = (state is AuthRegistrationStep)
        ? (state as AuthRegistrationStep).email
        : null;
    state = const AuthState.loading();
    try {
      final request = VerifyEmailCodeRequest(
        registrationSessionToken: sessionToken,
        code: code.trim(),
      );
      await _authRepository.verifyEmailCode(request);
      state = AuthState.registrationStep(
        step: 5,
        sessionToken: sessionToken,
        phone: currentPhone,
        email: currentEmail,
      );
    } catch (e) {
      _handleError(e);
    }
  }

  /// Registration Step 5: Complete Registration
  Future<void> completeRegistration({
    required String sessionToken,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final request = CompleteRegistrationRequest(
        registrationSessionToken: sessionToken,
        password: password,
      );
      final response = await _authRepository.completeRegistration(request);
      state = AuthState.registrationSuccess(username: response.username);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> logout() async {
    _clearCachedData();
    await _authRepository.logout();
    state = const AuthState.unauthenticated();
  }

  void reset() {
    state = const AuthState.initial();
  }

  void _handleError(dynamic error) {
    if (error is ApiException) {
      state = AuthState.error(
        message: error.message,
        errorCode: error.errorCode,
        details: error.details,
      );
    } else {
      state = AuthState.error(
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }
}
