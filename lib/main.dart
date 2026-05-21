import 'dart:async';
import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'services/notification_service.dart';
import 'services/tts_service.dart';
import 'theme/tema.dart';
import 'screens/welcome_screen.dart';
import 'screens/patient_list_screen.dart';
import 'screens/home_screen.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  runApp(const AlertaMedApp());
}

class AlertaMedApp extends StatefulWidget {
  const AlertaMedApp({super.key});

  @override
  State<AlertaMedApp> createState() => _AlertaMedAppState();
}

class _AlertaMedAppState extends State<AlertaMedApp> {
  StreamSubscription<String>? _notifSub;

  @override
  void initState() {
    super.initState();
    // Escuta taps em notificações enquanto o app está ativo ou em background.
    _notifSub = NotificationService.tapStream.listen(_handlePayload);
    // Verifica se o app foi aberto por notificação (cold start).
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkInitialNotification());
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    super.dispose();
  }

  Future<void> _checkInitialNotification() async {
    final payload = await NotificationService().getInitialPayload();
    if (payload != null) await _handlePayload(payload);
  }

  // payload: medId|name|dosage|voiceReminder|patientName|patientId
  Future<void> _handlePayload(String payload) async {
    final parts = payload.split('|');
    if (parts.length < 2) return;

    final medName = parts[1];
    final dosage = parts.length >= 3 ? parts[2] : '';
    final patientName = parts.length >= 5 ? parts[4] : '';
    final patientId = parts.length >= 6 ? int.tryParse(parts[5]) ?? 1 : 1;

    final patient = await DatabaseHelper().getPatientById(patientId);
    if (patient == null) return;

    final nav = _navigatorKey.currentState;
    if (nav == null) return;

    // Limpa a pilha e coloca PatientListScreen como raiz (sem await —
    // pushAndRemoveUntil retorna Future que só completa quando a rota é
    // fechada; aguardá-lo bloquearia o push seguinte indefinidamente).
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PatientListScreen()),
      (route) => false,
    );

    // Empurra HomeScreen no próximo frame, garantindo a pilha:
    // PatientListScreen → HomeScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nav.push(MaterialPageRoute(
        builder: (_) => HomeScreen(patient: patient),
      ));
    });

    // TTS: sempre fala ao tocar na notificação, independente do voiceReminder
    TtsService().speakReminder(medName, dosage, patientName: patientName);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlertaMed',
      debugShowCheckedModeBanner: false,
      theme: buildTema(),
      navigatorKey: _navigatorKey,
      home: const WelcomeScreen(),
    );
  }
}
