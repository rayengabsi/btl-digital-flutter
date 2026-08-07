class VerifyLoginOtpRequest {
  const VerifyLoginOtpRequest({
    required this.challengeId,
    required this.challengeToken,
    required this.otp,
  });

  final int challengeId;
  final String challengeToken;
  final String otp;

  Map<String, dynamic> toJson() => {
        'challengeId': challengeId,
        'challengeToken': challengeToken,
        'otp': otp,
      };
}

class AuthTokenResponse {
  const AuthTokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresInSeconds,
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.accountStatus,
  });

  final String accessToken;
  final String tokenType;
  final int expiresInSeconds;
  final int userId;
  final String email;
  final String firstName;
  final String lastName;
  final String accountStatus;

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponse(
      accessToken: json['accessToken'] as String? ?? '',
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresInSeconds: json['expiresInSeconds'] as int? ?? 900,
      userId: json['userId'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      accountStatus: json['accountStatus'] as String? ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'tokenType': tokenType,
        'expiresInSeconds': expiresInSeconds,
        'userId': userId,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'accountStatus': accountStatus,
      };
}
