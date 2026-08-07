abstract final class ApiEndpoints {
  static const String apiBase = '/api/v1';

  // Auth endpoints
  static const String login = '$apiBase/auth/login';
  static const String chooseMfa = '$apiBase/auth/login/choose-mfa';
  static const String verifyLoginOtp = '$apiBase/auth/login/verify-otp';

  // Registration endpoints
  static const String verifyClient = '$apiBase/registration/verify-client';
  static const String verifyPhoneOtp = '$apiBase/registration/verify-phone-otp';
  static const String sendEmailVerification = '$apiBase/registration/send-email-verification';
  static const String verifyEmail = '$apiBase/registration/verify-email';
  static const String completeRegistration = '$apiBase/registration/complete';

  // Accounts endpoints
  static const String accounts = '$apiBase/accounts';
  static String accountTransactions(String iban) =>
      '$apiBase/accounts/${Uri.encodeComponent(iban)}/transactions';

  // Beneficiaries endpoints
  static const String beneficiaries = '$apiBase/beneficiaries';
  static String beneficiaryById(int id) => '$apiBase/beneficiaries/$id';

  // Currencies endpoints
  static const String currencyRates = '$apiBase/currencies/rates';

  // Transfers endpoints
  static const String intraTransfer = '$apiBase/transfers/intra';
  static const String intraTransferConfirm = '$apiBase/transfers/intra/confirm';
  static const String transferDemands = '$apiBase/transfer-demands';
  static String transferDemandById(int id) => '$apiBase/transfer-demands/$id';

  // Health
  static const String health = '/actuator/health';
}

