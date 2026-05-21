import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/medication.dart';

// Deve ser função top-level para rodar no isolate de background.
@pragma('vm:entry-point')
void _bgNotificationHandler(NotificationResponse response) {}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const _channelId = 'alertamed_lembretes_v2';
  static const _channelName = 'Lembretes de Medicamentos';
  static const _channelDesc = 'Lembretes dos horários dos seus medicamentos';

  // Stream que emite o payload toda vez que o usuário toca em uma notificação.
  // Escutado pelo main.dart para navegação + TTS.
  static final _tapController = StreamController<String>.broadcast();
  static Stream<String> get tapStream => _tapController.stream;

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: androidInit),
      onDidReceiveNotificationResponse: _onTap,
      onDidReceiveBackgroundNotificationResponse: _bgNotificationHandler,
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  void _onTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) _tapController.add(payload);
  }

  /// Retorna o payload da notificação que abriu o app (cold start).
  /// Retorna null se o app não foi aberto por uma notificação.
  Future<String?> getInitialPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    return details?.notificationResponse?.payload;
  }

  // payload: medId|name|dosage|voiceReminder|patientName|patientId
  Future<void> schedule(Medication med, {String patientName = ''}) async {
    if (med.id == null || med.notificationTime.isEmpty) return;

    final timeParts = med.notificationTime.split(':');
    if (timeParts.length != 2) return;
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (hour == null || minute == null) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final vibrationPattern = Int64List.fromList([0, 600, 300, 600]);

    final notifDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      playSound: true,
    );

    final body = patientName.isNotEmpty
        ? '$patientName — ${med.name} · ${med.dosage}  |  ${med.notificationTime}'
        : '${med.name} — ${med.dosage}  |  ${med.notificationTime}';

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    await android.zonedSchedule(
      med.id!,
      'Hora do medicamento',
      body,
      scheduled,
      notifDetails,
      scheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload:
          '${med.id}|${med.name}|${med.dosage}|${med.voiceReminder}|$patientName|${med.patientId}',
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();
}
