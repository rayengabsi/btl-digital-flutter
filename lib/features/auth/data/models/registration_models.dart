// Step 1: Verify Client
class VerifyClientRequest {
  const VerifyClientRequest({
    required this.firstName,
    required this.lastName,
    required this.idType,
    required this.idNumber,
    required this.dateOfBirth,
    required this.phoneNumber,
  });

  final String firstName;
  final String lastName;
  final String idType; // 'CIN' or 'PASSPORT'
  final String idNumber;
  final String dateOfBirth; // 'yyyyMMdd'
  final String phoneNumber;

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'idType': idType,
        'idNumber': idNumber,
        'dateOfBirth': dateOfBirth,
        'phoneNumber': phoneNumber,
      };
}

class VerifyClientResponse {
  const VerifyClientResponse({
    required this.registrationSessionToken,
    required this.nextStep,
  });

  final String registrationSessionToken;
  final String nextStep;

  factory VerifyClientResponse.fromJson(Map<String, dynamic> json) {
    return VerifyClientResponse(
      registrationSessionToken: json['registrationSessionToken'] as String? ?? '',
      nextStep: json['nextStep'] as String? ?? '',
    );
  }
}

// Step 2: Verify Phone OTP
class VerifyPhoneOtpRequest {
  const VerifyPhoneOtpRequest({
    required this.registrationSessionToken,
    required this.otp,
  });

  final String registrationSessionToken;
  final String otp;

  Map<String, dynamic> toJson() => {
        'registrationSessionToken': registrationSessionToken,
        'otp': otp,
      };
}

// Step 3: Send Email Verification
class SendEmailVerificationRequest {
  const SendEmailVerificationRequest({
    required this.registrationSessionToken,
    required this.email,
  });

  final String registrationSessionToken;
  final String email;

  Map<String, dynamic> toJson() => {
        'registrationSessionToken': registrationSessionToken,
        'email': email,
      };
}

// Step 4: Verify Email Code
class VerifyEmailCodeRequest {
  const VerifyEmailCodeRequest({
    required this.registrationSessionToken,
    required this.code,
  });

  final String registrationSessionToken;
  final String code;

  Map<String, dynamic> toJson() => {
        'registrationSessionToken': registrationSessionToken,
        'code': code,
      };
}

// Step 5: Complete Registration
class CompleteRegistrationRequest {
  const CompleteRegistrationRequest({
    required this.registrationSessionToken,
    required this.password,
  });

  final String registrationSessionToken;
  final String password;

  Map<String, dynamic> toJson() => {
        'registrationSessionToken': registrationSessionToken,
        'password': password,
      };
}

class RegistrationSuccessData {
  const RegistrationSuccessData({
    required this.userId,
    required this.username,
    required this.accountStatus,
    required this.firstLoginRequired,
  });

  final int userId;
  final String username;
  final String accountStatus;
  final bool firstLoginRequired;

  factory RegistrationSuccessData.fromJson(Map<String, dynamic> json) {
    return RegistrationSuccessData(
      userId: json['userId'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      accountStatus: json['accountStatus'] as String? ?? 'ACTIVE',
      firstLoginRequired: json['firstLoginRequired'] as bool? ?? false,
    );
  }
}
