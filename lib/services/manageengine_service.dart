// Arquivo: lib/services/manageengine_service.dart
// Objetivo: simular integração com ManageEngine (ServiceDesk/Analytics)
// sem precisar de API real. Quando ME_DEMO=1 (padrão), salva "tickets"
// e "métricas" em SharedPreferences e retorna sucesso.
// Futuro: se quiser real, basta passar --dart-define=ME_DEMO=0
// e configurar ME_BASE_URL + ME_API_KEY.

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageEngineService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Lê variáveis de ambiente em build/run-time.
  final String _baseUrl = const String.fromEnvironment('ME_BASE_URL', defaultValue: '');
  final String _apiKey  = const String.fromEnvironment('ME_API_KEY',  defaultValue: '');
  final String _demoStr = const String.fromEnvironment('ME_DEMO',     defaultValue: '1');

  bool get _demoMode => _demoStr == '1' || _demoStr.toLowerCase() == 'true';

  // Chaves para "persistência" local (demo)
  static const String _kTickets = 'me_demo_tickets';
  static const String _kMetrics = 'me_demo_metrics';

  // ---------------- DEMO helpers ----------------

  Future<void> _saveDemoTicket(Map<String, dynamic> t) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_kTickets) ?? <String>[];
    list.add(jsonEncode(t));
    await sp.setStringList(_kTickets, list);
  }

  Future<void> _saveDemoMetric(Map<String, dynamic> m) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_kMetrics) ?? <String>[];
    list.add(jsonEncode(m));
    await sp.setStringList(_kMetrics, list);
  }

  static Future<List<Map<String, dynamic>>> listarTicketsDemo() async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_kTickets) ?? <String>[];
    return list.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
  }

  static Future<List<Map<String, dynamic>>> listarMetricasDemo() async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_kMetrics) ?? <String>[];
    return list.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
  }

  static Future<void> limparDemo() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kTickets);
    await sp.remove(_kMetrics);
  }

  // ---------------- API pública ----------------

  Future<bool> abrirTicket({
    required String titulo,
    required String descricao,
    String prioridade = 'High',
    String categoria = 'Ops/Clima',
  }) async {
    // MODO DEMO: salva local e retorna sucesso
    if (_demoMode || _baseUrl.isEmpty || _apiKey.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 400));
      await _saveDemoTicket({
        'titulo': titulo,
        'descricao': descricao,
        'prioridade': prioridade,
        'categoria': categoria,
        'criadoEm': DateTime.now().toIso8601String(),
        'status': 'ABERTO (DEMO)',
      });
      return true;
    }

    // FUTURO: chamada real (ServiceDesk Plus, por ex.)
    try {
      final resp = await _dio.post(
        '$_baseUrl/api/tickets',
        options: Options(headers: {'Authorization': 'Bearer $_apiKey'}),
        data: {
          'title': titulo,
          'description': descricao,
          'priority': prioridade,
          'category': categoria,
        },
      );
      return resp.statusCode == 200 || resp.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<void> enviarMetricaRisco(double score) async {
    if (_demoMode || _baseUrl.isEmpty || _apiKey.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 300));
      await _saveDemoMetric({
        'metric': 'risk_score',
        'value': score,
        'registradoEm': DateTime.now().toIso8601String(),
      });
      return;
    }

    try {
      await _dio.post(
        '$_baseUrl/api/analytics',
        options: Options(headers: {'Authorization': 'Bearer $_apiKey'}),
        data: {'metric': 'risk_score', 'value': score},
      );
    } catch (_) {
      // ignore no demo
    }
  }
}
