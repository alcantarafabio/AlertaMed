import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  bool soundEnabled = true;

  Future<void> _init() async {
    if (_initialized) return;
    await _tts.setLanguage('pt-BR');
    await _tts.setSpeechRate(0.38); // Lento e claro para idosos
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
    _initialized = true;
  }

  /// Lembrete de notificação: inclui nome do paciente e contexto.
  /// Exemplo: "Maria Helena, hora do medicamento Losartana, 50mg."
  Future<void> speakReminder(String name, String dosage, {String patientName = ''}) async {
    if (!soundEnabled) return;
    await _init();
    await _tts.stop();
    final prefix = patientName.isNotEmpty ? '$patientName, ' : '';
    await _tts.speak('${prefix}hora do medicamento $name, $dosage.');
  }

  /// Identificação rápida ao tocar no card: apenas nome e dosagem.
  /// Exemplo: "Losartana, 50mg."
  Future<void> speakIdentification(String name, String dosage) async {
    if (!soundEnabled) return;
    await _init();
    await _tts.stop();
    await _tts.speak('$name, $dosage.');
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
