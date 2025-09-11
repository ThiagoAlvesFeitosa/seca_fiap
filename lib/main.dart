import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';

// Providers
import 'providers/clima_provider.dart';

// Telas
import 'views/login_screen.dart';
import 'views/home_screen.dart';
import 'views/graficos_screen.dart';
import 'views/suporte_screen.dart';
import 'views/sobre_screen.dart';
import 'views/ia_screen.dart';
import 'views/me_logs_screen.dart';



void main() {
  // Boa prática quando alguns plugins acessam bindings de plataforma
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SecaApp());
}

class SecaApp extends StatelessWidget {
  const SecaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Estado global do clima
        ChangeNotifierProvider(create: (_) => ClimaProvider()),
      ],
      child: MaterialApp(
        title: 'RuraLTime',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        // Começa no login
        initialRoute: '/',
        // Rotas nomeadas do app
        routes: {
          '/':         (context) => const LoginScreen(),
          '/home':     (context) => const HomeScreen(),
          '/graficos': (context) => const GraficosScreen(),
          '/suporte':  (context) => const SuporteScreen(),
          '/ia':       (context) => const IaScreen(),
          '/sobre':    (context) => const SobreScreen(),
          '/me-logs':  (context) => const MeLogsScreen(),
          // Dica: MapaScreen segue via MaterialPageRoute porque recebe latitude/longitude.
        },
      ),
    );
  }
}
