import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/clima_provider.dart';

class DicasScreen extends StatelessWidget {
  const DicasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clima = Provider.of<ClimaProvider>(context).clima;

    String dica;

    if (clima == null) {
      dica = 'Nenhuma análise foi realizada ainda.\n\n'
          'Clique em "Analisar Local" na tela inicial para obter recomendações.';
    } else if (clima.umidade < 30) {
      dica = '''
🚨 Umidade muito baixa!

🔹 Evite queimadas — o risco de incêndio é extremo.
🔹 Utilize cobertura morta (palhada) para proteger o solo.
🔹 Aumente a irrigação com controle para evitar desperdícios.
🔹 Suspenda o uso de fertilizantes que exigem umidade.
''';
    } else if (clima.umidade < 50) {
      dica = '''
⚠️ Umidade baixa

🔹 Use sistemas de irrigação por gotejamento para economia.
🔹 Faça o plantio de culturas mais resistentes à seca.
🔹 Mantenha o solo coberto com folhas secas ou palha.
🔹 Evite plantio profundo durante esse período.
''';
    } else {
      dica = '''
✅ Umidade adequada

🔹 Ideal para manutenção do solo e preparo do plantio.
🔹 Aproveite para revisar sistemas de irrigação.
🔹 Planeje ações preventivas caso a umidade comece a cair.
🔹 Use adubação equilibrada e monitore o solo semanalmente.
''';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dicas de Manejo Agrícola')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          dica,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
