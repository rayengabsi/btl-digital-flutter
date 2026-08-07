import '../../data/models/login_challenge_response.dart';

sealed class AuthState {
  const AuthState();

  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;

  // Login MFA states
  const factory AuthState.credentialsVerified({
    required int challengeId,
    required String challengeToken,
    required List<MfaChannelInfo> availableChannels,
  }) = AuthCredentialsVerified;

  const factory AuthState.mfaOtpSent({
    required int challengeId,
    required String challengeToken,
    required String channel,
    required String maskedDestination,
  }) = AuthMfaOtpSent;

  // Authenticated state
  const factory AuthState.authenticated({
    required int userId,
    required String email,
    required String firstName,
    required String lastName,
    required String accountStatus,
  }) = AuthAuthenticated;

  const factory AuthState.unauthenticated() = AuthUnauthenticated;

  // Registration step state (steps 1 to 5)
  const factory AuthState.registrationStep({
    required int step, // 1: Verify Client, 2: Verify Phone OTP, 3: Email Input, 4: Verify Email, 5: Complete Password
    required String? sessionToken,
    String? phone,
    String? email,
  }) = AuthRegistrationStep;

  const factory AuthState.registrationSuccess({
    required String username,
  }) = AuthRegistrationSuccess;

  const factory AuthState.error({
    required String message,
    String? errorCode,
    List<String> details,
  }) = AuthError;
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthCredentialsVerified extends AuthState {
  const AuthCredentialsVerified({
    required this.challengeId,
    required this.challengeToken,
    required this.availableChannels,
  });

  final int challengeId;
  final String challengeToken;
  final List<MfaChannelInfo> availableChannels;
}

class AuthMfaOtpSent extends AuthState {
  const AuthMfaOtpSent({
    required this.challengeId,
    required this.challengeToken,
    required this.channel,
    required this.maskedDestination,
  });

  final int challengeId;
  final String challengeToken;
  final String channel;
  final String maskedDestination;
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.accountStatus,
  });

  final int userId;
  final String email;
  final String firstName;
  final String lastName;
  final String accountStatus;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthRegistrationStep extends AuthState {
  const AuthRegistrationStep({
    required this.step,
    required this.sessionToken,
    this.phone,
    this.email,
  });

  final int step;
  final String? sessionToken;
  final String? phone;
  final String? email;
}

class AuthRegistrationSuccess extends AuthState {
  const AuthRegistrationSuccess({required this.username});

  final String username;
}

class AuthError extends AuthState {
  const AuthError({
    required this.message,
    this.errorCode,
    this.details = const [],
  });

  final String message;
  final String? errorCode;
  final List<String> details;
}
