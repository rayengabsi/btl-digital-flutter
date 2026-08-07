import '../../../../core/network/api_exception.dart';
import '../datasources/beneficiaries_remote_data_source.dart';
import '../models/beneficiary_model.dart';
import '../../domain/repositories/beneficiaries_repository.dart';

class BeneficiariesRepositoryImpl implements BeneficiariesRepository {
  BeneficiariesRepositoryImpl({required BeneficiariesRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final BeneficiariesRemoteDataSource _remoteDataSource;

  @override
  Future<List<Beneficiary>> getBeneficiaries() async {
    try {
      return await _remoteDataSource.getBeneficiaries();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Failed to load beneficiaries. Please try again.',
        statusCode: 500,
      );
    }
  }

  @override
  Future<Beneficiary> getBeneficiaryById(int id) async {
    try {
      return await _remoteDataSource.getBeneficiaryById(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Beneficiary not found.',
        statusCode: 404,
      );
    }
  }

  @override
  Future<Beneficiary> createBeneficiary(BeneficiaryRequest request) async {
    try {
      return await _remoteDataSource.createBeneficiary(request);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Failed to create beneficiary. Please try again.',
        statusCode: 500,
      );
    }
  }

  @override
  Future<Beneficiary> updateBeneficiary(int id, BeneficiaryRequest request) async {
    try {
      return await _remoteDataSource.updateBeneficiary(id, request);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Failed to update beneficiary. Please try again.',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deleteBeneficiary(int id) async {
    try {
      await _remoteDataSource.deleteBeneficiary(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Failed to delete beneficiary. Please try again.',
        statusCode: 500,
      );
    }
  }
}
