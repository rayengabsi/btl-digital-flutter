import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/currency_rate_model.dart';

class CurrenciesRemoteDataSource {
  CurrenciesRemoteDataSource({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  /// POST /api/v1/currencies/rates
  Future<List<CurrencyRate>> fetchRates(List<CurrencyPair> pairs) async {
    final response = await _dioClient.post(
      ApiEndpoints.currencyRates,
      data: {
        'currencies': pairs.map((p) => p.toJson()).toList(),
      },
    );

    final body = response.data;
    List<dynamic> list = [];

    if (body is Map<String, dynamic> && body['data'] is List) {
      list = body['data'] as List;
    } else if (body is List) {
      list = body;
    }

    return list
        .map((e) => CurrencyRate.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}