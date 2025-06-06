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
  String resultado = 'Pressione "Analisar Local" para começar';

  @override
  Widget build(BuildContext context) {
    final climaProvider = Provider.of<ClimaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RuraLTime'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Sobre',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tela "Sobre" ainda será implementada')),
              );
            },
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
                  const Text(
                    'Monitoramento de Seca',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
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
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.orange.shade200),
                    ),
                    shadowColor: Colors.orange.shade100,
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
                  Row(
                    children: [
                      _buildActionCard(
                        context,
                        icon: Icons.cloud,
                        label: 'Analisar',
                        onPressed: () async {
                          final locationService = LocationService();
                          final position = await locationService.getCurrentPosition();

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
                            setState(() {
                              resultado = 'Permissão de localização negada!';
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionCard(
                        context,
                        icon: Icons.bar_chart,
                        label: 'Gráficos',
                        onPressed: () {
                          Navigator.pushNamed(context, '/graficos');
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionCard(
                        context,
                        icon: Icons.lightbulb,
                        label: 'Dicas',
                        onPressed: () {
                          Navigator.pushNamed(context, '/dicas');
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionCard(
                        context,
                        icon: Icons.support_agent,
                        label: 'Suporte',
                        onPressed: () {
                          Navigator.pushNamed(context, '/suporte');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                    icon: const Icon(Icons.warning, color: Colors.white),
                    label: const Text('193'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  },
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Sair'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: const TextStyle(fontSize: 14),
                    backgroundColor: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onPressed,
      }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Card(
          color: Colors.white,
          shadowColor: Colors.orange.shade100,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.orange.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 30, color: Colors.deepOrange),
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
