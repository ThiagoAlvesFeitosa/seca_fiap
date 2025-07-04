import 'package:dio/dio.dart';
import '../models/clima_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _apiKey = 'd5f6b6a00623c81b00a4b95bd7ef4d2a'; // chave da api

  Future<ClimaModel?> fetchClima(double lat, double lon) async {
    try {
      final response = await _dio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
          'units': 'metric',
          'lang': 'pt_br',
        },
      );
      return ClimaModel.fromJson(response.data);
    } catch (e) {
      print('Erro ao buscar clima: $e');
      return null;
    }
  }
}
