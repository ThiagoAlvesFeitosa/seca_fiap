import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/clima_provider.dart';
import 'views/login_screen.dart';
import 'views/home_screen.dart';
import 'views/dicas_screen.dart';
import 'views/graficos_screen.dart';
import 'views/mapa_screen.dart';
import 'views/suporte_screen.dart';

void main() {
  runApp(const SecaApp());
}

class SecaApp extends StatelessWidget {
  const SecaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClimaProvider()),
      ],
      child: MaterialApp(
        title: 'RuraLTime',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/graficos': (context) => const GraficosScreen(),
          '/dicas': (context) => const DicasScreen(),
          '/suporte': (context) => const SuporteScreen(),
          // MapaScreen continua sendo acessado com parâmetros via MaterialPageRoute
        },
      ),
    );
  }
}
