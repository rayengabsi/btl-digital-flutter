import '../../../../core/network/api_exception.dart';
import '../../../../core/services/token_storage_service.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
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
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _remoteDataSource.login(request);
      await _saveAuthData(response);
      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Failed to login. Please try again.',
        statusCode: 500,
      );
    }
  }

  @override
  Future<LoginResponse> register(RegisterRequest request) async {
    try {
      final response = await _remoteDataSource.register(request);
      await _saveAuthData(response);
      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Failed to register. Please try again.',
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
  Future<LoginResponse?> restoreSession() async {
    final token = await _tokenStorageService.getToken();
    if (token == null || token.isEmpty) return null;

    final userId = await _tokenStorageService.getUserId();
    final email = await _tokenStorageService.getUserEmail();
    final role = await _tokenStorageService.getUserRole();

    return LoginResponse(
      token: token,
      type: 'Bearer',
      userId: userId ?? 0,
      email: email ?? '',
      role: role ?? 'USER',
    );
  }

  Future<void> _saveAuthData(LoginResponse response) async {
    await _tokenStorageService.saveAuthData(
      token: response.token,
      userId: response.userId,
      email: response.email,
      role: response.role,
    );
  }
}
