// lib/services/risk_service.dart
// IA baseline "explicável" com VPD, vento e chuva.
// Sem dependência externa: calcula tudo localmente.
// Comentários em PT-BR para estudo.

import 'dart:math';

class RiskResult {
  final int score;                        // 0..100
  final String faixa;                     // Baixo/Médio/Alto
  final String recomendacao;              // ação sugerida
  final Map<String, double> contribuicao; // % por fator (soma ~100)
  final double vpd;                       // kPa (métrica útil p/ debug)

  const RiskResult({
    required this.score,
    required this.faixa,
    required this.recomendacao,
    required this.contribuicao,
    required this.vpd,
  });
}

class RiskService {
  // -------- utilidades físicas simples --------

  // Pressão de vapor de saturação (kPa) pela fórmula de Tetens (T em °C).
  static double _es(double tC) {
    // 0.6108 * exp(17.27*T/(T+237.3))
    return 0.6108 * exp((17.27 * tC) / (tC + 237.3));
  }

  // VPD (kPa): es(T) - e ; e = es(T) * RH
  static double _vpd(double tempC, double rhPct) {
    final esat = _es(tempC);
    final e = esat * (rhPct.clamp(0, 100) / 100.0);
    final v = (esat - e);
    return v.isFinite ? max(0.0, v) : 0.0; // nunca negativo
  }

  // Normaliza 0..1 com clamp
  static double _norm(double x, double min, double max) {
    if (max <= min) return 0;
    return ((x - min) / (max - min)).clamp(0.0, 1.0);
  }

  // -------- cálculo principal --------
  //
  // Parâmetros:
  // - tempC / rhPct: obrigatórios
  // - windMs: opcional (m/s)
  // - rain1hMm: opcional (mm de chuva na última 1h)
  // - pop: opcional (probabilidade de precipitação 0..1)
  //
  // Ideia:
  //   score_base = 100 * [ 0.30 * temp_norm(20..40)
  //                      + 0.25 * (1 - rh)
  //                      + 0.30 * vpd_norm(0..3kPa)
  //                      + 0.10 * wind_norm(0..10m/s)
  //                      - 0.15 * rain_norm(0..5mm OU pop) ]
  //
  // Pesos somam ~1 considerando o termo de chuva como "redutor".
  static RiskResult calcularAvancado({
    required double tempC,
    required double rhPct,
    double? windMs,
    double? rain1hMm,
    double? pop, // 0..1
  }) {
    // Fatores normalizados (0..1)
    final tempN = _norm(tempC, 20, 40);              // 20→0, 40→1
    final securaN = 1.0 - (rhPct.clamp(0, 100) / 100.0);
    final vpdVal = _vpd(tempC, rhPct);               // kPa
    final vpdN = _norm(vpdVal, 0, 3);                // 0..3 kPa cobertura boa

    final windN = windMs != null ? _norm(windMs, 0, 10) : 0.0;

    // Chuva recente reduz risco. Se não veio mm, uso POP (chance de chover).
    double rainN = 0.0;
    if (rain1hMm != null) {
      rainN = _norm(rain1hMm, 0, 5); // 5 mm/h já ajuda bastante
    } else if (pop != null) {
      rainN = pop.clamp(0.0, 1.0);
    }

    // Pesos (ajustáveis conforme validação):
    const wTemp = 0.30;
    const wSeca = 0.25;
    const wVpd  = 0.30;
    const wWind = 0.10;
    const wRain = 0.15; // redutor

    // Score bruto em 0..100
    double raw =
        100.0 * (wTemp * tempN + wSeca * securaN + wVpd * vpdN + wWind * windN - wRain * rainN);

    final score = raw.isFinite ? raw.clamp(0.0, 100.0).round() : 0;

    // Faixas simples
    String faixa;
    if (score >= 75) {
      faixa = 'ALTO';
    } else if (score >= 45) {
      faixa = 'MÉDIO';
    } else {
      faixa = 'BAIXO';
    }

    // Recomendações didáticas
    String rec;
    if (score >= 75) {
      rec =
      'Risco alto. Reforce irrigação onde possível, evite queimas, monitore focos e acione plano de contingência.';
    } else if (score >= 45) {
      rec = 'Risco moderado. Planeje irrigação e vigilância; ajuste operações sensíveis ao calor.';
    } else {
      rec = 'Condição adequada. Mantenha monitoramento e práticas regulares.';
    }

    // Explicabilidade (% de contribuição positiva e redutora)
    // Para exibir no UI, transformo cada termo na sua parcela do |raw| (valor absoluto).
    final parts = <String, double>{
      'Temperatura': (wTemp * tempN),
      'Secura (1-RH)': (wSeca * securaN),
      'VPD': (wVpd * vpdN),
      'Vento': (wWind * windN),
      'Chuva/POP (reduz)': (wRain * rainN), // marcado como redutor no UI
    };

    // Normalizo para somar ~100% (em termos absolutos)
    final sumAbs = parts.values.fold<double>(0.0, (a, b) => a + b.abs());
    final contrib = sumAbs > 0
        ? parts.map((k, v) => MapEntry(k, (v.abs() / sumAbs) * 100.0))
        : parts.map((k, v) => MapEntry(k, 0.0));

    return RiskResult(
      score: score,
      faixa: faixa,
      recomendacao: rec,
      contribuicao: contrib,
      vpd: vpdVal,
    );
  }
}
