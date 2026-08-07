import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/transfer_models.dart';

class TransfersRemoteDataSource {
  TransfersRemoteDataSource({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  /// POST /api/v1/transfers/intra
  Future<IntraTransferInitiationResponse> initiateIntraTransfer(
    IntraTransferRequest request,
  ) async {
    final response = await _dioClient.post(
      ApiEndpoints.intraTransfer,
      data: request.toJson(),
    );
    final apiResponse = ApiResponse<IntraTransferInitiationResponse>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => IntraTransferInitiationResponse.fromJson(
        data as Map<String, dynamic>,
      ),
    );
    if (apiResponse.data == null) {
      throw Exception('Missing transfer demand data');
    }
    return apiResponse.data!;
  }

  /// POST /api/v1/transfers/intra/confirm
  Future<IntraTransferResponse> confirmIntraTransfer(
    ConfirmIntraTransferRequest request,
  ) async {
    final response = await _dioClient.post(
      ApiEndpoints.intraTransferConfirm,
      data: request.toJson(),
    );
    final apiResponse = ApiResponse<IntraTransferResponse>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => IntraTransferResponse.fromJson(data as Map<String, dynamic>),
    );
    if (apiResponse.data == null) {
      throw Exception('Missing transfer result data');
    }
    return apiResponse.data!;
  }

  /// GET /api/v1/transfer-demands
  /// This endpoint returns the raw page object WITHOUT the ApiResponse envelope.
  Future<PageResponse<TransferDemand>> getTransferDemands(
    TransferDemandQuery query,
  ) async {
    final response = await _dioClient.get(
      ApiEndpoints.transferDemands,
      queryParameters: query.toQueryParams(),
    );
    return PageResponse<TransferDemand>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => TransferDemand.fromJson(data as Map<String, dynamic>),
    );
  }

  /// GET /api/v1/transfer-demands/{id}
  /// Returns the raw TransferDemand WITHOUT the ApiResponse envelope.
  Future<TransferDemand> getTransferDemandById(int id) async {
    final response = await _dioClient.get(ApiEndpoints.transferDemandById(id));
    return TransferDemand.fromJson(response.data as Map<String, dynamic>);
  }
}