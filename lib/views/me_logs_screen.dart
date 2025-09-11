import 'package:flutter/material.dart';
import '../services/manageengine_service.dart';

class MeLogsScreen extends StatefulWidget {
  const MeLogsScreen({super.key});

  @override
  State<MeLogsScreen> createState() => _MeLogsScreenState();
}

class _MeLogsScreenState extends State<MeLogsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _limpar() async {
    await ManageEngineService.limparDemo();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registros (DEMO) limpos')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs(DEMO)'),
        // Forço cor aqui para garantir contraste perfeito
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
        bottom: TabBar(
          controller: _tab,
          labelColor: scheme.onSecondary,
          unselectedLabelColor: scheme.onSecondary.withOpacity(.7),
          indicatorColor: scheme.onSecondary,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.confirmation_number), text: 'Tickets'),
            Tab(icon: Icon(Icons.analytics), text: 'Métricas'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Limpar',
            onPressed: _limpar,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          FutureBuilder(
            future: ManageEngineService.listarTicketsDemo(),
            builder: (context, snapshot) {
              final data = snapshot.data ?? [];
              if (data.isEmpty) return const Center(child: Text('Sem tickets (DEMO).'));
              return ListView.separated(
                itemCount: data.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final t = data[i];
                  return ListTile(
                    leading: const Icon(Icons.confirmation_number),
                    title: Text(t['titulo'] ?? '(sem título)'),
                    subtitle: Text('${t['descricao'] ?? ''}\n${t['status'] ?? ''} — ${t['criadoEm'] ?? ''}'),
                  );
                },
              );
            },
          ),
          FutureBuilder(
            future: ManageEngineService.listarMetricasDemo(),
            builder: (context, snapshot) {
              final data = snapshot.data ?? [];
              if (data.isEmpty) return const Center(child: Text('Sem métricas (DEMO).'));
              return ListView.separated(
                itemCount: data.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final m = data[i];
                  return ListTile(
                    leading: const Icon(Icons.analytics),
                    title: Text('${m['metric'] ?? ''}: ${m['value'] ?? ''}'),
                    subtitle: Text('Registrado em: ${m['registradoEm'] ?? ''}'),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
