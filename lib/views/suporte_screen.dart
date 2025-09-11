// lib/views/suporte_screen.dart
//
// Tela de Suporte com integração DEMO do ManageEngine.
// - Formulário simples: Assunto + Descrição
// - Botão "Enviar" chama ManageEngineService().abrirTicket(...) (DEMO)
// - Botão "Ver Logs (DEMO)" abre /me-logs para visualizar tickets/métricas salvos localmente
// - Rodapé com ações rápidas: 193 (ligar) e Sair (volta ao login)
//
// Observações p/ o pitch:
// • Em ME_DEMO=1 não expomos credenciais e mostramos o fluxo completo.
// • Em produção, rodar com ME_DEMO=0 e definir ME_BASE_URL/ME_API_KEY via --dart-define.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/manageengine_service.dart';

class SuporteScreen extends StatefulWidget {
  const SuporteScreen({super.key});

  @override
  State<SuporteScreen> createState() => _SuporteScreenState();
}

class _SuporteScreenState extends State<SuporteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _assuntoCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _assuntoCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enviando = true);
    final ok = await ManageEngineService().abrirTicket(
      titulo: _assuntoCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim(),
    );
    setState(() => _enviando = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Ticket enviado (DEMO). Veja em "Logs ManageEngine".'
            : 'Falha ao enviar. Verifique configuração.'),
      ),
    );

    if (ok) {
      _assuntoCtrl.clear();
      _descricaoCtrl.clear();
    }
  }

  Future<void> _ligar193() async {
    final uri = Uri.parse('tel:193');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o discador')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Suporte')),
      body: Column(
        children: [
          // ===== Conteúdo principal: formulário =====
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'Abrir Ticket',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Assunto
                        TextFormField(
                          controller: _assuntoCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Assunto',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.subject),
                          ),
                          validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Informe um assunto' : null,
                        ),
                        const SizedBox(height: 12),

                        // Descrição
                        TextFormField(
                          controller: _descricaoCtrl,
                          minLines: 4,
                          maxLines: 8,
                          decoration: const InputDecoration(
                            labelText: 'Descrição',
                            hintText:
                            'Detalhe o problema ou solicitação (local, contato, situação, etc.)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                            alignLabelWithHint: true,
                          ),
                          validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Descreva o ocorrido' : null,
                        ),
                        const SizedBox(height: 16),

                        // Enviar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _enviando ? null : _enviar,
                            icon: _enviando
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                                : const Icon(Icons.send),
                            label: Text(_enviando ? 'Enviando...' : 'Enviar'),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Ver logs (DEMO)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/me-logs'),
                            icon: const Icon(Icons.receipt_long),
                            label: const Text('Logs ManageEngine (DEMO)'),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Nota sobre o modo demo
                        const Text(
                          'Obs.: Integração em modo DEMO para apresentação. '
                              'Em produção, configure ME_BASE_URL e ME_API_KEY via --dart-define.',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ===== Rodapé com ações rápidas =====
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 193
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _ligar193,
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
                // Sair
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
