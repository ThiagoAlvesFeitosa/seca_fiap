import 'package:flutter/material.dart';
import '../models/clima_model.dart';
import '../services/api_service.dart';

class ClimaProvider with ChangeNotifier {
  ClimaModel? _clima;
  bool _loading = false;

  ClimaModel? get clima => _clima;
  bool get loading => _loading;

  final ApiService _apiService = ApiService();

  Future<void> buscarClima(double lat, double lon) async {
    _loading = true;
    notifyListeners();

    _clima = await _apiService.fetchClima(lat, lon);

    _loading = false;
    notifyListeners();
  }
}
