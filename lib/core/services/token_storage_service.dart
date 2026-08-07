import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_strings.dart';

class TokenStorageService {
  TokenStorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _secureStorage;

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppStrings.accessTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _secureStorage.read(key: AppStrings.accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: AppStrings.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: AppStrings.refreshTokenKey);
  }

  Future<void> saveUserId(int userId) async {
    await _secureStorage.write(
      key: AppStrings.userIdKey,
      value: userId.toString(),
    );
  }

  Future<int?> getUserId() async {
    final value = await _secureStorage.read(key: AppStrings.userIdKey);
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<void> saveUserEmail(String email) async {
    await _secureStorage.write(key: AppStrings.userEmailKey, value: email);
  }

  Future<String?> getUserEmail() async {
    return _secureStorage.read(key: AppStrings.userEmailKey);
  }

  Future<void> saveUserFirstName(String firstName) async {
    await _secureStorage.write(key: AppStrings.userFirstNameKey, value: firstName);
  }

  Future<String?> getUserFirstName() async {
    return _secureStorage.read(key: AppStrings.userFirstNameKey);
  }

  Future<void> saveUserLastName(String lastName) async {
    await _secureStorage.write(key: AppStrings.userLastNameKey, value: lastName);
  }

  Future<String?> getUserLastName() async {
    return _secureStorage.read(key: AppStrings.userLastNameKey);
  }

  Future<void> saveUserAccountStatus(String status) async {
    await _secureStorage.write(key: AppStrings.userAccountStatusKey, value: status);
  }

  Future<String?> getUserAccountStatus() async {
    return _secureStorage.read(key: AppStrings.userAccountStatusKey);
  }

  Future<void> saveUserRole(String role) async {
    await _secureStorage.write(key: AppStrings.userRoleKey, value: role);
  }

  Future<String?> getUserRole() async {
    return _secureStorage.read(key: AppStrings.userRoleKey);
  }

  Future<void> saveAuthData({
    required String token,
    required int userId,
    required String email,
    String? firstName,
    String? lastName,
    String? accountStatus,
    String role = 'USER',
    String? refreshToken,
  }) async {
    await Future.wait([
      saveToken(token),
      saveUserId(userId),
      saveUserEmail(email),
      if (firstName != null) saveUserFirstName(firstName),
      if (lastName != null) saveUserLastName(lastName),
      if (accountStatus != null) saveUserAccountStatus(accountStatus),
      saveUserRole(role),
      if (refreshToken != null) saveRefreshToken(refreshToken),
    ]);
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

