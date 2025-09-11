// lib/views/ia_screen.dart
//
// Tela de IA & Alertas (sem Builder) usando a IA avançada do RiskService.
// Mostra: Score + barra colorida, faixa, VPD, chips de contribuição e botões
// para "Registrar métrica (ME)" e "Abrir ticket (risco alto)" em modo DEMO.
//
// Requisitos no projeto:
//  - RiskService: lib/services/risk_service.dart  (este arquivo já enviado)
//  - ManageEngineService: lib/services/manageengine_service.dart (modo DEMO)
//  - ClimaProvider: lib/providers/clima_provider.dart (com clima.temperatura/umidade)
//
// Observações:
//  - Se seu modelo de clima não tem vento/chuva/pop, tudo funciona igual (passamos null).
//  - Quando tiver esses campos, é só preencher abaixo nas chamadas.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/risk_service.dart';
import '../services/manageengine_service.dart';
import '../providers/clima_provider.dart';

class IaScreen extends StatefulWidget {
  const IaScreen({super.key});

  @override
  State<IaScreen> createState() => _IaScreenState();
}

class _IaScreenState extends State<IaScreen> {
  bool _registrandoMetrica = false;
  bool _abrindoTicket = false;

  // Cor dinâmica da barra de risco (verde → laranja → vermelho)
  Color _corBarra(ColorScheme scheme, double v) {
    if (v >= 0.75) return Colors.red;
    if (v >= 0.45) return Colors.orange;
    return scheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final clima = context.watch<ClimaProvider>().clima; // último clima buscado
    final scheme = Theme.of(context).colorScheme;

    if (clima == null) {
      // Mensagem clara caso o usuário caia aqui sem ter rodado "Analisar" na Home
      return Scaffold(
        appBar: AppBar(title: const Text('IA & Alertas')),
        body: const Center(
          child: Text(
            'Nenhum dado encontrado.\nVolte à Home e toque em "Analisar".',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // ===== Cálculo do risco (IA avançada) =====
    final res = RiskService.calcularAvancado(
      tempC: clima.temperatura,
      rhPct: clima.umidade,
      // Descomente e ajuste se existirem no seu modelo:
      // windMs: clima.ventoMs,
      // rain1hMm: clima.chuva1hMm,
      // pop: clima.pop, // 0..1
    );

    return Scaffold(
      appBar: AppBar(title: const Text('IA & Alertas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título + valor
            Text(
              'Score de Risco: ${res.score}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Barra de progresso colorida pelo nível de risco
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: res.score / 100.0,
                minHeight: 14,
                color: _corBarra(scheme, res.score / 100.0),
                backgroundColor: scheme.surfaceVariant,
              ),
            ),
            const SizedBox(height: 6),

            // Chips: Faixa + VPD
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text('Faixa: ${res.faixa}')),
                Chip(label: Text('VPD: ${res.vpd.toStringAsFixed(2)} kPa')),
              ],
            ),

            const SizedBox(height: 16),

            // Resumo do clima utilizado (ajuda a explicar o score)
            Card(
              child: ListTile(
                leading: const Icon(Icons.thermostat),
                title: Text('Temp.: ${clima.temperatura} °C  |  Umidade: ${clima.umidade}%'),
                subtitle: Text('Condição: ${clima.descricao}'),
              ),
            ),

            const SizedBox(height: 16),

            const Text('Fatores (contribuição):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),

            // Contribuição por fator (explicabilidade)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: res.contribuicao.entries.map((e) {
                final isRedutor = e.key.contains('Chuva');
                final bg = isRedutor ? scheme.secondaryContainer : scheme.primaryContainer;
                final fg = scheme.onPrimary; // fica bem visível nos containers
                return Chip(
                  backgroundColor: bg,
                  label: Text('${e.key}: ${e.value.toStringAsFixed(0)}%'),
                  labelStyle: TextStyle(color: fg),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            const Text('Recomendação:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(res.recomendacao),

            const Spacer(),

            // ===== Integração ManageEngine (DEMO) =====

            // 1) Registrar métrica (Analytics)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _registrandoMetrica
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.analytics),
                label: Text(_registrandoMetrica ? 'Registrando métrica...' : 'Registrar métrica (ME)'),
                onPressed: _registrandoMetrica
                    ? null
                    : () async {
                  setState(() => _registrandoMetrica = true);
                  await ManageEngineService().enviarMetricaRisco(res.score.toDouble());
                  setState(() => _registrandoMetrica = false);

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Métrica registrada (DEMO).')),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // 2) Abrir ticket quando risco alto
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _abrindoTicket
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.warning_amber),
                label: Text(_abrindoTicket ? 'Abrindo ticket...' : 'Abrir ticket (risco alto)'),
                onPressed: (res.score >= 75 && !_abrindoTicket)
                    ? () async {
                  setState(() => _abrindoTicket = true);

                  final ok = await ManageEngineService().abrirTicket(
                    titulo: 'Risco alto detectado',
                    descricao: 'Score >= 75 com base no clima atual da sua localização.',
                  );

                  setState(() => _abrindoTicket = false);

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'Ticket aberto (DEMO).' : 'Falha ao abrir ticket.'),
                    ),
                  );
                }
                    : null,
              ),
            ),

            const SizedBox(height: 8),
            const Text(
              'Obs.: IA baseline com VPD/vento/chuva (explicável) + ManageEngine em modo DEMO.\n'
                  'No futuro, conectamos ServiceDesk/Analytics reais (ME_DEMO=0).',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
