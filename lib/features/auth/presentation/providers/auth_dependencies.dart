import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/auth_interceptor.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

final tokenStorageServiceProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final tokenStorageService = ref.watch(tokenStorageServiceProvider);
  return DioClient(
    authInterceptor: AuthInterceptor(
      tokenStorageService: tokenStorageService,
      onUnauthorized: null,
    ),
  );
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRemoteDataSource(dioClient: dioClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final tokenStorageService = ref.watch(tokenStorageServiceProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    tokenStorageService: tokenStorageService,
  );
});