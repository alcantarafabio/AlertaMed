import 'package:flutter/material.dart';
import 'theme/tema.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlertaMedApp());
}

class AlertaMedApp extends StatelessWidget {
  const AlertaMedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlertaMed',
      debugShowCheckedModeBanner: false,
      theme: buildTema(),
      home: const WelcomeScreen(),
    );
  }
}
