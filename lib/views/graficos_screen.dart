// lib/views/graficos_screen.dart
//
// ============================================================
//  TELA: GRÁFICOS DE CLIMA (com simulação didática + rodapé)
// ============================================================
//
// O QUE ESSA TELA FAZ
// -------------------
// • Lê o "clima atual" do Provider (valores vindos da API OpenWeather).
// • A partir desses valores REAIS (temperatura/umidade), gera uma série
//   "simulada" de 5 dias com tendência suave e coerente.
// • Calcula também o VPD (kPa), que combina T e RH e é ótimo indicador
//   de estresse hídrico (quanto maior, mais “o ar puxa água” das plantas/solo).
// • Renderiza 3 gráficos (fl_chart) com o tema do app:
//     1) Temperatura (barras)
//     2) Umidade (linha)
//     3) VPD (linha)
// • Mostra, no rodapé, os botões "📞 193" e "🚪 Sair" (iguais aos da Home).
//
// POR QUE SIMULAR?
// ----------------
// • Para o pitch, nem sempre você terá histórico/forecast salvos. A simulação
//   cria uma tendência EXPlicável (↑temp → ↓umidade) usando os dados REAIS como base.
// • Quando você tiver séries reais no Provider, é só substituir as listas
//   simuladas pelas reais (a UI dos gráficos já aceita listas).
//
// DEPENDÊNCIAS
// ------------
//   fl_chart: ^0.x
//   provider: ^6.x
//   url_launcher: ^6.x
//
//  *Lembre de importar no pubspec.yaml e rodar: flutter pub get
//

import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/clima_provider.dart';

/// ============================================================
///  WIDGET PRINCIPAL DA TELA
/// ============================================================
class GraficosScreen extends StatelessWidget {
  const GraficosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Pega o último "clima" consultado via Provider (Home -> "Analisar")
    final clima = context.watch<ClimaProvider>().clima;

    // ------------------------------------------------------------
    // 1) CONTEÚDO PRINCIPAL (gráficos) OU MENSAGEM DE ORIENTAÇÃO
    // ------------------------------------------------------------
    Widget content;
    if (clima == null) {
      // Caso o usuário abra a tela sem ter buscado o clima ainda
      content = const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Nenhum dado para exibir.\nVolte à Home e toque em "Analisar" para carregar o clima atual.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      // ------------------------------------------------------------
      // 2) SIMULAÇÃO DETERMINÍSTICA A PARTIR DO CLIMA REAL
      //    - Base: clima.temperatura (°C) e clima.umidade (%)
      //    - Cria 5 dias (D0..D4) com oscilação suave (senoide)
      //    - Ajusta umidade inversamente à variação de temperatura
      //    - Calcula VPD por dia (física simples via Tetens)
      // ------------------------------------------------------------
      final simulacao = _simularSerie5dias(
        baseTempC: clima.temperatura,
        baseUmidPct: clima.umidade,
      );

      // ------------------------------------------------------------
      // 3) GRÁFICOS (3 cards) + SCROLL
      // ------------------------------------------------------------
      content = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ----- Gráfico 1: TEMPERATURA (BARRAS) -----
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                child: Column(
                  children: [
                    Text(
                      'Temperatura (°C)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: _TemperaturaChart(
                        dias: simulacao.dias,
                        valores: simulacao.temp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ----- Gráfico 2: UMIDADE (LINHA) -----
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                child: Column(
                  children: [
                    Text(
                      'Umidade (%)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: _UmidadeChart(
                        dias: simulacao.dias,
                        valores: simulacao.umid,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ----- Gráfico 3: VPD (LINHA) -----
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                child: Column(
                  children: [
                    Text(
                      'VPD (kPa)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: _VpdChart(
                        dias: simulacao.dias,
                        valores: simulacao.vpd,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'VPD alto = ar “puxando” mais água (maior estresse hídrico).',
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ------------------------------------------------------------
    // 4) LAYOUT FINAL: CONTEÚDO + RODAPÉ (193 / SAIR)
    // ------------------------------------------------------------
    return Scaffold(
      appBar: AppBar(title: const Text('Gráficos de Clima')),
      body: Column(
        children: [
          // Área dos gráficos (ou mensagem de orientação), expandida
          Expanded(child: content),

          // ========== RODAPÉ FIXO COM AÇÕES RÁPIDAS ==========
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Botão 193 (ligação) — usa "error" do tema (vermelho)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse('tel:193');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Não foi possível abrir o discador')),
                        );
                      }
                    },
                    icon: Icon(Icons.warning, color: Theme.of(context).colorScheme.onError),
                    label: const Text('193'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Botão Sair — usa "secondary" do tema (Dark Moss)
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Sair'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
///  BLOCO: SIMULAÇÃO (gera listas a partir do clima real)
/// ============================================================
class _SerieSimulada {
  final List<String> dias; // rótulos (ex.: Seg..Sex)
  final List<double> temp; // °C
  final List<double> umid; // %
  final List<double> vpd;  // kPa
  _SerieSimulada(this.dias, this.temp, this.umid, this.vpd);
}

/// Gera 5 pontos (D0..D4) a partir de T/RH reais:
/// • Temperatura = base + senoide suave + leve tendência:
///    - se muito seco (<45% RH) → tendência a aquecer ~0.3 °C/dia
///    - se muito úmido (>65% RH) → tendência a esfriar ~0.2 °C/dia
/// • Umidade reage inversamente à variação de T (limitada entre 35% e 95%).
/// • VPD calculado pela fórmula de Tetens (tudo local/offline).
_SerieSimulada _simularSerie5dias({
  required double baseTempC,
  required double baseUmidPct,
}) {
  // Rótulos próximos 5 dias a partir de hoje
  final now = DateTime.now();
  final dias = List<String>.generate(5, (i) => _abbrPtBr(now.add(Duration(days: i)).weekday));

  // Amplitude de oscilação (mais seco → oscila mais)
  final amp = 1.5 + (1.0 - (baseUmidPct.clamp(30, 90) - 30) / 60.0) * 1.5; // ~1.5..3.0 °C

  // Tendência (slope) por nível de umidade
  final slope = baseUmidPct < 45
      ? 0.3
      : (baseUmidPct > 65 ? -0.2 : 0.0);

  final temp = <double>[];
  final umid = <double>[];

  for (var i = 0; i < 5; i++) {
    // Onda suave (período ~3 pontos)
    final wave = math.sin(i * math.pi / 3) * amp;

    // Temperatura simulada
    final t = baseTempC + wave + slope * i;
    temp.add(double.parse(t.toStringAsFixed(1)));

    // Umidade reage inversamente à variação da temperatura (com limites)
    final u = (baseUmidPct - (t - baseTempC) * 2).clamp(35.0, 95.0);
    umid.add(double.parse(u.toStringAsFixed(1)));
  }

  // VPD para cada par T/RH
  final vpd = <double>[];
  for (var i = 0; i < 5; i++) {
    vpd.add(double.parse(_vpd(temp[i], umid[i]).toStringAsFixed(2)));
  }

  return _SerieSimulada(dias, temp, umid, vpd);
}

// Abreviação PT-BR dos dias da semana
String _abbrPtBr(int weekday) {
  switch (weekday) {
    case DateTime.monday:    return 'Seg';
    case DateTime.tuesday:   return 'Ter';
    case DateTime.wednesday: return 'Qua';
    case DateTime.thursday:  return 'Qui';
    case DateTime.friday:    return 'Sex';
    case DateTime.saturday:  return 'Sáb';
    default:                 return 'Dom';
  }
}

// -------- Física simples p/ VPD --------
// es(T): pressão de vapor de saturação (kPa), fórmula de Tetens.
// e = es(T) * RH ; VPD = es(T) - e. Quanto maior o VPD, maior o “poder de secar” do ar.
double _es(double tC) => 0.6108 * math.exp((17.27 * tC) / (tC + 237.3));
double _vpd(double tempC, double rhPct) {
  final esat = _es(tempC);
  final e = esat * (rhPct.clamp(0, 100) / 100.0);
  final v = esat - e;
  return v.isFinite ? math.max(0.0, v) : 0.0;
}

/// ============================================================
///  BLOCO: WIDGETS DE GRÁFICO (fl_chart)
/// ============================================================

/// ---------- 1) Temperatura (Barras) ----------
class _TemperaturaChart extends StatelessWidget {
  const _TemperaturaChart({required this.dias, required this.valores});

  final List<String> dias;
  final List<double> valores;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final max = (valores.reduce((a, b) => a > b ? a : b) + 5);
    final min = (valores.reduce((a, b) => a < b ? a : b) - 2);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: max,
        minY: min,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: scheme.secondary.withOpacity(.95),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final dia = dias[group.x.toInt()];
              return BarTooltipItem(
                '$dia\n${rod.toY.toStringAsFixed(1)} °C',
                TextStyle(color: scheme.onSecondary, fontWeight: FontWeight.w600),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                return Text(
                  i >= 0 && i < dias.length ? dias[i] : '',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: 2,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) => FlLine(
            color: scheme.outline.withOpacity(.35),
            strokeWidth: 1,
            dashArray: const [4, 4],
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: scheme.outline.withOpacity(.6)),
        ),
        barGroups: [
          for (int i = 0; i < valores.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: valores[i],
                  width: 16,
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [scheme.primary, scheme.primaryContainer],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// ---------- 2) Umidade (Linha) ----------
class _UmidadeChart extends StatelessWidget {
  const _UmidadeChart({required this.dias, required this.valores});

  final List<String> dias;
  final List<double> valores;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final spots = <FlSpot>[
      for (int i = 0; i < valores.length; i++) FlSpot(i.toDouble(), valores[i]),
    ];
    final minY = (valores.reduce((a, b) => a < b ? a : b) - 5);
    final maxY = (valores.reduce((a, b) => a > b ? a : b) + 5);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (valores.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: scheme.secondary.withOpacity(.95),
            getTooltipItems: (items) => items
                .map((s) => LineTooltipItem(
              '${dias[s.x.toInt()]}\n${s.y.toStringAsFixed(1)} %',
              TextStyle(color: scheme.onSecondary, fontWeight: FontWeight.w600),
            ))
                .toList(),
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                return Text(
                  i >= 0 && i < dias.length ? dias[i] : '',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: 5,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          verticalInterval: 1,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: scheme.outline.withOpacity(.35),
            strokeWidth: 1,
            dashArray: const [4, 4],
          ),
          getDrawingVerticalLine: (value) => FlLine(
              color: scheme.outline.withOpacity(.25),
              strokeWidth: 1,
              dashArray: const [4, 6]),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: scheme.outline.withOpacity(.6)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: scheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 3.5,
                color: scheme.onPrimary,
                strokeWidth: 2,
                strokeColor: scheme.primary,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.primary.withOpacity(.35),
                  scheme.primary.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- 3) VPD (Linha) ----------
class _VpdChart extends StatelessWidget {
  const _VpdChart({required this.dias, required this.valores});

  final List<String> dias;
  final List<double> valores;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final spots = <FlSpot>[
      for (int i = 0; i < valores.length; i++) FlSpot(i.toDouble(), valores[i]),
    ];
    final minY = (valores.reduce((a, b) => a < b ? a : b) - 0.2).clamp(0.0, 10.0);
    final maxY = (valores.reduce((a, b) => a > b ? a : b) + 0.4).clamp(0.0, 10.0);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (valores.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: scheme.secondary.withOpacity(.95),
            getTooltipItems: (items) => items
                .map((s) => LineTooltipItem(
              '${dias[s.x.toInt()]}\n${s.y.toStringAsFixed(2)} kPa',
              TextStyle(color: scheme.onSecondary, fontWeight: FontWeight.w600),
            ))
                .toList(),
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                return Text(
                  i >= 0 && i < dias.length ? dias[i] : '',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 0.5,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(1),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          verticalInterval: 1,
          horizontalInterval: 0.5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: scheme.outline.withOpacity(.35),
            strokeWidth: 1,
            dashArray: const [4, 4],
          ),
          getDrawingVerticalLine: (value) => FlLine(
              color: scheme.outline.withOpacity(.25),
              strokeWidth: 1,
              dashArray: const [4, 6]),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: scheme.outline.withOpacity(.6)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: scheme.tertiary, // tom diferente para o VPD
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.tertiary.withOpacity(.25),
                  scheme.tertiary.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
