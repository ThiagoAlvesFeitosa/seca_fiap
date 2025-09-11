import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/clima_provider.dart';
import '../services/location_service.dart';
import 'mapa_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String resultado = 'Pressione "Analisar" para começar';

  @override
  Widget build(BuildContext context) {
    final climaProvider = Provider.of<ClimaProvider>(context);
    final scheme = Theme.of(context).colorScheme; // <- pega paleta do tema

    return Scaffold(
      appBar: AppBar(
        title: const Text('RuraLTime'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Sobre',
            onPressed: () => Navigator.pushNamed(context, '/sobre'),
          ),
        ],
      ),
      body: climaProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Título agora usa a cor primária do tema (Fern Green)
                  Text(
                    'Monitoramento de Seca',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Análise climática da sua região',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Card do resultado com borda/sombra vindas do tema
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: scheme.outline.withOpacity(.45)),
                    ),
                    shadowColor: scheme.outline.withOpacity(.15),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        resultado,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // LINHA 1
                  Row(
                    children: [
                      _buildActionCard(
                        context,
                        icon: Icons.cloud,
                        label: 'Analisar',
                        onPressed: () async {
                          final position = await LocationService().getCurrentPosition();
                          if (position != null) {
                            await climaProvider.buscarClima(
                              position.latitude,
                              position.longitude,
                            );

                            final clima = climaProvider.clima;
                            if (clima != null) {
                              setState(() {
                                String alerta = '';
                                if (clima.umidade < 30) {
                                  alerta = '🚨 Alerta de seca severa! 🌵';
                                } else if (clima.umidade < 50) {
                                  alerta = '⚠️ Atenção: Umidade baixa!';
                                } else {
                                  alerta = '✅ Condição adequada. Sem risco de seca. 🌤️';
                                }

                                resultado = '''
Clima: ${clima.descricao}
Temperatura: ${clima.temperatura}°C
Umidade: ${clima.umidade}%

$alerta
''';
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MapaScreen(
                                    latitude: position.latitude,
                                    longitude: position.longitude,
                                  ),
                                ),
                              );
                            }
                          } else {
                            setState(() => resultado = 'Permissão de localização negada!');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Permissão de localização negada.')),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionCard(
                        context,
                        icon: Icons.bar_chart,
                        label: 'Gráficos',
                        onPressed: () => Navigator.pushNamed(context, '/graficos'),
                      ),
                      const SizedBox(width: 8),
                      _buildActionCard(
                        context,
                        icon: Icons.support_agent,
                        label: 'Suporte',
                        onPressed: () => Navigator.pushNamed(context, '/suporte'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // LINHA 2
                  Row(
                    children: [
                      _buildActionCard(
                        context,
                        icon: Icons.smart_toy,
                        label: 'IA & Alertas',
                        onPressed: () => Navigator.pushNamed(context, '/ia'),
                      ),
                      const SizedBox(width: 8),
                      _buildActionCard(
                        context,
                        icon: Icons.refresh,
                        label: 'Atualizar',
                        onPressed: () async {
                          final position = await LocationService().getCurrentPosition();
                          if (position != null) {
                            await climaProvider.buscarClima(
                              position.latitude,
                              position.longitude,
                            );

                            final clima = climaProvider.clima;
                            if (clima != null) {
                              setState(() {
                                String alerta = '';
                                if (clima.umidade < 30) {
                                  alerta = '🚨 Alerta de seca severa! 🌵';
                                } else if (clima.umidade < 50) {
                                  alerta = '⚠️ Atenção: Umidade baixa!';
                                } else {
                                  alerta = '✅ Condição adequada. Sem risco de seca. 🌤️';
                                }

                                resultado = '''
Clima: ${clima.descricao}
Temperatura: ${clima.temperatura}°C
Umidade: ${clima.umidade}%

$alerta
''';
                              });
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Permissão de localização negada.')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Rodapé (ligação 193 + Sair)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Botão 193 com a cor de erro do tema (vermelho)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final Uri uri = Uri.parse('tel:193');
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
                      backgroundColor: scheme.error,
                      foregroundColor: scheme.onError,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Botão Sair usando o secundário (Dark Moss)
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Sair'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.secondary,
                    foregroundColor: scheme.onSecondary,
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

  // Card de ação reutilizável (icone + título)
  Widget _buildActionCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onPressed,
      }) {
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Card(
          color: Theme.of(context).cardColor,
          shadowColor: scheme.outline.withOpacity(.15),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: scheme.outline.withOpacity(.45)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 30, color: scheme.primary),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
