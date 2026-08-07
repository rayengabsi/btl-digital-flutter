import '../../data/models/transfer_models.dart';

abstract interface class TransfersRepository {
  Future<IntraTransferInitiationResponse> initiateIntraTransfer(
    IntraTransferRequest request,
  );
  Future<IntraTransferResponse> confirmIntraTransfer(
    ConfirmIntraTransferRequest request,
  );
  Future<PageResponse<TransferDemand>> getTransferDemands(
    TransferDemandQuery query,
  );
  Future<TransferDemand> getTransferDemandById(int id);
}