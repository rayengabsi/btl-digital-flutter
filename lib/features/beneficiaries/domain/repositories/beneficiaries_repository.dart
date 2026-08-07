import '../../data/models/beneficiary_model.dart';

abstract interface class BeneficiariesRepository {
  Future<List<Beneficiary>> getBeneficiaries();
  Future<Beneficiary> getBeneficiaryById(int id);
  Future<Beneficiary> createBeneficiary(BeneficiaryRequest request);
  Future<Beneficiary> updateBeneficiary(int id, BeneficiaryRequest request);
  Future<void> deleteBeneficiary(int id);
}
