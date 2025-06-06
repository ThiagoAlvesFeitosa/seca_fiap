import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraficosScreen extends StatelessWidget {
  const GraficosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gráficos de Clima')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Temperatura (°C)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 200, child: TemperaturaChart()),
            const SizedBox(height: 24),
            const Text('Umidade (%)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 200, child: UmidadeChart()),
          ],
        ),
      ),
    );
  }
}

class TemperaturaChart extends StatelessWidget {
  const TemperaturaChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: [
          for (int i = 0; i < 5; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(toY: [28.0, 30.0, 27.0, 31.0, 29.0][i], width: 16),
              ],
            )
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];
                return Text(dias[value.toInt()]);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class UmidadeChart extends StatelessWidget {
  const UmidadeChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 60.0),
              const FlSpot(1, 55.0),
              const FlSpot(2, 70.0),
              const FlSpot(3, 65.0),
              const FlSpot(4, 58.0),
            ],
            isCurved: true,
            barWidth: 3,
            dotData: FlDotData(show: true),
          )
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];
                return Text(dias[value.toInt()]);
              },
            ),
          ),
        ),
      ),
    );
  }
}
