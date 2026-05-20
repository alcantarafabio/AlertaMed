import 'package:flutter/material.dart';
import '../theme/cores.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppCores.saude, width: 2),
                      ),
                      child: const Icon(
                        Icons.health_and_safety,
                        size: 60,
                        color: AppCores.saude,
                      ),
                    ),
                    const SizedBox(height: 36),
                    const Text(
                      'AlertaMed',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: AppCores.primaria,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Autonomia e Organização da Saúde',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppCores.textoSecundario,
                      ),
                    ),
                    const SizedBox(height: 48),
                    const _DividerDecorado(),
                    const SizedBox(height: 40),
                    const Text(
                      'Organize seus medicamentos, acompanhe horários e simplifique o cuidado com a saúde de forma acessível e segura.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: AppCores.textoPrimario,
                        height: 1.65,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Desenvolvido com foco em idosos e pessoas com baixa visão.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppCores.textoSecundario,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Semantics(
                label: 'Começar a usar o AlertaMed',
                button: true,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  ),
                  child: const Text('Começar'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _DividerDecorado extends StatelessWidget {
  const _DividerDecorado();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: AppCores.primaria.withValues(alpha: 0.3), thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.medication,
            size: 20,
            color: AppCores.saude.withValues(alpha: 0.6),
          ),
        ),
        Expanded(
          child: Divider(color: AppCores.primaria.withValues(alpha: 0.3), thickness: 1),
        ),
      ],
    );
  }
}
