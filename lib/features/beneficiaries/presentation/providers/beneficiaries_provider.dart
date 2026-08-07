import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_dependencies.dart';

import '../../data/datasources/beneficiaries_remote_data_source.dart';
import '../../data/models/beneficiary_model.dart';
import '../../data/repositories/beneficiaries_repository_impl.dart';
import '../../domain/repositories/beneficiaries_repository.dart';


final beneficiariesRemoteDataSourceProvider =
    Provider<BeneficiariesRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return BeneficiariesRemoteDataSource(dioClient: dioClient);
});

final beneficiariesRepositoryProvider = Provider<BeneficiariesRepository>((ref) {
  final remoteDataSource = ref.watch(beneficiariesRemoteDataSourceProvider);
  return BeneficiariesRepositoryImpl(remoteDataSource: remoteDataSource);
});

final beneficiariesListProvider =
    AsyncNotifierProvider<BeneficiariesListNotifier, List<Beneficiary>>(
  BeneficiariesListNotifier.new,
);

class BeneficiariesListNotifier extends AsyncNotifier<List<Beneficiary>> {
  @override
  Future<List<Beneficiary>> build() async {
    final repository = ref.watch(beneficiariesRepositoryProvider);
    return repository.getBeneficiaries();
  }

  Future<void> addBeneficiary({
    required String name,
    required String ribNumber,
  }) async {
    final repository = ref.read(beneficiariesRepositoryProvider);
    final request = BeneficiaryRequest(
      beneficiaryName: name.trim(),
      ribNumber: ribNumber.replaceAll(RegExp(r'\D'), ''),
    );
    await repository.createBeneficiary(request);
    ref.invalidateSelf();
  }

  Future<void> updateBeneficiary({
    required int id,
    required String name,
    required String ribNumber,
  }) async {
    final repository = ref.read(beneficiariesRepositoryProvider);
    final request = BeneficiaryRequest(
      beneficiaryName: name.trim(),
      ribNumber: ribNumber.replaceAll(RegExp(r'\D'), ''),
    );
    await repository.updateBeneficiary(id, request);
    ref.invalidateSelf();
  }

  Future<void> deleteBeneficiary(int id) async {
    final repository = ref.read(beneficiariesRepositoryProvider);
    await repository.deleteBeneficiary(id);
    ref.invalidateSelf();
  }
}
