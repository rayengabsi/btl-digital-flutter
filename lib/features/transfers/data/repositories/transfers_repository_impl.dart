import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/transfers_repository.dart';
import '../datasources/transfers_remote_data_source.dart';
import '../models/transfer_models.dart';

class TransfersRepositoryImpl implements TransfersRepository {
  TransfersRepositoryImpl({required TransfersRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final TransfersRemoteDataSource _remoteDataSource;

  @override
  Future<IntraTransferInitiationResponse> initiateIntraTransfer(
    IntraTransferRequest request,
  ) async {
    try {
      return await _remoteDataSource.initiateIntraTransfer(request);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Failed to initiate transfer. Please try again.',
        statusCode: 500,
      );
    }
  }

  @override
  Future<IntraTransferResponse> confirmIntraTransfer(
    ConfirmIntraTransferRequest request,
  ) async {
    try {
      return await _remoteDataSource.confirmIntraTransfer(request);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Failed to confirm transfer. Please try again.',
        statusCode: 500,
      );
    }
  }

  @override
  Future<PageResponse<TransferDemand>> getTransferDemands(
    TransferDemandQuery query,
  ) async {
    try {
      return await _remoteDataSource.getTransferDemands(query);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Failed to load transfer history. Please try again.',
        statusCode: 500,
      );
    }
  }

  @override
  Future<TransferDemand> getTransferDemandById(int id) async {
    try {
      return await _remoteDataSource.getTransferDemandById(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        message: 'Failed to load transfer. Please try again.',
        statusCode: 500,
      );
    }
  }
}