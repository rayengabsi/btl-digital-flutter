import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/beneficiary_model.dart';

class BeneficiariesRemoteDataSource {
  BeneficiariesRemoteDataSource({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  Future<List<Beneficiary>> getBeneficiaries() async {
    final response = await _dioClient.get(ApiEndpoints.beneficiaries);
    final body = response.data;
    List<dynamic> list = [];

    if (body is List) {
      list = body;
    } else if (body is Map<String, dynamic> && body['data'] is List) {
      list = body['data'] as List;
    }

    return list
        .map((e) => Beneficiary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Beneficiary> getBeneficiaryById(int id) async {
    final response = await _dioClient.get(ApiEndpoints.beneficiaryById(id));
    final body = response.data;
    final map = (body is Map<String, dynamic> && body.containsKey('data'))
        ? body['data'] as Map<String, dynamic>
        : body as Map<String, dynamic>;
    return Beneficiary.fromJson(map);
  }

  Future<Beneficiary> createBeneficiary(BeneficiaryRequest request) async {
    final response = await _dioClient.post(
      ApiEndpoints.beneficiaries,
      data: request.toJson(),
    );
    final body = response.data;
    final map = (body is Map<String, dynamic> && body.containsKey('data'))
        ? body['data'] as Map<String, dynamic>
        : body as Map<String, dynamic>;
    return Beneficiary.fromJson(map);
  }

  Future<Beneficiary> updateBeneficiary(int id, BeneficiaryRequest request) async {
    final response = await _dioClient.put(
      ApiEndpoints.beneficiaryById(id),
      data: request.toJson(),
    );
    final body = response.data;
    final map = (body is Map<String, dynamic> && body.containsKey('data'))
        ? body['data'] as Map<String, dynamic>
        : body as Map<String, dynamic>;
    return Beneficiary.fromJson(map);
  }

  Future<void> deleteBeneficiary(int id) async {
    await _dioClient.delete(ApiEndpoints.beneficiaryById(id));
  }
}
