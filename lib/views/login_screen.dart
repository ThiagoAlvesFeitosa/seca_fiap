import 'package:flutter/material.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final senhaController = TextEditingController();
    final scheme = Theme.of(context).colorScheme; // usa as cores do tema

    return Scaffold(
      // Use o background do tema (fica igual ao resto)
      backgroundColor: scheme.background,
      appBar: AppBar(
        title: const Text('Login'),
        // Deixe o AppBar pegar a cor do Theme (já vem Dark Moss do nosso tema)
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Título com a cor primária da marca (Fern Green)
                Text(
                  'Bem-vindo ao RuraLTime',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // Campo de e-mail
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: scheme.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de senha
                TextField(
                  controller: senhaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: scheme.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botão Entrar (usa Elevated padrão do tema -> cor primaria)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    child: const Text('Entrar'),
                  ),
                ),
                const SizedBox(height: 12),

                // Link Cadastrar usando a cor primária
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidade futura')),
                    );
                  },
                  child: Text(
                    'Cadastrar',
                    style: TextStyle(color: scheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
