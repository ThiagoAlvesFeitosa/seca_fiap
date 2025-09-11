// lib/views/sobre_screen.dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SobreScreen extends StatefulWidget {
  const SobreScreen({super.key});

  @override
  State<SobreScreen> createState() => _SobreScreenState();
}

class _SobreScreenState extends State<SobreScreen> {
  PackageInfo? _info;

  // Variáveis de ambiente (nunca expomos valores)
  final String _owmKey   = const String.fromEnvironment('OWM_KEY',    defaultValue: '');
  final String _meDemo   = const String.fromEnvironment('ME_DEMO',    defaultValue: '1');
  final String _meBase   = const String.fromEnvironment('ME_BASE_URL',defaultValue: '');
  final String _meApiKey = const String.fromEnvironment('ME_API_KEY', defaultValue: '');

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _info = info);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o link')),
      );
    }
  }

  Future<void> _goMeLogs() async {
    try {
      if (!mounted) return;
      await Navigator.of(context).pushNamed('/me-logs');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rota "/me-logs" não encontrada.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appName  = _info?.appName ?? 'RuraLTime';
    final version  = _info?.version ?? '-';
    final buildNum = _info?.buildNumber ?? '-';

    final bool demoLigado = _meDemo == '1' || _meDemo.toLowerCase() == 'true';
    final bool meConfigOk = demoLigado ? true : (_meBase.isNotEmpty && _meApiKey.isNotEmpty);

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o App')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.apps),
              title: Text(appName),
              subtitle: Text('Versão $version (build $buildNum)'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Status de Configuração'),
              subtitle: Text(
                'OpenWeatherMap: ${_owmKey.isNotEmpty ? 'configurada ✅' : 'não configurada ❌'}\n'
                    'ManageEngine: ${demoLigado ? 'DEMO ativado ✅' : (meConfigOk ? 'modo REAL (configurado) ✅' : 'modo REAL (faltam ME_BASE_URL/ME_API_KEY) ❌')}',
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Equipe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Card(child: ListTile(leading: Icon(Icons.person), title: Text('Gustavo Martins Mendes'), subtitle: Text('RM 99728'))),
          const Card(child: ListTile(leading: Icon(Icons.person), title: Text('Isabella Freire'),       subtitle: Text('RM 98908'))),
          const Card(child: ListTile(leading: Icon(Icons.person), title: Text('Pedro Lucas Santos Diniz'), subtitle: Text('RM 97935'))),
          const Card(child: ListTile(leading: Icon(Icons.person), title: Text('Thiago Alves Feitosa'),  subtitle: Text('RM 550442'))),
          const Card(child: ListTile(leading: Icon(Icons.person), title: Text('Yasmin Botelho Santiago'), subtitle: Text('RM 550335'))),
          const SizedBox(height: 12),
          const Text('Links Úteis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _openUrl('https://github.com/ThiagoAlvesFeitosa/seca_fiap'),
            icon: const Icon(Icons.link),
            label: const Text('Repositório no GitHub'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _openUrl('https://youtube.com/'), //  pitch
            icon: const Icon(Icons.ondemand_video),
            label: const Text('Vídeo Pitch (YouTube)'),
          ),
          const SizedBox(height: 8),
          if (demoLigado)
            OutlinedButton.icon(
              onPressed: _goMeLogs,
              icon: const Icon(Icons.receipt_long),
              label: const Text('Ver Logs ManageEngine (DEMO)'),
            ),
          const SizedBox(height: 24),
          const Text('Sobre', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Aplicativo de monitoramento climático local com cálculo de score de risco (IA baseline) '
                'e integração operacional (ManageEngine) simulada em modo DEMO. '
                'Projeto acadêmico FIAP – Enterprise Challenge.',
          ),
          const SizedBox(height: 16),
          const Text('Contato', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _openUrl('mailto:contato@exemplo.com?subject=RuraLTime%20-%20Contato'),
            icon: const Icon(Icons.email_outlined),
            label: const Text('contato@exemplo.com'),
          ),
        ],
      ),
    );
  }
}
