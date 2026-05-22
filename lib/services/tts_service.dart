import 'dart:io';
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
    await _tts.setSpeechRate(0.38);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    if (Platform.isIOS) {
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.defaultMode,
      );
    }
    _initialized = true;
  }

  Future<void> speakReminder(String name, String dosage,
      {String patientName = ''}) async {
    if (!soundEnabled) return;
    await _init();
    if (Platform.isIOS) await _tts.setSharedInstance(true);
    await _tts.stop();
    final prefix = patientName.isNotEmpty ? '$patientName, ' : '';
    _tts.speak('${prefix}hora do medicamento $name, $dosage.');
  }

  Future<void> speakIdentification(String name, String dosage) async {
    if (!soundEnabled) return;
    await _init();
    await _tts.stop();
    _tts.speak('$name, $dosage.');
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
